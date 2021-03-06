pro virgo_globulars_aper_2
     
     fits_read,  '/Users/jkrick/Virgo/IRAC/ch1/ch1_Combine-mosaic/mosaic_bkgd.fits', data, header
     fits_read, '/Users/jkrick/Virgo/IRAC/ch1/ch1_Combine-mosaic/mosaic_cov.fits', covdata, covheader
     fits_read, '/Users/jkrick/Virgo/IRAC/globulars/ch1_background.fits', backdata, backheader

     ;subtract a SExtractor background with large mesh size
     data = data - backdata
     fits_write, '/Users/jkrick/Virgo/IRAC/globulars/ch1_mosaic_bkgd.fits', data, header

;read in the locations of the globulars
    ; readcol, '/Users/jkrick/Virgo/IRAC/globulars/ngvs_ra_dec_g24.txt',  ra_start, dec_start ;, format = '(G10.4, G10.4)'
    ; adxy, header, ra_start, dec_start, x_start, y_start
    ; ftab_ext, '/Users/jkrick/Virgo/IRAC/globulars/NGVS.ptcat.ugiz.i24.5.v0.2.pps99.iracregion.fits', [1, 6,7], num, ra_start, dec_start
     ;adxy, header, ra_start, dec_start, x_start, y_start

     ngvs = mrdfits( '/Users/jkrick/Virgo/IRAC/globulars/NGVS.ptcat.ugiz.i24.5.v0.2.pps99.iracregion.fits',1,ngvsheader)
     adxy, header, ngvs.alpha_j2000, ngvs.dec_j2000, x_start, y_start
     print, 'n_elements(x_start)', n_elements(x_start)

;set up the objects
     numobjects = n_elements(ra_start)
     gclus = replicate({gob, gnum:0L,gra:0D, gdec:0D,ch1_ra:0D, ch1_dec:0.0, x_start:0.0, y_start:0.0, ch1_xcen:0.0, ch1_ycen:0.0, ch1_flux:0.0,ch1_fluxerr:0.0, ch1_mag:0.0,ch1_magerr:0.0, ch1_sky:0.0, ch1_skyerr:0.0, ch2_flux:0.0,ch2_fluxerr:0.0, ch2_mag:0.0,ch2_magerr:0.0, ch2_sky:0.0, ch2_skyerr:0.0, flag_confuse:0},numobjects)
     gclus.gnum = num
     gclus.gra = ra_start
     gclus.gdec = dec_start
     gclus.x_start = x_start
     gclus.y_start = y_start

     flux_startarr = fltarr(n_elements(ra_start))
     fluxarr =  fltarr(n_elements(ra_start))
     ferraparr=  fltarr(n_elements(ra_start))
     skyarr =  fltarr(n_elements(ra_start))
     skyerrarr =  fltarr(n_elements(ra_start))
     fluxarr_ch2 =  fltarr(n_elements(ra_start))
     ferraparr_ch2=  fltarr(n_elements(ra_start))
     skyarr_ch2 =  fltarr(n_elements(ra_start))
     skyerrarr_ch2 =  fltarr(n_elements(ra_start))


;find good centroids for the NGVS positions in the IRAC dataset
     a = where(gclus.x_start gt 0 and gclus.y_start gt 0 and finite(data(gclus.x_start, gclus.y_start)) eq 1 and covdata(gclus.x_start, gclus.y_start) ge 5, acount, complement = na)
     cntrd, data, gclus[a].x_start, gclus[a].y_start, xcen, ycen, 2.0, /silent;,/debug
     gclus[a].ch1_xcen = xcen
     gclus[a].ch1_ycen = ycen


;--------------------------------------------
     
;convert new centroids into ra and dec
     xyad, header, gclus.ch1_xcen, gclus.ch1_ycen, ra, dec
     gclus.ch1_ra = ra
     gclus.ch1_dec = dec

;make a region file to visually check the centroiding
     openw, outlun, '/Users/jkrick/Virgo/IRAC/globulars/irac_ra_dec_g24.reg', /get_lun
     for r = 0L,  n_elements(ra) - 1 do begin
        if finite(ra(r)) lt 1 then ra(r) = 0.0
        if finite(dec(r)) lt 1 then dec(r) = 0.0
        printf, outlun, format ='(A, g10.9, A, g10.9, A)', 'J2000; circle  ',ra_start(r), 'd  ', dec_start(r),    'd 5.0" # color=green'
        printf, outlun,format ='(A, g10.9, A, g10.9, A)', 'J2000; circle  ', ra(r), 'd  ', dec(r),    'd 4.5" # color=red'
     endfor
     close, outlun
     free_lun, outlun

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;run aperture photometry on the NGVS positions

     b = where(finite(gclus.ch1_xcen) eq 1 and gclus.ch1_xcen gt 0 and gclus.ch1_ycen gt 0, bcount, complement = nb)

