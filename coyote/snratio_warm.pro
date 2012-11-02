pro snratio_warm
 dir_name =  '/Users/jkrick/iwic/iwic_recovery3/IRAC017200'

;find a few bright, but unsaturated stars, do photometry
;better to use dark field catalog then to try to find them from warm
;photometry

readcol, dir_name + '/stars.txt', star_ra, star_dec, format="A"

;-----------------------------------------------------
;do photometry on warm data

;pick a 12s raw frame to read in 
fits_read, '/Users/jkrick/iwic/iwic_recovery3/IRAC017200/raw/0035448832/IRAC.1.0035448832.0009.0000.01.mipl.fits', warmdata_ch1, junkh1
fits_read, '/Users/jkrick/iwic/iwic_recovery3/IRAC017200/raw/0035448832/IRAC.2.0035448832.0009.0000.01.mipl.fits', warmdata_ch2, junkh2

fits_read, '/Users/jkrick/iwic/iwic_recovery3/IRAC017200/bcd/0035448832/IRAC.1.0035448832.0009.0000.1.pipe0_fp.fits', warmdata_ch1, warmhead_ch1
fits_read, '/Users/jkrick/iwic/iwic_recovery3/IRAC017200/bcd/0035448832/IRAC.2.0035448832.0009.0000.1.pipe0_fp.fits', warmdata_ch2, warmhead_ch2


test1 = warmdata_ch1 
test2 = warmdata_ch2

hreverse,test1, warmhead_ch1, 2,/silent
hreverse, test2, warmhead_ch2, 2,/silent

fits_write, '/Users/jkrick/iwic/iwic_recovery3/IRAC017200/bcd/0035448832/IRAC.1.0035448832.0009.0000.1.pipe0_fp_wcs.fits', warmdata_ch1, warmhead_ch1

;read in cold data
fits_read, '/Users/jkrick/iwic/r25131776/ch1/raw/SPITZER_I1_0025131776_0003_0000_01_dce.fits', colddata_ch1_int, coldhead_ch1
fits_read, '/Users/jkrick/iwic/r25131776/ch2/raw/SPITZER_I2_0025131776_0003_0000_01_dce.fits', colddata_ch2_int, coldhead_ch2

;need to turn these into real numbers, with dewrap etc.
barrel = fxpar(coldhead_ch1, 'A0741D00')
fowlnum = fxpar(coldhead_ch1, 'A0614D00')
pedsig = fxpar(coldhead_ch1, 'A0742D00')
ichan = fxpar (coldhead_ch1, 'CHNLNUM')
waitper = fxpar(coldhead_ch1, 'A0615D00')
AFPAT1B = fxpar(coldhead_ch1, 'A0653E00')
AFPAT2B = fxpar(coldhead_ch1, 'A0655E00')
AFPAT1E = fxpar(coldhead_ch1, 'A0662E00')
AFPAT2E = fxpar(coldhead_ch1, 'A0664E00')
sclk = fxpar(coldhead_ch1, 'A0601D00')
aorid = fxpar(coldhead_ch1, 'A0553D00')

dewrap2,colddata_ch1, ichan, barrel, fowlnum, pedsig, 0, colddata_ch1


fits_read, '/Users/jkrick/iwic/r25131776/ch1/bcd/SPITZER_I1_25131776_0003_0000_2_bcd.fits', junkch1, coldhead_ch1
fits_read, '/Users/jkrick/iwic/r25131776/ch2/bcd/SPITZER_I2_25131776_0003_0000_2_bcd.fits', junkch2, coldhead_ch2

;ch1
;keep the stars inside the warm image
adxy, warmhead_ch1, star_ra, star_dec, xcen_warm_ch1, ycen_warm_ch1
adxy, coldhead_ch1, star_ra, star_dec, xcen_cold_ch1, ycen_cold_ch1

print, n_elements(xcen_warm_ch1), n_elements(xcen_cold_ch1)

;for ic = 0, n_elements(xcen_warm_ch1) -1 do begin
;   if xcen_warm_ch1(ic) gt 20 and ycen_warm_ch1(ic) gt 20 and xcen_warm_ch1(ic) lt 250 and ycen_warm_ch1(ic) lt 250 and xcen_cold_ch1(ic) gt 20 and ycen_cold_ch1(ic) gt 20 and xcen_cold_ch1(ic) lt 250 and ycen_cold_ch1(ic) lt 250 then print, xcen_warm_ch1(ic), ycen_warm_ch1(ic), xcen_cold_ch1(ic), ycen_cold_ch1(ic) 
;endfor


good= where(xcen_warm_ch1 gt 20 and ycen_warm_ch1 gt 20 and xcen_warm_ch1 lt 250 and ycen_warm_ch1 lt 250 and xcen_cold_ch1 gt 20 and ycen_cold_ch1 gt 20 and xcen_cold_ch1 lt 250 and ycen_cold_ch1 lt 250)


