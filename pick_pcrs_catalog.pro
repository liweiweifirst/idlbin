pro pick_pcrs_catalog, ra, dec, pm_ra, pm_dec

;calling sequence
;pick_pcrs_catalog, 330.79488375, 18.88431750, 0.029, -0.019

;ra = ra(J2000) in degrees
;dec = dec(J2000) in degrees
;pm = pm(arcsec/year)

;calculate the current location of the target

;read in the pcrs_catalog
readcol, '~/external/irac_warm/pcrs_catalog/pcrsguidestarcatalog.txt', star_id, junk, junk, Validity, Q, posEr, pErWk,  vMag, rightAscensn,  declination, prpMtnRA, prpMtnDc,  parllx, magEr,  raErr, declEr, mKER, mKED, plxEr, dOjbE, bkgEr, bstEr, P, M, X

;calculate the angular distance of the whole catalog from the target
;cos(A) = sin(d1)sin(d2) + cos(d1)cos(d2)cos(ra1-ra2)

;convert all degrees to radians
cosa = sin(dec*!DTOR)*sin(declination*!DTOR) + cos(dec*!DTOR)*cos(declination*!DTOR)*cos((ra*!DTOR) - (rightAscensn*!DTOR))
angle = acos(cosa) * !RADEG  ; then convert back to degrees

;sort to find the nearest 6 catalog stars

;display a list of the stars with 
;-Comment = Tycho/Hipparcos
;-RA
;-DEC
;-PM RA +/- uncertainty
;-PM DEC +/- uncertainty
;-RA uncertainty (mas/yr)
;-DEC uncertainty (mas/yr)
;-Angular distance from target 
;-Vmag
;-Epoch


end