; calculate effective gain based on coverage map
;effective gain = N * gain

     N= covdata[gclus.ch1_xcen, gclus.ch1_ycen]
     phpadu = N*3.7             ; the ch1 gain

     for i = 0L, bcount - 1 do begin
        aper, data, gclus[b[i]].x_start, gclus[b[i]].y_start, flux_start, ferrap_start, sky_start, skyerr_start, phpadu[b[i]], [3.16], [12,20],/nan, /exact,/flux,/silent
        flux_startarr[b[i]] = flux_start
     
        ;run some aperture photometry on the new centroids
        aper, data, gclus[b[i]].ch1_xcen, gclus[b[i]].ch1_ycen, flux, ferrap, sky, skyerr, phpadu[b[i]], [3.16], [12,20],/nan, /exact,/flux,/silent
        fluxarr[b[i]] = flux
        ferraparr[b[i]] = ferrap
        skyarr[b[i]] = sky
        skyerrarr[b[i]] = skyerr

     endfor

;make aperture correction
   apcorr_ch1 = 0.736 ; from SWIRE
   flux = fluxarr / apcorr_ch1
   flux_start = flux_startarr / apcorr_ch1
     
;array location dependent correction
     fits_read, '/Users/jkrick/Virgo/IRAC/array_location/ch1/ch1_Combine-mosaic/mosaic.fits', arraydata, arrayheader
     array_corr = arraydata[gclus.ch1_xcen, gclus.ch1_ycen]
     flux = flux * array_corr
     flux_start = flux_start * array_corr
     
     print, 'working into mjypersrtojansky'
     help,flux
;convert into useful units  
     jy = Mjypersrtojansky(flux,0.6) ; convert from Mjy/sr to jy
     erg = jy * 1E-23                ;conver from jy to erg/s/cm2/Hz
     magab = flux_to_magab(erg)      ;convert from erg/s/cm2/Hz to MagAB
     
     jyerr_ch1 = Mjypersrtojansky(ferraparr,0.6) ; convert from Mjy/sr to jy
     ergerr_ch1 = jyerr_ch1 * 1E-23                     ;conver from jy to erg/s/cm2/Hz
     noise_ch1 = erg + ergerr_ch1 
     magerr_ch1 = abs(flux_to_magab(noise_ch1) - magab)

     for i = 0L, n_elements(flux) -1 do gclus[i].ch1_mag = magab[i]
     for i = 0L, n_elements(flux) -1 do gclus[i].ch1_magerr = magerr_ch1[i]
     for i = 0L, n_elements(flux) -1 do gclus[i].ch1_flux = flux[i]
     for i = 0L, n_elements(flux) -1 do gclus[i].ch1_fluxerr = ferraparr[i]
     for i = 0L, n_elements(flux) -1 do gclus[i].ch1_sky = skyarr[i]
     for i = 0L, n_elements(flux) -1 do gclus[i].ch1_skyerr = skyerrarr[i]

; mark those globulars off the field of view
     a = where(gclus.x_start gt 0 and gclus.y_start gt 0 and finite(data(gclus.x_start, gclus.y_start)) eq 1, acount, complement = na)
     gclus[na].ch1_flux = -99
     gclus[na].ch2_flux = -99   
     gclus[na].ch1_mag = -99
     gclus[na].ch2_mag = -99   

;get rid of the ones which return NANs which really are off the field
     b = where(finite(gclus.ch1_xcen) eq 1 and gclus.ch1_xcen gt 0 and gclus.ch1_ycen gt 0, bcount, complement = nb)
     gclus[nb].ch1_flux = -99
     gclus[nb].ch2_flux = -99
     gclus[nb].ch1_xcen = 0
     gclus[nb].ch1_ycen = 0
     gclus[nb].ch1_mag = -99
     gclus[nb].ch2_mag = -99   

;how many globular candidates are left?
     print, 'there are ', bcount, 'globulars in the FOV'


;--------------------------------------------

;how far is the centroided position from the starting position?
     dist = sqrt((gclus.ch1_xcen - x_start)^2 + (gclus.ch1_ycen-y_start)^2)
     dist = dist *0.6           ; put in arcseconds, not in pixels
     
;want a cumulative distribution for this; then make a cut by percentage.
;need to sort on distance
;only consider those with actual centroids
     good = where(gclus.ch1_xcen gt 0 and gclus.ch1_ycen gt 0)
     dist = dist(good)
     sortdist= dist(sort(dist))
     N1 = n_elements(sortdist)
     f1 = (findgen(N1) + 1.)/ N1
     c = plot( sortdist, f1, '6b2', xtitle='Distance from Original Center (arcsec)', ytitle='Cumulative Fraction', xrange=[0,3], yrange=[0,1])
     
     line_x = [0, 2.0]
     line_y = [0.9, 0.9]
     line5 = polyline(line_x, line_y, thick = 2, color = !color.black,/data)
     
;test plot distance vs. brightness.  Probably the faint ones that are at larger distances
  ; although maybe not since the new source could be any brightness
     t = plot( dist,flux_start(good) - flux(good), '6r1.', xtitle = 'distance from original position (arcsec)',ytitle = 'flux _start - flux(Mjy/sr)', yrange = [-5,3] )
     line_x = [0.9, 0.9]
     line_y = [-3.0, 1.0]
     line5 = polyline(line_x, line_y, thick = 2, color = !color.black,/data)
     