print, 'good', n_elements(good)
xcen_warm_ch1 = xcen_warm_ch1(good)
ycen_warm_ch1 = ycen_warm_ch1(good)
xcen_cold_ch1 = xcen_cold_ch1(good)
ycen_cold_ch1 = ycen_cold_ch1(good)


for ic = 0, n_elements(good) - 1 do print, xcen_warm_ch1(ic), ycen_warm_ch1(ic), xcen_cold_ch1(ic), ycen_cold_ch1(ic)



;------
;ch2
adxy, warmhead_ch2, star_ra, star_dec, xcen_warm_ch2, ycen_warm_ch2
adxy, coldhead_ch2, star_ra, star_dec, xcen_cold_ch2, ycen_cold_ch2
;keep the stars inside the warm image
good = where(xcen_warm_ch2 gt 20 and ycen_warm_ch2 gt 20 and xcen_warm_ch2 lt 250 and ycen_warm_ch2 lt 250 and xcen_cold_ch2 gt 20 and ycen_cold_ch2 gt 20 and xcen_cold_ch2 lt 250 and ycen_cold_ch2 lt 250)
xcen_warm_ch2 = xcen_warm_ch2(good)
ycen_warm_ch2 = ycen_warm_ch2(good)

xcen_cold_ch2 = xcen_cold_ch2(good)
ycen_cold_ch2 = ycen_cold_ch2(good)


;--------------------------------------------------------

;do photometry on the cold data at the positions of the stars used for
aper,  colddata_ch1, xcen_cold_ch1, ycen_cold_ch1, flux_cold_ch1, fluxerr_cold_ch1, sky, $
       skyerr, 3.3, [5], [15,25], [-100,1000], /nan,/exact,/flux,/silent
aper,  colddata_ch1, 117.65738, 91.368, testflux, testfluxerr, sky, $
       skyerr, 3.3, [5], [15,25], [-100,1000], /nan,/exact,/flux,/silent

print, 'test', testflux, testfluxerr
;ch2
;adxy, coldhead_ch2, ra_warm_ch2, dec_warm_ch2, xcen_cold_ch2, ycen_cold_ch2
aper,  colddata_ch2, xcen_cold_ch2, ycen_cold_ch2, flux_cold_ch2, fluxerr_cold_ch2, sky, $
       skyerr, 3.7, [5], [15,25], [-100,1000], /nan,/exact,/flux,/silent


;------



;do photometry
aper,  warmdata_ch1, xcen_warm_ch1, ycen_warm_ch1, flux_warm_ch1, fluxerr_warm_ch1, sky, $
       skyerr, 3.3, [5], [15,25], [-100,1000], /nan,/exact,/flux,/silent

;do photometry
aper,  warmdata_ch2, xcen_warm_ch2, ycen_warm_ch2, flux_warm_ch2, fluxerr_warm_ch2, sky, $
       skyerr, 3.7, [5], [15,25], [-100,1000], /nan,/exact,/flux,/silent

;
;print out some output
for i = 0, n_elements(xcen_cold_ch1) -1 do begin
   print, 'ch1 ', flux_warm_ch1(i), flux_cold_ch1(i)
endfor

for i = 0, n_elements(xcen_cold_ch2) -1 do begin
   print, 'ch2 ', flux_warm_ch2(i), flux_cold_ch2(i)
endfor

end
;convert back to ra and dec for using on the cold mission
;xyad, warmhead_ch2, xcen_warm_ch2 , ycen_warm_ch2, ra_warm_ch2, dec_warm_ch2

;convert back to ra and dec for using on the cold mission
;xyad, warmhead_ch1, xcen_warm_ch1 , ycen_warm_ch1, ra_warm_ch1, dec_warm_ch1

;openw, outlunred, '/Users/jkrick/iwic/iwic_recovery3/IRAC017200/star_ch1.reg', /get_lun
;printf, outlunred, 'fk5'
;for rc=0, n_elements(dec_warm_ch1) -1 do  begin
;   printf, outlunred, 'circle( ', ra_warm_ch1(rc), dec_warm_ch1(rc), ' 3")'
;   print, xcen_warm_ch1(rc), ycen_warm_ch1(rc),  ra_warm_ch1(rc), dec_warm_ch1(rc)
;endfor

;close, outlunred
;free_lun, outlunred

;openw, outlunred, '/Users/jkrick/iwic/iwic_recovery3/IRAC017200/star_ch2.reg', /get_lun
;printf, outlunred, 'fk5'
;for rc=0, n_elements(dec_warm_ch2) -1 do  printf, outlunred, 'circle( ', ra_warm_ch2(rc), dec_warm_ch2(rc), ' 3")'
;close, outlunred
;free_lun, outlunred
