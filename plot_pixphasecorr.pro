pro plot_pixphasecorr, planetname, bin_level
;get all the necessary saved info/photometry
  planetinfo = create_planetinfo()
  aorname = planetinfo[planetname, 'aorname']
  basedir = planetinfo[planetname, 'basedir']
  chname = planetinfo[planetname, 'chname']
  dirname = strcompress(basedir + planetname +'/')

  for a = 0, n_elements(aorname) - 1 do begin
     filename =strcompress(dirname +'pixphasecorr_ch'+chname+'_'+aorname(a) +'.sav')
     print, a, aorname(a), 'restoring', filename
     restore, filename

;binning
     numberarr = findgen(n_elements(flux_m))
     h = histogram(numberarr, OMIN=om, binsize = bin_level, reverse_indices = ri)
     print, 'omin', om, 'nh', n_elements(h)
     

;mean together the flux values in each phase bin
     bin_corrflux = dblarr(n_elements(h))
     bin_flux_m = dblarr(n_elements(h))
     bin_flux_np = dblarr(n_elements(h))
     bin_flux = dblarr(n_elements(h))
     bin_time = dblarr(n_elements(h))
     bin_time_0 = dblarr(n_elements(h))
     
     c = 0
     for j = 0L, n_elements(h) - 1 do begin

;get rid of the bins with no values and low numbers, meaning low overlap
        if (ri[j+1] gt ri[j] + 2)  then begin ;require 3 elements in the bin
        
           if finite(corrflux[ri[ri[j]]]) gt 0 and finite(corrflux[ri[ri[j+1]-1]]) gt 0 then begin
              meanclip, corrflux[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
              bin_corrflux[c] = meanx ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
           endif else begin
              bin_corrflux[c] = alog10(-1)
           endelse

           meanclip, flux_m[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
           bin_flux_m[c] = meanx   ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
 
           meanclip, flux_np[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
           bin_flux_np[c] = meanx   ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
 
           meanclip, flux[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
           bin_flux[c] = meanx   ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])

           meanclip, time[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
           bin_time[c] = meanx   ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])

           meanclip, time_0[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
           bin_time_0[c] = meanx   ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])

            c = c + 1
        endif
     endfor
     
     bin_corrflux =bin_corrflux[0:c-1]
     bin_flux_m = bin_flux_m[0:c-1]
     bin_flux_np = bin_flux_np[0:c-1]
     bin_flux = bin_flux[0:c-1]
     bin_time = bin_time[0:c-1]
     bin_time_0 =  bin_time_0[0:c-1]

;plot the results
     p1 = plot(bin_time/60./60., bin_flux_m/ median(bin_flux_m), '1s', sym_size = 0.1,   sym_filled = 1,color = 'black', xtitle = 'Time (hrs)', ytitle = 'Flux', title = planetname, name = 'raw flux')
     p4 =  plot(bin_time/60./60., (bin_corrflux /median( bin_corrflux)) + 0.01, '1s', sym_size = 0.1,   sym_filled = 1,color = 'grey',/overplot, name = 'pmap corr')
     p2 = plot(bin_time_0/60./60., bin_flux/median(bin_flux)-0.015 , '1s', sym_size = 0.1,   sym_filled = 1,color = 'red', /overplot, name = 'position corr')
     p3 = plot(bin_time_0/60./60., bin_flux_np /median(bin_flux_np) + 0.015, '1s', sym_size = 0.1,   sym_filled = 1,color = 'blue', /overplot, name = 'position + np')

;  l = legend(target = [p1, p4, p2,p3], position = [1.5, 1.18], /data, /auto_text_color)


;plot residuals between position corr and position + np corr
;resid = bin_flux - bin_flux_np
;pr = plot(bin_time_0, resid, '1s', sym_size = 0.1, sym_filled = 1, xtitle = 'Time (hrs)', ytitle = 'residual')

  endfor                        ; n_elements(aorname)

end


