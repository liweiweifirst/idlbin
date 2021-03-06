PRO count_flux
close,/all

fits_read, "/n/Godiva2/jkrick/A3984/galV.bblock.fits", data, header
inner = 0.
innersum = 0.D
outer = 0.
outersum = 0.
sum = 0.D
npix = 0.D
npix2 = 0.D
true = 0
xcenter1 = 1321.;1157.
ycenter1 = 1789.;2267.
xcenter2 = 1445.
ycenter2 = 1298.
FOR x = 100, 2600,1 DO BEGIN
    FOR y= 650, 2900, 1 DO BEGIN
        true = 0
        dist1 = sqrt((xcenter1 - x)^2 + (ycenter1 - y)^2)
        dist2 = sqrt((xcenter2 - x)^2 + (ycenter2 - y)^2)
;        IF (dist2 LE 500)  THEN begin
;            npix2 = npix2 + 1
;            true = 1
;            IF (data[x,y] GT -1) AND (data[x,y] NE 0) THEN BEGIN
;                outer = outer + 1
;                outersum = outersum + data[x,y]
;            ENDIF
;        ENDIF
        IF (dist1 LE 1060) AND (true NE 1) THEN begin
            npix = npix + 1
            IF (data[x,y] GT -1) AND (data[x,y] NE 0) THEN BEGIN
                inner = inner + 1
                innersum = innersum + data[x,y]
            ENDIF
        ENDIF

;        IF (dist GT 224) AND (dist LT 300) AND (data[x,y] GT -10)THEN BEGIN
;            outer = outer +1
;            outersum = outersum + data[x,y] - 2.
;        ENDIF


;        IF data[x,y] GT 0 THEN BEGIN
;            sum = sum +data[x,y] -2.
;            npix = npix + 1
         ;   print, data[x,y]
;        ENDIF

    ENDFOR
ENDFOR
print,"r1",inner, innersum, innersum/inner, 24.3 - 2.5*alog10((innersum/inner)/(0.259^2))
print, "should be npix: ", npix, inner/npix,"%"
;print, "new sum = " , innersum + (innersum/inner)*(npix - innersum)
print, "new sum = ", (innersum/inner)*npix
;print,"r2",outer, outersum, outersum/outer, 24.3 - 2.5*alog10((outersum/outer)/(0.259^2))
;print, "should be npix2: ", npix2, outer/npix2,"%"
;print, "new sum = " , outersum + (outersum/outer)*(npix2 - outersum)
;print, "new sum = ", (outersum/outer)*npix2
END
