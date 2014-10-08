pro get_centroids_for_calstar_jk, im, h, unc, ra, dec, t, dt, hjd, xft, x3, y3, $
                       x5, y5, x7, y7, xg, yg, xh, yh, f, b, x3s, y3s, x5s, y5s, $
                       x7s, y7s, fs, bs, xp3, yp3, xp5, yp5, xp7, yp7, xp3s, yp3s, $
                       xp5s, yp5s, xp7s, yp7s, fp, fps, np, flag, ns, sf, $
                       xfwhmarr, yfwhmarr, bb, WARM=warm, SILENT=silent
                       
;
	name = 'GET_CENTROIDS_FOR_CALSTAR:'


	if (not keyword_set(SILENT)) then silent = 0 else silent = 1

; Bad pixel settings needed for aper.pro
	badpix = [-9., 9.] * 1.D8
	
; Edge limit
	edge = 5.

; First set of apertures	
	back1 =  [3., 7.]
; Third set of apertures
	aps3 = [3.]
; Number of apertures
	napers = n_elements(aps3) ;+ 2
; Number of background annuli
	nbacks = 1; 3;4

; full width at half maximum of sources imaged by IRAC in arcseconds
	fwhm = [1.66, 1.72, 1.88, 1.98]
	
; Plate scales for full array BCDs
	pxscal1 = [-1.22334117768332D, -1.21641835430637D, -1.22673962032422D, -1.2244968325831D]
	pxscal1 = abs(pxscal1)
	pxscal2 = [1.22328355209902D, 1.21585676679388D, 1.22298117494211D, 1.21904995758086D]


; Array of readnoise in electrons, per channel for 0.02, 0.1, 0.4 frametimes
; 2s sub, 0.4, 0.6, 1.2, 2, 6, 12, 30, 100 second full
	if (keyword_set(WARM)) then begin
		readnoise = [[23.9, 23.8, 12.7, 11.9], [16.9, 16.8, 9.0, 8.4], $
	             [11.8, 12.1, 9.1, 7.1], [9.4, 9.4, 8.8, 6.7], $
	             [23.9, 23.8, 12.7, 11.9], [23.9, 23.8, 12.7, 11.9], $
	             [23.9, 23.8, 12.7, 11.9], [11.8, 12.1, 9.1, 7.1], $
	             [9.4, 9.4, 8.8, 6.7], [9.4, 9.4, 8.8, 6.7], $
	             [6.0, 8.4, 4.5, 4.2], [6.0, 8.4, 4.5, 4.2]] * 1.D 
; Bump up readnoise by 5% for warm mission for FPA 1
	    readnoise[0, *] = readnoise[0, *] * 1.05	    
	endif else $
		readnoise = [[23.9, 23.8, 12.7, 11.9], [16.9, 16.8, 9.0, 8.4], $
	             [11.8, 12.1, 9.1, 7.1], [9.4, 9.4, 8.8, 6.7], $
	             [23.9, 23.8, 12.7, 11.9], [23.9, 23.8, 12.7, 11.9], $
	             [23.9, 23.8, 12.7, 11.9], [11.8, 12.1, 9.1, 7.1], $
	             [9.4, 9.4, 8.8, 6.7], [9.4, 9.4, 8.8, 6.7], $
	             [8.5, 8.4, 4.5, 4.2], [8.5, 8.4, 4.5, 4.2]] * 1.D

; Array of saturation limits per channel for all frametimes in mJy
; mm is limit for inappropriate frametime for channel or mission status
	mm = 0.001
; 0.02, 0.1, 0.4, 2.0 sub, 0.4, 0.6, 1.2, 2, 6, 12, 30, 100 frametimes
	if (keyword_set(WARM)) then $
		sat_levels = [[20000., 28000., mm, mm], [3000., 3700., mm, mm], $
	             [700., 900., mm, mm], [150., 180., mm, mm], $
	             [900., 1000., mm, mm], [500., 600., mm, mm], $
	             [250., 300., mm, mm], [160., 200., mm, mm], $
	             [50., 60., mm, mm], [25., 30., mm, mm], $
	             [10., 12., mm, mm], [2.8, 3.5, mm, mm]] $
	else $
		sat_levels = [[20000., 17000., 63000., 45000.], [4000., 3300., 13000., 9000.], $
	             [1000., 820., 3100., 2300.], [mm, mm, mm, mm], $
	             [950., 980., 6950., 3700.], [630., 650., 4600., 2500.], $
	             [23.9, 23.8, 12.7, 11.9], [190., 200., 1400., 740.], $
	             [mm, mm, mm, mm], [32., 33., 230., 120.], $
	             [13., 13., 92., 48.], [3.8, 3.9, 27., 28.]]	
	             
