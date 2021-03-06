;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;May 2002
;
; This program is a form of IRAF's imcombine
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pro imcombine_redo2

close, /all

xmax = 4050                      ;xsize of the image
ymax = 4070                      ;ysize of the image
numoimages = 5                  ;number of images to combine
hsigma = 39                     ;for rejection, in sigma
lsigma = 39                     ;for rejection, in sigma
R = 7.                          ;read noise of the tek5
g = 3.                          ;gain 
k = 0
sum = float(0)
numnotzero = 0
ncombine = 0
nreject = 0                     ;number of pixels rejected
ngood = fltarr(xmax+1,ymax+1)


;read in blank image
FITS_READ, '/n/Sheriff1/jkrick/sep00/A3888/blank.fits',newdata,newheader

;read in registered images to be combined
FITS_READ, '/n/Sheriff1/jkrick/sep00/A3888/ccd4063s.shift.fits',data0 ,header0
FITS_READ, '/n/Sheriff1/jkrick/sep00/A3888/ccd4064s.shift.fits',data1 ,header1
FITS_READ, '/n/Sheriff1/jkrick/sep00/A3888/ccd4065s.shift.fits',data2 ,header2
FITS_READ, '/n/Sheriff1/jkrick/sep00/A3888/ccd4066s.shift.fits',data3 ,header3
FITS_READ, '/n/Sheriff1/jkrick/sep00/A3888/ccd4067s.shift.fits',data4 ,header4

print, "read in data"

;make an array of pointers to the data arrays
imarr = ptrarr(numoimages, /allocate_heap)
*imarr[0] = data0
*imarr[1] = data1
*imarr[2] = data2
*imarr[3] = data3
*imarr[4] = data4

print,"pointers made"

nonzeroflt_a = fltarr(numoimages)
nonzeroptr_a = ptrarr(numoimages,/allocate_heap)

