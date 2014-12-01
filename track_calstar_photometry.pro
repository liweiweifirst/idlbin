pro track_calstar_photometry, savefilename,ch, make_plot = make_plot
;track_calstar_photometry,'/Users/jkrick/irac_warm/calstars/track_calstar_ch2.sav', 2, /make_plot
;XXX need to fix for full array and sub array  ; test
;do_calstar_photometry on subarray data
;need access to iracdata
COMMON track_block, photcordata, photcorhead, xcenarr,  ycenarr,  starnamearr,  timearr,  fluxarr,  fluxerrarr,  backarr,  corrfluxarr ,  raarr ,  decarr

;look for a save file with photometry
;for array dependant photometric correction warm
if ch eq 1 then fits_read, '/Users/jkrick/irac_warm/calstars/arrayloccorr/ch1_photcorr_ap_5.fits', photcordata, photcorhead
if ch eq 2 then fits_read, '/Users/jkrick/irac_warm/calstars/arrayloccorr/ch2_photcorr_ap_5.fits', photcordata, photcorhead

   
result = file_test(savefilename)
if result eq 1 then begin  ;file exists
;if that file exists then figure out which campaign was last done and
;incrememnt by 1.  + turn into string
;                        to find the right directory
   restore, savefilename
   ti = ti -100                 ; set back since the first thing the while loop does is to increment
endif else begin
;if that file doesn't exist, then start from old campaign
;and increment until there are no more directories
   orig_num = 38500 ;33500
   ti = orig_num
endelse


;error check on existance of directory
good_dir = 1
while good_dir eq 1 do begin  ; while there is data to work with, and not an empty directory
   ti =ti + 100
   dirname = strcompress('/Volumes/iracdata/flight/IWIC/IRAC0' +string(ti),/remove_all)
   print, 'dirname ', dirname
   good_dir = chk_dir(dirname)

   if good_dir eq 1 then begin  ;got a live one
      junk = do_calstar_photometry(ch, dirname)
      if ti eq orig_num + 100 then begin
      ;need to dynamically assaign these arrays since I don't
      ;know how many there are
         bigxcen = xcenarr
         bigycen = ycenarr
         bigstarnamearr = starnamearr
         bigtimearr = timearr
         bigfluxarr = fluxarr
         bigfluxerrarr = fluxerrarr
         bigbackarr = backarr
         bigcorrfluxarr = corrfluxarr
         bigraarr = raarr
         bigdecarr = decarr
      endif else begin
         bigxcen = [bigxcen, xcenarr]
         bigycen = [bigycen,ycenarr]
         bigstarnamearr = [bigstarnamearr,starnamearr]
         bigtimearr = [bigtimearr,timearr]
         bigfluxarr = [bigfluxarr, fluxarr]
         bigfluxerrarr = [bigfluxerrarr,fluxerrarr]
         bigbackarr = [bigbackarr,backarr]
         bigcorrfluxarr = [bigcorrfluxarr, corrfluxarr]
         bigraarr = [bigraarr, raarr]
         bigdecarr = [bigdecarr, decarr]
      endelse
   endif

endwhile


print, 'after while loop ', ti
;save,  ti, bigxcen,  bigycen,  bigstarnamearr,  bigtimearr,  bigfluxarr,  bigfluxerrarr,  bigcorrfluxarr, bigbackarr,  bigraarr,  bigdecarr , filename =savefilename



if keyword_set(make_plot) then begin
     colorarr = ['blue', 'red','black','green','grey','purple', 'deep_pink','fuchsia', 'magenta', 'medium_purple','medium_orchid', 'orchid', 'violet', 'plum', 'thistle', 'pink', 'orange_red', 'light_pink', 'rosy_brown','pale_violet_red',  'chocolate', 'saddle_brown', 'maroon', 'hot_pink', 'dark_orange', 'peach_puff', 'pale_goldenrod','red',  'aquamarine', 'teal', 'steel_blue', 'dodger_blue', 'dark_blue', 'indigo','dark_slate_blue', 'blue_violet', 'purple','dim_grey', 'slate_grey', 'dark_slate_grey', 'khaki', 'tomato', 'lavender','gold', 'green_yellow', 'lime', 'green', 'olive_drab', 'pale_green', 'spring_green','blue', 'red','deep_pink', 'magenta', 'medium_purple','light_sea_green', 'teal']

   ;need to sort by star
     names = [ '1812095', 'KF08T3_', 'KF06T2_', 'KF06T1_', 'KF09T1_',  'NPM1p67','NPM1p60','BD20_417', 'HD4182_', 'HD37725', 'HD55677','HD77823', 'HD89562', 'HD99253', 'HD11374', 'HD13176', 'HD13742', 'HD15689', 'HD18483', 'HD19506', 'HD21852', 'HD28437'];, 'NPM1p68'] ;, 'HD16545']
     
     normvals = fltarr(n_elements(names))
     for n = 0, n_elements(names) - 1 do begin
        
        an = where(bigstarnamearr eq names(n), count)
        if count gt 0 then begin
