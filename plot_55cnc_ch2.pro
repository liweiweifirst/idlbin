pro plot_55cnc_ch2
  colorarr = ['red', 'orange', 'green', 'blue', 'deep_pink', 'magenta', 'medium_purple', 'hot_pink', 'light_pink', 'rosy_brown', 'chocolate', 'saddle_brown', 'maroon', 'orange_red', 'dark_orange', 'peach_puff', 'pale_goldenrod','red',  'aquamarine', 'teal', 'steel_blue', 'dodger_blue', 'dark_blue', 'indigo','dark_slate_blue', 'blue_violet', 'purple','dim_grey', 'slate_grey', 'dark_slate_grey', 'khaki','black', 'light_cyan', 'lavender','gold', 'green_yellow', 'lime', 'green', 'olive_drab', 'pale_green', 'spring_green']

   fits_read, '/Users/jkrick/idlbin/pmap_fits/pmap_ch2_0p1s_x4_500x500_0043_120827.fits', pmapdata, pmapheader

; c = contour(pmapdata, /fill, n_levels = 21, rgb_table = 0, xtitle = 'X (pixel)', ytitle = 'Y (pixel)', aspect_ratio = 1, xrange = [0,500], yrange = [0,500])


  restore, '/Users/jkrick/irac_warm/pcrs_planets/55cnc/55cnc_phot_ch2_3_11_15.sav'
  aorname_55cnc = ['r43981312','r43981568','r43981824','r43981056'] ;ch2

  
  ;utmjd_center = [double(55947.20505),double(55949.41467), double(55957.51661),double(55944.25889)]  
  utmjd_center = [double(55944.25889), double(55947.20505),double(55949.41467), double(55957.51661)]  

  duration = 105.7              ;in minutes
  duration = duration /60./24.  ; in days
  period = 0.73654 ;days
  

;set time = 0.5 in the middle of the eclipse
;     bin_time = bin_time -tt
  for a = 0, n_elements(aorname_55cnc) - 1 do  begin
     test =  ((AOR55cnc[a].bmjdarr - utmjd_center[a]) / period) + 0.5
     
     ;if a eq 1 then begin
        ;for t = 0, 100*63,63  do begin
        ;   print, t/63, ' ', AOR55cnc[1].bmjdarr[t], ' ',test[t], ' ', utmjd_center[a], format = '(F0,A, F0, A, F0, A, F0)'
       ; endfor
     ;endif

     AOR55cnc[a].bmjdarr = ((AOR55cnc[a].bmjdarr - utmjd_center[a]) / period) + 0.5

  endfor


 ;c = contour(pmapdata, /fill, n_levels = 21, rgb_table = 0, xtitle = 'X (pixel)', ytitle = 'Y (pixel)', aspect_ratio = 1, xrange = [0,500], yrange = [0,500])
