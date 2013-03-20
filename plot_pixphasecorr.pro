pro plot_pixphasecorr, planetname, bin_level, selfcal=selfcal, errorbars = errorbars, phaseplot = phaseplot

;get all the necessary saved info/photometry
  planetinfo = create_planetinfo()
  aorname = planetinfo[planetname, 'aorname']
  basedir = planetinfo[planetname, 'basedir']
  chname = planetinfo[planetname, 'chname']
  dirname = strcompress(basedir + planetname +'/')

  for a = 1, 1 do begin
     filename =strcompress(dirname +'pixphasecorr_ch'+chname+'_'+aorname(a) +'.sav')
     print, a, aorname(a), 'restoring', filename
     restore, filename

;binning
     numberarr = findgen(n_elements(flux_m))
     h = histogram(numberarr, OMIN=om, binsize = bin_level, reverse_indices = ri)
     print, 'omin', om, 'nh', n_elements(h)
     

;mean together the flux values in each phase bin
     bin_corrflux = dblarr(n_elements(h))
     bin_corrfluxerr = dblarr(n_elements(h))
     bin_flux_m = dblarr(n_elements(h))
     bin_fluxerr_m = dblarr(n_elements(h))
     bin_flux_np = dblarr(n_elements(h))
     bin_fluxerr_np = dblarr(n_elements(h))
     bin_flux = dblarr(n_elements(h))
     bin_fluxerr = dblarr(n_elements(h))
     bin_time = dblarr(n_elements(h))
     bin_time_0 = dblarr(n_elements(h))
     bin_phase = dblarr(n_elements(h))
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

           icorrdataerr = corrfluxerr[ri[ri[j]:ri[j+1]-1]]
           bin_corrfluxerr[c] =   sqrt(total(icorrdataerr^2))/ (n_elements(icorrdataerr))

           meanclip, flux_m[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
           bin_flux_m[c] = meanx   ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
 
           ifluxmerr = fluxerr_m[ri[ri[j]:ri[j+1]-1]]
           bin_fluxerr_m[c] =   sqrt(total(ifluxmerr^2))/ (n_elements(ifluxmerr))

           meanclip, flux_np[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
           bin_flux_np[c] = meanx   ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
 
           ifluxnperr = fluxerr_np[ri[ri[j]:ri[j+1]-1]]
           bin_fluxerr_np[c] =   sqrt(total(ifluxnperr^2))/ (n_elements(ifluxnperr))

           meanclip, flux[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
           bin_flux[c] = meanx   ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])

           idataerr = fluxerr[ri[ri[j]:ri[j+1]-1]]
           bin_fluxerr[c] =   sqrt(total(idataerr^2))/ (n_elements(idataerr))

           meanclip, time[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
           bin_time[c] = meanx   ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])

           meanclip, time_0[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
           bin_time_0[c] = meanx   ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])

           meanclip, phase[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
           bin_phase[c] = meanx   ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
           
            c = c + 1
        endif
     endfor
     
     bin_corrflux =bin_corrflux[0:c-1]
     bin_flux_m = bin_flux_m[0:c-1]
     bin_flux_np = bin_flux_np[0:c-1]
     bin_flux = bin_flux[0:c-1]
     bin_time = bin_time[0:c-1]
     bin_time_0 =  bin_time_0[0:c-1]
     bin_phase = bin_phase[0:c-1]

     bin_corrfluxerr = bin_corrfluxerr[0:c-1]
     bin_fluxerr_m = bin_fluxerr_m[0:c-1]
     bin_fluxerr_np = bin_fluxerr_np[0:c-1]
     bin_fluxerr = bin_fluxerr[0:c-1]

;if working on a secondary, then want to plot the phase around 0.5,
;and not split it around 0.
     intended = planetinfo[planetname, 'intended_phase']
     if intended eq 0.5 then begin
        pa = where(bin_phase lt 0.0,pacount)
        if pacount gt 0 then bin_phase[pa] = bin_phase[pa] + 1.0
     endif



;plot the results
     if keyword_set(errorbars) then begin

        if keyword_set(phaseplot) then begin
   
           p1 = errorplot(bin_phase, bin_flux_m/ median(bin_flux_m),bin_fluxerr_m/median(bin_flux_m),$
                   '1s', sym_size = 0.3, sym_filled = 1,$
                   color = 'black', xtitle = 'Phase', ytitle = 'Normalized Flux', title = planetname, $
                   name = 'raw flux', yrange =[0.984, 1.013], xrange = [0.47, 0.53], axis_style = 1,  $
                   xstyle = 1, errorbar_capsize = 0.025)

           p4 =  errorplot(bin_phase, (bin_corrflux /median( bin_corrflux)) + 0.006, $
                   bin_corrfluxerr / median(bin_corrflux), '1s', sym_size = 0.3,   $
                   sym_filled = 1,color = 'grey',/overplot, name = 'pmap corr', $
                   errorbar_color = 'grey', errorbar_capsize = 0.025)

           P2 = errorplot(bin_phase, bin_flux/median(bin_flux)-0.012 , bin_fluxerr/median(bin_flux),$
                  '1s', sym_size = 0.3, sym_filled = 1, errorbar_color = 'red',$
                  color = 'red', /overplot, name = 'position corr', errorbar_capsize = 0.025)

           p3 = errorplot(bin_phase, bin_flux_np /median(bin_flux_np) + 0.011, $
                  bin_fluxerr_np/median(bin_flux_np), '1s', sym_size = 0.3, errorbar_color = 'blue',   $
                  sym_filled = 1,color = 'blue', /overplot, name = 'position + np',$
                  errorbar_capsize = 0.025)

        endif else begin        ;plot as a function of time
           p1 = errorplot(bin_time/60./60., bin_flux_m/ median(bin_flux_m),bin_fluxerr_m/median(bin_flux_m),$
                  '1s', sym_size = 0.3,sym_filled = 1,$
                  color = 'black', xtitle = 'Time (hrs)', ytitle = 'Flux', title = planetname,$
                  name = 'raw flux', yrange =[0.984, 1.013], xrange = [0,7.5], axis_style = 1, $
                  xstyle = 1, errorbar_capsize = 0.025)

           p4 =  errorplot(bin_time/60./60., (bin_corrflux /median( bin_corrflux)) + 0.006, $
                   bin_corrfluxerr / median(bin_corrflux), '1s', sym_size = 0.3, $
                   sym_filled = 1,color = 'grey',/overplot, name = 'pmap corr', $
                   errorbar_color = 'grey', errorbar_capsize = 0.025, errorbar_capsize = 0.025)

           p2 = errorplot(bin_time_0/60./60., bin_flux/median(bin_flux)-0.012, bin_fluxerr/median(bin_flux),$
                  '1s', sym_size = 0.3, errorbar_color = 'red',sym_filled = 1,color = 'red', $
                  /overplot, name = 'position corr', errorbar_capsize = 0.025)

           p3 = errorplot(bin_time_0/60./60., bin_flux_np /median(bin_flux_np) + 0.011,$
                  bin_fluxerr_np/median(bin_flux_np), '1s', sym_size = 0.3, $
                  sym_filled = 1,color = 'blue', /overplot, name = 'position + np', $
                  errorbar_color = 'blue', errorbar_capsize = 0.025)

        endelse                 ;phaseplot

     endif else begin           ;now without errorbars
        if keyword_set(phaseplot) then begin
   
           p1 = plot(bin_phase, bin_flux_m/ median(bin_flux_m), '1s', sym_size = 0.3, sym_filled = 1,$
                  color = 'black', xtitle = 'Phase', ytitle = 'Normalized Flux', title = planetname, $
                  name = 'raw flux', yrange =[0.984, 1.013], xrange = [0.47, 0.53], axis_style = 1,  $
                  xstyle = 1)

           p4 =  plot(bin_phase, (bin_corrflux /median( bin_corrflux)) + 0.006, '1s', sym_size = 0.3,   $
                   sym_filled = 1,color = 'grey',/overplot, name = 'pmap corr')

           p2 = plot(bin_phase, bin_flux/median(bin_flux)-0.012 , '1s', sym_size = 0.3, sym_filled = 1,$
                  color = 'red', /overplot, name = 'position corr')

           p3 = plot(bin_phase, bin_flux_np /median(bin_flux_np) + 0.011, '1s', sym_size = 0.3,   $
                  sym_filled = 1,color = 'blue', /overplot, name = 'position + np')

        endif else begin        ;plot as a function of time
           p1 = plot(bin_time/60./60., bin_flux_m/ median(bin_flux_m), '1s', sym_size = 0.3,sym_filled = 1,$
                  color = 'black', xtitle = 'Time (hrs)', ytitle = 'Flux', title = planetname,$
                  name = 'raw flux', yrange =[0.984, 1.013], xrange = [0,7.5], axis_style = 1,  xstyle = 1)

           p4 =  plot(bin_time/60./60., (bin_corrflux /median( bin_corrflux)) + 0.006, '1s', sym_size = 0.3, $
                   sym_filled = 1,color = 'grey',/overplot, name = 'pmap corr')

           p2 = plot(bin_time_0/60./60., bin_flux/median(bin_flux)-0.012 , '1s', sym_size = 0.3, $
                  sym_filled = 1,color = 'red', /overplot, name = 'position corr')
           p3 = plot(bin_time_0/60./60., bin_flux_np /median(bin_flux_np) + 0.011, '1s', sym_size = 0.3, $
                  sym_filled = 1,color = 'blue', /overplot, name = 'position + np')

        endelse                 ;phaseplot
     endelse                    ; no errorbars


     if keyword_set(selfcal) then begin
        restore, strcompress(dirname + 'selfcal.sav')    
        print, 'testing selfcal phase', phase[0:10], phase[n_elements(phase) - 1]
        print, 'test selfcal', y[0:10], 'x', x[0:10]
        
         if keyword_set(phaseplot) then begin
            p5 = plot(bin_phasearr, y -0.007, '1s', sym_size = 0.3,   sym_filled = 1, $
                      color = 'green',/overplot, name = 'selfcal')
         endif else begin
            p5 = plot(bin_timearr, y -0.007, '1s', sym_size = 0.3,   sym_filled = 1, $
                      color = 'green',/overplot, name = 'selfcal')
         endelse


     endif

     ;plot flat lines to guide the eyes
     x = findgen(1000) / 10. - 10.
     p6 = plot(x, fltarr(n_elements(x)) + 1.0, color = 'black',/overplot)
     p7 = plot(x, fltarr(n_elements(x)) + 1.006, color = 'grey',/overplot)
     p8 = plot(x, fltarr(n_elements(x)) +1.- 0.012, color = 'red',/overplot)
     p9 = plot(x, fltarr(n_elements(x))  +1.011, color = 'blue',/overplot)
     if keyword_set(selfcal) then p10 = plot(x, fltarr(n_elements(x)) +1. -0.007, color = 'green',/overplot)

     ;xaxis = axis('X', location = [1.01, 0], coord_transform = [bin_phase[0], slope_convert], target = p1)

;  l = legend(target = [p1, p4, p2,p3], position = [1.5, 1.18], /data, /auto_text_color)


;plot residuals between position corr and position + np corr
;resid = bin_flux - bin_flux_np
;pr = plot(bin_time_0, resid, '1s', sym_size = 0.3, sym_filled = 1, xtitle = 'Time (hrs)', ytitle = 'residual')

  endfor                        ; n_elements(aorname)

end


