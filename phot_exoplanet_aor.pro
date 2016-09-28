pro phot_exoplanet_aor, planetname, apradius,chname, ra, dec, thisaor, hybrid = hybrid, simulated = simulated, phase = phase
  ;do photometry on any IRAC staring mode AOR
COMMON centroid_block
 t1 = systime(1)

;convert aperture radius in pixels into what get_centroids_for_calstar_jk uses 
case apradius of
   1.5: apval = 0
   2.0: begin
      apval = 0
      if chname eq '2' then pmapfile = '/Users/jkrick/irac_warm/pcrs_planets/pmap_phot/pmap_data_ch2_rmulti_s3_7_0p1s_x4_150226.sav'
      if chname eq '1' then pmapfile =  '/Users/jkrick/irac_warm/pcrs_planets/pmap_phot/pmap_data_ch1_r2p00_s3_7_0p4s_140314.sav'
   end
   2.25: begin
      apval = 1
      if chname eq '2' then begin
         pmapfile = '/Users/jkrick/irac_warm/pcrs_planets/pmap_phot/pmap_data_ch2_rmulti_s3_15_0p1s_x4_160126.sav'
      endif

      if chname eq '1' then pmapfile =  '/Users/jkrick/irac_warm/pcrs_planets/pmap_phot/pmap_data_ch1_rmulti_s3_7_sd_0p4s_sdark_150722.sav'
   end
   2.5: begin
      apval = 2
      if chname eq '2' then pmapfile = '/Users/jkrick/irac_warm/pcrs_planets/pmap_phot/pmap_data_ch2_rmulti_s3_7_0p1s_x4_sdark_150223.sav'
      if chname eq '1' then pmapfile =  '/Users/jkrick/irac_warm/pcrs_planets/pmap_phot/pmap_data_ch1_r2p50_s3_7_0p4s_140314.sav'
   end
   2.75: apval = 2
   3.25: apval = 2
   3: apval = 3

   Else: apval = 2              ; if no decision, then choose an apradius = 2.5 pixels
endcase

if keyword_set(simulated) then pmapfile = '/Users/jkrick/irac_warm/pcrs_planets/pmap_phot/pmap_sim_data_ch2_rmulti_s3_7_0p1sx4_151030.sav'
print, 'using pmap file', pmapfile, apval


exoplanet_data_file = '/Users/jkrick/idlbin/exoplanets.csv'
exosystem = planetname

print, exosystem, 'exosystem'

if chname eq '2' then lambdaname  = '4.5'
if chname eq '1' then lambdaname  = '3.6'
get_exoplanet_data,EXOSYSTEM=exosystem,MSINI=msini,MSTAR=mstar,TRANSIT_DEPTH=transit_depth,RP_RSTAR=rp_rstar,AR_SEMIMAJ=ar_semimaj,$
                       TEQ_P=1315,TEFF_STAR=teff_star,SECONDARY_DEPTH=secondary_depth,SECONDARY_LAMBDA=lambdaname,$
                       INCLINATION=inclination,MJD_TRANSIT=mjd_transit,P_ORBIT=p_orbit,EXODATA=exodata,RA=ra_exosystem,DEC=dec_exosystem,VMAG=vmag,$
                       DISTANCE=distance,ECC=ecc,T14=t14,F36=f36,F45=f45,FP_FSTAR0=fp_fstar0,/verbose


;---------------
;dirname = '/Users/jkrick/external/irac_warm/trending/'
dirname = '/Volumes/Backup2/jk/irac_warm/trending/' ;temporary while changing disks



