pro plot_pixphasecorr, planetname, bin_level, selfcal=selfcal, errorbars = errorbars, phaseplot = phaseplot, fit_eclipse = fit_eclipse

;get all the necessary saved info/photometry
  planetinfo = create_planetinfo()
  aorname = planetinfo[planetname, 'aorname']
  basedir = planetinfo[planetname, 'basedir']
  chname = planetinfo[planetname, 'chname']
  intended_phase = planetinfo[planetname, 'intended_phase']

  delta_red = -0.012
  delta_grey =  0.006
  delta_blue = 0.011
  delta_green =- 0.007

  dirname = strcompress(basedir + planetname +'/')
  ;a = 1
  for a = 1, 1 do begin
     filename =strcompress(dirname +'pixphasecorr_ch'+chname+'_'+aorname(a) +'.sav')
     print, a, ' ', aorname(a), 'restoring', filename
     restore, filename


;binning
     numberarr = findgen(n_elements(flux_m))
     h = histogram(numberarr, OMIN=om, binsize = bin_level, reverse_indices = ri)
     print, 'omin', om, 'nh', n_elements(h)
     

;mean together the flux values in each phase bin
     bin_bmjd = dblarr(n_elements(h))
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
           
           meanclip, bmjd[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
           bin_bmjd[c] = meanx   ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])

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
     bin_bmjd = bin_bmjd[0:c-1]
     bin_corrfluxerr = bin_corrfluxerr[0:c-1]
     bin_fluxerr_m = bin_fluxerr_m[0:c-1]
     bin_fluxerr_np = bin_fluxerr_np[0:c-1]
     bin_fluxerr = bin_fluxerr[0:c-1]

;if working on a secondary, then want to plot the phase around 0.5,
;and not split it around 0.
 ;    if intended eq 0.5 then begin
 ;       pa = where(bin_phase lt 0.0,pacount)
 ;       if pacount gt 0 then bin_phase[pa] = bin_phase[pa] + 1.0
 ;    endif


;test the levels
     print, 'mean raw black flux', mean(bin_flux_m / median(bin_flux_m))
     print, 'mean corr gray flux', mean((bin_corrflux /median( bin_corrflux)))
     print, 'mean position red flux', mean(bin_flux/median(bin_flux))
     print, 'mean np blue flux', mean(bin_flux_np /median(bin_flux_np))
     print, 'phase', mean(bin_phase)

     for exofast = 0, n_elements(bin_time) - 1 do begin
        if finite(bin_corrflux(exofast)) gt 0 then begin
;           print, bin_bmjd(exofast) + 2400000.5D, ' ',bin_corrflux(exofast), ' ',bin_corrfluxerr(exofast), format = '(F0, A,F0, A, F0)'
           print, bin_bmjd(exofast) - 56081.26 , ' ',(bin_corrflux(exofast) / median(bin_corrflux)) - 0.0005, format = '(F0, A,F0)'
           ;a guess at mid-transit
        endif

     endfor