;           print, 'n, name', n, bigstarnamearr(an), colorarr(n)
;XXX want this to be corrflux - these are all infinte now???
                                                       
           p = errorplot((bigtimearr(an) - bigtimearr(0))/60./60./ 24., bigfluxarr(an)/median(bigfluxarr(an)), $
                         bigfluxerrarr(an)/median(bigfluxarr(an)), '1s', sym_size = 0.5, $
                         sym_filled = 1, xtitle = 'Time (days)', ytitle = 'Flux',color = colorarr(n), overplot = p)
        endif

           
     endfor

  
endif

end






;----------------------------------------
function do_calstar_photometry, ch, dirname
  common track_block

  cd, dirname
  pwd
  command ="find ./bcd/00*/ -name 'IRAC.2*bcd_fp.fits' > /Users/jkrick/irac_warm/calstars/allch2bcdlist.txt "
  spawn, command  
  readcol,strcompress('/Users/jkrick/irac_warm/calstars/allch'+string(ch)+'bcdlist.txt',/remove_all), fitsname, format = 'A', /silent
  
  nfits =  n_elements(fitsname) 
  
  startfits = 0L
  stopfits = nfits - 1
  i = 0L
  for c = startfits, stopfits do begin
     header = headfits(fitsname(i)) ;
     NAXIS= sxpar(header, 'NAXIS')
     AORLABEL= sxpar(header, 'AORLABEL')
;       print, i, strmid(AORLABEL, 0, 12), naxis
     if strmid(AORLABEL, 0, 12) eq 'IRAC_calstar'  then begin ;got a good one  
        
;set up storage arrays
        if naxis eq 3 then begin
           xarr = fltarr(nfits*64)
           starnamearr = strarr(nfits*64)
           timearr = dblarr(nfits*64)
        endif else begin
           xarr = fltarr(nfits)
           starnamearr = strarr(nfits)
           timearr = dblarr(nfits)
        endelse
        yarr = xarr 
        fluxarr = xarr
        fluxerrarr = xarr
        backarr = xarr
        backerrarr = xarr
        corrfluxarr = xarr
        raarr = xarr
        decarr = xarr
        nparr = xarr
        xfwhmarr = xarr
        yfwhmarr = xarr
        raarr = timearr
        decarr = timearr
        bmjdarr = timear     
        
;read in the image, get important info from the header
        fits_read,fitsname(c), im, h
        inter = strmid(fitsname(c), 0, 48)
        uncname = strcompress(inter + 'sig_dntoflux.fits',/remove_all)
;        print, 'uncname',i,  uncname, fitsname(i)
        fits_read, uncname, unc, hunc, /no_abort ; so it won't crash if the file isn't there but should use the last unc file.
        chnlnum = sxpar(h, 'CHNLNUM')
        ra_ref = sxpar(h, 'RA_REF')
        dec_ref = sxpar(h, 'DEC_REF')
        sos_ver = sxpar(h, 'SOS_VER')
        sclk_obs = sxpar(h, 'SCLK_OBS')
        aintbeg = sxpar(header, 'AINTBEG')
        atimeend = sxpar(header, 'ATIMEEND')
        bmjd_obs = sxpar(header, 'BMJD_OBS')
        starname = strmid(AORLABEL, 13, 7)

