PRO predicticl
;device, true=24 
;device, decomposed=0
colors = GetColor(/load, Start=1)
close, /all		;close all files = tidiness

mydevice = !D.NAME
!p.multi = [0, 0, 1]
SET_PLOT, 'ps'

device, filename = '/Users/jkrick/umich/icl/predicticl.color.ps', /portrait, $
  BITS=8, scale_factor=0.9 , /color

out = textoidl('Surface Brightness (mag/arcsec^{-2})')



;_______________________________________
;A3888
;________________________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;r  curve
OPENR, lun,'/Users/jkrick/umich/icl/A3888/iclrtab2', /GET_LUN 

;read in the radial profile
rows= 18-2
rradius2 = FLTARR(rows)
rcounts2 = FLTARR(rows)
rerr2 = FLTARR(rows)
r = 0.0				;radius
c = 0.0				;mean counts
ellerr = 0.0

FOR j=0,rows-1 DO BEGIN
      READF, lun, r,c, ellerr,s
      rradius2(j) = r
      rcounts2(j) = c
      rerr2(j) = ellerr
ENDFOR

close, lun
free_lun, lun

rcounts2 = rcounts2 - 2;[0:j-3] - 2
;rradous2 = rradius2;[0:j-3]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;rradius = rradius*(1/147.)*(1/10.)
;;rradius2 = rradius2*(1/1.47)
;rradius3 = rradius3*(1/147.)*(1/10.)
;rradius4 = rradius4*(1/147.)*(1/10.)


;plot, rradius2,24.6 - 0.628 - 2.5*alog10(rcounts2/(0.259^2)),thick = 3, $
;YRANGE = [30, 25], xrange = [0,0.7],ytitle = out, $;1.034
;psym = 3,xstyle = 1,ystyle = 1,$
;xtitle = 'Semi-major Axis (Mpc)', charthick = 3, xthick = 3, ythick = 3

;print, 24.6 - 0.628 - 2.5*alog10(rcounts2*(1.47^2))

;logplot
plot, rradius2*0.259,24.6 - 0.628 - 2.5*alog10(rcounts2/(0.259^2)),$
 thick = 3,ytitle = out, yrange=[30,24], xrange=[30,400],/xlog,xstyle = 1,$
xtitle = 'Semi-major Axis (arcsec)', charthick = 3, xthick = 3, ythick = 3, color = colors.black

;axis, 0, 25.0, xaxis=1, xrange=[0,0.9], xstyle = 1, xthick =3,charthick = 3  ;A3
;;oplot, rradius2,24.1 - 2.5*alog10(rcounts2/(0.259^2)),thick = 3;, $

;pxval = [rradius2,reverse(rradius4)]
;pyval = [24.15 - 2.5*alog10(rcounts2/(0.259^2)),reverse(24.15 - 2.5*alog10(rcounts4/(0.259^2)))]
;polyfill, pxval,pyval, color = colors.gray
;polyfill, pxval,pyval, color = colors.lightsalmon

;pxval = [rradius2,reverse(rradius)]
;pyval = [24.15 - 2.5*alog10(rcounts2/(0.259^2)),reverse(24.15 - 2.5*alog10(rcounts/(0.259^2)))]
;polyfill, pxval,pyval, color = colors.darkgray
;polyfill, pxval,pyval, color = colors.orangered

;oplot, rradius* 0.259,24.1 - 2.5*alog10(rcounts/(0.259^2)),thick = 3
;oplot, rradius2,24.6 - 0.628 - 2.5*alog10(rcounts2/(0.259^2)),thick = 3
;oplot, rradius3* 0.259,24.1 - 2.5*alog10(rcounts3/(0.259^2)),thick = 5,color = colors.red

;oplot, rradius4* 0.259,24.1 - 2.5*alog10(rcounts4/(0.259^2)),thick = 3

;out = textoidl('h_{70}^{-1}kpc')

;print, "r-3",  rradius2^(-3.)
;;;;;;;;

;lower2 = 24.1 - 2.5*alog10((rcounts2 - rerr2)/(0.259^2))
;upper2 = 24.1 - 2.5*alog10((rcounts2 + rerr2)/(0.259^2)) 
lower2 = 24.6 -0.628 - 2.5*alog10((rcounts2 - 0.00158)/(0.259^2))
upper2 = 24.6 - 0.628 - 2.5*alog10((rcounts2 + 0.00158)/(0.259^2)) 
;lower2 = 24.6 -0.628 - 2.5*alog10((rcounts2 - 0.00158)*(1.47^2))
;upper2 = 24.6 - 0.628 - 2.5*alog10((rcounts2 + 0.00158)*(1.47^2)) 
;use this errplot 
errplot, rradius2*0.259,lower2, upper2, thick = 3

;lower2 = 23.7 - 2.5*alog10((counts2[0:i - 2] - 0.00051)/(0.259^2))
;upper2 = 23.7  - 2.5*alog10((counts2[0:i - 2] + 0.00051)/(0.259^2)) 
;errplot, radius2,lower2, upper2

;lower3 = 24.1 - 2.5*alog10((counts3- Verr3)/(0.259^2))
;upper3 = 24.1 - 2.5*alog10((counts3 + Verr3)/(0.259^2)) 
;errplot, radius3* 0.259,lower3, upper3

start = [0.03,20]
result2 = MPFITFUN('reynolds',rradius2,rcounts2, rerr2, start)    ;ICL
numbers = result2(0) / ((1 + (rradius2/result2(1)))^2)
numbers = 0.01 / ((1 + (rradius2/0.102))^2)

oplot, rradius2*0.259, 8.6 - 0.628 - 2.5*alog10(numbers/(0.259^2)), thick = 5, color = colors.black
;oplot, rradius2, 9.5 - 0.628 - 2.5*alog10(numbers*(1.47^2)), thick = 5, color = colors.black
xyouts, 180,29.7,"NFW", charthick=3

print, 8.6 - 0.628 - 2.5*alog10(numbers/(0.259^2))

