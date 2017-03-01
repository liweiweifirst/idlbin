pro run_pld_correct_withfit
  ;specific to HD75289 for now
  restore, '/Users/jkrick/external/irac_warm/HD75289/HD75289_phot_ch2_2.25000_160126_pi.sav'
  
  aorname = ['r52584192', 'r52616448', 'r52617728', 'r52619008', 'r52620288', 'r52621568',  'r52608256', 'r52616704', 'r52617984', 'r52619264', 'r52620544', 'r52621824', 'r52615680', 'r52616960', 'r52618240', 'r52619520', 'r52620800', 'r52622080', 'r52615936', 'r52617216', 'r52618496', 'r52619776', 'r52621056', 'r52622336', 'r52616192', 'r52617472', 'r52618752', 'r52620032', 'r52621312', 'r52622592']

  utmjd_center = 57398.541D
  period = 3.5091651
  phasearr = fltarr(n_elements(aorname))
  fluxerrarr=phasearr
  fluxarr=phasearr
  corrfluxerrarr=phasearr
  corrfluxarr=phasearr
  
  for a = 0,  n_elements(aorname) - 1 do begin
     pixgrid = planethash[aorname(a),'pixvals']
     flux = planethash[aorname(a),'flux']
     sigma_flux = planethash[aorname(a),'fluxerr']
     bmjd = planethash[aorname(a),'bmjdarr']

     corrected_flux = PLD_CORRECT_WITHFIT(pixgrid,flux,sigma_flux,CORR_UNC=corr_unc)

     ;;--------------------
     ;;set up for some testing plots
     bmjd_dist =bmjd - utmjd_center ; how many UTC away from the transit center
     
     phase =( bmjd_dist / period )- fix(bmjd_dist/period)
     phase = phase + (phase lt -0.5 and phase ge -1.0)
     phase = phase- (phase gt 0.5 and phase le 1.0)
     
     ;;p1 = plot(phase, flux, '1s', xtitle = 'phase', ytitle = 'Flux',sym_size= 0.2,   sym_filled= 1, overplot = p1, $
     ;;          xrange = [-0.5, 0.5], yrange = [1.50, 1.58])
     ;;p1 = plot(phase, corrected_flux, '1s', sym_size= 0.2,   sym_filled= 1, color = 'red', overplot = p1)


     ;;make some meanclip arrays
     meanclip, phase, meanphase, sigmaphase
     meanclip, flux, meanflux, sigmaflux
     meanclip, sigma_flux, meansigma_flux, sigmasigma
     meanclip, corrected_flux, meancorr, meansigmacorr
     meanclip, corr_unc, meancorr_unc, sigmacorr_unc
     phasearr[a] = meanphase
     fluxerrarr[a] = meansigma_flux
     fluxarr[a] = meanflux
     corrfluxerrarr[a] = meancorr_unc
     corrfluxarr[a] = meancorr
  endfor

  ;;now plot
  p2 = errorplot(phasearr, fluxarr, fluxerrarr, '1s',   sym_filled= 1, overplot = p1, $
                 xrange = [-0.5, 0.5], yrange = [1.52, 1.56], title = 'HD75289 PLD', xtitle = 'Phase', ytitle = 'Flux')
  p2 = errorplot(phasearr, corrfluxarr, corrfluxerrarr, '1s', color = 'red',errorbar_color = 'red',sym_filled= 1, overplot = p2)
  
  
end
