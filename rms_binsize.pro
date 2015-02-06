pro rms_binsize
 colorarr = ['gray', 'gray','gray','gray','gray','burlywood','sandy_brown', 'rosy_brown','saddle_brown', 'brown', 'maroon', 'firebrick', 'crimson', 'salmon', 'orange_red', 'dark_orange', 'orange', 'goldenrod', 'gold', 'yellow','khaki', 'green_yellow', 'lime', 'lime_green', 'green', 'dark_green', 'olive', 'olive_drab', 'sea_green', 'light_green', 'medium_spring_green', 'medium_sea_green', 'teal', 'cadet_blue', 'aquamarine', 'cyan', 'light_sky_blue', 'dodger_blue', 'steel_blue', 'blue', 'dark_blue', 'indigo', 'medium_slate_blue', 'purple', 'blue_violet', 'dark_orchid', 'orchid', 'pink', 'pale_violet_red', 'deep_pink', 'fuchsia']
 
  planetinfo = create_planetinfo()
  aorname= planetinfo['WASP-14b', 'aorname_ch2'] 

  restore, '/Users/jkrick/irac_warm/pcrs_planets/WASP-14b/WASP-14b_phot_ch2_2.25000.sav'

  readcol, '/Users/jkrick/irac_warm/pcrs_planets/WASP-14b/wong/ch2.dat', model_phase, model_flux

  for a =5, n_elements(aorname) -1 do begin
     corrflux =planethash[aorname(a),'corrflux_d']
     corrfluxerr =planethash[aorname(a),'corrfluxerr']
     phasearr = planethash[aorname(a),'phase']

     ;;get rid of NANs
     b = where(finite(corrflux) gt 0, good)

     ;;only consider those AORs with more than 20% of their data in
     ;;the sweet spot.
     if good gt 0.2*n_elements(corrflux) then begin
        print, 'a', a, good, colorarr(a), mean(corrflux, /nan)

        corrflux = corrflux(b)
        corrfluxerr = corrfluxerr(b)
        phasearr = phasearr(b)
 
 
        bin_scale = 189         ; largest bin_scale = 1/3 of the number of data points
        rmsarr = fltarr(bin_scale + 1 )
        numberarr = findgen(n_elements(corrflux))
     
        for n = 1, bin_scale  do begin
           ;;bin up the snapshot data
           h = histogram(numberarr, OMIN=om, binsize = n, reverse_indices = ri)
        
           bin_corrflux = dblarr(n_elements(h))
           bin_corrfluxerr = bin_corrflux
           bin_timearr = bin_corrflux
           bin_phasearr = bin_corrflux
           bin_modelarr = bin_corrflux
           
           if n eq 1 then begin
              bin_timearr = numberarr
              bin_corrflux = corrflux
              bin_corrfluxerr = corrfluxerr
              bin_phasearr = phasearr
              ;;only fit the function for n = 1, t`hen for the other
              ;;binnings, re-scale
              start = [1E-7,mean(corrflux, /nan)]
              result= MPFITFUN('linear',bin_timearr,bin_corrflux, bin_corrfluxerr, start,/Quiet) 
              
           endif else begin
              c = 0
              for j = 0L, n_elements(h) - 1 do begin
                 
                 if (ri[j+1] gt ri[j] + 1)  then begin ;require 2 elements in the bin
                    meanclip, corrflux[ri[ri[j]:ri[j+1]-1]], meanflux, sigmaflux
                    bin_corrflux[c] = meanflux
                    bin_corrfluxerr[c] = sigmaflux
                    meantimearr = mean(numberarr[ri[ri[j]:ri[j+1]-1]])
                    bin_timearr[c] = meantimearr
                    meanphasearr = mean(phasearr[ri[ri[j]:ri[j+1]-1]])
                    bin_phasearr[c] = meanphasearr
;              icorrdataerr = corrfluxerrp[rip[rip[j]:rip[j+1]-1]]
;              icorrdata = corrfluxp[rip[rip[j]:rip[j+1]-1]]
;              bin_corrfluxerrp[cp] =  sqrt(total(icorrdataerr^2))/ (n_elements(icorrdataerr))
                    
                    c = c + 1
                 endif
              endfor
              bin_timearr = bin_timearr[0:c-1]
              bin_corrflux = bin_corrflux[0:c-1]
              bin_corrfluxerr = bin_corrfluxerr[0:c-1]
              bin_phasearr = bin_phasearr[0:c-1]
              
           endelse
           
           ;; make a model light curve with the same phase as the
           ;; snapshot data
           for im = 0, n_elements(bin_corrflux) -1 do begin
              mp = where(bin_phasearr(im) gt (model_phase - 5E-5) and bin_phasearr(im) lt (model_phase + 5E-5),num_mp)
              if num_mp eq 0 then begin
                 print, 'hmmm no phase matches'
                 print, 'n corr', n_elements(corrflux)
                 print, bin_phasearr(im)
                 ;;ok but I should be able to find the nearest in
                 ;;phase and use that, the gaps aren't that big

                 ;;use function closest - do this for all of these in
                 ;;                       fact....
;                 index = closest(
              endif
              
              if num_mp eq 1 then bin_modelarr[im] = model_flux(mp)
              if num_mp gt 1 then begin
                 bin_modelarr[im] = mean(model_flux(mp))
              endif
              
           endfor
           
           
           residual = bin_corrflux -  bin_modelarr
           ;;residual = bin_corrflux -  (result(0)*bin_timearr +result(1)
           ;;                          + 0.01)  ;linear fit to the snapshots
           rmsarr(n) = stddev(residual)
        endfor
        
        
        p2 = plot(findgen(n_elements(rmsarr)), rmsarr/ rmsarr(1),/xlog, /ylog, overplot = p2, $
                  color = colorarr(a), yrange = [1E-3,3], xrange =[1, 200], xtitle = 'Number of frames',$
                  ytitle = 'Normalized residual RMS')
     endif  ; on the sweet spot

  endfor ; for all AORs
     
;------------------------
;now add straight root N
     
     source_mjy = 68.29         ;mJy  from Star-pet
     exptime = 2.
     
;ch2
     gain = 3.71
     pixel_scale = 1.22
  flux_conv = .1469
  xmax = max(p2.xrange)
  bin_scale = findgen(xmax) + 1
  root_n = sqrt(bin_scale)
  source_electrons = mjy_to_electron( source_mjy, pixel_scale, gain, exptime, flux_conv)
  sigma_poisson = sqrt(source_electrons)
  y =  (sigma_poisson / root_n) / source_electrons
  
  p2 = plot( bin_scale, y/y(0), thick = 3, linestyle = 2, overplot = p2)
;now add root2 * root N
  y2 =  1.5 * y/y(0)
;  p2 = plot( bin_scale, y2, thick = 3, linestyle = 2, color = 'grey', overplot = p2)
  
end