xyouts, 75,26.25, "X", charthick=3,color = colors.black
xyouts, 115,26.75, "X", charthick=3,color = colors.black

;for x = 0, 1E5 do print, x

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;_______________________________________
;A3984
;________________________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;r  curve
OPENR, lun,'/Users/jkrick/umich/icl/A3984/iclrtab', /GET_LUN

;read in the radial profile
rows= 17  - 3
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;rradius = rradius*(1/126.)*(1/10.)
;;rradius = rradius*(1/1.26)
;rradius2 = rradius2*(1/126.)*(1/10.)
;rradius3 = rradius3*(1/126.)*(1/10.)
;rradius4 = rradius4*(1/126.)*(1/10.)


out = textoidl('Surface Brightness (mag/kpc^{-2})')

;;oplot, rradius,24.6 - 0.723 - 2.5*alog10(rcounts*(1.26^2)),thick = 3, color = colors.red
oplot, rradius*0.259,24.6 - 0.723 - 2.5*alog10(rcounts/(0.259^2)),thick = 3, color = colors.red

xyouts, 32.2, 27.4, "A4059", color = colors.violet, charthick=3
xyouts, 32.2, 27.7, "A3880", color = colors.forestgreen, charthick=3
xyouts, 32.2, 28.0, "A2734", color = colors.cyan, charthick=3
xyouts, 32.2, 28.3, "A2556", color = colors.blue, charthick = 3
xyouts, 32.2, 28.6, "A4010", color = colors.orange, charthick = 3
xyouts, 32.2, 28.9, "A3888", color = colors.black, charthick = 3
xyouts, 32.2, 29.2, "A3984", color = colors.red, charthick = 3
xyouts, 32.2, 29.5, "AC114", color = colors.green, charthick = 3

;xyouts, 110, 27.4, "A4059", color = colors.violet, charthick=3
;xyouts, 110, 27.7, "A3880", color = colors.forestgreen, charthick=3
;xyouts, 110, 28.0, "A2734", color = colors.cyan, charthick=3
;xyouts, 110, 28.3, "A2556", color = colors.blue, charthick = 3
;xyouts, 110, 28.6, "A4010", color = colors.orange, charthick = 3
;xyouts, 110, 28.9, "A3888", color = colors.black, charthick = 3
;xyouts, 110, 29.2, "A3984", color = colors.red, charthick = 3
;xyouts, 110, 29.5, "AC114", color = colors.green, charthick = 3


xyouts, 65, 26.25, "X", charthick=3, color = colors.red
xyouts, 100, 27.15, "X", charthick=3, color = colors.red
;pxval = [rradius,reverse(rradius1)]
;pyval = [24.09 - 2.5*alog10(rcounts/(0.259^2)),reverse(23.95 - 2.5*alog10(rcounts1/(0.259^2)))]
;;polyfill, pxval,pyval, color = colors.lightsalmon

;pxval = [rradius,reverse(rradius3)]
;pyval = [24.09 - 2.5*alog10(rcounts/(0.259^2)),reverse(23.95 - 2.5*alog10(rcounts3/(0.259^2)))]
;;polyfill, pxval,pyval, color = colors.indianred

;oplot, rradius,24.6 - 0.723 - 2.5*alog10(rcounts/(0.259^2)),thick = 3, color = colors.red

;lower2 = 24.09 - 2.5*alog10((rcounts - 0.00123)/(0.259^2))
;upper2 = 24.09 - 2.5*alog10((rcounts + 0.00123)/(0.259^2)) 
;errplot, rradius,lower2, upper2

;xarrjunk = fltarr(10)+202
;yarrjunk = findgen(10) + 28.2;29.8
;oplot, xarrjunk, yarrjunk


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;_______________________________________
;A114
;________________________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

OPENR, lun,'/Users/jkrick/umich/icl/A114/iclrtab', /GET_LUN

;read in the radial profile
rows= 7
radius = FLTARR(rows)
counts = FLTARR(rows)
Verr = FLTARR(rows)
stop = FLTARR(rows)
r = 0.0				;radius
c = 0.0				;mean counts
ellerr = 0.0
s = 0
FOR j=0,rows-1 DO BEGIN
      READF, lun, r,c, ellerr,s
      radius(j) = r
      counts(j) = c
      Verr(j) = ellerr 
      stop(j) = s
ENDFOR

close, lun
free_lun, lun

counts = counts[0:j-1]    ;get rid of the points which have bad stop codes
radius = radius[0:j-1]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;
;radius = radius*(1/85.)*(1/10.)
;;radius = radius*(1/0.85)
;radius2 = radius2*(1/85.)*(1/10.)
;radius3 = radius3*(1/85.)*(1/10.)
;radius4 = radius4*(1/85.)*(1/10.)

;pxval = [radius* 0.259,reverse(radius3* 0.259)]
;pyval = [24.6 - 2.5*alog10(counts/(0.259^2)),reverse(24.6 - 2.5*alog10(counts3/(0.259^2)))]

;;polyfill, pxval,pyval, color = colors.salmon
;polyfill, pxval,pyval, /line_fill, orientation = 45

;pxval = [radius* 0.259,reverse(radius2* 0.259)]
;pyval = [24.6 - 2.5*alog10(counts/(0.259^2)),reverse(24.6 - 2.5*alog10(counts2/(0.259^2)))]
;;
;;polyfill, pxval,pyval, color = colors.firebrick
;polyfill, pxval,pyval, color = colors.white, /line_fill, orientation = 45

oplot, radius*0.259, 24.6 - 1.125 - 2.5*alog10(counts/(0.259^2)),thick = 3, color = colors.green;
;oplot, radius, 24.6 - 1.125 - 2.5*alog10(counts*(0.85^2)),thick = 3, color = colors.green;

;lower2 = 23.83 - 2.5*alog10((counts - 0.000555)/(0.259^2))
;upper2 = 23.83 - 2.5*alog10((counts + 0.000555)/(0.259^2)) 
;errplot, radius,lower2, upper2


