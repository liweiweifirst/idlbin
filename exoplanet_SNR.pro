; PURPOSE:
;  This code calculates the predicted SNR of a transit given the flux
;  density of the source in mJy and the depth of the transit. The code
;  assumes a relation for how the noise of the source decreases with
;  increasing number of frames which is based on an empiracle relation
;  taken from the literature.  After data reduction, on average the
;  literature is finding that the poisson noise limit is routinely
;  achieved ch1 on binning scales less than 30 frames and for ch2 on
;  binning scales less than 100 frames.  Ch1 data are able to achieve
;  2 times the poisson noise on binning scales greater than 30 frames
;  and a factor of 1.5 times poisson on binning scales greater than
;  100 frames for ch2.
;
; INPUTS:
;  -source_mJy = the flux density of the source in mJy in either ch1 or ch2
;  -transit_depth in percentage of the stellar signal
;  -ch = the name of the channel for observations and in which
;  source_mJy is given.  Can be either '1' or '2' corresponding to 3.6
;  and 4.5 microns
;
; OUTPUTS:
;  SNR = Signal to Noise Ratio
; 
; EXAMPLE:
;  SNR = exoplanet_snr(68, 1E-3,'2')
;
; MODIFICATION HISTORY:
;  January 2015 Original Version  JK
;-
Function exoplanet_SNR, source_mJy, transit_depth, ch
 
  ;;need to calculate frame time best suited for this target
  exptime = find_exptime(source_mJy, ch)

  ;;given frame time; how many frames = binning scale of 20min.
  n_frames = fix(20.*60./exptime) 

  ;;basics of the detector
      pixel_scale = 1.22
      case ch of
         '1': begin
            gain =3.7
            flux_conv = .1253
            factor = 2.
         end
         '2': begin
            gain = 3.71
            flux_conv = .1469
            factor = 1.5
         end
      endcase


  ;;calculate the number of electrons in the target
  source_electrons = mjy_to_electron( source_mjy, pixel_scale, gain, exptime, flux_conv)
  
  ;;poisson noise
  sigma_poisson = sqrt(source_electrons)

  ;;noise binns down like some factor times root n
  ;;this is an empiracle relation based on literature values
  root_n = sqrt(n_frames)
  if n_frames lt 100 then begin
     noise = sigma_poisson / root_n
  endif else begin
     noise = sigma_poisson / (factor * root_n)
  endelse

  ;;noise as percentage of the source flux
  noise = noise / source_electrons

  ;;signal to noise ratio
  SNR = transit_depth / noise

  print,   exptime, n_frames, SNR

RETURN, SNR
end
