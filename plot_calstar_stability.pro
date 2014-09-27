pro plot_calstar_stability

restore, '/Users/jkrick/irac_warm/calstars/allch1phot.sav'
;potential calstar names
names = [ '1812095', 'KF08T3_', 'KF06T2_', 'KF06T1_'];, 'KF09T1_', 'NPM1p60', 'NPM1p67', 'NPM1p68', 'HD16545']
colors = ['black', 'grey', 'red', 'blue'];, 'chocolate', 'cyan', 'orange', 'maroon', 'medium purple']
;start with the first four, the rest were observed differently
keyname = ['f12s', 'F12sc', 'F12sc', 'F12s', 'F2s', 'F2sc', 'F0p4s', 'F0p4sc', 'FS0p4sc']


for n = 0, n_elements(names) - 1 do begin

   ;add a correction for pixel phase effect
   corrflux = pixel_phase_correct_gauss(fluxarr,xcenarr,ycenarr,1, '3_3_7')


   a = where(starnamearr eq names(n), count)

   p1 = errorplot((timearr(a) - min(timearr))/60./60./ 24./365, fluxarr(a)/median(fluxarr(a)), fluxerrarr(a)/median(fluxarr(a)),$
                  '1s', sym_size = 0.2,   sym_filled = 1, color = colors(n),errorbar_color = colors(n), yrange = [0.9, 1.1],$
                   xtitle = 'Time(years)', ytitle = 'Normalized Flux', title = 'Ch 1 Primary Calibrators', overplot = p1)
                  
;----------------------------------------------------
;need some binning on time, since there are either 5 or 6 observations per visit.
;XXXch2 has 6 frames, ch1 has 5 frames.  Would like to ignore the first frame on ch2 anyway.
   timeb = timearr(a)
   fluxb = fluxarr(a)
   fluxerrb = fluxerrarr(a)
   starnameb = starnamearr(a)
   corrfluxb  = corrflux(a)

   x = indgen(n_elements(timeb))
   h = histogram(x, OMIN=om, binsize = 5L, reverse_indices = ri)
   print, n, n_elements(h)
   bin_flux = dblarr(n_elements(h))
   bin_corrflux = bin_flux
   bin_fluxerr = bin_flux
   bin_time = bin_flux
   bin_starname = strarr(n_elements(h))
   c = 0
   for j = 0L, n_elements(h) - 1 do begin
      if (ri[j+1] gt ri[j] + 2)  then begin ;require 3 elements in the bin
         
         meanclip, fluxb[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
         bin_flux[c] = meanx    ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])

         meanclip, corrfluxb[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
         bin_corrflux[c] = meanx    ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
         
         idataerr = fluxerrb[ri[ri[j]:ri[j+1]-1]]
         bin_fluxerr[c] =   sqrt(total(idataerr^2))/ (n_elements(idataerr))
         
         meanclip, timeb[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
         bin_time[c] = meanx    ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
         
         bin_starname[c] = starnameb[ri[ri[j]]] ; is true unless the observations changed!
         c = c + 1
      endif
   endfor
   
   bin_flux = bin_flux[0:c-1]
   bin_corrflux = bin_corrflux[0:c-1]
   bin_fluxerr = bin_fluxerr[0:c-1]
   bin_time = bin_time[0:c-1]
   bin_starname = bin_starname[0:c-1]
   
;----------------------------------------------------
;and some binned plotting
   pb = errorplot((bin_time - min(bin_time))/60./60./ 24./365, bin_corrflux/median(bin_corrflux), bin_fluxerr/median(bin_flux),$
                  '1s', sym_size = 0.2,   sym_filled = 1, color = colors(n),errorbar_color = colors(n), yrange = [0.96, 1.04],$
                  xtitle = 'Time(years)', ytitle = 'Normalized Flux', title = 'Ch 1 Primary Calibrators', overplot = pb)
   
;----------------------------------------------------
;fill in multiple star array
;a bit messy because I don't know how big each array will be up front
   if n eq 0 then begin
      all_corrflux = bin_corrflux/median(bin_corrflux)
      all_time = bin_time
      all_starname = bin_starname
      all_fluxerr = bin_fluxerr
   endif else begin
      all_corrflux = [all_corrflux, bin_corrflux/median(bin_corrflux)]
      all_time = [all_time, bin_time]
      all_starname = [all_starname, bin_starname]
      all_fluxerr = [all_fluxerr, bin_fluxerr]
   endelse


endfor  ; for each star

;----------------------------------------------------
;bin all stars together as a function of 2 week PAO!
;turns out PAOs change length slightly, starting with 13.6 days for now

   h = histogram((all_time- min(all_time))/60./60./ 24., OMIN=om, binsize = 13.6, reverse_indices = ri)
   print,  n_elements(h)
   bin_all_corrflux = findgen(n_elements(h))
   bin_all_fluxerr = bin_all_corrflux
   bin_all_time = bin_all_corrflux
   c = 0
   for j = 0L, n_elements(h) - 1 do begin
      if (ri[j+1] gt ri[j] + 2)  then begin ;require 3 elements in the bin
         
         meanclip, all_corrflux[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
         bin_all_corrflux[c] = meanx    ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
         
         idataerr = all_fluxerr[ri[ri[j]:ri[j+1]-1]]
         bin_all_fluxerr[c] =   sqrt(total(idataerr^2))/ (n_elements(idataerr))
         
         meanclip, all_time[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
         bin_all_time[c] = meanx    ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
         
         c = c + 1
      endif
   endfor
   
   bin_all_corrflux = bin_all_corrflux[0:c-1]
   bin_all_fluxerr = bin_all_fluxerr[0:c-1]
   bin_all_time = bin_all_time[0:c-1]

;----------------------------------------------------
;and some binned plotting
   
   print, 'bin_all_corrflux', bin_all_corrflux
    print, 'bin_all_time', bin_all_time

   pb2 = errorplot((bin_all_time - min(bin_all_time))/60./60./ 24./365,$
                   bin_all_corrflux/median(bin_all_corrflux), bin_all_fluxerr/median(bin_all_corrflux),$
                   '1s', sym_size = 0.2,   sym_filled = 1, color = 'black', yrange = [0.98, 1.02],$
                   xtitle = 'Time(years)', ytitle = 'Normalized Flux', title = 'Ch 1 Primary Calibrators', overplot = pb2)
 


end