xyouts, 42, 25.95, "X", charthick=3, color = colors.green
xyouts, 65, 26.65, "X", charthick=3, color = colors.green

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;_______________________________________
;A2556
;________________________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OPENR, lun,'/Users/jkrick/umich/icl/A2556/icl2rtab', /GET_LUN

;read in the radial profile
rows= 15-3
radius = FLTARR(rows)
counts = FLTARR(rows)
Verr = FLTARR(rows)
stop = FLTARR(rows)
r = 0.0				;radius
c = 0.0				;mean counts
ellerr = 0.0
s = 0
FOR j=0,rows-1 DO BEGIN
      READF, lun, r,c, ellerr,s
      radius(j) = r
      counts(j) = c
      Verr(j) = ellerr 
      stop(j) = s
ENDFOR

close, lun
free_lun, lun

counts = counts[0:j-1]    ;get rid of the points which have bad stop codes
radius = radius[0:j-1]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;lower limit, 30% larger galaxy masks


;radius = radius*(1/141.)*(1/10.)
;;radius = radius*(1/1.41)


oplot, radius*0.435,22.04 - 0.38 - 2.5*alog10(counts/(0.435^2)),thick = 3, color = colors.blue;
;oplot, radius,22.04 - 0.38 - 2.5*alog10(counts*(1.41^2)),thick = 3, color = colors.blue;
;;;;;;;;
;error bars
;;;;;;;;

;lower2 = fltarr(n_elements(counts))
;FOR counter = 0, n_elements(counts) - 1, 1 DO BEGIN
;    IF (counts(counter) - .001047 LE 0. )THEN BEGIN
;        lower2(counter) = 35.
;    ENDIF ELSE BEGIN
;        lower2(counter) = 21.77 - 2.5*alog10((counts(counter) - .00104)/(0.435^2))
;    ENDELSE
;ENDFOR;

;upper2 = 21.77 - 2.5*alog10((counts + .00104)/(0.435^2)) 
;errplot, radius,lower2, upper2

xyouts, 120, 27.05, "X", charthick=3, color = colors.blue
xyouts, 182, 27.5, "X", charthick=3, color = colors.blue

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OPENR, lun,'/Users/jkrick/umich/icl/A2556/iclBtab', /GET_LUN

;read in the radial profile
rows= 14
radiusB = FLTARR(rows)
countsB = FLTARR(rows)
VerrB = FLTARR(rows)
stopB = FLTARR(rows)
r = 0.0				;radius
c = 0.0				;mean counts
ellerr = 0.0
s = 0
FOR j=0,rows-1 DO BEGIN
      READF, lun, r,c, ellerr,s
      radiusB(j) = r
      countsB(j) = c
      VerrB(j) = ellerr 
      stopB(j) = s
ENDFOR

close, lun
free_lun, lun

countsB = countsB[0:j-1]    ;get rid of the points which have bad stop codes
radiusB = radiusB[0:j-1]
radiusB = radiusB*(1/141.)*(1/10.)

;;oplot, radiusB,21.82 - 2.5*alog10(countsB/(0.435^2)),thick = 3, color = colors.blue;


;;;;;;;;
;error bars
;;;;;;;;

lower2 = fltarr(n_elements(countsB))
FOR counter = 0, n_elements(countsB) - 1, 1 DO BEGIN
    IF (countsB(counter) - .000247 LE 0. )THEN BEGIN
        lower2(counter) = 35.
    ENDIF ELSE BEGIN
        lower2(counter) = 21.82 - 2.5*alog10((countsB(counter) - .000247)/(0.435^2))
    ENDELSE
ENDFOR

upper2 = 21.82 - 2.5*alog10((countsB + .000247)/(0.435^2)) 
;;errplot, radiusB,lower2, upper2


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;_______________________________________
;A4010
;________________________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OPENR, lun,'/Users/jkrick/umich/icl/A4010/iclrtab', /GET_LUN

;read in the radial profile
rows= 34 - 6
radius = FLTARR(rows)
counts = FLTARR(rows)
Verr = FLTARR(rows)
stop = FLTARR(rows)
r = 0.0				;radius
c = 0.0				;mean counts
ellerr = 0.0
s = 0
FOR j=0,rows-1 DO BEGIN
      READF, lun, r,c, ellerr,s
      radius(j) = r
      counts(j) = c
      Verr(j) = ellerr 
      stop(j) = s
ENDFOR

close, lun
free_lun, lun

counts = counts[0:j-1]    ;get rid of the points which have bad stop codes
radius = radius[0:j-1]

;radius = radius*(1/129.)*(1/10.)
;;radius = radius*(1/1.29)

oplot, radius*0.435,22.04 - 0.416 - 2.5*alog10(counts/(0.435^2)),thick = 3, color = colors.orange;
;;;;;;;;
;error bars
;;;;;;;;
lower2 = fltarr(n_elements(counts))
FOR counter = 0, n_elements(counts) - 1, 1 DO BEGIN
    IF (counts(counter) - .001047 LE 0. )THEN BEGIN
        lower2(counter) = 35.
    ENDIF ELSE BEGIN
        lower2(counter) = 21.74 - 2.5*alog10((counts(counter) - .00104)/(0.435^2))
    ENDELSE
ENDFOR

upper2 = 21.74 - 2.5*alog10((counts + .00104)/(0.435^2)) 
;errplot, radius,lower2, upper2



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OPENR, lun,'/Users/jkrick/umich/icl/A4010/iclBtab', /GET_LUN

;read in the radial profile
rows= 24 
radiusB = FLTARR(rows)
countsB = FLTARR(rows)
VerrB = FLTARR(rows)
stopB = FLTARR(rows)
r = 0.0				;radius
c = 0.0				;mean counts
ellerr = 0.0
s = 0
FOR j=0,rows-1 DO BEGIN
      READF, lun, r,c, ellerr,s
      radiusB(j) = r
      countsB(j) = c
      VerrB(j) = ellerr 
      stopB(j) = s
ENDFOR

close, lun
free_lun, lun

countsB = countsB[0:j-1]    ;get rid of the points which have bad stop codes
radiusB = radiusB[0:j-1]
radiusB = radiusB*(1/129.)*(1/10.)

