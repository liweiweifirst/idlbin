;May 2002
;
;The purpose of this program is to block all the objects in an image.
; The stars are fit with a moffat profile, and subtracted as well as
; blocked in the centers.
; bad columns, cosmic rays, faint objects, and galaxies are also dealt
; with.
; saturated stars are ignored and need to be blocked by hand
;
;input: image with objects to be blocked, and a blank image of the
;       same size
;
;output: an image named ccd****.s.fits with the objects set equal to 
; 	-100, and an image called substars with the homemade stars on a 
;	a zero background ready to be subtracted
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


FUNCTION starmask, f, xcenter, ycenter, maxradius, xmax, ymax,blankdata

;this function acutally makes the homemade star and adds it to a blank
;image

;need to change this for final version. is a way of normalizing the flux
;D = f * 1.36/38.6597
;D = f * 1.36/53.4
;D = f * 1.36/39.6
;D = f* 1.36/35.6
;D = f 
D = 0.044*f 
sb4 = 24.3 - 2.5*alog10((D*mymoffat(15.4))/(0.259^2.))
sb2 = 24.3 - 2.5*alog10((D*mymoffat(7))/(0.259^2.))
;print, "xcen, ycenf, D, sb4",xcenter, ycenter, f, D, sb4, sb2
radius = 0.0		

intx = fix(xcenter)
inty = fix(ycenter)

dx = xcenter-intx
dy = ycenter-inty

;print, "star inside starmask", intx, dx, inty, dy

blank1 = blankdata
blank1(*,*) = 0.0

FOR y = inty-maxradius, inty + maxradius,1 DO BEGIN
    FOR x = intx -maxradius, intx + maxradius,1 DO BEGIN
        ;find what the radius is from the center
        radius = sqrt((intx - x)^2 + (inty - y)^2)
        
;        intensity = D*mymoffat(radius)
        IF radius NE 0 THEN BEGIN
;            intensitysb = 3.9 + 2.5*alog10((38.6/radius)^(-3.)) + sb4
            intensitysb = 6.9 + 2.5*alog10((38.6/radius)^(-3.)) + sb2
            intensity = (0.259^2.)*(10.^((24.6-intensitysb)/(2.5)))
        ENDIF

        ;make sure not off the edge of the chip
        ;need to deal with going from fractional pixels to whole pixels
        IF (x LT xmax AND y LT ymax AND x GT 1 AND y GT 1 ) THEN BEGIN
            blank1[x,y] = blank1[x,y] + intensity
        ENDIF
    ENDFOR
ENDFOR

blank1 = shiftf(blank1, dx,dy)
blankdata = blankdata - blank1
return, 0              
END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PRO block_obj

close, /all

openw, starlun, "/n/Godiva1/jkrick/A3888/final/starlist", /get_lun
openw, gallun, "/n/Godiva1/jkrick/A3888/final/gallist", /get_lun

;declare variables
o = 0.0                         ;object number
xcenter = 0.0   		;xcenter
ycenter = 0.0			;ycenter
e = 0.0                         ;ellipticity
a = 0.0                         ;semi-major axis
b = 0.0                         ;semi-minor axis
m = 0.0                         ;magnitude (un-corrected for zpt, X, ...)
j = 0.0                         ;junk
f = 0.0                         ;flux
fwhm = 0.0                      ;full width at half maximum
isoarea = 0.0                   ;area inside of last isophote

filename = strarr(1)            ;declare filename to be a stringarray
maxradius = 58.0                ; maximum radius in pixels to create a star
intensity = 0.0
bkgd = 0.0

true = 0                        ;manual boolean variable

;size of the image
xmax = 2900  ;V
ymax = 3140

;read in a blank image to which I can add my own stars			

FITS_READ, '/n/Godiva2/jkrick/A3984/original/blank.fits', blankdata, blankheader
filename = '/n/Godiva2/jkrick/A3984/original/fullV.div'


imagefile = filename + '.fits'
;datafile = filename + '.cat'
datafile = '/n/Godiva2/jkrick/A3984/SExtractor.V.cat'
newimagefile = filename + '.s.fits'	

;run SExtractor on the image to find the objects
commandline = '/n/Godiva7/jkrick/Sex/sex ' + "/n/Godiva2/jkrick/A3984/original/fullV.div.fits" + " -c /n/Godiva2/jkrick/A3984/iclV.sex"

spawn, commandline

;for the galaxies that did not make the color cut in cmd.pro
;datafile = '/n/Godiva1/jkrick/A3888/final/block_obj.r.input'

;read in the fits image with the stars that need to be subtracted
FITS_READ, imagefile, data, header