;make sure the target is on the frame
        ADXY, h, ra_ref, dec_ref, xcen, ycen
        if naxis eq 2 then begin
           xmax =250
           ymax = 250
        endif else begin
           xmax = 30
           ymax = 30
        endelse
        
        if xcen gt 5 and ycen gt 5 and xcen lt xmax and ycen lt ymax then begin
           ;do photometry
           get_centroids_for_calstar_jk,im, h, unc, ra_ref, dec_ref,  t, dt, hjd, xft, x3, y3, $
                                        x5, y5, x7, y7, xg, yg, xh, yh, f, b, x3s, y3s, x5s, y5s, $
                                        x7s, y7s, fs, bs, xp3, yp3, xp5, yp5, xp7, yp7, xp3s, yp3s, $
                                        xp5s, yp5s, xp7s, yp7s, fp, fps, np, flag, ns, sf, $
                                        xfwhm, yfwhm, /WARM
           
                                ;choose the requested pixel aperture
           abcdflux = f[*,apval]      
           fs = fs[*,apval]
                                ; 3-7 pixel background
           back = b[*,0]
           backerr = bs[*,0]
           
                                ;make a correction for pixel phase 
           ppcorr = pixel_phase_correct_gauss(abcdflux,x3,y3,ch, '3_3_7')
           corrflux = abcdflux*ppcorr
                                ;XXXX why corrflux isn't working?
                                ;apply array dependent correction
           arraycorr = photcordata(x3, y3) 
           corrflux= corrflux * arraycorr
           
                                ;save them
                                ;XXX need to make this handle sub and full array
           starnamearr[c] = strmid(AORLABEL, 13, 7)
           if naxis eq 3 then begin  
              xarr[i*64] = x3
              yarr[i*64] = y3
              fluxarr[i*64] = abcdflux
              fluxerrarr[i*64] = fs
              corrfluxarr[i*64] = corrflux
              backarr[i*64] = back
              backerrarr[i*64] = backerr
              nparr[i*64] = np
              xfwhmarr[i*64] = xfwhm
              yfwhmarr[i*64] = yfwhm
              raarr[i*64:i*64+63] = ra_ref
              decarr[i*64:i*64+63] = dec_ref
              starnamearr[i*64:i*64+63] = starname
              
              deltatime = (atimeend - aintbeg) / 64.D ; real time for each of the 64 frames
              nt = dindgen(64)
              timearr[i*64] = sclk_obs  + (deltatime*nt)/60./60./24.D ; 0.5*frametime + frametime*nt
              bmjdarr[i*64] = bmjd_obs + (deltatime*nt)/60./60./24.D  ; 0.5*(frametime/60./60./24.) + (frametime/60./60./24.)*nt
           endif 
           if naxis eq 2 then begin ; and i eq 0 then begin
              xarr[i] = x3
              yarr[i]  =  y3
              fluxarr[i]  =  abcdflux
              fluxerrarr[i]  =  fs
              corrfluxarr[i]  = corrflux
              timearr[i]  = sclk_obs
              bmjdarr[i]  = bmjd_obs
              backarr[i]  =  back
              backerrarr[i]  = backerr
              nparr[i]  = np
              xfwhmarr[i] = xfwhm
              yfwhmarr[i] = yfwhm
              raarr[i] = ra_ref
              decarr[i] = dec_ref
              starnamearr[i] = starname
           endif
           i = i + 1
        endif                   ; if the target is on the frame
        
     endif                      ; if full array calstar
  endfor                        ; for each fits image
  print, 'final i', i, ' ', nfits, ' or  ', i * 64, ' ', nfits*64
  if naxis eq 3 then final = i*64 else final = i
  xarr = xarr[0:final-1] 
  yarr = yarr[0:final-1] 
  fluxarr = fluxarr[0:final-1] 
  corrfluxarr = corrfluxarr[0:final-1]
  fluxerrarr = fluxerrarr[0:final-1] 
  backarr = backarr[0:final-1] 
  backerrarr = backerrarr[0:final-1] 
  timearr = timearr[0:final-1] 
  bmjdarr = bmjdarr[0:final-1] 
  nparr = nparr[0:final-1] 
  xfwhmarr = xfwhmarr[0:final-1] 
  yfwhmar = yfwhmarr[0:final-1] 
  starnamearr = starnamearr[0:final-1] 
  raarr = raarr[0:final-1] 
  decarr = decarr[0:final-1] 
                               
  return, 0
end


