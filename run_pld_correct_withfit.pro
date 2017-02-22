pro run_pld_correct_withfit
  ;specific to HD75289 for now
  restore, '/Users/jkrick/external/irac_warm/HD75289/HD75289_phot_ch2_2.25000_160126.sav'
  
  aorname = ['r52584192', 'r52616448', 'r52617728', 'r52619008', 'r52620288', 'r52621568',  'r52608256', 'r52616704', 'r52617984', 'r52619264', 'r52620544', 'r52621824', 'r52615680', 'r52616960', 'r52618240', 'r52619520', 'r52620800', 'r52622080', 'r52615936', 'r52617216', 'r52618496', 'r52619776', 'r52621056', 'r52622336', 'r52616192', 'r52617472', 'r52618752', 'r52620032', 'r52621312', 'r52622592']
  
  pixgrid = planethash[aorname(0),'pixvals']
  flux = planethash[aorname(0),'flux']
  sigma_flux = planethash[aorname(0),'fluxerr']
  bmjd = planethash[aorname(0),'bmjdarr']
  
  corrected_flux = PLD_CORRECT_WITHFIT(pixgrid,flux,sigma_flux)
  
  
  ;;--------------------
  ;;set up for some testing plots
  utmjd_center = 57398.541D
  period = 3.5091651
  bmjd_dist =bmjd - utmjd_center ; how many UTC away from the transit center
  phase =( bmjd_dist / period )- fix(bmjd_dist/period)
  phase = phase + (phase lt -0.5 and phase ge -1.0)
  phase = phase- (phase gt 0.5 and phase le 1.0)

  p1 = plot(phase, flux, '1s', xtitle = 'phase', ytitle = 'raw flux',sym_size= 0.2,   sym_filled= 1)
  p2 = plot(phase, corrected_flux, '1s', xtitle = 'phase', ytitle = 'corrected flux',sym_size= 0.2,   sym_filled= 1)
  
end
