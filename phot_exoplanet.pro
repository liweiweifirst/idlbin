pro phot_exoplanet, planetname
;do photometry on any IRAC staring mode exoplanet data
;now with hashes of hashes!
 
;run code to read in all the planet parameters
planetinfo = create_planetinfo()
chname = planetinfo[planetname, 'chname']
ra_ref = planetinfo[planetname, 'ra']
dec_ref = planetinfo[planetname, 'dec']
aorname = planetinfo[planetname, 'aorname']
basedir = planetinfo[planetname, 'basedir']

;---------------
dirname = strcompress(basedir + planetname +'/')
planethash = hash()

  for a = 0, n_elements(aorname) - 1 do begin
     print, 'working on ',aorname(a)
     dir = dirname+ string(aorname(a) ) 
     CD, dir                    ; change directories to the correct AOR directory
     command  = strcompress( 'find ch'+chname+"/bcd -name '*_bcd.fits' > "+dirname+'bcdlist.txt')
     spawn, command
     command2 =  strcompress('find ch'+chname+"/bcd -name '*bunc.fits' > "+dirname + 'bunclist.txt')
     spawn, command2

     readcol,strcompress(dirname +'bcdlist.txt'),fitsname, format = 'A', /silent
     readcol,strcompress(dirname+'bunclist.txt'),buncname, format = 'A', /silent

     for i =0.D,  n_elements(fitsname) - 1 do begin ;read each cbcd file, find centroid, keep track
        ;print, 'working on ', fitsname(i)         
        header = headfits(fitsname(i)) ;
        sclk_obs= sxpar(header, 'SCLK_OBS')
        frametime = sxpar(header, 'FRAMTIME')
        bmjd_obs = sxpar(header, 'BMJD_OBS')
        utcs_obs = sxpar(header, 'UTCS_OBS')
        ch = sxpar(header, 'CHNLNUM')
        ronoise = sxpar(header, 'RONOISE')
        gain = sxpar(header, 'GAIN')
        fluxconv = sxpar(header, 'FLUXCONV')
        exptime = sxpar(header, 'EXPTIME')

        if i eq 0 then sclk_0 = sxpar(header, 'SCLK_OBS')

        sclkarr = dblarr(64)
        bmjdarr = fltarr(64)
        utcsarr = fltarr(64)
        for nt = 0., 64 - 1 do begin
           sclkarr[nt] = (sclk_obs ) + 0.5*frametime + frametime*nt
           bmjdarr[nt]= bmjd_obs + 0.5*(frametime/60./60./24.) + (frametime/60./60./24.)*nt
           utcsarr[nt]= utcs_obs + 0.5*(frametime/60./60./24.)  + (frametime/60./60./24.) *nt
        endfor
         
        ;do the photometry
   
        fits_read, fitsname(i), im, h
        fits_read, buncname(i), unc, hunc
                                ; fits_read, covname, covdata, covheader
        get_centroids_for_calstar_jk,im, h, unc, ra_ref, dec_ref,  t, dt, hjd, xft, x3, y3, $
                                     x5, y5, x7, y7, xg, yg, xh, yh, f, b, x3s, y3s, x5s, y5s, $
                                     x7s, y7s, fs, bs, xp3, yp3, xp5, yp5, xp7, yp7, xp3s, yp3s, $
                                     xp5s, yp5s, xp7s, yp7s, fp, fps, np, flag, ns, sf, $
                                     xfwhm, yfwhm, /WARM
        
      ;choose 3 pixel aperture, 3-7 pixel background
       abcdflux = f[*,9]      
        fs = fs[*,9]

        ;choose [10, 12-20]
;        abcdflux = f[*,5]
;        fs = fs[*,5]

        x_center = x3
        y_center = y3
        back = b[*,2]
        backerr = bs[*,2]