;take out those sources which have distances greater than 0.9arcsec, or 10% of the total sources
     d = where(dist le 0.9, dcount, complement = nd)
     gclus[good(nd)].flag_confuse = 1
     print, 'there are ', dcount, 'globulars after cutting on distance'
                                ;make sure I did this correctly
                                ;plothist,  (sqrt((xcen - x_start)^2 + (ycen-y_start)^2))*0.6, xarr, yarr, bin = 0.1
                                ; plothist, gclus.flag_confuse, bin = 0.5
     
     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;need to do ch2 = 4.5 microns
   ;use the ch1 positions to measure
   ;simple aperture photometry on ch2

     fits_read,  '/Users/jkrick/Virgo/IRAC/ch2/ch2_Combine-mosaic/mosaic_bkgd.fits', data_ch2, header_ch2
     fits_read,  '/Users/jkrick/Virgo/IRAC/ch2/ch2_Combine-mosaic/mosaic_cov.fits', covdata_ch2, covheader_ch2
     fits_read, '/Users/jkrick/Virgo/IRAC/globulars/ch2_background.fits', backdata, backheader

     ;subtract a SExtractor background with large mesh size
     data_ch2 = data_ch2 - backdata
     fits_write, '/Users/jkrick/Virgo/IRAC/globulars/ch2_mosaic_bkgd.fits', data_ch2, header_ch2

; calculate effective gain based on coverage map
;effective gain = N * gain

     N= covdata_ch2[gclus.ch1_xcen, gclus.ch1_ycen]
     phpadu = N*3.71            ; the ch2 gain
     for i = 0, bcount - 1 do begin
        aper, data_ch2, gclus[b[i]].ch1_xcen, gclus[b[i]].ch1_ycen, flux_ch2, ferrap_ch2, sky_ch2, skyerr_ch2, phpadu[b[i]], [3.16], [24,40],/nan, /exact,/flux,/silent
        fluxarr_ch2[b[i]] = flux_ch2
        ferraparr_ch2[b[i]] = ferrap_ch2
        skyarr_ch2[b[i]] = sky_ch2
        skyerrarr_ch2[b[i]] = skyerr_ch2
     endfor

;aperture correction from SWIRE
     apcorr_ch2 = 0.716
     flux_ch2 = fluxarr_ch2 / apcorr_ch2

;array location dependent correction
     fits_read, '/Users/jkrick/Virgo/IRAC/array_location/ch2/ch2_Combine-mosaic/mosaic.fits', arraydata, arrayheader
     array_corr = arraydata[gclus.ch1_xcen, gclus.ch1_ycen]
     flux_ch2 = flux_ch2 * array_corr

;convert into useful units  
     jy_ch2 = Mjypersrtojansky(flux_ch2,0.6) ; convert from Mjy/sr to jy
     erg_ch2 = jy_ch2 * 1E-23                ;conver from jy to erg/s/cm2/Hz
     magab_ch2 = flux_to_magab(erg_ch2)      ;convert from erg/s/cm2/Hz to MagAB

     jyerr_ch2 = Mjypersrtojansky(ferraparr_ch2,0.6) ; convert from Mjy/sr to jy
     ergerr_ch2 = jyerr_ch2 * 1E-23                     ;conver from jy to erg/s/cm2/Hz
     noise_ch2 = erg_ch2 + ergerr_ch2 
     magerr_ch2 = abs(flux_to_magab(noise_ch2) - magab_ch2)
     
     for i = 0L, n_elements(flux) -1 do gclus[i].ch2_flux = flux_ch2[i]
     for i = 0L, n_elements(flux) -1 do gclus[i].ch2_fluxerr = ferraparr_ch2[i]
     for i = 0L, n_elements(flux) -1 do gclus[i].ch2_sky = skyarr_ch2[i]
     for i = 0L, n_elements(flux) -1 do gclus[i].ch2_skyerr = skyerrarr_ch2[i]
     for i = 0L, n_elements(flux) -1 do gclus[i].ch2_mag = magab_ch2[i]
     for i = 0L, n_elements(flux) -1 do gclus[i].ch2_magerr = magerr_ch2[i]
     
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;what is the best way to store all of this?
;need some sort of useful output file
     for i = 0L, 5000- 1 do begin
        if gclus[i].ch1_xcen gt 0 then print, format = '(I10, F10.2, F10.2, F10.5, F10.5, F10.2, F10.2, F10.4, F10.4, F10.2, F10.2, F10.2, F10.2)', gclus[i].gnum, gclus[i].ch1_xcen, gclus[i].ch1_ycen, gclus[i].ch1_ra, gclus[i].ch1_dec, gclus[i].ch1_mag, gclus[i].ch1_magerr, gclus[i].ch1_flux, gclus[i].ch1_fluxerr, gclus[i].ch2_mag, gclus[i].ch2_magerr,gclus[i].ch2_flux, gclus[i].ch2_fluxerr
     endfor

     save, gclus, filename = '/Users/jkrick/Virgo/IRAC/globulars/gclus_back.sav'

;also put new columns for the irac info in the fits file that Peng
;sent.


end