;read the data file into the variables until hit EOF
starcount = 0
galcount = 0
crcount = 0
dimcount = 0
satcount = 0
totalflux = 0.0  				;in case I want to know
galbestflux = 0.0
galisoflux = 0.0
subgalscount = 0
;-________________________________________________________________________________
;saturated stars from USNO

satx = fltarr(18)
saty = fltarr(18)
satVmag = fltarr(18)

satx=[  45.56, 188.31,2208.15,1957.70,2040.87,1209.30,1673.14,2600.13, 834.34,2846.29, 347.72, 978.27,1887.04,2145.90,2352.65,1561.90, 252.98,2777.16]


saty=[  339.25,  447.55,  232.10,  663.85,  884.55, 1008.29, 1167.90, 1074.04, 1523.80, 1550.03, 1819.07, 2165.32,2028.93,1942.23, 2257.33, 2484.01, 3133.61, 2923.11]

satVmag = [13.3,11.1,16.1,15.4,11.1,15.6,16.4,15.8,16.3,15.3,13.4,13.3,15.5,15.7,14.0,15.1,17.1,15.5]

newblank = blankdata

FOR satstar = 0, 17, 1 DO BEGIN
    holder = starmask (10^((satVmag[satstar] - 24.3)/(-2.5)), satx[satstar],$
              saty[satstar],500.,xmax,ymax,data)
    holder = starmask (10^((satVmag[satstar] - 24.3)/(-2.5)), satx[satstar],$
              saty[satstar],500.,xmax,ymax,newblank)
ENDFOR



;-------------------------------------------------------------------------------
;open the SExtractor output datafile (ccd*.cat)
OPENR, lun, datafile, /GET_LUN

WHILE (NOT EOF(lun)) DO BEGIN
    ;!!!! change this if you change the daofind.param , now usign godiva7/galfit/dao..
    READF, lun, o, xcenter, ycenter, a, b, e, f, m, isoarea, fwhm, pa, bkgd, apflux,isocorflux,isoflux
    ;print, "working on object", o
    
   
    ;___________________________________________________________________________
    ; ignore the other bad spots with flux less than 0
    IF (f LT 0 ) THEN true = 1
   
    ;__________________________________________________________________________
    ;get rid of dim objects
    ;these objects aren't putting enough into their wings to worry about them
    IF (apflux LE 0.14 ) AND (isoarea GE 6.0) AND (true EQ 0) THEN BEGIN
        ;go out to two times the fwhm then zap 'em
        a = 1.5*fwhm
        b = 1.5*fwhm

        IF (isoarea LT 14) THEN isoarea = 14 ;small galaxies

        sma = sqrt(isoarea/(!PI*(1-e)))
        smb = isoarea/(!PI*sma)
       ;print, "reomving dim object", o,xcenter, ycenter
        return = del_star(pa, f, sma , smb, xcenter, ycenter, data)
        return = del_star(pa, f, sma , smb, xcenter, ycenter, blankdata)
        
        true = 1
        IF (xcenter GT 950) AND (xcenter LT 1800) AND (ycenter GT 1100) AND (ycenter LT 1950) THEN dimcount = dimcount +1

    ENDIF

    ;_________________________________________________________________________
    ;get rid of cosmic rays
    IF(isoarea LT 6.0 OR fwhm LT 3.0 AND true EQ 0) THEN BEGIN  
        ;add 2 pixels to both a and b, and then block out to that radius
        ;print, "CR", o,xcenter,ycenter
        a = a + 2
        b = b + 2
       return = del_star(pa, f, a , b, xcenter, ycenter, data)

		
	;print, "removing cosmic ray", o, xcenter, ycenter
        true = 1
        IF (xcenter GT 950) AND (xcenter LT 1800) AND (ycenter GT 1100) AND (ycenter LT 1950) THEN crcount = crcount +1
    ENDIF
		
    ;__________________________________________________________________________
    ;get rid of the stars that are not very saturated
        
;    V fwhm limits
    IF (fwhm GE 3.0 AND fwhm LE 4.1  AND true EQ 0) THEN BEGIN   
        openw, dimlun, "/n/Godiva1/jkrick/A3888/tvmark.out", /GET_LUN, /append
        printf, dimlun, xcenter, ycenter, fwhm
        close, dimlun
        free_lun, dimlun
        IF (m LE 12.6) THEN BEGIN
            print,"shouldn't have gotten here", xcenter, ycenter
            true = 1
        ENDIF 

        ;for the dim things that could be
        ;stars, or galaxies, or junk, I won't subtract a profile, instead just
        ;block out to 2"
        IF (m GT 22.1) THEN BEGIN
            return = del_star(pa, f, 8, 8, xcenter, ycenter, data)

            true = 1

            ;holder = starmask (f, xcenter, ycenter, maxradius,xmax,ymax,blankdata)
            IF (xcenter GT 436) AND (xcenter LT 2436) AND (ycenter GT 524) AND (ycenter LT 2524) THEN BEGIN
                starcount = starcount + 1