;;oplot, radiusB,21.73 - 2.5*alog10(countsB/(0.435^2)),thick = 3, color = colors.orange;

;;;;;;;;
;error bars
;;;;;;;;

lower2 = fltarr(n_elements(countsB))
FOR counter = 0, n_elements(countsB) - 1, 1 DO BEGIN
    IF (countsB(counter) - .000247 LE 0. )THEN BEGIN
        lower2(counter) = 35.
    ENDIF ELSE BEGIN
        lower2(counter) = 21.73 - 2.5*alog10((countsB(counter) - .000247)/(0.435^2))
    ENDELSE
ENDFOR

upper2 = 21.73 - 2.5*alog10((countsB + .000247)/(0.435^2)) 
;;errplot, radiusB,lower2, upper2

xyouts, 110, 25.55, "X", charthick=3, color = colors.orange
xyouts, 165, 26.45, "X", charthick=3, color = colors.orange

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;_______________________________________
;A2734
;________________________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OPENR, lun,'/Users/jkrick/umich/icl/A2734/icl2rtab', /GET_LUN

;read in the radial profile
rows= 17 -2
radius = FLTARR(rows)
counts = FLTARR(rows)
Verr = FLTARR(rows)
stop = FLTARR(rows)
r = 0.0				;radius
c = 0.0				;mean counts
ellerr = 0.0
s = 0
FOR j=0,rows-1 DO BEGIN
      READF, lun, r,c, ellerr,s
      radius(j) = r
      counts(j) = c
      Verr(j) = ellerr 
      stop(j) = s
ENDFOR

close, lun
free_lun, lun

counts = counts[0:j-1]    ;get rid of the points which have bad stop codes
radius = radius[0:j-1]

;radius = radius*(1/191.)*(1/10.)
;;radius = radius*(1/1.91)

oplot, radius*.435,22.04 - 0.270 - 2.5*alog10(counts/(0.435^2)),thick = 3, color = colors.cyan;
;oplot, radius,22.04 - 0.270 - 2.5*alog10(counts*(1.91^2)),thick = 3, color = colors.cyan;
;;;;;;;;
;error bars
;;;;;;;;
lower2 = fltarr(n_elements(counts))
FOR counter = 0, n_elements(counts) - 1, 1 DO BEGIN
    IF (counts(counter) - .000399 LE 0. )THEN BEGIN
        lower2(counter) = 35.
    ENDIF ELSE BEGIN
        lower2(counter) = 21.85 - 2.5*alog10((counts(counter) - .000399)/(0.435^2))
    ENDELSE
ENDFOR

upper2 = 21.85 - 2.5*alog10((counts + .000399)/(0.435^2)) 
;errplot, radius,lower2, upper2



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OPENR, lun,'/Users/jkrick/umich/icl/A2734/icl2Btab', /GET_LUN

;read in the radial profile
rows= 12 -2
radiusB = FLTARR(rows)
countsB = FLTARR(rows)
VerrB = FLTARR(rows)
stopB = FLTARR(rows)
r = 0.0				;radius
c = 0.0				;mean counts
ellerr = 0.0
s = 0
FOR j=0,rows-1 DO BEGIN
      READF, lun, r,c, ellerr,s
      radiusB(j) = r
      countsB(j) = c
      VerrB(j) = ellerr 
      stopB(j) = s
ENDFOR

close, lun
free_lun, lun

countsB = countsB[0:j-1]    ;get rid of the points which have bad stop codes
radiusB = radiusB[0:j-1]
;;radiusB = radiusB*(1/191.)*(1/10.)

;;oplot, radiusB,22.19 - 2.5*alog10(countsB/(0.435^2)),thick = 3, color = colors.cyan;

;;;;;;;;
;error bars
;;;;;;;;

lower2 = fltarr(n_elements(countsB))
FOR counter = 0, n_elements(countsB) - 1, 1 DO BEGIN
    IF (countsB(counter) - .00028 LE 0. )THEN BEGIN
        lower2(counter) = 35.
    ENDIF ELSE BEGIN
        lower2(counter) = 22.19 - 2.5*alog10((countsB(counter) - .00028)/(0.435^2))
    ENDELSE
ENDFOR

upper2 = 22.19 - 2.5*alog10((countsB + .00028)/(0.435^2)) 
;;errplot, radiusB,lower2, upper2
xyouts, 165, 26.4, "X", charthick=3, color = colors.cyan
xyouts, 250, 28.70, "X", charthick=3, color = colors.cyan

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;_______________________________________
;A4059
;________________________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OPENR, lun,'/Users/jkrick/umich/icl/A4059/icl2rtab', /GET_LUN

;read in the radial profile
rows= 20
radius = FLTARR(rows)
counts = FLTARR(rows)
Verr = FLTARR(rows)
stop = FLTARR(rows)
r = 0.0				;radius
c = 0.0				;mean counts
ellerr = 0.0
s = 0
FOR j=0,rows-1 DO BEGIN
      READF, lun, r,c, ellerr,s
      radius(j) = r
      counts(j) = c
      Verr(j) = ellerr 
      stop(j) = s
ENDFOR

close, lun
free_lun, lun

counts = counts[0:j-1]    ;get rid of the points which have bad stop codes
radius = radius[0:j-1]

;radius = radius*(1/244.)*(1/10.)
;;radius = radius*(1/2.44)

oplot, radius*0.435,22.04 - 0.206 - 2.5*alog10(counts/(0.435^2)),thick = 3, color = colors.violet;
;oplot, radius,22.04 - 0.206 - 2.5*alog10(counts*(2.44^2)),thick = 3, color = colors.violet;
;;;;;;;;
;error bars
;;;;;;;;
lower2 = fltarr(n_elements(counts))
FOR counter = 0, n_elements(counts) - 1, 1 DO BEGIN
    IF (counts(counter) - .00098 LE 0. )THEN BEGIN
        lower2(counter) = 35.
    ENDIF ELSE BEGIN
        lower2(counter) = 21.89 - 2.5*alog10((counts(counter) - .00098)/(0.435^2))
    ENDELSE