; Increase saturation levels by 5% to account for them being pessimistic
	sat_levels = sat_levels * 1.05
; Gain (conversion from DN to e-) per channel
	if (keyword_set(WARM)) then gain = [3.7, 3.7, 3.8, 3.8] * 1.D$
	else gain = [3.3, 3.7, 3.8, 3.8] * 1.D
	
; Sigma level for outlier rejection
	sigma = 3.0

; Get channel number of image
	nch = sxpar(h, 'CHNLNUM')

; Set image dimensions
        nx = sxpar(h, 'NAXIS1')
        ny = sxpar(h, 'NAXIS2')
	naxis = sxpar(h, 'NAXIS')	

; Check to see if BCD or not! (1: BCD, 0: Raw, -1: pbcd?)
	areadmod = sxpar(h, 'AREADMOD', COUNT=acount)
	aortime = sxpar(h, 'AORTIME', COUNT=xcount)
	if (xcount gt 0) then bcdflag = 1 else bcdflag = 0
	if (acount eq 0) then bcdflag = -bcdflag

        ft = sxpar(h, 'FRAMTIME')


; Get sigma image
; Need to determine which readnoise and sat level to use
; 0.02, 0.1, 0.4, 2.0 sub, 0.4, 0.6, 1.2, 2, 6, 12, 30, 100 frametimes

	if (abs(ft-0.02) lt 0.01) then findex = 0 $
	else if (abs(ft-0.1) lt 0.01) then findex = 1 $
	else if (abs(ft-0.4) lt 0.01 and areadmod eq 1) then findex = 2 $
	else if (abs(ft-0.4) lt 0.01 and areadmod eq 0) then findex = 4 $
	else if (abs(ft-0.6) lt 0.01) then findex = 5 $
	else if (abs(ft-1.2) lt 0.01) then findex = 6 $
	else if (abs(ft-2.) lt 0.01 and areadmod eq 1) then findex = 3 $
	else if (abs(ft-2.) lt 0.01 and areadmod eq 0) then findex = 7 $
	else if (abs(ft-6.) lt 0.01) then findex = 8 $
	else if (abs(ft-12.) lt 0.01) then findex = 9 $
	else if (abs(ft-30.) lt 0.01) then findex = 10 $
	else if (abs(ft-100.) lt 0.01) then findex = 11 else findex = 0

; If no sigma image then make one -- BCD case first poisson + readnoise
	if (bcdflag ne 0) then begin
		sbtoe = sxpar(h, 'GAIN') * sxpar(h, 'EXPTIME') / sxpar(h,'FLUXCONV')
		sig = abs(cube) * sbtoe
; Make noise positive definite
;			if (min(sig) lt 0.0) then sig = sig - min(sig)
		sig = sig + readnoise[nch-1, findex] * readnoise[nch-1, findex]
		sig = sqrt(sig)
; Convert back to MJy/sr
		sig = sig / sbtoe
	endif 

; Create arrays to hold centroids
	x3 = dblarr(ns)* !VALUES.D_NAN
        y3 = x3

; Centroids using alternate uncertainty estimate
	xp3 = x3
	yp3 = x3

; Flux and background arrays, 4 choices of background annulus
	f = dblarr(ns, napers)* !VALUES.D_NAN
	b = f; fltarr(ns, nbacks)* !VALUES.D_NAN
	fp =  f;fltarr(ns, napers)* !VALUES.D_NAN
	bp =  f;fltarr(ns, nbacks)* !VALUES.D_NAN
	bb =  f;fltarr(ns,nbacks) * !VALUES.D_NAN; from box_centroider directly
;  count arrays
	c =  f;fltarr(ns, napers)* !VALUES.D_NAN
	cb =  f;fltarr(ns, nbacks)* !VALUES.D_NAN

; Sigma arrays
	x3s = x3; fltarr(ns)* !VALUES.D_NAN
	y3s = x3;fltarr(ns)* !VALUES.D_NAN
	xp3s = x3;fltarr(ns)* !VALUES.D_NAN
	yp3s = x3;fltarr(ns)* !VALUES.D_NAN

	fs = f;fltarr(ns, napers)* !VALUES.D_NAN
	bs = f;fltarr(ns, nbacks)* !VALUES.D_NAN
	fps = f;fltarr(ns, napers)* !VALUES.D_NAN
	bps = f;fltarr(ns, nbacks)* !VALUES.D_NAN

; Noise pixel array
	np = dblarr(ns,/nozero)
	
	
; Flag array
	flag = intarr(ns)
	
; Full width at half max arrays
	xfwhmarr = dblarr(ns,/nozero)
	yfwhmarr = dblarr(ns,/nozero)

