pro cddp_alldata

  ;;this code measures something akin to photometric precision for all
  ;;staring mode light curves in the archive


    savenames = [ '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/centroids_save/track_centroids_pixval_01.sav','/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/centroids_save/track_centroids_pixval_02.sav','/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/centroids_save/track_centroids_pixval_03.sav','/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/centroids_save/track_centroids_pixval_04.sav','/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/centroids_save/track_centroids_pixval_05.sav','/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/centroids_save/track_centroids_pixval_06.sav','/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/centroids_save/track_centroids_pixval_07.sav','/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/centroids_save/track_centroids_pixval_08.sav']
  
  extra={xthick: 2, ythick:2, margin: 0.2, sym_size: 0.2,   sym_filled: 1, xstyle:1}
  
  starts = 0
  stops =  n_elements(savenames) - 1
  totalaorcount = 0
  TIC

  ;;how long of a timespan in which to measure the stddev?
  section_dur = 90              ;in minutes

             
  for s = starts, stops do begin
     print, 'restoring ', savenames(s)
     restore, savenames(s)
     aorname = planethash.keys()
     
     for a = 0,  n_elements(aorname) - 1 do begin
        print, '--------------------------------'
        min_dur = planethash[aorname(a), 'min_dur']
        print, 'working on ', aorname(a), ' ', a
        corrflux =planethash[aorname(a),'pld_flux'] ;'corrflux_d'
        bmjdarr = planethash[aorname(a), 'bmjdarr']
        bmjdarr = bmjdarr - bmjdarr(0)
        xcen = planethash[aorname(a), 'xcen']
        ycen = planethash[aorname(a), 'ycen']
        exptime = planethash[aorname(a),'exptime']
        ;;if exptime eq 0.01 then exptime = 0.05 ; otherwise total times of observation don't work out
        ;;if exptime eq 0.08 then exptime = 0.1
        ;;if exptime eq 10.4 then exptime = 11.0
        chname = planethash[aorname(a),'chname']
        flux = planethash[aorname(a), 'flux']
        
        data_section = section_dur*60/exptime  ;;but these numbers are not so exact
        thirtymin = 30*60/exptime
        fudge = 10.*60. / exptime  ; 10 min. fudge factor
        print, 'extimate of duration in minutes',  (n_elements(flux) * exptime) / 60., exptime
        
        ;;remove dithered observations and AORs less than 5 section durations
;        if (stddev(xcen) lt 0.15) and (stddev(ycen) lt 0.15) and (n_elements(flux) gt (5*data_section + thirtymin + fudge)) then begin
        if (stddev(xcen) lt 0.15) and (stddev(ycen) lt 0.15) and ((n_elements(flux) * exptime) / 60. gt (5*section_dur + 30 + 10)) then begin
           ;;divide data into sections ignoring the first 30 min.
           num_sections = fix(((n_elements(flux) *exptime)/60. - 30. - 10.) / section_dur)
           stddev_flux = fltarr(num_sections)
           stddev_corrflux = stddev_flux
           print, 'testing sections', num_sections, (n_elements(flux) * exptime) / 60., (5*section_dur + 30 + 10)
          
           ;;measure standard deviation within each section
           for i = 0, num_sections -1 do begin
              print, 'section boundaries',i, n_elements(flux),data_section*i + thirtymin, data_section*(i+1) + thirtymin
              meanclip, flux[(data_section*i + thirtymin): (data_section*(i+1) + thirtymin)], meanflux, sigmaflux
              stddev_flux[i] = sigmaflux

              meanclip, corrflux[(data_section*i + thirtymin): (data_section*(i+1) + thirtymin)], meancorrflux, sigmacorrflux
              ;;print, 'sigmacorrflux', meancorrflux, sigmacorrflux, corrflux[10]
              stddev_corrflux[i] = sigmacorrflux
              
           endfor
           

           ;; take the median standard deviation of all sections and
           ;; divide by sqrt(number of data points in a section)
           cddp_flux = median(stddev_flux)/sqrt(data_section)
           cddp_corrflux = median(stddev_corrflux)/sqrt(data_section)
           print, 'cddp', cddp_flux, cddp_corrflux
           
           ;;add data to the planethashs
           planethash[aorname(a),'cddp_raw'] = cddp_flux
           planethash[aorname(a),'cddp_pld'] = cddp_corrflux           


        endif else begin
           ;;add Nans to the planethashs
           planethash[aorname(a),'cddp_raw'] = alog10(-1)
           planethash[aorname(a),'cddp_pld'] = alog10(-1)        
        endelse
        
     endfor                     ;for each AOR
     save, planethash, filename=savenames(s)

  endfor                        ;for each savename
  TOC
end

  
     