ENDFOR

upper2 = 21.89 - 2.5*alog10((counts + .00098)/(0.435^2)) 
;errplot, radius,lower2, upper2



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OPENR, lun,'/Users/jkrick/umich/icl/A4059/icl2Btab', /GET_LUN

;read in the radial profile
rows= 20 - 2
radiusB = FLTARR(rows)
countsB = FLTARR(rows)
VerrB = FLTARR(rows)
stopB = FLTARR(rows)
r = 0.0				;radius
c = 0.0				;mean counts
ellerr = 0.0
s = 0
FOR j=0,rows-1 DO BEGIN
      READF, lun, r,c, ellerr,s
      radiusB(j) = r
      countsB(j) = c
      VerrB(j) = ellerr 
      stopB(j) = s
ENDFOR

close, lun
free_lun, lun

countsB = countsB[0:j-1]    ;get rid of the points which have bad stop codes
radiusB = radiusB[0:j-1]
;;radiusB = radiusB*(1/244.)*(1/10.)

;;oplot, radiusB,22.19 - 2.5*alog10(countsB/(0.435^2)),thick = 3, color = colors.violet;

;;;;;;;;
;error bars
;;;;;;;;

lower2 = fltarr(n_elements(countsB))
FOR counter = 0, n_elements(countsB) - 1, 1 DO BEGIN
    IF (countsB(counter) - .00015 LE 0. )THEN BEGIN
        lower2(counter) = 35.
    ENDIF ELSE BEGIN
        lower2(counter) = 22.19 - 2.5*alog10((countsB(counter) - .00015)/(0.435^2))
    ENDELSE
ENDFOR

upper2 = 22.19 - 2.5*alog10((countsB + .00015)/(0.435^2)) 
;;errplot, radiusB,lower2, upper2

xyouts, 210, 25.95, "X", charthick=3, color = colors.violet
xyouts, 318, 28.1, "X", charthick=3, color = colors.violet

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;_______________________________________
;A3880
;________________________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OPENR, lun,'/Users/jkrick/umich/icl/A3880/icl2rtab', /GET_LUN

;read in the radial profile
rows= 17-2
radius = FLTARR(rows)
counts = FLTARR(rows)
Verr = FLTARR(rows)
stop = FLTARR(rows)
r = 0.0				;radius
c = 0.0				;mean counts
ellerr = 0.0
s = 0
FOR j=0,rows-1 DO BEGIN
      READF, lun, r,c, ellerr,s
      radius(j) = r
      counts(j) = c
      Verr(j) = ellerr 
      stop(j) = s
ENDFOR

close, lun
free_lun, lun

counts = counts[0:j-1]    ;get rid of the points which have bad stop codes
radius = radius[0:j-1]

;radius = radius*(1/204.)*(1/10.)
;;radius = radius*(1/2.04)

oplot, radius*0.435,22.04 - 0.252 - 2.5*alog10(counts/(0.435^2)),thick = 3, color = colors.forestgreen;
;oplot, radius,22.04 - 0.252 - 2.5*alog10(counts*(2.04^2)),thick = 3, color = colors.forestgreen;
;;;;;;;;
;error bars
;;;;;;;;
lower2 = fltarr(n_elements(counts))
FOR counter = 0, n_elements(counts) - 1, 1 DO BEGIN
    IF (counts(counter) - .00081 LE 0. )THEN BEGIN
        lower2(counter) = 35.
    ENDIF ELSE BEGIN
        lower2(counter) = 21.86 - 2.5*alog10((counts(counter) - .00081)/(0.435^2))
    ENDELSE
ENDFOR

upper2 = 21.86 - 2.5*alog10((counts + .00081)/(0.435^2)) 
;errplot, radius,lower2, upper2



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OPENR, lun,'/Users/jkrick/umich/icl/A3880/icl2Btab', /GET_LUN

;read in the radial profile
rows= 10
radiusB = FLTARR(rows)
countsB = FLTARR(rows)
VerrB = FLTARR(rows)
stopB = FLTARR(rows)
r = 0.0				;radius
c = 0.0				;mean counts
ellerr = 0.0
s = 0
FOR j=0,rows-1 DO BEGIN
      READF, lun, r,c, ellerr,s
      radiusB(j) = r
      countsB(j) = c
      VerrB(j) = ellerr 
      stopB(j) = s
ENDFOR

close, lun
free_lun, lun

countsB = countsB[0:j-1]    ;get rid of the points which have bad stop codes
radiusB = radiusB[0:j-1]
;;radiusB = radiusB*(1/204.)*(1/10.)

;;oplot, radiusB,22.19 - 2.5*alog10(countsB/(0.435^2)),thick = 3, color = colors.violet;

;;;;;;;;
;error bars
;;;;;;;;

lower2 = fltarr(n_elements(countsB))
FOR counter = 0, n_elements(countsB) - 1, 1 DO BEGIN
    IF (countsB(counter) - .00029 LE 0. )THEN BEGIN
        lower2(counter) = 35.
    ENDIF ELSE BEGIN
        lower2(counter) = 22.19 - 2.5*alog10((countsB(counter) - .00029)/(0.435^2))
    ENDELSE
ENDFOR

upper2 = 22.19 - 2.5*alog10((countsB + .00029)/(0.435^2)) 
;;errplot, radiusB,lower2, upper2

xyouts, 175, 26.5, "X", charthick=3, color = colors.forestgreen
xyouts, 265, 27.1, "X", charthick=3, color = colors.forestgreen


device, /close
set_plot, mydevice

END

