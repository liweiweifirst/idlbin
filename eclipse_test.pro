pro eclipse_test
restore,'/Users/jkrick/irac_warm/hd209458/hd209458_plot_ch4.sav'
x = bin_time +tt                ; phase_time             ;/ max(timearr)        ; fix to 1 phase
y = bin_flux                    ;/ fluxarr[1]          ;normalize
yerr = bin_fluxerr              ;/ fluxarr[1]    ;normalize

t1 = 4.; hrs start of ingress
dt = .5 ; hrs duration of ingress (or egress)
;t2 = t1+dt ; hrs end of ingress
;t4 = 3.36 + t1 ; hrs, end of egress
t3 = 3.36 + t1 - dt ; hrs start of egress

  pa0 = [median(sortfluxarr), 0.003,t1,t3,dt] ;f0, d, t1, t3, dt

  afargs = {FLUX:y, X:x, ERR:yerr}
  pa = mpfit('eclipse_trapezoid', pa0, FUNCTARGS=afargs, PERROR=spa, BESTNORM=achi, DOF=adof, COVAR = COV, status = status, errmsg = errmsg);, parinfo = parinfo) ;,/quiet)
  print, 'status', status
  print, 'errmsg', errmsg
  achi = achi / adof
  print, 'reduced chi squared', achi
 
  model_fit =eclipse_func(pa, flux = y, x =x, err=yerr)
  ;print, 'model)fit', model_fit[0:100]

  a = plot(x, y, '1.', color = 'black', xtitle = 'Time (hrs)', ytitle = 'Flux (mJy)', title = 'Ch4', yrange =[0.164, 0.169], xrange = [0, 10])


  flat = where(x le pa(2), flatcount)
  x1 = x[flat]
  y1 = fltarr(flatcount) + pa(0)
  print, 'x,y', x1[15], y1[15]
  f1 = plot(x1,   y1  , '2b',/overplot)

  ingress = where(x ge pa(2) and x lt (pa(2) + pa(4)))
  x2 = x[ingress]
  y2 = y[ingress]- pa[1] * (1.0 - ((pa[2] + pa[4]) - x[ingress]) / pa[4])
  f2 = plot(x2, y2, '2b',/overplot)
 
; In eclipse
   eclipse = where(x ge (pa[2] + pa[4]) and x lt pa[3], count)
   y3 = fltarr(count) + pa[0] - pa[1]
   x3 = x[eclipse]
   f3 = plot(x3, y3, '2b',/overplot)

; Leaving eclipse
   egress = where(x ge pa[3] and x lt (pa[3] + pa[4]), count)
   y4 = y[egress] + pa[1] * ((x[egress] - pa[3]) / pa[4] - 1.0)
   x4 = x[egress]
   f4 = plot(x4, y4, '2b',/overplot)

   flat = where(x ge (pa[3] + pa[4]), flatcount)
   x5 = x[flat]
   y5 = fltarr(flatcount) + pa(0)
   print, 'x,y', x1[15], y1[15]
   f5 = plot(x5,   y5  , '2b',/overplot)
   
end


function eclipse_trapezoid, p, FLUX=flux, X=x, ERR=err
; p is parameters, f0, d, t1, t3, dt
; t is time
; Start of ingress is t1, end of ingress is t2, start of egress is t3, end of egress is t4
; assume ingress and egress have same durations, dt 
   n = n_elements(x)
   model = fltarr(n) + p[0]

   t2 = p[2] + p[4]
   t4 = p[3] + p[4]

; Out of eclipse
    ptr = where(x le p[2], count)
    if (count gt 0) then model[ptr] = p[0]

    ptr = where(x gt t4, count)
    if (count gt 0) then model[ptr] = p[0]

; Beginning eclipse
   ptr = where(x gt p[2] and x le t2, count)
   if (count gt 0) then $
       model[ptr] = model[ptr] - p[1] * (1.0 - (t2 - x[ptr]) / p[4])

; In eclipse
   ptr = where(x gt t2 and x le p[3], count)
   if (count gt 0) then model[ptr] = model[ptr] - p[1]

; Leaving eclipse
   ptr = where(x gt p[3] and x le t4, count)
   if (count gt 0) then $
       model[ptr] = model[ptr] + p[1] * ((x[ptr] - p[3]) / p[4] - 1.0)

 model = (flux - model) / err

return, model
end
