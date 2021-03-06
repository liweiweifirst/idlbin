PRO colorplot
close,/all



;read in the V radial profile
OPENR, lun,'/Users/jkrick/umich/icl/A2734/cdBtab2', /GET_LUN  ;iclVtab2
rows=35
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
;interpcounts = fltarr(9)
;interpradius = fltarr(9)
;interpradius = interpolate(radius, [1,2,3,4,5,6,7,8,9])
;interpcounts = interpolate(counts, [1,2,3,4,5,6,7,8,9])
;print, "B radius", interpradius

;cd included
interpcounts = fltarr(40)
interpradius = fltarr(40)
interpradius = interpolate(radius, [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,17.5,18,19,20,21,21.66,22,23,24,24.5,25,25.5,26,27,28,29,30,31,32,33,33.5,34])
interpcounts = interpolate(counts, [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,17.5,18,19,20,21,21.66,22,23,24,24.5,25,25.5,26,27,28,29,30,31,32,33,33.5,34])
print, "B radius", interpradius





;read in the r sb profile
OPENR, lun,'/Users/jkrick/umich/icl/A2734/cdtab', /GET_LUN 
rows= 36
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
;interprcounts = fltarr(9)
;interprradius = fltarr(9)
;interprradius = interpolate(rradius, [0,1,2,3,4,5,5.5,6,7])
;interprcounts = interpolate(rcounts, [0,1,2,3,4,5,5.5,6,7])
;print, "rradius", rradius


;
interprcounts = fltarr(40)
interprradius = fltarr(40)
interprradius = interpolate(rradius, [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,16.5,17,17.5,18,18.25,18.5,19,19.5,20,20.5,21,22,23,24,25,26,27,28,28.5,29,30,31,32])
interprcounts = interpolate(rcounts, [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,16.5,17,17.5,18,18.25,18.5,19,19.5,20,20.5,21,22,23,24,25,26,27,28,28.5,29,30,31,32])
print, "rradius", interprradius

;print, interprcounts

Vyarr = fltarr(9)
ryarr = fltarr(9)
radarr = fltarr(9)

Vyarr(0) = mean(interpcounts(0:4))
Vyarr(1) = mean(interpcounts(5:9))
Vyarr(2) = mean(interpcounts(10:14))
Vyarr(3) = mean(interpcounts(15:19))
Vyarr(4) = mean(interpcounts(20:24))
Vyarr(5) = mean(interpcounts(25:27))
Vyarr(6) = mean(interpcounts(28:30))
Vyarr(7) = mean(interpcounts(31:33))
Vyarr(8) = mean(interpcounts(34:35))

radarr(0) = mean(interpradius(0:4))
radarr(1) = mean(interpradius(5:9))
radarr(2) = mean(interpradius(10:14))
radarr(3) = mean(interpradius(15:19))
radarr(4) = mean(interpradius(20:24))
radarr(5) = mean(interpradius(25:27))
radarr(6) = mean(interpradius(28:30))
radarr(7) = mean(interpradius(31:33))
radarr(8) = mean(interpradius(34:35))

;ryarr(0) = mean(rcounts(0:2))
;ryarr(1) = mean(rcounts(3:5))
;ryarr(2) = mean(rcounts(6:8))
;ryarr(3) = mean(rcounts(13:17))
;ryarr(4) = mean(rcounts(18:22))
ryarr(0) = mean(interprcounts(0:4))
ryarr(1) = mean(interprcounts(5:9))
ryarr(2) = mean(interprcounts(10:14))
ryarr(3) = mean(interprcounts(15:19))
ryarr(4) = mean(interprcounts(20:24))
ryarr(5) = mean(interprcounts(25:27))
ryarr(6) = mean(interprcounts(28:30))
ryarr(7) = mean(interprcounts(31:33))
ryarr(8) = mean(interprcounts(34:35))


;print, Vyarr, ryarr

Vyarr = 22.19 -2.5*(alog10(Vyarr/(0.435^2)))
ryarr = 22.04 -2.5*(alog10(ryarr/(0.435^2)))
;print, Vyarr, ryarr


;f0v = 3.75E-9
f0v = 6.40E-9 ;= f0B
f0r = 1.75E-9
noiser = fltarr(9) +28.7
;noiser= [28.7,28.7,28.7]
noisev = noiser + 0.6


fv = f0v*10^(Vyarr/(-2.5))
sigv = f0v*10^(noisev/(-2.5))
fr = f0r*10^(ryarr/(-2.5))
sigr = f0r*10^(noiser/(-2.5))


;because I have averaged together 4(sometimes 3 values, the sigma is
;better than the individual sigma)

sigv = sqrt(1./3.)*sigv
;sigv(4) = sqrt(1./3.)*sigv(4)

sigr = sqrt(1./3.)*sigr
;sigr(1) = sqrt(1./3.)*sigr(1)
;sigr(2) = sqrt(1./3.)*sigr(2)
;sigr(3) = (1./2.)*sigr(3)

color = Vyarr - ryarr

sig = sqrt(((fv/fr)^2)*(((sigv/fv)^2)+((sigr/fr)^2)))
percent = sig/(fv/fr)

FOR gah =0, 2 DO BEGIN
    IF percent[gah] GT 1 THEN percent[gah] =0.99
ENDFOR


plus = -2.5*alog10(1+percent)
minus = -2.5*alog10(1-percent)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


mydevice = !D.NAME
!p.multi = [0, 0, 1]
SET_PLOT, 'ps'

device, filename = '/Users/jkrick/umich/icl/A2734/color.ps', /portrait, $
  BITS=8, scale_factor=0.9 , /color

plot, radarr*0.435, color, psym = 2, xrange = [0,250], ytitle ="B-r",thick = 3,$
charthick = 3, xthick = 3, ythick = 3,xtitle = 'Semi-major Axis (arcseconds)',$
yrange=[1.5,3.0],ystyle = 1, xstyle = 8

axis, 0, 3.0, xaxis=1, xrange=[0,0.301], xstyle = 1, xthick = 3,charthick = 3

;upper = [0.2,0.2,0.2,0.2]
errplot, radarr*0.435, color-minus, color-plus

;fit this with a linear function
err = plus
start = [-0.0025,0.6]
result = MPFITFUN('linear',radarr,color,err, start,perror =test)

oplot, findgen(1200)*0.435, result(0)*findgen(1200) + result(1), thick = 3, linestyle = 2
;oplot, findgen(1200)*0.435, (result(0) -1*test(0))*findgen(1200) + (result(1) - 1*test(1)), linestyle = 2
;oplot, findgen(1200)*0.435, (result(0)+1*test(0) )*findgen(1200) + (result(1) + 1*test(1)), linestyle = 2

out = textoidl('h_{70}^{-1}kpc')


;the red cluster sequence
x= findgen(100) + 210
y = x - (findgen(100)+210) + 2.00
;y2 = x - (findgen(100)+135) + 0.0

oplot, x, y, thick = 3
;oplot, x, y2, thick = 3
xyouts, 210, 1.90, 'RCS', charthick = 3
;xyouts, 230, 0.02, 'Tidal Features', charthick = 3
xyouts, 30,2.8,"A2734", charthick =3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sum = total(color)
av = sum / n_elements(color)

sig2 = sig^2
sumsig = sqrt(total(sig2))

sigav = av*(sqrt(sumsig^2/sum^2))


print, "sum, av, sumsig, sigav", sum, av, sumsig, sigav

device, /close
set_plot, mydevice


END
