pro test_addcurve

;fake time
x = findgen(250) / 25

;a flat light curve
y_flat = fltarr(250) + 1.0
;fake some noise
noise = randomn(seed, 250, /Double)
yerr_flat= (noise- mean(noise))/stddev(noise)*0.001 + 0.001

;a sin curve
y_sin = .0006*sin(x/1. ) ;+ 1.0
;are these realistic noise estimates for the phase curve?
noise = randomn(seed, 250, /Double)
yerr_sin= (noise- mean(noise))/stddev(noise)*0.0002 + 0.0002

;try combining the curves
y_sum = y_flat + y_sin
yerr_sum = sqrt( yerr_flat^2 + yerr_sin^2)

;the plots!
;p1 = errorplot(x, y_flat, yerr_flat, '+.-2', yrange = [0.994, 1.006])
;p3 = errorplot(x, y_sum,yerr_sum, '+b2',/overplot)

;---------------------------------------------
;now for some real data in the time dimension
restore,  '/Users/jkrick/irac_warm/snapshots/HD158460_stare_v2.sav'
a = 1
if a eq 1 then begin
timearr = timearr_1
fluxarr = fluxarr_1
fluxerrarr = fluxerrarr_1
xarr = xarr_1
yarr = yarr_1
endif
if a eq 0 then begin
timearr = timearr_0
fluxarr = fluxarr_0
fluxerrarr = fluxerrarr_0
xarr = xarr_0
yarr = yarr_0
endif

x = timearr

y_flat = fltarr(n_elements(x)) + 1.0
noise = randomn(seed, n_elements(x), /Double)
yerr_flat= (noise- mean(noise))/stddev(noise)*0.001 + 0.001

y_sin = .0006*sin(x/1. ) ;+ 1.0
noise = randomn(seed, n_elements(x), /Double)
yerr_sin= (noise- mean(noise))/stddev(noise)*0.0002 + 0.0002

y_sum = y_flat + y_sin
yerr_sum = sqrt( yerr_flat^2 + yerr_sin^2)

;the plots!
;p1 = errorplot(x, y_flat, yerr_flat, '+.-2',  yrange = [0.994, 1.006])
;p3 = errorplot(x, y_sum,yerr_sum, '+b2',/overplot)

;can I recover the sin curve? YES!
; Initial guess	
;start = [1., 1., 1.,1.]
;result= MPFITFUN('sin_func',x,y_sum, yerr_sum, start) ;ICL
;p4 = plot( x, result(0)*sin(x/result(2) + result(3)) + result(1),  '6r1.',/overplot)

;--------------------------------------------------
;---------------------------------------------------
;now for the real deal (data in the flux dimension and time dimension)
;only now y_flat is not flat, but is the real data with its own pixel phase effect and drift

;get rid of outliers in the pointing
if a eq 1 then good = where(xarr gt 14.94 and xarr lt 15.12 and yarr gt 14.9 and yarr lt 15.2 )
if a eq 0 then good = where(xarr gt 14.84 and xarr lt 15.15 and yarr gt 14.55 and yarr lt 14.9 )
xarr = xarr[good]
yarr = yarr[good]
timearr = timearr[good]
fluxerrarr = fluxerrarr[good]
fluxarr = fluxarr[good]

;get rid of first 30 min of observations
if a eq 1 then good = where(timearr gt 0.5)
xarr = xarr[good]
yarr = yarr[good]
timearr = timearr[good]
fluxerrarr = fluxerrarr[good]
fluxarr = fluxarr[good]

x = timearr
y = fluxarr
yerr = fluxerrarr

;the sin curve
amplitude =  0.0006
period = 1.0
phase = 2.4
y_sin = amplitude*sin(x/period + phase ) 
noise = randomn(seed, n_elements(x), /Double)
yerr_sin= (noise- mean(noise))/stddev(noise)*0.0002 + 0.0002

y_sum = y + y_sin
yerr_sum = sqrt( yerr^2 + yerr_sin^2)

;the plots!
;p0 = plot(x, y, '+2', yrange = [4.13,4.17], xrange = [0.5, 0.54])
;;p1 = errorplot(x, y, yerr, '+2', yrange = [4.0,4.2], title = aorname(a), xtitle = 'Time (hours)', ytitle = 'Flux ');, errorbar_capsize = .001)
;;p3 = errorplot(x, y_sum,yerr_sum, '+b2',/overplot)


