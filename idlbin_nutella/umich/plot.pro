PRO plotphot
close, /all		;close all files = tidiness

device, true=24
device, decomposed=0
colors = GetColor(/load, Start=1)

mydevice = !D.NAME
!p.multi = [0, 0, 1]
SET_PLOT, 'ps'

device, filename = '/n/Godiva4/jkrick/aug98/aug19/phot.ps', /portrait, $
  BITS=8, scale_factor=0.9 , /color
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


OPENR, lun,'/n/Godiva4/jkrick/aug98/aug23/phottest', /GET_LUN

;read in the radial profile
rows= 8
airmass = FLTARR(rows)
mag1 = FLTARR(rows)
mag2 = FLTARR(rows)
mag3 = FLTARR(rows)
mag4 = FLTARR(rows)
mag5 = FLTARR(rows)
mag6 = FLTARR(rows)

a = 0.0			
m1 = 0.0
m2 = 0.0
m3 = 0.0
m4 = 0.0
m5 = 0.0
m6 = 0.0

		
j = 0
FOR j=0,rows - 1 DO BEGIN
      READF, lun, a, m1, m2,m3,m4,m5,m6
      airmass(j) = a
      mag1(j) = m1
      mag2(j) = m2
      mag3(j) = m3
      mag4(j) = m4 + 2.7
      mag5(j) = m5
      mag6(j) = m6

ENDFOR

close, lun
free_lun, lun


plot,airmass, mag1, yrange = [18.5, 20.7], charthick = 3, $
  xthick = 3, ythick = 3, color = colors.black, psym = 2

oplot,airmass, mag2, color = colors.red;, psym = 2, thick = 3
oplot,airmass, mag3, color = colors.blue;, psym = 6, thick = 3
oplot,airmass, mag4, color = colors.green, psym = 4, thick = 3
oplot,airmass, mag5, color = colors.orange;, psym = 5, thick = 3
oplot,airmass, mag6, color = colors.brown;, psym = 6, thick = 3

device, /close
set_plot, mydevice

END