;track the value of a column
        centerpixval1 = findgen(64)
        centerpixval2 = findgen(64)
        centerpixval3 = findgen(64)
        centerpixval4 = findgen(64)
        centerpixval5 = findgen(64)
        centerpixval6 = findgen(64)
        sigmapixval1 = findgen(64)
        sigmapixval2 = findgen(64)
        sigmapixval3 = findgen(64)
        sigmapixval4 = findgen(64)
        sigmapixval5 = findgen(64)
        sigmapixval6 = findgen(64)
        for nframes = 0, 64 - 1 do begin
           meanclip, im[13, 6:12,nframes], meancol1, sigmacol
           centerpixval1[nframes] = meancol1
           sigmapixval1[nframes] = sigmacol
           meanclip, im[13, 18:24,nframes], meancol2, sigmacol
           centerpixval2[nframes] = meancol2   
           sigmapixval2[nframes] = sigmacol     
           meanclip, im[14, 6:12,nframes], meancol3, sigmacol
           centerpixval3[nframes] = meancol3           
           sigmapixval3[nframes] = sigmacol
           meanclip, im[14, 18:24,nframes], meancol4, sigmacol
           centerpixval4[nframes] = meancol4
           sigmapixval4[nframes] = sigmacol
           meanclip, im[13, 6:24,nframes], meancol5, sigmacol
           centerpixval5[nframes] = meancol5
           sigmapixval5[nframes] = sigmacol
           meanclip, im[14, 6:24,nframes], meancol6, sigmacol
           centerpixval6[nframes] = meancol6
           sigmapixval6[nframes] = sigmacol
 endfor


;--------------------------------
      ;correct for pixel phase effect based on pmaps from Jim
        file_suffix = ['500x500_0043_120409.fits','0p1s_x4_500x500_0043_120124.fits']
        corrflux = iracpc_pmap_corr(abcdflux,x_center,y_center,ch,/threshold_occ, threshold_val = 20, file_suffix = file_suffix)
        corrfluxerr = fs        ;leave out the pmap err for now
     
 ;--------------------------------
        ;calculate noise pixel
        np = noisepix(im, x_center, y_center, ronoise, gain, exptime, fluxconv)