if chname eq '2' then occ_filename =  '/Users/jkrick/irac_warm/pmap/pmap_fits/pmap_ch2_0p1s_x4_500x500_0043_120827_occthresh.fits'$
else occ_filename = '/Users/jkrick/irac_warm/pmap/pmap_fits/pmap_ch1_500x500_0043_120828_occthresh.fits'
fits_read,occ_filename, occdata, occheader

   print, '----------------------------'
   print, 'working on ', thisaor
   dir = strcompress(dirname+ 'r' + string(thisaor ) ,/remove_all)
   CD, dir                      ; change directories to the correct AOR directory
   pwd

   command  = strcompress( 'find ch'+chname+"/bcd -name 'SPITZER*_bcd.fits' > "+dirname+'bcdlist.txt')
   spawn, command

   command2 =  strcompress('find ch'+chname+"/bcd -name '*bunc.fits' > "+dirname + 'bunclist.txt')
   spawn, command2

   command3 =  strcompress('find ch'+chname+"/bcd -name '*dce.fits' > "+dirname + 'dcelist.txt')
   spawn, command3
 
   readcol,strcompress(dirname +'bcdlist.txt'),fitsname, format = 'A', /silent
   readcol,strcompress(dirname+'bunclist.txt'),buncname, format = 'A', /silent
   readcol,strcompress(dirname+'dcelist.txt'),rawname, format = 'A', /silent

   print,'n_elements(fitsname)', n_elements(fitsname)

   
   startfits = 0L


   for i =startfits, n_elements(fitsname) - 1  do begin ;read each cbcd file, find centroid, keep track
       print, 'working on ', fitsname(i)         
      header = headfits(fitsname(i)) ;
      sclk_obs= sxpar(header, 'SCLK_OBS')
      frametime = sxpar(header, 'FRAMTIME')
      bmjd_obs = sxpar(header, 'BMJD_OBS')
       ;utcs_obs = sxpar(header, 'UTCS_OBS')
      ch = sxpar(header, 'CHNLNUM')
      ronoise = sxpar(header, 'RONOISE') ; these are zeros
      gain = sxpar(header, 'GAIN')
      fluxconv = sxpar(header, 'FLUXCONV')
      exptime = sxpar(header, 'EXPTIME')
      aintbeg = sxpar(header, 'AINTBEG')
      atimeend = sxpar(header, 'ATIMEEND')
      ;;print, 'aintbeg, atimeend', aintbeg, atimeend
      naxis = sxpar(header, 'NAXIS')
      framedly = sxpar(header, 'FRAMEDLY')
 
      if ch eq '2' and frametime eq 2 then ronoise = 12.1

      if i eq startfits then begin
         ;print, 'ronoise', ronoise, gain, fluxconv, exptime, ra_ref, dec_ref, naxis
         sclk_0 = sclk_obs
      endif


      if i eq startfits and naxis eq 3 then begin
         xarr = fltarr(63*(n_elements(fitsname)))
         yarr = xarr
         fluxarr = xarr
         fluxerrarr = xarr
         corrfluxarr = xarr
         corrfluxerrarr = xarr
         timearr =  dblarr(63*(n_elements(fitsname)))
         bmjd = dblarr(63*(n_elements(fitsname)))
         backarr = xarr
         backerrarr = xarr
         nparr = xarr
         npcentroidsarr = xarr
         xfwhmarr = xarr
         yfwhmarr = xarr
         peakpixDNarr = xarr
      endif
      if i eq startfits and naxis ne 3 then begin
         xarr = fltarr(n_elements(fitsname))
         yarr = xarr
         fluxarr = xarr
         fluxerrarr = xarr
         corrfluxarr = xarr
         corrfluxerrarr = xarr
         timearr =dblarr(n_elements(fitsname))
         bmjd = dblarr(n_elements(fitsname))
         backarr = xarr
         backerrarr = xarr
         nparr = xarr
         npcentroidsarr = xarr
         xfwhmarr = xarr
         yfwhmarr = xarr
         peakpixDNarr = xarr
      endif
      fdarr = fltarr(n_elements(fitsname))
      fdarr[i] = framedly

      if naxis eq 3 then begin
         deltatime = (atimeend - aintbeg) / 64.D ; real time for each of the 64 frames
         nt = dindgen(64)
         sclkarr = sclk_obs  + (deltatime*nt);/60./60./24.D ; 0.5*frametime + frametime*nt
         bmjdarr= bmjd_obs + (deltatime*nt)/60./60./24.D   ; 0.5*(frametime/60./60./24.) + (frametime/60./60./24.)*nt
      endif else begin          ; full array, so don't need to expand out the times
         sclkarr = sclk_obs
         bmjdarr = bmjd_obs
      endelse
        ;; print, 'sclk split up', sclkarr(0), ' ' ,sclkarr(1), ' ' ,sclkarr(60),  format = '(A, D0, A, D0, A, D0)'

      ;read in the files
      fits_read, fitsname(i), im, h
      fits_read, buncname(i), unc, hunc
      test = sxpar(h, 'RAWFILE')
      
    ; fits_read, covname, covdata, covheader

      ;;calculate a background manually
 ;     bkgd = calc_bkgd(im, h, ra_ref, dec_ref)

      ;run the centroiding and photometry
      get_centroids_for_calstar_jk,im, h, unc, ra, dec,  t, dt, hjd, xft, x3, y3, $
                                   x5, y5, x7, y7, xg, yg, xh, yh, f, b, x3s, y3s, x5s, y5s, $
                                   x7s, y7s, fs, bs, xp3, yp3, xp5, yp5, xp7, yp7, xp3s, yp3s, $
                                   xp5s, yp5s, xp7s, yp7s, fp, fps, np, flag, ns, sf, $
                                   xfwhm, yfwhm,  /WARM
      nanfound = where(FINITE(np) lt 1, nancount)
      if nancount gt 0 then print, 'NAN: ', fitsname(i), nanfound
      
      x_center = temporary(x3)
      y_center = temporary(y3)
     ;choose the requested pixel aperture
      abcdflux = f[*,apval]      
      fs = fs[*,apval]
     ; 3-7 pixel background
      back = b[*,0]
      backerr = bs[*,0]
      npcentroids = np   ;keep track of np from get_centroids
      np = findgen(64)
      
      ;;read in the raw data file and get the DN level of the peakpixel      
      fits_read, rawname(i), rawdata, rawheader
      
      barrel = fxpar(rawheader, 'A0741D00')
      fowlnum = fxpar(rawheader, 'A0614D00')
      pedsig = fxpar(rawheader, 'A0742D00')
      ichan = fxpar (rawheader, 'CHNLNUM')
      
      ;;use Bill's code to conver to DN
      dewrap2, rawdata, ichan, barrel, fowlnum, pedsig, 0, rawdata
      
      ;;or use Jim's code to convert to DN
      ;;rawdata = irac_raw2dn(rawdata,ichan,barrel,fowlnum)
      peakpixDN = abcdflux      ; set up the array to be the same size as abcdflux
      if naxis eq 3 then begin
         rawdata = reform(rawdata, 32, 32, 64)
         for pp = 0, 63 do begin
            peakpixDN[pp] = max(rawdata[13:16,13:16,pp])
         endfor
      endif else begin
         peakpixDN = max(rawdata[21:24,229:232])
      endelse
      

     