;plot the results
     if keyword_set(errorbars) then begin

        if keyword_set(phaseplot) then begin
                ;print, 'inside plotting phase', bin_phase[0:10]

           p1 = errorplot(bin_phase, bin_flux_m/ median(bin_flux_m),bin_fluxerr_m/median(bin_flux_m),$
                   '1s', sym_size = 0.3, sym_filled = 1,$
                   color = 'black', xtitle = 'Phase', ytitle = 'Normalized Flux', title = planetname, $
                   name = 'raw flux', yrange =[0.984, 1.013], axis_style = 1,  $
                   xstyle = 1, errorbar_capsize = 0.025)

           ;print, 'grey in plotting', bin_corrflux
           p4 =  errorplot(bin_phase, (bin_corrflux /Median( bin_corrflux)) + delta_grey, $
                   bin_corrfluxerr / median(bin_corrflux), '1s', sym_size = 0.3,   $
                   sym_filled = 1,color = 'grey',/overplot, name = 'pmap corr', $
                   errorbar_color = 'grey', errorbar_capsize = 0.025)

           P2 = errorplot(bin_phase, bin_flux/median(bin_flux)+delta_red , bin_fluxerr/median(bin_flux),$
                  '1s', sym_size = 0.3, sym_filled = 1, errorbar_color = 'red',$
                  color = 'red', /overplot, name = 'position corr', errorbar_capsize = 0.025)


           p3 = errorplot(bin_phase, bin_flux_np /median(bin_flux_np) + delta_blue, $
                  bin_fluxerr_np/median(bin_flux_np), '1s', sym_size = 0.3, errorbar_color = 'blue',   $
                  sym_filled = 1,color = 'blue', /overplot, name = 'position + np',$
                  errorbar_capsize = 0.025)

        endif else begin        ;plot as a function of time
           p1 = errorplot(bin_time/60./60., bin_flux_m/ median(bin_flux_m),bin_fluxerr_m/median(bin_flux_m),$
                  '1s', sym_size = 0.3,sym_filled = 1,$
                  color = 'black', xtitle = 'Time (hrs)', ytitle = 'Flux', title = planetname,$
                  name = 'raw flux', yrange =[0.984, 1.013], xrange = [0,7.5], axis_style = 1, $
                  xstyle = 1, errorbar_capsize = 0.025)

           p4 =  errorplot(bin_time/60./60., (bin_corrflux /median( bin_corrflux)) + delta_grey, $
                   bin_corrfluxerr / median(bin_corrflux), '1s', sym_size = 0.3, $
                   sym_filled = 1,color = 'grey',/overplot, name = 'pmap corr', $
                   errorbar_color = 'grey', errorbar_capsize = 0.025, errorbar_capsize = 0.025)

           p2 = errorplot(bin_time_0/60./60., bin_flux/median(bin_flux)+delta_red, bin_fluxerr/median(bin_flux),$
                  '1s', sym_size = 0.3, errorbar_color = 'red',sym_filled = 1,color = 'red', $
                  /overplot, name = 'position corr', errorbar_capsize = 0.025)

           p3 = errorplot(bin_time_0/60./60., bin_flux_np /median(bin_flux_np) + delta_blue,$
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

           p4 =  plot(bin_phase, (bin_corrflux /median( bin_corrflux)) + delta_grey, '1s', sym_size = 0.3,   $
                   sym_filled = 1,color = 'grey',/overplot, name = 'pmap corr')

           p2 = plot(bin_phase, bin_flux/median(bin_flux)+delta_red , '1s', sym_size = 0.3, sym_filled = 1,$
                  color = 'red', /overplot, name = 'position corr')

           p3 = plot(bin_phase, bin_flux_np /median(bin_flux_np) + delta_blue, '1s', sym_size = 0.3,   $
                  sym_filled = 1,color = 'blue', /overplot, name = 'position + np')

        endif else begin        ;plot as a function of time
           p1 = plot(bin_time/60./60., bin_flux_m/ median(bin_flux_m), '1s', sym_size = 0.3,sym_filled = 1,$
                  color = 'black', xtitle = 'Time (hrs)', ytitle = 'Flux', title = planetname,$
                  name = 'raw flux', yrange =[0.984, 1.013], xrange = [0,7.5], axis_style = 1,  xstyle = 1)

           p4 =  plot(bin_time/60./60., (bin_corrflux /median( bin_corrflux)) + delta_grey, '1s', sym_size = 0.3, $
                   sym_filled = 1,color = 'grey',/overplot, name = 'pmap corr')

           p2 = plot(bin_time_0/60./60., bin_flux/median(bin_flux)+delta_red , '1s', sym_size = 0.3, $
                  sym_filled = 1,color = 'red', /overplot, name = 'position corr')
           p3 = plot(bin_time_0/60./60., bin_flux_np /median(bin_flux_np) + delta_blue, '1s', sym_size = 0.3, $
                  sym_filled = 1,color = 'blue', /overplot, name = 'position + np')

        endelse                 ;phaseplot
     endelse                    ; no errorbars

;----------------------------------------------------
   ;fit the curves to a trapezoid, and plot
     if keyword_set(phaseplot) and keyword_set(fit_eclipse) then begin
        print, 'starting all fitting'
        trap = fit_eclipse(bin_phase, bin_flux/median(bin_flux) , bin_fluxerr/median(bin_flux),0.486 , 0.005,0.515,0.001, delta_red,'red')
        trap = fit_eclipse(bin_phase,bin_flux_np /median(bin_flux_np), bin_fluxerr_np/median(bin_flux_np),0.486 , 0.005,0.515,0.001, delta_blue,'blue')
        trap = fit_eclipse(bin_phase, (bin_corrflux /median( bin_corrflux)),bin_corrfluxerr / median(bin_corrflux),0.486 , 0.005,0.515,0.001, delta_grey,'grey')
        
     endif
     
;;----------------------------------------------------
     
     if keyword_set(selfcal) then begin
        restore, strcompress(dirname + 'selfcal.sav')    
       ; if intended_phase gt 0 then bin_phasearr = bin_phasearr + 0.5


         if keyword_set(phaseplot) then begin
            p5 = errorplot(bin_phasearr, y +delta_green, yerr, '1s', sym_size = 0.3,   sym_filled = 1, $
                      color = 'green',/overplot, name = 'selfcal', errorbar_color = 'green', $
                      errorbar_capsize = 0.025)
            if keyword_set(fit_eclipse) then begin
               trap = fit_eclipse(bin_phasearr, y ,yerr,0.486 , 0.005,0.515,0.001, delta_green,'green')
            endif

         endif else begin
            p5 = errorplot(bin_timearr, y +delta_green, yerr,  '1s', sym_size = 0.3,   sym_filled = 1, $
                      color = 'green',/overplot, name = 'selfcal', errorbar_color = 'green', $
                      errorbar_capsize = 0.025)
         endelse


     endif
                                ;plot flat lines to guide the eyes
     x = [0.46, 0.50, 0.54]
     p6 = plot(x, fltarr(n_elements(x)) + 1.0, color = 'black',/overplot)
;     p7 = plot(x, fltarr(n_elements(x)) + 1.006, color = 'grey',/overplot)
     p8 = plot(x, fltarr(n_elements(x)) +.988, color = 'red',/overplot)
     p9 = plot(x, fltarr(n_elements(x))  +1.011, color = 'blue',/overplot)
     if keyword_set(selfcal) then p10 = plot(x, fltarr(n_elements(x)) +.993, color = 'green',/overplot)

     ;xaxis = axis('X', location = [1.01, 0], coord_transform = [bin_phase[0], slope_convert], target = p1)

;  l = legend(target = [p1, p4, p2,p3], position = [1.5, 1.18], /data, /auto_text_color)


;plot residuals between position corr and position + np corr
;resid = bin_flux - bin_flux_np
;pr = plot(bin_time_0, resid, '1s', sym_size = 0.3, sym_filled = 1, xtitle = 'Time (hrs)', ytitle = 'residual')

 ;    print, 'END of LOOP a'
;     print, 'a ', a
 ;    print, 'hello'

  endfor                        ; n_elements(aorname)

;finally save the plot
  p9.save, dirname+'allfluxes_binned.png'

end

function fit_eclipse, xphase, ynorm, ynormerr, t1, dt, t3, d, delta, plotcolor
     print, 'inside fit_eclipse, working on ', plotcolor

     ;fit the eclipse with a trapezoid
     ;start with the red curve in phase plot only
     ;starting value educated guesses
;     t1 = 0.486; 1.                    ; hrs start of ingress
;     dt = 0.005;.5                    ; hrs duration of ingress (or egress)
;     t3 =0.515                 ; hrs start of egress
;     d = 0.001

  MESSAGE, /RESET
  ;remove indices with nans
  badnan = where(finite(ynormerr) lt 1 or finite(ynorm) lt 1 , badcount)
  if badcount gt 0 and badcount ne n_elements(ynorm) then begin
     remove, badnan, ynorm
     remove, badnan, ynormerr
     remove, badnan, xphase
  endif

     pa0 = [mean(ynorm,/nan), d,t1,t3,dt] ;f0, d, t1, t3, dt
     afargs = {FLUXfit:ynorm, Xfit:xphase, YERRfit:ynormerr}
     pi = replicate({fixed:0, limited:[0,0], limits:[0.D,0.D]},n_elements(pa0))
     pi(4).limited(0) = 1
     pi(4).limits(0) = 1E-4
     pi(3).limited(0) = 1
     pi(3).limits(0) = 0.505
     pi(2).limited(0) = 1
     pi(2).limits(0) = xphase(2)
     pi(1).limited(0) = 1
     pi(2).limits(0) = 0.
     pa = mpfit('eclipse_trapezoid', pa0, FUNCTARGS=afargs, PERROR=spa, BESTNORM=achi, DOF=adof, COVAR = COV, status = status, errmsg = errmsg, parinfo = pi) ;, parinfo = parinfo) ;,/quiet)
     print, 'status', status
     print, 'errmsg', errmsg
     achi = achi / adof
     print, 'reduced chi squared', achi
     print, 'depth of eclipse', pa(1)
          
   ;plotting overlay
     flat = where(xphase le pa(2), flatcount)
     ;catch a bug: if there is no initial flat part
     if flatcount lt 1 then begin
        print, 'inside if statement'
        flatcount = 1
        flat = 1
     endif