;                printf, starlun, "star in center with mag ", m
            ENDIF

        ENDIF
        IF (true EQ 0 AND m GT 17) THEN BEGIN
;            return = del_star(pa, f, 22, 22, xcenter, ycenter, data)
            return = del_star(pa, f, 30, 30, xcenter, ycenter, data)
 ;           return = del_star(pa, f, 30, 30, xcenter, ycenter, blankdata)
            true = 1
;           print, "removing star at   ",xcenter, ycenter,m
;;            holder = starmask (f, xcenter, ycenter, maxradius,xmax,ymax,blankdata)
            holder = starmask (f, xcenter, ycenter, maxradius,xmax,ymax,data)

            IF (xcenter GT 436) AND (xcenter LT 2436) AND (ycenter GT 524) AND (ycenter LT 2524) THEN BEGIN
                starcount = starcount + 1
                printf, starlun, "star in center with mag ", m
            ENDIF

        ENDIF
        IF (true EQ 0) THEN BEGIN
	; want to make the flux within a radius of 5" the same as
	; the flux within the inner 5" taken from mymoffat profile
	; that function is sitting in mymoffat.pro 
	; D is the scale factor for making mymoffat have the same flux as the star
	; 38.65 is gotten by making a normalized star with the same specs
	; 54 should be the number according to the math
	;need to change this if Sextractor params change or params in next loop change

;;            holder = starmask (f, xcenter, ycenter, maxradius,xmax,ymax,blankdata)
            holder = starmask (f, xcenter, ycenter, maxradius,xmax,ymax,data)


		
	;and now for the part where I block out the inner 'a' pixels of all of the stars
	;just to make sure that we get it all, and so I don't have to worry about
	;seeing, focus, ...

            b= 30;19               ;block out star up to a radius of B1 pixels
            a= 30;19
            return = del_star(pa, f, a , b, xcenter, ycenter, data)
;;            return = del_star(pa, f, a , b, xcenter, ycenter, blankdata)

            IF (xcenter GT 436) AND (xcenter LT 2436) AND (ycenter GT 524) AND (ycenter LT 2524) THEN BEGIN
                starcount = starcount + 1  
                printf, starlun, "star in center with mag ", m
            ENDIF

            totalflux = totalflux + f
		
;           print, "removing star at   ",xcenter, ycenter
            true = 1

        ENDIF
        IF (true EQ 0 AND m LE 17) THEN BEGIN
            print, "m LT 17 ", xcenter, ycenter
            true = 1
        ENDIF

    ENDIF


 
    true = 0

ENDWHILE

print,"number of stars is:", starcount
print,"number of galaxies is:", galcount
print,"number of cosmic rays is:", crcount
print,"number of dim objects is:", dimcount
;print,"number of saturated objects is:", satcount
print,"total flux_iso in galaxies is:",galbestflux
print,"total flux_isocor in galaxies is:",galisoflux

;print,"number of subtracted galaxies is:", subgalscount
;close the SExtractor file, and free up the lun so it can be used again
close, lun
free_lun, lun

;want to put the sextractor paramters in the header to avoid loosing
;them
j = "j"
OPENR, lunicl, "/n/Godiva1/jkrick/A3888/final/iclV.sex", /GET_LUN
WHILE (NOT EOF(lunicl)) DO BEGIN
    readf, lunicl, j
    sxaddpar, header, "COMMENT",j
ENDWHILE
close, lunicl
free_lun, lunicl

;write a new fits file with the masked pixels, and one with the stars
;fits_write, newimagefile, shift(data, -1,-1), header
;fits_write, '/n/Godiva2/jkrick/A3984/mask.bblock.galr.fits',shift(blankdata,-1,-1), blankheader

;lessstars = data ;- blankdata   ;;;minus
;fits_write, '/n/Godiva1/jkrick/A3888/galfit/nogals.s-stars.fits', shift(lessstars, -1, -1), header

fits_write, '/n/Godiva2/jkrick/A3984/fullV.standard.fits', shift(data, -1, -1), header
fits_write, '/n/Godiva2/jkrick/A3984/satstars.fits', newblank, header

;undefine, subgals

close, /all
END