;
; Find centroid for each image plane
	for i = 0, ns-1 do begin
           slice = cube[*, *, i]
; Uncertainty image calculated from Poisson plus readnoise
           sigma2 = sig[*, *, i] * sig[*, *, i]
; SSC provided uncertainty image		
           unc2 = unc[*, *, i] * unc[*, *, i]

; Find position of brightest pixel or if coordinate is passed find brightest
; pixel in small search window (5 pixel) around coordinate
           skip_src = 0
           adxy, h, ra, dec, xmax, ymax

;cheating for now
;           xmax = xmax
;           ymax = ymax 
; Only continue with images that have a source that not 5 pixels from edge
           xedge = nx - edge - 1.
           if (xmax lt edge or xmax gt xedge or ymax lt edge or ymax gt xedge)  then begin ;   or eflux[nch-1] gt sat_levels[nch-1, findex])
		    
              if (xmax lt edge or xmax gt xedge or ymax lt edge or ymax gt xedge) then begin 
                 expid =  sxpar(h, 'EXPID')
                 if not keyword_set(silent) then print, 'Source outside array for image number ', expid
                 flag[0:ns-1] = -2
              endif 

              skip_src = 1
           endif
		
; If source position is in image, then try to find centroid and perform photometry
           if (skip_src eq 0) then begin
; Calculate size of pixels in arcseconds
; Code that used header information so full and subarray frames used different plate scales
; which is wrong as all corrections applied assume a uniform plate scale to account for
; distortions and other variations across the focal plabe
;;			if (bcdflag ne 0) then pscale2 = abs(sxpar(h, 'PXSCAL1')) * $
;;	                                    sxpar(h, 'PXSCAL2') $
;;	        else pscale2 = 1.22D * 1.22D
; Updated code using hardwired constants 11 May 2011 SJC	        
	        pscale2 = pxscal1[nch-1] * pxscal2[nch-1]
	        pscale = sqrt(pscale2)

; Calculate source centroid a variety of ways, will use 3 pixel half radius 1st moment centroider
; as default

; if keyword APER set, then use it for the aperture photometry
; 3 pixel half-width, use smallest aperture for FWHM
;                print, 'starting box_centroider ', xmax, ymax
                expid = sxpar(h, 'EXPID')

                box_centroider, slice, sigma2, xmax, ymax, 3, 6,3, tx, ty, tf, tb, $
                                txs, tys, tfs, tbs, tc, tcb, tnp, xfwhm, yfwhm, expid,/twopass

                x3[i] = tx & y3[i] = ty & x3s[i] = txs & y3s[i] = tys
                bb[i] = tb
                np[i] =tnp
; Store FWHM			
                xfwhmarr[i] = xfwhm & yfwhmarr[i] = yfwhm
		
; Convert image to electrons
                if (bcdflag ne 0) then eim = slice * sbtoe else eim = slice


;manually find the background in the images
;mask the top and bottom row
                eim[*,0] = !VALUES.D_NAN &  eim[*,31] = !VALUES.D_NAN


; 1st set of apertures
;;			aper, eim, x5[i], y5[i], xf, xfs, xb, xbs, 1.0, aps1, back1, $
                aper, eim, x3[i], y3[i], xf, xfs, xb, xbs, 1.0, aps3, back1, $
                      badpix, /FLUX, /EXACT, /SILENT, /NAN, /MEANBACK,$
                      READNOISE=readnoise[nch-1, findex]
                f[i, 0:(naps1-1)] = xf / sbtoe
                b[i, 0] = xb
                bs[i, 0] = xbs
                bptr = where(xf ne xf, bcount)
                if (bcount ne 0) then xfs[bptr] = !VALUES.D_NAN
                rn = readnoise[nch-1, findex] * !DPI * aps1
                fs[i, 0:(naps1-1)] = sqrt(xfs * xfs + rn * rn) / sbtoe

; Set flag to number of good apertures
			ptr = where(f[i, *] eq f[i, *], count)
			flag[i] = count					
		endif else pscale2 = 1.0
	endfor
	
; Convert from summed MJy/sr to Jy
; convert scale from arcsec^2 to sr and scale to Jy
	scale = pscale2 * !DPI * !DPI / (3600.D * 3600.D * 180.D * 180.D) * 1.0D+06
	f = f * scale
	fp = fp * scale
	b = b * scale
        bb = b * scale
; Return sigma instead of variance
	x3s = sqrt(x3s)
	y3s = sqrt(y3s)

	xp3s = sqrt(xp3s)
	yp3s = sqrt(yp3s)

	fs = fs * scale
	fps = sqrt(fps)
	fps = fps * scale
	bs = bs * scale
	
return
end