;     print, 'xphase', xphase
;     print, 'flatcount', flatcount , pa(2)
     x1 = xphase[flat]
     y1 = fltarr(flatcount) + pa(0) + delta ;  pa(0)
    ; print, 'x,y', x1[15], y1[15]
 ;;    f1 = plot(x1,   y1  , '2',color = plotcolor, /overplot)
     
     ingress = where(xphase ge pa(2) and xphase le (pa(2) + pa(4)))
     x2 = fltarr(2)
     x2(0) = pa(2)
     x2(1) = pa(2) + pa(4)
     y2 = fltarr(2)
     y2(0) = pa(0) + delta
     y2(1) = pa(0) + delta - pa[1]
 ;;    f2 = plot(x2, y2, '2',color = plotcolor,/overplot)
     
; In eclipse
     eclipse = where(xphase ge (pa[2] + pa[4]) and xphase le pa[3], count)
     y3 = fltarr(count) + pa(0) + delta - pa[1] ; pa[0] - pa[1]
     x3 = xphase[eclipse]
;;     f3 = plot(x3, y3, '2',color = plotcolor,/overplot)
     
; Leaving eclipse
     egress = where(xphase ge pa[3] and xphase le (pa[3] + pa[4]), count)
;   y4 = y[egress] + pa[1] * ((x[egress] - pa[3]) / pa[4] - 1.0)
;   x4 = x[egress]
     x4 = fltarr(2)
     x4(0) = pa(3)
     x4(1) = pa(3) + pa(4)
     y4 = fltarr(2)
     y4(0) = pa(0) + delta - pa[1]
     y4(1) = pa(0) + delta
     
