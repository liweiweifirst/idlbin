pro get_centroids_mosaic, file, x0, y0, f, xs, ys, fs, b, cube, $
                       BOXWIDTH=boxwidth, SIGFILE=sigfile, $
					   BACKBOXWIDTH=backboxwidth, BOXBORDER=boxborder, $
					   SUPSIGMA=supsigma, WARM=warm, APER=aper, $
					   NOISE_PIXELS=noise_pixels, SILENT=silent, APRAD = aprad,$
					   RA=ra, DEC=dec
;+
; PROCEDURE:
;    GET_FULL_CENTROIDS
; PURPOSE: 
;    Return x and y position of brightest source for an IRAC
;    image.
; USAGE:
;    get_sub_centroids, imagefilename, sclk, x0, y0, f, xs, ys, fs, $
;                        b, bs, c, cb, cube, BOXWIDTH=width, SIGFILE=sigfile, $
;                        BOXBORDER=boxborder, BACKBOXWIDTH=backboxwidth, $
;                        SUPSIGMA=supsigma, WARM=warm
; INPUT:
;    file: string containing filename of subarray data
;
; OUTPUTS:
;    x0: float array containing x coordinate of centroid
;    y0: float array containing y coordinate of centroid
;     f: float array containing flux of source in specified aperture
;    xs: float array containing uncertainty in x coordinate of centroid
;    ys: float array containing uncertainty in y coordinate of centroid
;    fs: float array containing flux uncertainty of source
;     b: float array containing background
;    bs: float array containing uncertainty in background
;     c: array containing number of pixels in source aperture
;    cb: array containing number of pixels in background aperture
;
; OPTIONAL OUTPUT:
;    cube: data cube containing subarray data
;
; OPTIONAL INPUT KEYWORD:
;    backboxwidth: should be the desired width of the background box annulus 
;                  in pixels
;    boxwidth: should be the desired width of the centroiding box in pixels
;    boxborder: space between box and background box in pixels
;    sigfile: name of sig_dntoflux image corresponding to input data
;    supsigma: optional supplied sigma for each photometric point, could be from
;              first pass through data
;
; OPTIONAL FLAG:
;    APER: if set, use aper routine to calculate flux of source
;    WARM: if set, use warm IRAC factors for noise
;
; METHOD:
;    The brightest pixel in each slice of the data cube is found, a median
;    background is removed and the first moments are calculated using a 
;    2*boxwidth+1 box centered on the brightest pixel 
;
; HISTORY:
;    03 August 2009 SJC Modified for warm mission
;    17 Jan 2008 SJC Corrected typos in code. 
;    13 Nov 2006 SJC Added flux an03 aud flux uncertainty measurement, added 
;                keywords for background annulus and box border
;    14 September 2004 SJC Added uncertainty calculations
;    08 September 2004 SJC Cleanup of initial code
;    10 March 2005 SJC Corrected calculation of sclk for raw data
;    June 2004 SJC Initial code 
;-
	name = 'GET_SUB_CENTROIDS:'

	if (N_params() lt 4 or N_params() gt 13) then begin
		str = 'Syntax - get_full_centroids, file, t, x0, y0, [f, xs, ys, $'
		str1 = '                   fs,b,bs,c,cb,cube], BOXWIDTH=boxwidth, $'
		str2 = '                   BACKBOXWIDTH=backboxwidth, SIGFILE=sigfile, $'
		str3 = '                   BOXBORDER=boxborder, SUPSIGMA=supsigma, /WARM, /APER'
		print, str
		print, str1
		print, str2
		print, str3
		return
	endif

; Set boxwidth if not set by keyword
	if (not keyword_set(BOXWIDTH)) then boxwidth = 5

; Set backboxwidth if not set by keyword
	if (not keyword_set(BACKBOXWIDTH)) then backboxwidth = 6

; Set backboxwidth if not set by keyword
	if (not keyword_set(BOXBORDER)) then boxborder = 3
	if (not keyword_set(SILENT)) then begin
		print, 'Aperture box width = ' + strn(boxwidth) + ' pixels'
		print, 'Background box inner width = ' + strn(boxwidth + boxborder) + $
		        ' pixels'
		print, 'Background box outer width = ' + $
		        strn(boxwidth + boxborder + backboxwidth) + ' pixels'
	endif