;at each pixel...
FOR x = 0, xmax, 1 DO BEGIN
    print, "inside loop",x
    FOR y = 0, ymax, 1 DO BEGIN
        ;throw away the images with no value at that particular pixel
        ; keep the ones with real data in an array of floats
        FOR i =0, numoimages - 1, 1 DO BEGIN
            IF ((*imarr(i))(x,y) NE 0) THEN BEGIN 
                numnotzero = numnotzero +1
            ENDIF
        ENDFOR
        IF (numnotzero EQ 0) THEN BEGIN
            newdata(x,y) = 0
        ENDIF ELSE BEGIN
            nonzeroflt = fltarr(numnotzero)
            
            n = 0
            FOR k = 0, numoimages-1,1 DO BEGIN 
                IF ((*imarr(k))(x,y) NE 0) THEN BEGIN
                    nonzeroflt(n) = (*imarr(k))(x,y)
                    n = n+1
                ENDIF 
            ENDFOR 
            
            
            ;if none of the pixels to be combined have data
            IF (numnotzero EQ 0) THEN newdata(x,y) = 0
            
            ;if there is only one good data point
            IF (numnotzero EQ 1) THEN newdata(x,y) = nonzeroflt[0]
            
            ;if there are two good data points
            IF (numnotzero EQ 2) THEN newdata(x,y) = (nonzeroflt[0] + nonzeroflt[1])/2
            
            ;if there are three or more good data points
            IF (numnotzero GE 3) THEN BEGIN  
                 ;print, "in nnz GE 3",x, y, nonzeroflt
                med = MEDIAN(nonzeroflt, /EVEN)
                 ;result = MOMENT(nonzeroarr,SDEV = sigmanormal)
                
                 ;using sigma based on assumption of just shot noise
                 ;need to deal with neg values in the sqrt
                IF ((R/g)^2 + med/g LT 0) THEN BEGIN
                    print, "sigma neg", x, y, med
                    sigma = sqrt(-((R/g)^2 + med/g))
                ENDIF ELSE BEGIN
                    sigma = sqrt((R/g)^2 + med/g)
                ENDELSE
                
                FOR j = 0,numoimages - 1,1 DO BEGIN
                    IF ( (*imarr(j))(x,y) NE 0 AND $
                         ((*imarr(j))(x,y) LT (med + (hsigma * sigma))) AND $
                         ((*imarr(j))(x,y) GT (med - (lsigma * sigma)))) THEN BEGIN
                        ngood(x,y) = ngood(x,y) + 1
                    ENDIF
                ENDFOR
                 ;print,"ngood", x,y,ngood(x,y)
                FOR j = 0, numoimages-1, 1 DO BEGIN
                    ;good values, within lowsigma and highsigma
                    IF ( (*imarr(j))(x,y) NE 0 AND $
                         ((*imarr(j))(x,y) LT (med + (hsigma * sigma))) AND $
                         ((*imarr(j))(x,y) GT (med - (lsigma * sigma)))) THEN BEGIN
                         ;print,"good values", x, y, j
                        sum = sum + (*imarr(j))(x,y)
                        ncombine = ncombine +1
                     ;values that I want to reject, either 0 or bad value
                    ENDIF ELSE BEGIN
                         ;in the center of a star
                        IF(x+1 LT xmax ) THEN BEGIN 
                            IF ((*imarr(j))(x,y)+(*imarr(j))(x+1,y) GE 2000) THEN BEGIN
                                ngood(x,y) = 0
                            ENDIF
                        ENDIF
                        
                        ;grow out the cosmic rays(not blank images, centers of objects)
                        IF(((*imarr(j))(x,y)) NE 0 AND ngood(x,y) NE 0) THEN BEGIN
                            ;nreject = nreject +25
                                ;print, "r",x,y,j,(*imarr(j))(x,y)
                            IF (x-2 GE 0 AND x+2 LE xmax $
                                AND y-2 GE 0 AND y+2 LE ymax) THEN BEGIN
                                IF (j EQ 0) THEN  data0(x-2:x+2,y-2:y+2) = 0
                                IF (j EQ 1) THEN  data1(x-2:x+2,y-2:y+2) = 0
                                IF (j EQ 2) THEN  data2(x-2:x+2,y-2:y+2) = 0
                                IF (j EQ 3) THEN  data3(x-2:x+2,y-2:y+2) = 0
                                IF (j EQ 4) THEN  data4(x-2:x+2,y-2:y+2) = 0
                            ENDIF
                            ;(*imarr(j))(x,y) = 0
                        ENDIF
                    ENDELSE
                ENDFOR
                ;if all points are rejected = centers of objects
                IF (ngood(x,y) EQ 0) THEN BEGIN
                    ;plan for if it rejects all values
                    FOR m = 0,numnotzero-1 DO BEGIN
                        sum = sum+nonzeroflt(m)
                        ncombine = ncombine +1
                    ENDFOR
                
                ENDIF 


                newdata(x,y) = sum/ncombine
                ;rezero numbers for the next pixel
                sum = 0.
                ncombine = 0
            ENDIF 
            numnotzero = 0
        ENDELSE
    ENDFOR
ENDFOR


FITS_WRITE, '/n/Sheriff1/jkrick/sep00/A3888/testcombine.fits', newdata,newheader
FITS_READ, '/n/Sheriff1/jkrick/sep00/A3888/ccd4063s.shift.fits',data0 ,header0
FITS_READ, '/n/Sheriff1/jkrick/sep00/A3888/ccd4064s.shift.fits',data1 ,header1
FITS_READ, '/n/Sheriff1/jkrick/sep00/A3888/ccd4065s.shift.fits',data2 ,header2
FITS_READ, '/n/Sheriff1/jkrick/sep00/A3888/ccd4066s.shift.fits',data3 ,header3
FITS_READ, '/n/Sheriff1/jkrick/sep00/A3888/ccd4067s.shift.fits',data4 ,header4


;print, "nreject %", (nreject/40000.)*100
END

;FITS_WRITE, '/n/Sheriff1/jkrick/sep00/A3888/imcombine/combtest1.fits',data0, header0
;FITS_WRITE, '/n/Sheriff1/jkrick/sep00/A3888/imcombine/combtest2.fits',data1 ,header1
;FITS_WRITE, '/n/Sheriff1/jkrick/sep00/A3888/imcombine/combtest3.fits',data2 ,header2
;FITS_WRITE, '/n/Sheriff1/jkrick/sep00/A3888/imcombine/combtest4.fits',data3 ,header3
;FITS_WRITE, '/n/Sheriff1/jkrick/sep00/A3888/imcombine/combtest5.fits',data4 ,header4