;;     f4 = plot(x4, y4, '2',color = plotcolor,/overplot)
     
     flat = where(xphase ge (pa[3] + pa[4]), flatcount)
     x5 = xphase[flat]
     y5 = fltarr(flatcount) + pa(0) + delta ; pa(0)
;;     f5 = plot(x5,   y5  , '2',color = plotcolor,/overplot)

return, 0

end



function eclipse_trapezoid, p, FLUXfit=fluxfit, Xfit=xfit, yERRfit=yerrfit
; p is parameters, f0, d, t1, t3, dt
; t is time
; Start of ingress is t1, end of ingress is t2, start of egress is t3, end of egress is t4
; assume ingress and egress have same durations, dt 
   n = n_elements(xfit)
   model = fltarr(n) + p[0]

   t2 = p[2] + p[4]
   t4 = p[3] + p[4]

; Out of eclipse
    ptr = where(xfit le p[2], count)
    if (count gt 0) then model[ptr] = p[0]

    ptr = where(xfit gt t4, count)
    if (count gt 0) then model[ptr] = p[0]

; Beginning eclipse
   ptr = where(xfit gt p[2] and xfit le t2, count)
   if (count gt 0) then $
       model[ptr] = model[ptr] - p[1] * (1.0 - (t2 - xfit[ptr]) / p[4])

; In eclipse
   ptr = where(xfit gt t2 and xfit le p[3], count)
   if (count gt 0) then model[ptr] = model[ptr] - p[1]

; Leaving eclipse
   ptr = where(xfit gt p[3] and xfit le t4, count)
   if (count gt 0) then $
       model[ptr] = model[ptr] + p[1] * ((xfit[ptr] - p[3]) / p[4] - 1.0)

 model = (fluxfit - model) / yerrfit

return, model
end
