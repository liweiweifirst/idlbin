PRO colorplot
close,/all



;read in the V radial profile
OPENR, lun,'/Users/jkrick/umich/icl/A4059/icl2Btab', /GET_LUN  ;iclVtab2
rows=20
radius = FLTARR(rows)
counts = FLTARR(rows)
Verr = FLTARR(rows)
stop = FLTARR(rows)
r = 0.0				;radius
c = 0.0				;mean counts
ellerr = 0.0
s = 0
i = 0
FOR j=0,rows-1 DO BEGIN
      READF, lun, r,c, ellerr,s
      
          radius(i) = r
          counts(i) = c
          Verr(i) = ellerr 
          stop(i) = s
          i = i +1
     
ENDFOR

close, lun
free_lun, lun

counts = counts[0:i -1 ] 
radius = radius[0:i-1]

;print, radius

;iclrtab2 vs samemask/iclVtab2.2
interpcounts = fltarr(19)
interpradius = fltarr(19)
interpradius = interpolate(radius, [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19])
interpcounts = interpolate(counts, [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19])
print, "B radius", interpradius





;read in the r sb profile
OPENR, lun,'/Users/jkrick/umich/icl/A4059/icl2rtab', /GET_LUN 
rows= 20
rradius = FLTARR(rows)
rcounts = FLTARR(rows)
rerr = FLTARR(rows)
r = 0.0				;radius
c = 0.0				;mean counts
ellerr = 0.0

FOR j=0,rows-1 DO BEGIN
      READF, lun, r,c, ellerr,s
      rradius(j) = r
      rcounts(j) = c
      rerr(j) = ellerr
ENDFOR

close, lun
free_lun, lun

rcounts = rcounts[0:j-1]; - 2
rradius = rradius[0:j-1]

;iclrtab2 vs samemask/iclVtab2.2
interprcounts = fltarr(19)
interprradius = fltarr(19)
interprradius = interpolate(rradius, [0,1,2,3,4,5,6,7,8,9,9.5,10,11,12,13,14,15,16,17])
interprcounts = interpolate(rcounts, [0,1,2,3,4,5,6,7,8,9,9.5,10,11,12,13,14,15,16,17])
print, "rradius", interpradius

;print, interprcounts

Vyarr = fltarr(4)
ryarr = fltarr(4)
radarr = fltarr(4)

Vyarr(0) = mean(interpcounts(0:2))
Vyarr(1) = mean(interpcounts(3:6))
Vyarr(2) = mean(interpcounts(7:10))
Vyarr(3) = mean(interpcounts(11:14))
;Vyarr(4) = mean(interpcounts(15:18))

radarr(0) = mean(interpradius(0:2))
radarr(1) = mean(interpradius(3:6))
radarr(2) = mean(interpradius(7:10))
radarr(3) = mean(interpradius(11:14))
;radarr(4) = mean(interpradius(15:18))

ryarr(0) = mean(rcounts(0:2))
ryarr(1) = mean(rcounts(3:6))
ryarr(2) = mean(rcounts(7:10))
ryarr(3) = mean(rcounts(11:14))
;ryarr(4) = mean(rcounts(15:18))


;print, Vyarr, ryarr

Vyarr = 22.19 -2.5*(alog10(Vyarr/(0.435^2)))
ryarr = 22.04 -2.5*(alog10(ryarr/(0.435^2)))
;print, Vyarr, ryarr


;f0v = 3.75E-9
f0v = 6.40E-9 ;= f0B
f0r = 1.75E-9
noiser = fltarr(4)
noiser= [27.7,27.7,27.7,27.7]
noisev = noiser + 2.2


fv = f0v*10^(Vyarr/(-2.5))
sigv = f0v*10^(noisev/(-2.5))
fr = f0r*10^(ryarr/(-2.5))
sigr = f0r*10^(noiser/(-2.5))
print,"sigB,sigr", sigv, sigr

;because I have averaged together 4(sometimes 3 values, the sigma is
;better than the individual sigma)

;;sigv = sqrt(1./4.)*sigv
;sigv(4) = sqrt(1./3.)*sigv(4)

;;sigr = sqrt(1./4.)*sigr
;sigr(1) = sqrt(1./3.)*sigr(1)
;sigr(2) = sqrt(1./3.)*sigr(2)
;sigr(3) = (1./2.)*sigr(3)

color = Vyarr - ryarr

sig = sqrt(((fv/fr)^2)*(((sigv/fv)^2)+((sigr/fr)^2)))
percent = sig/(fv/fr)
print, "percent",percent
FOR gah =0, 3 DO BEGIN
    IF percent[gah] GT 1 THEN percent[gah] =0.99
ENDFOR

print, "percent",percent
plus = -2.5*alog10(1+percent)
minus = -2.5*alog10(1-percent)
print, "plus,minus",plus, minus
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


mydevice = !D.NAME
!p.multi = [0, 0, 1]
SET_PLOT, 'ps'

device, filename = '/Users/jkrick/umich/icl/A4059/color.ps', /portrait, $
  BITS=8, scale_factor=0.9 , /color

plot, radarr*0.435, color, psym = 2, xrange = [0,450], ytitle ="B-r",thick = 3,$
charthick = 3, xthick = 3, ythick = 3,xtitle = 'Semi-major Axis (arcseconds)',$
yrange=[1.0,2.5],ystyle = 1, xstyle = 8

axis, 0, 2.5, xaxis=1, xrange=[0,0.4638], xstyle = 1, xthick = 3,charthick = 3

;upper = [0.2,0.2,0.2,0.2]
errplot, radarr*0.435, color-minus, color-plus

;fit this with a linear function
err = plus
start = [-0.0025,0.6]
result = MPFITFUN('linear',radarr,color,err, start,perror =test)
print, "test", test
oplot, findgen(1200)*0.435, result(0)*findgen(1200) + result(1), thick = 3, linestyle = 2
oplot, findgen(1200)*0.435, (result(0) -1*test(0))*findgen(1200) + (result(1) - 1*test(1)), linestyle = 2
oplot, findgen(1200)*0.435, (result(0)+1*test(0) )*findgen(1200) + (result(1) + 1*test(1)), linestyle = 2

out = textoidl('h_{70}^{-1}kpc')


;the red cluster sequence
x= findgen(100) + 400
y = x - (findgen(100)+400) + 1.9
;y2 = x - (findgen(100)+135) + 0.0

oplot, x, y, thick = 3
;oplot, x, y2, thick = 3
xyouts, 400, 1.84, 'RCS', charthick = 3
;xyouts, 230, 0.02, 'Tidal Features', charthick = 3
xyouts, 30, 2.4, "A4059", charthick = 3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


device, /close
set_plot, mydevice


END