;OPENR, lun,'/n/Godiva1/jkrick/A3888/final/iclVtab', /GET_LUN
;
;;read in the radial profile
;rows= 20-2
;radius = FLTARR(rows)
;counts = FLTARR(rows)
;Verr = FLTARR(rows)
;stop = FLTARR(rows)
;r = 0.0				;radius
;c = 0.0				;mean counts
;ellerr = 0.0
;s = 0
;FOR j=0,rows-1 DO BEGIN
;      READF, lun, r,c, ellerr,s
;      radius(j) = r
;      counts(j) = c
;      Verr(j) = ellerr 
;      stop(j) = s
;ENDFOR
;
;close, lun
;free_lun, lun
;
;counts = counts[0:j-1] - 2    
;radius = radius[0:j-1]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;OPENR, lun,'/n/Godiva1/jkrick/A3888/final/iclVtab2', /GET_LUN  
;;read in the radial profile
;rows=21-1
;radius2 = FLTARR(rows)
;counts2 = FLTARR(rows)
;Verr2 = FLTARR(rows)
;stop2 = FLTARR(rows)
;r = 0.0				;radius
;c = 0.0				;mean counts
;ellerr = 0.0
;s = 0
;i = 0
;FOR j=0,rows-1 DO BEGIN
;      READF, lun, r,c, ellerr,s
;      IF c GT 2.0 THEN BEGIN
;          radius2(i) = r
;          counts2(i) = c
;          Verr2(i) = ellerr 
;          stop2(i) = s
;          i = i +1
;      ENDIF
;ENDFOR
;
;close, lun
;free_lun, lun
;
;counts2 = counts2[0:i - 2] -  2
;radius2 = radius2[0:i-2]
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;OPENR, lun,'/n/Godiva1/jkrick/A3888/final/iclVtab3', /GET_LUN
;
;;read in the radial profile
;rows= 19-1
;radius4 = FLTARR(rows)
;counts4 = FLTARR(rows)
;Verr4 = FLTARR(rows)
;stop4 = FLTARR(rows)
;r = 0.0				;radius
;c = 0.0				;mean counts
;ellerr = 0.0
;s = 0
;l = 0
;FOR j=0,rows-1 DO BEGIN
;      READF, lun, r,c, ellerr,s
;      IF c GT 2.0 THEN BEGIN
;          radius4(l) = r
;          counts4(l) = c
;          Verr4(l) = ellerr 
;          stop4(l) = s
;          l = l +1
;      ENDIF
;ENDFOR
;
;close, lun
;free_lun, lun
;
;counts4 = counts4[0:l - 2] -  2
;radius4 = radius4[0:l-2]
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ellipse2 fits applied to
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;unmasked image
;
;OPENR, lun,'/n/Godiva1/jkrick/A3888/final/galVtab2', /GET_LUN  ;galVtab2
;;
;rows= 21-1
;radius3 = FLTARR(rows)
;counts3 = FLTARR(rows)
;Verr3 = FLTARR(rows)
;stop3 = FLTARR(rows)
;r = 0.0				;radius
;c = 0.0				;mean counts
;ellerr = 0.0
;s = 0
;FOR j=0,rows-1 DO BEGIN
;      READF, lun, r,c, ellerr,s
;      radius3(j) = r
;      counts3(j) = c
;      Verr3(j) = ellerr 
;      stop3(j) = s
;ENDFOR
;
;close, lun
;free_lun, lun
;
;counts3 = counts3[0:j - 2] - 2
;radius3 = radius3[0:j-2]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;radius = radius*(1/147.)*(1/10.)
;radius2 = radius2*(1/147.)*(1/10.)
;radius3 = radius3*(1/147.)*(1/10.)
;radius4 = radius4*(1/147.)*(1/10.)
;
;print, radius2
;print, 23.7 - 2.5*alog10(counts2[2:i-2]/(0.259^2))
;
;out = textoidl('Surface Brightness (mag/arcsec^{-2})')
;;plot, radius2[2:i-2],23.7 - 2.5*alog10(counts2[2:i-2]/(0.259^2)),thick = 3, $
;;YRANGE = [30, 25], xrange = [0,0.9],ytitle = out, $;1.034
;;psym = 3,xstyle = 1,ystyle = 1,$
;;xtitle = 'Semi-major Axis (Mpc)', charthick = 3, xthick = 3, ythick = 3
;
;;axis, 0, 25.0, xaxis=1, xrange=[0,0.9], xstyle = 1, xthick =3,charthick = 3  ;A3888
;;axis, 0, 31.0, xaxis=0, xrange=[0,1.034], xstyle = 1, xthick =3,charthick = 3 ,$
;;      xtitle = 'Semi-major Axis (arcseconds)' ;A3888
;;axis, 0, 23.0, xaxis=1, xrange=[0,1.681], xstyle = 1, xthick =3,charthick = 3  ;A141

;;;;;;
;pxval = [radius2[0:i - 2],reverse(radius4[0:l-2])]
;pyval = [23.7 - 2.5*alog10(counts2[0:i - 2]/(0.259^2)),reverse(23.7 - 2.5*alog10(counts4[0:l-2]/(0.259^2)))]
;polyfill, pxval,pyval, color = colors.aquamarine ;lightgray
;polyfill, pxval,pyval, /line_fill, orientation = 45