; Defaults for aper procedure	
	ap = aprad ; [3]
	skyrad = [12., 20.]
	badpix = [-9., 9.] * 1.D8


; Gain (conversion from DN to e-) per channel
	gain = [3.3, 3.7, 3.8, 3.8]


; Bump up readnoise by 20% for warm mission
;manually set gain and fluxconv while they are wrong in the headers.
;	if (keyword_set(WARM)) then begin
;           readnoise = readnoise * 1.2
;           gain = [3.7, 3.7, 3.8, 3.8] 
;           fluxconv = [.1198,.1443,100,100] ;doesn't matter for 3 & 4
;        endif 


; Sigma level for outlier rejection
	sigma = 3.0

; Number of subarray images in stack
;	ns = 64
	
; read in image
	im = readfits(file, h, /SILENT)

; Get channel number of image
	nch = sxpar(h, 'CHNLNUM')

	naxis = sxpar(h, 'NAXIS')
        if (naxis eq 3) then begin
; Set image dimensions
           nx = 32
           ny = 32
; Number of subarray images in stack
           ns = 64	
        endif
  ; Set image dimensions
	nx = sxpar(h, 'NAXIS1')
	ny = sxpar(h, 'NAXIS2')
        ns = 1
      
; Check to see if BCD or not!
	areadmod = sxpar(h, 'AREADMOD', COUNT=acount)
	if (acount gt 0) then bcdflag = 1 else bcdflag = 0
 ;       print, 'bcdflag', bcdflag

; If raw image need to convert to cube
        cube = im

; Get sigma image
	if (keyword_set(SIGFILE)  ) then sig = readfits(sigfile,hs) 
; Need to determine which readnoise to use
;XXXtook this out


; Arrays holding x and y coordinates of each pixel
	xx = findgen(nx) # replicate(1.0, ny)
	yy = transpose(xx)

; Create arrays to hold centroids
	x0 = fltarr(ns)
	y0 = fltarr(ns)

; Flux and background arrays
	f = fltarr(ns)
	b = fltarr(ns)

;  count arrays
	c = fltarr(ns)
	cb = fltarr(ns)

; Sigma arrays
	xs = fltarr(ns)
	ys = fltarr(ns)
	fs = fltarr(ns)
	bs = fltarr(ns)
	
; Noise pixel array
	np = fltarr(ns)

; Find centroid for each image plane
	for i = 0, ns-1 do begin
		slice = cube[*, *, i]
		sigma2 = sig[*, *, i] * sig[*, *, i]
                

; Find position of brightest pixel or if coordinate is passed find brightest
; pixel in small search window (5 pixel) around coordinate

		if (keyword_set(RA) ) then begin
			adxy, h, ra, dec, xmax, ymax
;                        print, 'xmax,ymax',xmax, ymax
			xmask = slice * 0
			xmask[round(xmax)-2:round(xmax)+2, round(ymax)-2:round(ymax)+2] = 1
			xslice = slice * xmask
 ;                       print, 'xslice', xslice
			ptr = where(xslice eq max(xslice,/nan))
 ;                       print, 'ptr', ptr
			xmax = xx[ptr]
			ymax = yy[ptr]
			xmax = xmax[0]
			ymax = ymax[0]
		endif else begin
			ptr = where(slice eq max(slice,/nan))
			xmax = xx[ptr]
			ymax = yy[ptr]
			xmax = xmax[0]
			ymax = ymax[0]
		endelse

; Set box limits
		xa = xmax-boxwidth > 0
		xb = xmax+boxwidth < (nx-1)
		ya = ymax-boxwidth > 0
		yb = ymax+boxwidth < (ny-1)

; Set background regions
		xamin = xa - backboxwidth - boxborder > 0 < xa
		xamax = xa - boxborder > 0 < xa
		xbmax = xb + backboxwidth + boxborder > xb < (nx-1)
		xbmin = xb + boxborder > xb < (nx-1)
		yamin = ya - backboxwidth - boxborder > 0 < ya
		yamax = ya - boxborder > 0 < ya
		ybmax = yb + backboxwidth + boxborder > yb < (ny-1)
		ybmin = yb + boxborder > yb < (ny-1)