;test input values
print, 'mean y', mean(y)
print, 'mean yerr', mean(yerr)

;can I recover the sin curve? Maybe?
;now need to make a hybrid function
; Initial guess	
  pa0 = [median(y_sum), 1.,1.,1.,1.,1.,amplitude,1.,1.0]
  amx = median(xarr);xa[agptr])
  amy = median(yarr); ya[agptr])	
  adx = xarr - amx; xa[agptr] - amx
  ady = yarr - amy; ya[agptr] - amy
  
  parinfo = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0.D]}, n_elements(pa0))
  ;limit the range of the sin cuve phase
  parinfo[8].limited[0] = 1 
 ; parinfo[8].limited[1] = 1
  parinfo[8].limits[0] = 0.0D
 ; parinfo[8].limits[1] = 2.*!pi

  afargs = {FLUX:y_sum, DX:adx, DY:ady, T:timearr, ERR:yerr_sum}
  pa = mpfit('fpa1_xfunc3', pa0, FUNCTARGS=afargs, PERROR=spa, BESTNORM=achi, DOF=adof, COVAR = COV, status = status, errmsg = errmsg, parinfo = parinfo)
  print, 'status', status
  print, errmsg
  achi = achi / adof
  print, 'reduced chi squared', achi
  print, 'input amplitude, period, phase', amplitude, period*2.*!pi, phase/(2.*!pi)
  print, 'fitted amplitude', pa[6], spa[6]
  print, 'fitted period (hours)', pa[7]*2.*!pi, spa[7]*2.*!pi
  print, 'fitted phase [0,1]', pa[8]/(2.*!pi), spa[8]/(2.*!pi)

  ;look at correlations amongs parameters
  ;PCOR = COV * 0
  ;n = n_elements(spa)
  ;FOR i = 0, n-1 DO FOR j = 0, n-1 DO PCOR[i,j] = COV[i,j]/sqrt(COV[i,i]*COV[j,j])
  ;print, 'pcor', pcor

;;  f1 = plot(timearr,   pa[0] * (1+ pa[1] * adx + pa[2] * ady + pa[3] * adx * ady + pa[4] * adx * adx + $
;;            pa[5] * ady * ady ) + pa[6]*sin(timearr/pa[7] + pa[8]) , '6r1.',/overplot)
 
  ;plot residuals
  sub = y_sum - (pa[0] * (1+ pa[1] * adx + pa[2] * ady + pa[3] * adx * ady + pa[4] * adx * adx + $
            pa[5] * ady * ady ) + pa[6]*sin(timearr/pa[7] + pa[8]))
;;  f2 = plot(timearr, sub+4.04, '6g1.',/overplot)


;fit residuals to know what the errors look like.
  plothist, sub, xhist, yhist,bin=0.0010, /noprint,/noplot
;;  r0 = barplot(xhist, yhist, fill_color = 'green', xrange = [-0.05, 0.05], xtitle = 'Residuals', ytitle = 'Number')

  noise = fltarr(n_elements(yhist)) + 1.0;  
  start = [0.0001, 0.01, 3000.]
  result= MPFITFUN('mygauss',xhist,yhist, noise, start) 
;;  r1 = plot( xhist, result(2)/sqrt(2.*!Pi) * exp(-0.5*((xhist - result(0))/result(1))^2.),  '3',/overplot)
  
  t_sig = text(0.02, 2000, string(result(1)),'3',/data)


end

function fpa1_xfunc3, p, FLUX=flux, DX=dx, DY=dy, T=t, ERR=err
; p is parameters, f0, a1..a5
; t is time
    n = n_elements(dx)
    model = dblarr(n) + p[0]

    scale = p[1] * dx + p[2] * dy + p[3] * dx * dy + p[4] * dx * dx + $
            p[5] * dy * dy 
    dt = t - min(t)
    
    model = model * (1. + scale) 
    
    ;now add in the sin curve (XXX)
    model = model + p[6]*sin(t/p[7] + p[8]) 
 

   model = (flux - model) / err

return, model
end