;pxval = [radius2[0:i - 2],reverse(radius)]
;pyval = [23.7 - 2.5*alog10(counts2[0:i - 2]/(0.259^2)),reverse(23.7 - 2.5*alog10(counts/(0.259^2)))]
;;polyfill, pxval,pyval, color = colors.darkgray
;;polyfill, pxval,pyval, color = colors.white, /line_fill, orientation = 45
;;polyfill, pxval,pyval, color = colors.seagreen
;
;
;;;;;;;;
;;;oplot, radius2[0:i-2],23.7 - 2.5*alog10(counts2[0:i-2]/(0.259^2)),thick = 3;,linestyle = 2
;;oplot, radius3* 0.259,23.7 - 2.5*alog10(counts3/(0.259^2)),thick = 5, linestyle = 2, color = colors.seagreen
;
;;oplot, radius4* 0.259,23.7 - 2.5*alog10(counts4/(0.259^2)),thick = 3
;
;;;;;;;;;
;
;;lower2 = 23.7 - 2.5*alog10((counts2[0:i - 2] - Verr2[0:i - 2])/(0.259^2))
;;upper2 = 23.7 - 2.5*alog10((counts2[0:i - 2] + Verr2[0:i - 2])/(0.259^2)) 
;lower2 = 23.7 - 2.5*alog10((counts2 - 0.00051)/(0.259^2))
;upper2 = 23.7 - 2.5*alog10((counts2 + 0.00051)/(0.259^2)) 
;;;errplot, radius2,lower2, upper2
;;print, counts2
;;print, lower2
;;print, upper2
;;lower3 = 23.7 - 2.5*alog10((counts3- Verr3)/(0.259^2))
;;upper3 = 23.7 - 2.5*alog10((counts3 + Verr3)/(0.259^2)) 
;;errplot, radius3* 0.259,lower3, upper3
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;r  curve
;OPENR, lun,'/n/Godiva1/jkrick/A3888/final/iclrtab', /GET_LUN
;
;;read in the radial profile
;rows= 19-2
;rradius = FLTARR(rows)
;rcounts = FLTARR(rows)
;rerr = FLTARR(rows)
;r = 0.0				;radius
;c = 0.0				;mean counts
;ellerr = 0.0
;
;FOR j=0,rows-1 DO BEGIN
;      READF, lun, r,c, ellerr,s
;      rradius(j) = r
;      rcounts(j) = c
;      rerr(j) = ellerr
;ENDFOR
;
;close, lun
;free_lun, lun


;rcounts = rcounts - 2;[0:j-5] - 2
;rradius = rradius;[0:j-5]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;r  curve
;OPENR, lun,'/n/Godiva1/jkrick/A3888/final/galrtab2', /GET_LUN
;
;;read in the radial profile
;rows= 18-2
;rradius3 = FLTARR(rows)
;rcounts3 = FLTARR(rows)
;rerr3 = FLTARR(rows)
;r = 0.0				;radius
;c = 0.0				;mean counts
;ellerr = 0.0
;
;FOR j=0,rows-1 DO BEGIN
;      READF, lun, r,c, ellerr,s
;      rradius3(j) = r
;      rcounts3(j) = c
;      rerr3(j) = ellerr
;ENDFOR
;
;close, lun
;free_lun, lun
;
;rcounts3 = rcounts3 -2;[0:j-3] - 2
;rradius3 = rradius3;[0:j-3]
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;OPENR, lun,'/n/Godiva1/jkrick/A3888/final/iclrtab3', /GET_LUN  ;4
;
;;read in the radial profile
;rows= 19-2
;rradius4 = FLTARR(rows)
;rcounts4 = FLTARR(rows)
;rerr4 = FLTARR(rows)
;r = 0.0				;radius
;c = 0.0				;mean counts
;ellerr = 0.0
;
;FOR j=0,rows-1 DO BEGIN
;      READF, lun, r,c, ellerr,s
;      rradius4(j) = r
;      rcounts4(j) = c
;      rerr4(j) = ellerr
;ENDFOR
;
;close, lun
;free_lun, lun
;
;rcounts4 = rcounts4 -2;[0:j-6] - 2
;rradius4 = rradius4;[0:j-6]
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;########################################################################3

;OPENR, lun,'/n/Godiva4/jkrick/A3984/iclVtab', /GET_LUN
;
;;read in the radial profile
;rows= 18
;radius = FLTARR(rows)
;counts = FLTARR(rows)
;Verr = FLTARR(rows)
;stop = FLTARR(rows)
;r = 0.0				;radius
;c = 0.0				;mean counts
;ellerr = 0.0
;s = 0
;FOR j=0,rows-1 DO BEGIN
;      READF, lun, r,c, ellerr,s
;      radius(j) = r
;      counts(j) = c
;      Verr(j) = ellerr 
;      stop(j) = s
;ENDFOR
;
;close, lun
;free_lun, lun
;
;counts = counts[0:j-1] ;- 2    
;radius = radius[0:j-1]
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;OPENR, lun,'/n/Godiva4/jkrick/A3984/iclVtab3', /GET_LUN
;
;;read in the radial profile
;rows= 16-2
;radius3 = FLTARR(rows)
;counts3 = FLTARR(rows)
;Verr3 = FLTARR(rows)
;stop = FLTARR(rows)
;r = 0.0				;radius
;c = 0.0				;mean counts
;ellerr = 0.0
;s = 0
;FOR j=0,rows-1 DO BEGIN
;      READF, lun, r,c, ellerr,s
;      radius3(j) = r
;      counts3(j) = c
;      Verr3(j) = ellerr 
;      stop(j) = s
;ENDFOR
;
;close, lun
;free_lun, lun
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;OPENR, lun,'/n/Godiva4/jkrick/A3984/iclVtab1', /GET_LUN
;
;;read in the radial profile
;rows= 16 
;radius1 = FLTARR(rows)
;counts1 = FLTARR(rows)
;Verr1 = FLTARR(rows)
;stop = FLTARR(rows)
;r = 0.0				;radius
;c = 0.0				;mean counts
;ellerr = 0.0
;s = 0
;FOR j=0,rows-1 DO BEGIN
;      READF, lun, r,c, ellerr,s
;      radius1(j) = r
;      counts1(j) = c
;      Verr1(j) = ellerr 
;      stop(j) = s
;ENDFOR
;
;close, lun
;free_lun, lun
;
;
;
;radius = radius*(1/126.)*(1/10.)
;radius2 = radius2*(1/126.)*(1/10.)
;radius3 = radius3*(1/126.)*(1/10.)
;radius4 = radius4*(1/126.)*(1/10.)
;
;pxval = [radius,reverse(radius1)]
;pyval = [23.52 - 2.5*alog10(counts/(0.259^2)),reverse(23.52 - 2.5*alog10(counts1/(0.259^2)))]
;;;polyfill, pxval,pyval, color = colors.palegreen
;
;pxval = [radius,reverse(radius3)]
;pyval = [23.52 - 2.5*alog10(counts/(0.259^2)),reverse(23.52 - 2.5*alog10(counts3/(0.259^2)))]
;;;polyfill, pxval,pyval, color = colors.forestgreen
;
;;;oplot, radius,23.52 - 2.5*alog10(counts/(0.259^2)),$
;;;  thick = 3, color = colors.red
;
;lower2 = 23.52 - 2.5*alog10((counts - 0.000555)/(0.259^2))
;upper2 = 23.52 - 2.5*alog10((counts + 0.000555)/(0.259^2)) 
;;;errplot, radius,lower2, upper2
;
;;re-plot r-error bars so they are on top of V shading
;lower2 = 23.95 - 2.5*alog10((rcounts - 0.00123)/(0.259^2))
;upper2 = 23.95 - 2.5*alog10((rcounts + 0.00123)/(0.259^2)) 
;;errplot, rradius,lower2, upper2
;
;;oplot, radius4* 0.259,23.52 - 2.5*alog10(counts4/(0.259^2)),$
;;  thick = 3, color = colors.green  



