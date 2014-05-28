pro test_aper
  fits_read, '/Users/jkrick/irac_warm/pcrs_planets/wasp-52b/r0000000001/ch2/bcd/SPITZER_I2_0000000001_0329_0000_1_bcd.fits', im, h
 
for j = 0, 63 do begin  
   subframe = im[*,*,j]
  
  ronoise = sxpar(h, 'RONOISE')
  exptime = sxpar(h, 'EXPTIME')
  gain = sxpar(h, 'GAIN')
  fluxconv = sxpar(h, 'FLUXCONV')

  subframe = (subframe / fluxconv) * exptime * gain  ; now in electrons
  badpix = [-9., 9.] * 1.D8

  aper, subframe, 15.5, 15.5, flux, err, back, backerr, 1.0, 3.0, [3,7], $
         /FLUX, /EXACT, /SILENT, /NAN,  setskyval = 0,$;/meanback,$
        READNOISE=ronoise

  print, 'electrons', flux
  print, 'DN', flux / gain
  print, 'MJy/sr', flux / gain / exptime * fluxconv
endfor

end
