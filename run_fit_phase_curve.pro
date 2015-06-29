pro run_fit_phase_curve, exodata = exodata
 ;;wrapper to fit phase curves with Jim's model of C&A11

  t = systime(1)

  ;;setup some known quantities for wasp14
  porbit = 2.24376543D          ;days
  mjd_transit = 2456034.21290D - 2400000.5D
  ecc = 0.0828D
  argperi = 252.11D             ;degrees
  ar_semimaj = 5.99
  exosystem = 'WASP-14 b'
  verbose = 1
  trad = 2.0    ;; initial guess
  omrot = 0.9   ;; initial guess
  fstar = 0.0577d ;; initial guess
  albedo = !NULL  ;; set to null to fix the value at zero in the fit
  IF N_ELEMENTS(RP_RSTAR) EQ 0 AND ~KEYWORD_SET(FIT_SYSTEM) THEN rp_rstar = 0.09420d
  IF N_ELEMENTS(INCLINATION) EQ 0 AND ~KEYWORD_SET(FIT_SYSTEM) THEN inclination=84.63

  ;;read in the snapshot mode photometry
  starefile = '/Users/jkrick/irac_warm/pcrs_planets/wasp-14b/wasp14_snap_latenterr_150226.txt'
  readcol, starefile, starebmjd, starephase, corrflux, corrfluxerr, format = 'D, F, F, F',/nan

  ;;in this instance want to not include transit and eclipse
 ; good1 = where(starephase gt -0.47 and starephase lt -0.04)
 ; good2 = where(starephase gt 0.03 and starephase lt 0.45)
 ; goodphase = [starephase(good1), starephase(good2)]
 ; goodcorrflux = [corrflux(good1), corrflux(good2)]
 ; goodcorrfluxerr = [corrfluxerr(good1), corrfluxerr(good2)]
 ; goodbmjd = [starebmjd(good1), starebmjd(good2)]
 
  
      
  ;;test output by plotting
  ;;p1 = plot(goodphase, goodcorrflux, '1s', sym_size =0.2, sym_filled= 1, xtitle = 'phase', ytitle = 'corrflux')
     
     ;;now do some fitting
  FIT_PHASE_CURVE,starebmjd,corrflux,exosystem,fstar,albedo,trad,omrot,tperi,tphase,model,$
                     EXODATA=exodata,LAMBDA_BAND='IRAC4.5',VERBOSE=verbose,PARAM_ERR=param_err,$
                     REDUCED_CHI2=reduced_chi2,ECC=ecc,ARGPERI=argperi,$
                     PORBIT=porbit,MJD_TRANSIT=mjd_transit,RP_RSTAR=rp_rstar,AR_SEMIMAJ=ar_semimaj,$
                     INCLINATION=inclination,TPERI_2=tperi_2,MODEL_2=model_2,FUNC=corrfluxerr,$
                     /FIT_SYSTEM ,TPHASE_2=tphase_2,AMPLITUDE=amplitude,PHASE_MAX=phase_max,$
                     PHASE_MIN=phase_min

   
  print, 'final fit amplitude', amplitude, 'phase_max', phase_max, 'phase_min', phase_min
  print, 'param err albedo, trad, omrot', param_err
  print, 'other params', rp_rstar, inclination, mjd_transit
  ;;check duration of code
  print, 'time check: ',systime(1) - t, 'seconds'
end