;OPENR, lun,'/n/Godiva7/jkrick/A114/iclr2tab', /GET_LUN
;
;;read in the radial profile
;rows= 13
;radius2 = FLTARR(rows)
;counts2 = FLTARR(rows)
;Verr = FLTARR(rows)
;stop = FLTARR(rows)
;r = 0.0				;radius
;c = 0.0				;mean counts
;ellerr = 0.0
;s = 0
;FOR j=0,rows-1 DO BEGIN
;      READF, lun, r,c, ellerr,s
;      radius2(j) = r
;      counts2(j) = c
;      Verr(j) = ellerr 
;      stop(j) = s
;ENDFOR
;
;close, lun
;free_lun, lun
;
;counts2 = counts2[0:j-1]    ;get rid of the points which have bad stop codes
;radius2 = radius2[0:j-1]

;;oplot, radius2* 0.259,24.6 - 2.5*alog10(counts2/(0.259^2)),thick = 3, color = colors.red;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;OPENR, lun,'/n/Godiva7/jkrick/A114/iclr3tab', /GET_LUN
;
;;read in the radial profile
;rows= 17 - 9
;radius3 = FLTARR(rows)
;counts3 = FLTARR(rows)
;Verr = FLTARR(rows)
;stop = FLTARR(rows)
;r = 0.0				;radius
;c = 0.0				;mean counts
;ellerr = 0.0
;s = 0
;FOR j=0,rows-1 DO BEGIN
;      READF, lun, r,c, ellerr,s
;      radius3(j) = r
;      counts3(j) = c
;      Verr(j) = ellerr 
;      stop(j) = s
;ENDFOR
;
;close, lun
;free_lun, lun
;
;counts3 = counts3[0:j-1]    ;get rid of the points which have bad stop codes
;radius3 = radius3[0:j-1]

;;oplot, radius3* 0.259,24.6 - 2.5*alog10(counts3/(0.259^2)),thick = 3, color = colors.salmon;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;OPENR, lun,'/n/Godiva7/jkrick/A114/iclVtab', /GET_LUN
;
;;read in the radial profile
;rows= 12
;Vradius = FLTARR(rows)
;Vcounts = FLTARR(rows)
;Verr = FLTARR(rows)
;stop = FLTARR(rows)
;r = 0.0				;radius
;c = 0.0				;mean counts
;ellerr = 0.0
;s = 0
;FOR j=0,rows-1 DO BEGIN
;      READF, lun, r,c, ellerr,s
;      Vradius(j) = r
;      Vcounts(j) = c
;      Verr(j) = ellerr 
;      stop(j) = s
;ENDFOR
;
;close, lun
;free_lun, lun
;
;Vcounts = Vcounts[0:j-1]    ;get rid of the points which have bad stop codes
;Vradius = Vradius[0:j-1]
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Vradius = Vradius*(1/85.)*(1/10.)

;;oplot, Vradius,22.52 - 2.5*alog10(Vcounts/(0.259^2)),thick = 3, color = colors.green;

;;pxval = [Vradius* 0.259,reverse(Vradius3* 0.259)]
;;pyval = [24.29 - 2.5*alog10(Vcounts/(0.259^2)),reverse(24.29 - 2.5*alog10(Vcounts3/(0.259^2)))]

;;polyfill, pxval,pyval, color = colors.aquamarine
;;polyfill, pxval,pyval, /line_fill, orientation = 45

;pxval = [Vradius* 0.259,reverse(Vradius2* 0.259)]
;pyval = [24.29 - 2.5*alog10(Vcounts/(0.259^2)),reverse(24.29 - 2.5*alog10(Vcounts2/(0.259^2)))]

;;polyfill, pxval,pyval, color = colors.darkgreen
;;polyfill, pxval,pyval, color = colors.white, /line_fill, orientation = 45


;lower2 = 22.52 - 2.5*alog10((Vcounts - 0.00043)/(0.259^2))
;upper2 = 22.52 - 2.5*alog10((Vcounts + 0.00043)/(0.259^2)) 
;;errplot, Vradius,lower2, upper2

;pxval = [radius* 0.259,reverse(radius3* 0.259)]
;pyval = [24.6 - 2.5*alog10(counts/(0.259^2)),reverse(24.6 - 2.5*alog10(counts3/(0.259^2)))]

;;polyfill, pxval,pyval, color = colors.salmon
;polyfill, pxval,pyval, /line_fill, orientation = 45

;pxval = [radius* 0.259,reverse(radius2* 0.259)]
;pyval = [24.6 - 2.5*alog10(counts/(0.259^2)),reverse(24.6 - 2.5*alog10(counts2/(0.259^2)))]

;;polyfill, pxval,pyval, color = colors.firebrick
;polyfill, pxval,pyval, color = colors.white, /line_fill, orientation = 45

;oplot, radius* 0.259,24.6 - 2.5*alog10(counts/(0.259^2)),thick = 3;

;lower2 = 24.6 - 2.5*alog10((counts - 0.000555)/(0.259^2))
;upper2 = 24.6 - 2.5*alog10((counts + 0.000555)/(0.259^2)) 
;errplot, radius* 0.259,lower2, upper2