;---------------------------------
        if i eq 0 then begin
           xarr = x_center[1:*]
           yarr = y_center[1:*]
           fluxarr = abcdflux[1:*]
           fluxerrarr = fs[1:*]
           corrfluxarr = corrflux[1:*]
           corrfluxerrarr = corrfluxerr[1:*]
           timearr = sclkarr[1:*]        
           bmjd = bmjdarr[1:*]
           utcs = utcsarr[1:*]
           backarr = back[1:*]
           backerrarr = backerr[1:*]
           centerpixarr1 = centerpixval1[1:*]
           centerpixarr2 = centerpixval2[1:*]
           centerpixarr3 = centerpixval3[1:*]
           centerpixarr4 = centerpixval4[1:*]
           centerpixarr5 = centerpixval5[1:*]
           centerpixarr6 = centerpixval6[1:*]
           sigmapixarr1 = sigmapixval1[1:*]
           sigmapixarr2 = sigmapixval2[1:*]
           sigmapixarr3 = sigmapixval3[1:*]
           sigmapixarr4 = sigmapixval4[1:*]
           sigmapixarr5 = sigmapixval5[1:*]
           sigmapixarr6 = sigmapixval6[1:*]

           nparr = np[1:*]

        endif else begin
           xarr = [xarr, x_center[1:*]]
           yarr = [yarr, y_center[1:*]]
           fluxarr = [fluxarr, abcdflux[1:*]]
           fluxerrarr = [fluxerrarr, fs[1:*]]
           corrfluxarr = [corrfluxarr, corrflux[1:*]]
           corrfluxerrarr = [corrfluxerrarr, corrfluxerr[1:*]]
           timearr = [timearr, sclkarr[1:*]]
           bmjd = [bmjd, bmjdarr[1:*]]
           utcs = [utcs, utcsarr[1:*]]
           backarr = [backarr, back[1:*]]
           backerrarr = [backerrarr, backerr[1:*]]
           centerpixarr1 = [centerpixarr1, centerpixval1[1:*]]
           centerpixarr2 = [centerpixarr2, centerpixval2[1:*]]
           centerpixarr3 = [centerpixarr3, centerpixval3[1:*]]
           centerpixarr4 = [centerpixarr4, centerpixval4[1:*]]
           centerpixarr5 = [centerpixarr5, centerpixval5[1:*]]
           centerpixarr6 = [centerpixarr6, centerpixval6[1:*]]
           sigmapixarr1 = [sigmapixarr1, sigmapixval1[1:*]]
           sigmapixarr2 = [sigmapixarr2, sigmapixval2[1:*]]
           sigmapixarr3 = [sigmapixarr3, sigmapixval3[1:*]]
           sigmapixarr4 = [sigmapixarr4, sigmapixval4[1:*]]
           sigmapixarr5 = [sigmapixarr5, sigmapixval5[1:*]]
           sigmapixarr6 = [sigmapixarr6, sigmapixval6[1:*]]

          nparr = [nparr, np[1:*]]

         endelse
        
     endfor                     ; for each fits file in the AOR
 ;    p1 = plot(xarr, yarr, '1.')
 ;    p2 = plot(timearr - timearr(0), yarr, '1.')
 ;    p3 = plot(timearr- timearr(0), corrfluxarr, '1.')
    ; print, 'fluxarr', fluxarr[0:10]
                                ;fill in that hash of hases

       keys =['ra', 'dec', 'xcen', 'ycen', 'flux','fluxerr', 'corrflux', 'corrfluxerr', 'sclktime_0', 'timearr', 'aor', 'bmjdarr', 'utcsarr', 'bkgd', 'bkgderr','np', 'centerpixarr1','centerpixarr2','centerpixarr3','centerpixarr4','centerpixarr5','centerpixarr6','sigmapixarr1','sigmapixarr2','sigmapixarr3','sigmapixarr4','sigmapixarr5','sigmapixarr6']
       values=list(ra_ref,  dec_ref, xarr, yarr, fluxarr, fluxerrarr, corrfluxarr, corrfluxerrarr, sclk_0, timearr, aorname(a), bmjd, utcs, backarr, backerrarr, nparr, centerpixarr1, centerpixarr2, centerpixarr3, centerpixarr4, centerpixarr5, centerpixarr6, sigmapixarr1, sigmapixarr2, sigmapixarr3, sigmapixarr4, sigmapixarr5, sigmapixarr6)
       planethash[aorname(a)] = HASH(keys, values)

  endfor                        ;for each AOR
  
  ;test
  save, planethash, filename=strcompress(dirname + planetname +'_phot_ch'+chname+'.sav')
  print, planethash.keys()
;  print, planethash[aorname(0)].keys()
 ; print, 'testing (planethash[aorname(0),flux])[0:10]',(planethash[aorname(0),'flux'])[0:10]
;  print, 'n_elements in hash', n_elements(planethash[aorname(1),'xcen'])
  
end




;function to calcluate noise pixel
function noisepix, im, xcen, ycen, ronoise, gain, exptime, fluxconv

  convfac = gain*exptime/fluxconv
  np = fltarr(64)
  for npj = 0, 63 do begin
     indim = im[*,*,npj]
     indim = indim*convfac
     
     aper, indim, xcen[npj], ycen[npj], topflux, topfluxerr, xb, xbs, 1.0, 8,[10,12],/flux,/exact, /silent, /nan, readnoise = ronoise, setskyval = 0
     aper, indim^2, xcen[npj], ycen[npj], bottomflux, bottomfluxerr, xb, xbs, 1.0,8,[10,12],/flux,/exact, /silent, /nan, readnoise = ronoise, setskyval = 0
     
     beta = topflux^2 / bottomflux
  ;   print, npj, beta
     np[npj] = beta
  endfor

     return, np                 ;this should be a 64 element array
end
