pro noise_levels
;make a plot of the noise levels in an exoplanet staring mode observation
;some things are hard coded in so be careful to expand this to other observations


;using WASP-14 data
  fits_read, '/Users/jkrick/irac_warm/pcrs_planets/wasp-14b/r48682752/ch2/bcd/SPITZER_I2_48682752_0013_0000_1_bcd.fits', im, h

;assume aperture size of 2.25 pixels radius
  apsize = 2.25
  aparea = !Pi*apsize^2
  ronoise = sxpar(h, 'RONOISE')
  exptime = sxpar(h, 'EXPTIME')
  gain = sxpar(h, 'GAIN')
  fluxconv = sxpar(h, 'FLUXCONV')


  print, 'electrons', flux
  print, 'DN', flux / gain
  print, 'MJy/sr', flux / gain / exptime * fluxconv

;readnoise
  sigma_rn = sqrt(aparea*ronoise^2)
  print, 'sigma readnoise', sigma_rn
;poisson noise
;take the average over 64 subframes in a single image
;could seperate out the source and the background later XXX
  meane = fltarr(64)
  for j = 0, 63 do begin  
     subframe = im[*,*,j]
     subframe = (subframe / fluxconv) * exptime * gain ; now in electrons
     aper, subframe, 15.5, 15.5, flux, err, back, backerr, 1.0, 3.0, [3,7], $
           /FLUX, /EXACT, /SILENT, /NAN,  setskyval = 0,$ ;/meanback,$
           READNOISE=ronoise
     meane(j) = flux
  endfor
  meanclip, meane, avgelectrons, avgsigma
  sigma_poisson = sqrt(avgelectrons)
  print, 'poisson noise', sigma_poisson

;dark level
skydkmed = sxpar(h, 'SKYDKMED')  ; in MJy/sr
;XXX need to convert to electrons
sigma_dark = sqrt(skydkmed)
print, 'sigma sky dark', sigma_dark

;bas level
;can't seperate this from the dark level, since it is all measured together


end