; Segment image into box and everything else

               ; print, 'xa,xb,ya,yb',xa,xb,ya,yb
		mask = slice * 0
		mask[xa:xb, ya:yb] = 1
		bptr = where(xx le xamax and xx ge xamin, bcount)
		if (bcount gt 0) then mask[bptr] = -1
		bptr = where(xx le xbmax and xx ge xbmin, bcount)
		if (bcount gt 0) then mask[bptr] = -1
		bptr = where(yy le yamax and yy ge yamin, bcount)
		if (bcount gt 0) then mask[bptr] = -1
		bptr = where(yy le ybmax and yy ge ybmin, bcount)
		if (bcount gt 0) then mask[bptr] = -1

; remove background - median of non box region
		bptr = where(mask eq -1, bcount)
		if (bcount gt 0) then begin 
			back = median(slice[bptr]) 
; One pass of outlier rejection for the background, could use mmm as well
			bmom = moment(slice[bptr])
			bsig = bmom[1]
			bbptr = where(abs(slice[bptr] - back) le sigma * sqrt(bsig), bbcount)
			if (bbcount gt 0) then begin
				back = median(slice[bptr[bbptr]])
				bmom = moment(slice[bptr[bbptr]] - back)
				bsig = bmom[1]
				bcount = bbcount
			endif else begin
				back = 0.0
				bsig = 0.0
			endelse
		endif else begin
			back = 0.0
			bsig = 0.0
		endelse

		slice = slice - back
		b[i] = back

; Perform centroid in 2*boxwidth+1 pixel box centered on peak pixel
		gptr = where(mask eq 1 and slice eq slice, gcount)
		fluxsum = total(slice[gptr])
		flux2sum = total(slice[gptr] * slice[gptr])
		fluxsum2 = fluxsum * fluxsum
		x0[i] = total(xx[gptr] * float(slice[gptr])) / fluxsum
		y0[i] = total(yy[gptr] * float(slice[gptr])) / fluxsum
; Use summed flux as measure of total flux and calculate noise pixels		
		np[i] = flux2sum / fluxsum
; Number of pixels in source and background regions
		c[i] = float(gcount)
		cb[i] = float(bcount)
; If a bad pixel exists in the source aperture return a flux of -1.
		xptr = where(mask eq 1 and slice ne slice, xcount)
		if (xcount gt 0) then f[i] = -1.0 else f[i] = fluxsum

; Uncertainties
		xs[i] = total((xx[gptr] - x0[i]) * (xx[gptr] - x0[i]) * sigma2[gptr])
		ys[i] = total((yy[gptr] - y0[i]) * (yy[gptr] - y0[i]) * sigma2[gptr])
		xs[i] = xs[i] / fluxsum2
		ys[i] = ys[i] / fluxsum2
		bs[i] = c[i] * c[i] * bsig / cb[i]
		fs[i] = total(sigma2[gptr]) + bs[i]
		
; if keyword APER set, then use it for the aperture photometry

		if (keyword_set(APER)) then begin
			 eim = slice
			aper, eim, x0[i], y0[i], xf, xfs, xb, xbs, 1.0, ap, skyrad, $
			      badpix, /FLUX, /EXACT, /SILENT, /NAN;, $
			   ;   READNOISE=readnoise[nch-1, findex]
;                        print, 'xf/sbtoe', xf/sbtoe
			f[i] = xf ;/ sbtoe
 ;                       print, 'i,f[i],', i, f[i]
			fs[i] = xfs ;/ sbtoe
		endif
; Bad fluxes have uncertainties of zero
		if (xcount gt 0) then fs[i] = 0.0
	endfor
	
; Convert from summed MJy/sr to Jy
	 scale = abs(sxpar(h, 'PXSCAL1')) *  sxpar(h, 'PXSCAL2') 
; convert scale from arcsec^2 to sr and scale to Jy
	scale = scale * !DPI * !DPI / (3600.D * 3600.D * 180.D * 180.D) * 1.0D+06
	f = f * scale
	b = b * scale

; Return sigma instead of variance
	xs = sqrt(xs)
	ys = sqrt(ys)
	fs = sqrt(fs)
	fs = fs * scale
	bs = sqrt(bs)
	bs = bs * scale
	
	if (keyword_set(NOISE_PIXELS)) then noise_pixels = median(np)

return
end