;  for a = 0, n_elements(aorname_55cnc) - 1 do begin
;     xcen500 = 500.* (AOR55cnc[a].xcen - 14.5)
;     ycen500 = 500.* (AOR55cnc[a].ycen - 14.5)
;     an = plot(xcen500, ycen500, '6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a],/overplot)
; endfor

;-----
  
;    for a = 0, n_elements(aorname_55cnc) - 1 do begin
;     if a eq 0 then begin
;        am = plot( (AOR55cnc[a].timearr - AOR55cnc[a].timearr(0))/60./60., AOR55cnc[a].xcen,'6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a+14], xtitle = 'Time(hrs)', ytitle = 'X pix', yrange = [14.2, 15.4])
;     endif else begin
;        am = plot( (AOR55cnc[a].timearr - AOR55cnc[a].timearr(0))/60./60., AOR55cnc[a].xcen,'6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a+14],/overplot)
;     endelse

;  endfor

;------

;  for a = 0, n_elements(aorname_55cnc) - 1 do begin
;     if a eq 0 then begin
;        am = plot( (AOR55cnc[a].timearr - AOR55cnc[a].timearr(0))/60./60., AOR55cnc[a].ycen,'6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a+14], xtitle = 'Time(hrs)', ytitle = 'Y pix',  yrange = [14.2, 15.4])
;     endif else begin
;        am = plot( (AOR55cnc[a].timearr - AOR55cnc[a].timearr(0))/60./60., AOR55cnc[a].ycen,'6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a+14],/overplot)
;     endelse

;  endfor

;------
;  for a = 0, n_elements(aorname_55cnc) - 1 do begin
;     if a eq 0 then begin
;        am = plot( (AOR55cnc[a].timearr - AOR55cnc[a].timearr(0))/60./60., AOR55cnc[a].bkgd,'6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a], xtitle = 'Time(hrs)', ytitle = 'Background')
;     endif else begin
;        am = plot( (AOR55cnc[a].timearr - AOR55cnc[a].timearr(0))/60./60., AOR55cnc[a].bkgd,'6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a],/overplot)
;     endelse

;  endfor

;------

  for a = 0, n_elements(aorname_55cnc) - 1 do begin
;sort by time
     s = sort(AOR55cnc[a].bmjdarr)
     sorttime = AOR55cnc[a].timearr[s]
     sortxcen= AOR55cnc[a].xcen[s]
     sortycen = AOR55cnc[a].ycen[s]
     sortflux = AOR55cnc[a].flux[s]
     sortcorrflux = AOR55cnc[a].corrflux[s]
     sortcorrfluxerr = AOR55cnc[a].corrfluxerr[s]
     sortbmjd = AOR55cnc[a].bmjdarr[s]
     sortutcs = AOR55cnc[a].utcsarr[s]
     sortbkgd = AOR55cnc[a].bkgd[s]
     sortbkgderr = AOR55cnc[a].bkgderr[s]
      ;remove outliers
     good = where(sortxcen lt mean(sortxcen) + 2.5*stddev(sortxcen) and sortxcen gt mean(sortxcen) -2.5*stddev(sortxcen) and sortycen lt mean(sortycen) +3.0*stddev(sortycen) and sortycen gt mean(sortycen) - 3.0*stddev(sortycen),ngood_pmap, complement=bad) 
     print, 'bad ',n_elements(bad)
     xarr = sortxcen[good]
     yarr = sortycen[good]
     timearr = sorttime[good]
     flux = sortflux[good]
     corrflux = sortcorrflux[good]
     corrfluxerr = sortcorrfluxerr[good]
     bmjdarr = sortbmjd[good]
     bkgdarr = sortbkgd[good]
     bkgderrarr = sortbkgderr[good]
     
; binning
     bin_level = 63L;*60
     nframes = bin_level
     nfits = long(n_elements(corrflux)) / nframes
     print, 'nframes, nfits', n_elements(corrflux), nframes, nfits
     bin_flux = dblarr(nfits)
     bin_corrflux= dblarr(nfits)
     bin_corrfluxerr= dblarr(nfits)
     bin_timearr = dblarr(nfits)
     bin_bmjdarr = dblarr(nfits)
     bin_bkgd = dblarr(nfits)
     bin_bkgderr = dblarr(nfits)
     bin_xcen = dblarr(nfits)
     bin_ycen = dblarr(nfits)

     for si = 0L, long(nfits) - 1L do begin
                                ;print, 'working on si', n_elements(AOR55cnc[a].corrflux), si, si*nframes, si*nframes + (nframes - 1)
        idata = corrflux[si*nframes:si*nframes + (nframes - 1)]
        id = flux[si*nframes:si*nframes + (nframes - 1)]
        idataerr = corrfluxerr[si*nframes:si*nframes + (nframes - 1)]
        ib = bkgdarr[si*nframes:si*nframes + (nframes - 1)]
        iberr = bkgderrarr[si*nframes:si*nframes + (nframes - 1)]
       ; if si lt 2 then print, 'ib', ib
       ; print, 'mean', mean(ib,/nan)
        bin_flux[si] = mean(id, /nan)
        bin_corrflux[si] = mean(idata,/nan)
        bin_corrfluxerr[si] =   sqrt(total(idataerr^2))/ (n_elements(idataerr))
        bin_timearr[si]= mean(timearr[si*nframes:si*nframes + (nframes - 1)])
        bin_bmjdarr[si]= mean(bmjdarr[si*nframes:si*nframes + (nframes - 1)])
        bin_bkgd[si] = mean(ib,/nan)
        bin_bkgderr[si] = mean(iberr,/nan)
        bin_xcen[si]= mean(xarr[si*nframes:si*nframes + (nframes - 1)])
        bin_ycen[si]= mean(yarr[si*nframes:si*nframes + (nframes - 1)])

     endfor                     ;for each fits image
     
 ;try getting rid of flux outliers.
  ;do some running mean with clipping
     start = 0
     print, 'nflux', n_elements(bin_flux)
     for ni = 50, n_elements(bin_flux) -1, 50 do begin
        meanclip,flux[start:ni], m, s, subs = subs ;,/verbose
                                ;print, 'good', subs+start
                                ;now keep a list of the good ones
        if ni eq 50 then good_ni = subs+start else good_ni = [good_ni, subs+start]
        start = ni
     endfor
                                ;see if it worked
     ;xarr = xarr[good_ni]
     ;yarr = yarr[good_ni]
     bin_timearr = bin_timearr[good_ni]
     bin_bmjdarr = bin_bmjdarr[good_ni]
     bin_corrfluxerr = bin_corrfluxerr[good_ni]
     bin_flux = bin_flux[good_ni]
     bin_corrflux = bin_corrflux[good_ni]
     bin_bkgd = bin_bkgd[good_ni]
     bin_bkgderr = bin_bkgderr[good_ni]
     bin_xcen = bin_xcen[good_ni]
     bin_ycen = bin_ycen[good_ni]

     print, 'nflux', n_elements(bin_flux)
     
 xcen_coeff = [1.5,0.5,-0.1, -0.8]
 ycen_coeff = [1.0,0,0,-0.7]
     if a eq 0 then begin
;        am = plot( (AOR55cnc[a].timearr - AOR55cnc[a].timearr(0))/60./60., AOR55cnc[a].flux,'6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a+14], xtitle = 'Time(hrs)', ytitle = 'Flux', xrange = [0,6], yrange = [3,5])
;        am = plot( (AOR55cnc[a].timearr - AOR55cnc[a].timearr(0))/60./60., AOR55cnc[a].corrflux,'6r1s', sym_size = 0.1,   sym_filled = 1, color = 'black', /overplot)
        
;        am = plot(bin_bmjdarr, bin_corrflux,  '1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a+14], xtitle = 'Phase', ytitle = 'Corrected Flux')

;        ab = plot(bin_bmjdarr  , bin_flux,'6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a+14], xtitle = 'period', ytitle = 'Flux (Jy)')
;        ab = plot(bin_bmjdarr, bin_xcen + xcen_coeff(a),'6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a], title = 'aperture [3,11,15.5]', xtitle = 'Period', ytitle = 'Xcen');, xrange = [0.3,0.65])
  
;        ab = plot(bin_bmjdarr, bin_flux/mean(bin_flux), '6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a], title = 'aperture [3,11,15.5]', xtitle = 'Period', ytitle = 'Flux');, xrange = [0.3,0.65])
        ab = plot(bin_bmjdarr, bin_bkgd, '6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a], title = 'aperture [3,11,15.5]', xtitle = 'Period', ytitle = 'Bkgd');, xrange = [0.3,0.65])


   ;  print,'time', bin_bmjdarr - bin_bmjdarr(0) 
     endif else begin
     ; am = plot( (AOR55cnc[a].timearr - AOR55cnc[a].timearr(0))/60./60., AOR55cnc[a].flux,'6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a+14],/overplot)
; am = plot( (AOR55cnc[a].timearr - AOR55cnc[a].timearr(0))/60./60., AOR55cnc[a].corrflux,'6r1s', sym_size = 0.1,   sym_filled = 1, color = 'black', /overplot)
;        am = plot(bin_bmjdarr, bin_corrflux- 1.5E-2*a,  '1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a+14],/overplot)

;        am = plot(bin_bmjdarr, bin_xcen +xcen_coeff(a),'1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a], /overplot)
        am = plot(bin_bmjdarr, bin_bkgd-0.00005*(a),'1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a], /overplot)

     endelse


  endfor

end