;---------------------------------
;use pmap data to find nearest neighbors in pmap dataset and find a
;correction based on those neighbors.  
      if keyword_set(hybrid) then begin
                                ;use hybrid technique with pmap dataset and nn techniques
;         print, 'starting corrflux', x_center[0], y_center[0],
;         abcdflux[0], ch, xfwhm[0], yfwhm[0], npcentroids[0]
         ;;read in a list of indices for rejecting some of the pmap
         ;;data points
         if naxis eq 2 then begin
            corrflux = pmap_correct(x_center,y_center,abcdflux,ch,xfwhm,yfwhm,NP = npcentroids,$
                                    FUNC=fs,CORR_UNC=corrfluxerr, DATAFILE=pmapfile,NNEAREST=nn, $
                                    R_USE = apradius, USE_PMAP = IMAIN,/full) ;,/VERBOSE
         endif else begin
            corrflux = pmap_correct(x_center,y_center,abcdflux,ch,xfwhm,yfwhm,NP = npcentroids,$
                                    FUNC=fs,CORR_UNC=corrfluxerr, DATAFILE=pmapfile,NNEAREST=nn, $
                                    R_USE = apradius, USE_PMAP = IMAIN) ;,/VERBOSE
            
         endelse
         
;         print, 'corrflux', corrflux[0:10]
         ;corrflux = pmap_correct(x_center,y_center,abcdflux,ch,npcentroids,occdata, corr_unc = corrfluxerr, func = fs,$
         ;                       datafile =pmapfile,/threshold_occ,/use_np) 
      endif else begin
                                ;make up some junk for corrflux, so I can keep it as a variable in the rest of this
         corrflux = fltarr(n_elements(x_center))
         corrfluxerr = corrflux
               ;correct for pixel phase effect based on pmaps from Jim
                                ;file_suffix =
                                ;['500x500_0043_120828.fits','0p1s_x4_500x500_0043_121120.fits']
