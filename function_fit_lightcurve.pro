function function_fit_lightcurve, planetname, phasearr, fluxarr, errarr


 ;first pull the info we know from the internet
  exoplanet_data_file = '/Users/jkrick/idlbin/exoplanets.csv'
  exosystem = strmid(planetname, 0, 7) + ' b' ;'HD 209458 b' ;

  get_exoplanet_data,EXOSYSTEM=exosystem,MSINI=msini,MSTAR=mstar,TRANSIT_DEPTH=transit_depth,RP_RSTAR=rp_rstar,AR_SEMIMAJ=ar_semimaj,$
                       TEQ_P=teq_p,TEFF_STAR=teff_star,SECONDARY_DEPTH=secondary_depth,SECONDARY_LAMBDA='4.5',$
                       INCLINATION=inclination,MJD_TRANSIT=mjd_transit,P_ORBIT=p_orbit,EXODATA=exodata,RA=ra,DEC=dec,VMAG=vmag,$
                       DISTANCE=distance,ECC=ecc,T14=t14,F36=f36,F45=f45,FP_FSTAR0=fp_fstar0,/VERBOSE;verbose

  IF N_ELEMENTS(mjd_start) EQ 0 THEN BEGIN
     mjd_start = get_exoplanet_start(p_orbit,mjd_transit,START_HR_BEFORE_TRANSIT=start_hr_before_transit,START_PHASE=start_phase)
  ENDIF 

 
 ;normalize for more understandable plots
 normcorr = mean(fluxarr)
 fluxarr = fluxarr / normcorr
 errarr = errarr / normcorr
 testplot = errorplot(phasearr, fluxarr, errarr, '1s', yrange = [0.985, 1.005])
;Initial guess, start with those from the literature
  params0 = [fp_fstar0, rp_rstar, ar_semimaj, inclination]
  parinfo = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0.D]}, n_elements(params0))
; ;limit fp_f_star0 to be positive and less than 1.
  parinfo[0].limited[0] = 1
  parinfo[0].limits[0] = 0.0 ;;
  parinfo[0].limited[1] = 1
  parinfo[0].limits[1] = 1.0
;  parinfo[0].fixed = 1
; ;limit rp/rf_star to be positive and less than 1.
  parinfo[1].limited[0] = 1
  parinfo[1].limits[0] = 0.0 ;;
  parinfo[1].limited[1] = 1
  parinfo[1].limits[1] = 1.0
; ;limit ar_semimaj to be positive 
  parinfo[2].limited[0] = 1
  parinfo[2].limits[0] = 0.0 ;;
; limit inclination to be positive 
  parinfo[3].limited[0] = 1
  parinfo[3].limits[0] = 0.0 ;;

;do the fitting
  afargs = {t:phasearr, flux:fluxarr, err:errarr, p_orbit:p_orbit, mjd_start:mjd_start, mjd_transit:mjd_transit, savefilename:savefilename};, rp_rstar:rp_rstar ar_semimaj:ar_semimaj,,inclination:inclination}
  pa = mpfit('mandel_agol', params0, FUNCTARGS=afargs, PERROR=spa, BESTNORM=achi, DOF=adof, COVAR = COV, status = status, errmsg = errmsg, parinfo = parinfo);, savefilename = savefilename)

  print, 'status', status
  print, errmsg
  print, 'reduced chi squared',  achi / adof
  

;want to overplot the fitted curve
  params0 = pa  ; just give it the answer, and run with overplot
  ph = findgen(100) / 100. - 0.5   ; give it a nice set of phases for a nice plot
  model = mandel_agol(params0, t=ph, flux=fluxarr, err=errarr, p_orbit=p_orbit, mjd_start=mjd_start, mjd_transit=mjd_transit ,savefilename = savefilename, /overplot);, rp_rstar=rp_rstar, ar_semimaj=ar_semimaj,inclination=inclination,


return, 0
end