;         corrflux = iracpc_pmap_corr(abcdflux,x_center,y_center,ch,/threshold_occ, threshold_val = 20) ;, file_suffix = file_suffix)
;         corrflux = abcdflux
;         corrfluxerr = fs       ;leave out the pmap err for now
      endelse


;---------------------------------

      if naxis eq 3 then begin  ; and i eq 0 then begin
         xarr[i*63] = x_center[1:*]
         yarr[i*63] = y_center[1:*]
         fluxarr[i*63] = abcdflux[1:*]
         fluxerrarr[i*63] = fs[1:*]
         corrfluxarr[i*63] = corrflux[1:*]
         corrfluxerrarr[i*63] = corrfluxerr[1:*]
         timearr[i*63] = sclkarr[1:*]        
         bmjd[i*63] = bmjdarr[1:*]
         backarr[i*63] = back[1:*]
         backerrarr[i*63] = backerr[1:*]
         nparr[i*63] = np[1:*]
         npcentroidsarr[i*63] = npcentroids[1:*]
         xfwhmarr[i*63] = xfwhm[1:*]
         yfwhmarr[i*63] = yfwhm[1:*]
         peakpixDNarr[i*63] = peakpixDN[1:*]
      endif 
      if naxis eq 2 then begin; and i eq 0 then begin
         xarr[i] = x_center
         yarr[i]  =  y_center
         fluxarr[i]  =  abcdflux
         fluxerrarr[i]  =  fs
         corrfluxarr[i]  = corrflux
         corrfluxerrarr[i]  =  corrfluxerr
         timearr[i]  = sclkarr
         bmjd[i]  = bmjdarr
         backarr[i]  =  back
         backerrarr[i]  = backerr
         nparr[i]  = npcentroids
         npcentroidsarr[i] = npcentroids
         xfwhmarr[i] = xfwhm
         yfwhmarr[i] = yfwhm
         peakpixDNarr[i] = peakpixDN
      endif

     ;; if a eq startaor and i eq startfits then begin
         time_0 = bmjdarr(0)
     ;; endif

   endfor; for each fits file in the AOR


   
   ;---------------------------------
   if keyword_set(phase) then begin
;   print, 'testing bmjd, utmjd', bmjd(0), ' ' ,bmjd(20), ' ' ,bmjd(60), ' ' ,bmjd(100) , format = '(A, D0, A, D0, A, D0, A, D0)'
;get phasing out of the way here
      bmjd_dist = bmjd - utmjd_center ; how many UTC away from the transit center
      phase =( bmjd_dist / period )- fix(bmjd_dist/period)
      
;   low = where(phase lt-0.5 and phase ge -1.0)
;   phase(low) = phase(low) + 1.
      phase = phase + (phase lt -0.5 and phase ge -1.0)
      
;   high = where(phase gt 0.5 and phase le 1.0)
;   phase(high) = phase(high) - 1.0
      phase = phase- (phase gt 0.5 and phase le 1.0)
      
;instead of wrapping the phase at 0.5, this makes the secondary eclipse be in the middle
      if intended_phase gt 0.4 and intended_phase lt 0.6 then begin
         n = where(phase lt 0, ncount)
         if ncount gt 0 then phase(n) = phase(n) + 1
      endif
      
      
;   if intended_phase gt 0.4 and intended_phase lt 0.6 then begin ;secondary eclipse
;      print, 'secondary eclipse intended'
;      phase = temporary(phase)+0.5
;   endif 
      
;print, 'testing phase', phase[0:200]
;   print, 'end phase', phase[n_elements(phase) - 1]
   endif else begin
      ;;make a blank phase array
      phase = fltarr(n_elements(bmjd))
   endelse
   
   
  ;---------------------------------

   ;; make a correction for flux degradation as a function of time
   ;;since the beginning of this targets AORs.


   if chname eq '2' then factor = 0.0005
   if chname eq '1' then factor = 0.0010
   ;;0.05% per year or 0.0005*(time in
   ;;years since start of observation)
   deltatime = bmjd - time_0 ; in days
   deltatime = deltatime /365. ; in years
   degrade = factor*deltatime
   corrflux_d =  corrfluxarr +(corrfluxarr* degrade)
   



   print, 'time check', systime(1) - t1



end


