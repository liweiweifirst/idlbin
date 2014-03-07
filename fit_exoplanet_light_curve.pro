pro fit_exoplanet_light_curve, exosystem
 ;first pull the info we know from the internet
  exoplanet_data_file = '/Users/jkrick/idlbin/exoplanets.csv'
 
  get_exoplanet_data,EXOSYSTEM=exosystem,MSINI=msini,MSTAR=mstar,TRANSIT_DEPTH=transit_depth,RP_RSTAR=rp_rstar,AR_SEMIMAJ=ar_semimaj,$
                       TEQ_P=teq_p,TEFF_STAR=teff_star,SECONDARY_DEPTH=secondary_depth,SECONDARY_LAMBDA=4.5,$
                       INCLINATION=inclination,MJD_TRANSIT=mjd_transit,P_ORBIT=p_orbit,EXODATA=exodata,RA=ra,DEC=dec,VMAG=vmag,$
                       DISTANCE=distance,ECC=ecc,T14=t14,F36=f36,F45=f45,FP_FSTAR0=fp_fstar0,VERBOSE=verbose

  IF N_ELEMENTS(mjd_start) EQ 0 THEN BEGIN
     mjd_start = get_exoplanet_start(p_orbit,mjd_transit,START_HR_BEFORE_TRANSIT=start_hr_before_transit,START_PHASE=start_phase)
  ENDIF 

  ;then I need final phase and flux for the fits
 filename = '/Users/jkrick/irac_warm/pcrs_planets/wasp14/hybrid_pmap_nn/wasp14_phot_ch2_2.50000.sav'
 restore, filename
 aorname = [ 'r45428992', 'r45428736', 'r45428480', 'r45428224', 'r45426688', 'r45838592', 'r45840128', 'r45841408', 'r45842176', 'r45842944', 'r45844480', 'r45845248', 'r45846016', 'r45846784', 'r45839104', 'r45840896', 'r45841664', 'r45842432', 'r45843200', 'r45844736', 'r45845504', 'r45846272', 'r45847040', 'r45839616', 'r45841152', 'r45841920','r45843968','r45843712','r45843456','r45840640','r45840384','r45839872','r45839360','r45838848','r45838336','r48688384','r48688128','r48687872','r48687616','r48683776','r48683264', 'r48682752','r48682240','r48681472','r48681216','r48680704'] 
 for a = 0, n_elements(aorname) -1 do begin
    meanclip, planethash[aorname(a),'corrflux'], meancorr, sigmacorr
    ;XXabomination for the purpose of testing fitting
    sigmacorr =sigmacorr/2
    if a eq 0 then phasearr = [median(planethash[aorname(a),'phase'])] else phasearr = [phasearr, median(planethash[aorname(a),'phase'])]
    if a eq 0 then fluxarr = [meancorr] else fluxarr = [fluxarr, meancorr]
    if a eq 0 then errarr = [sigmacorr] else errarr = [errarr, sigmacorr]
 endfor

 ;now sort the arrays since they are taken at random phase
 sp = sort(phasearr)
 phasearr = phasearr[sp]
 fluxarr = fluxarr[sp]
 errarr = errarr[sp]

 ;and normalize for more understandable plots
 normcorr = mean(fluxarr)
 fluxarr = fluxarr / normcorr
 errarr = errarr / normcorr
 testplot = errorplot(phasearr, fluxarr, errarr, '1s', yrange = [0.985, 1.005])

;Initial guess
  params0 = [0.002]
  parinfo = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0.D]}, n_elements(params0))
; ;limit fp/f_star to be positive
  parinfo[0].limited[0] = 1
  parinfo[0].limits[0] = 0.0 ;;
  
;do the fitting
  afargs = {t:phasearr, flux:fluxarr, err:errarr, p_orbit:p_orbit, mjd_start:mjd_start, mjd_transit:mjd_transit, ar_semimaj:ar_semimaj,inclination:inclination, rp_rstar:rp_rstar}
  pa = mpfit('mandol_agol', params0, FUNCTARGS=afargs, PERROR=spa, BESTNORM=achi, DOF=adof, COVAR = COV, status = status, errmsg = errmsg, parinfo = parinfo)

  print, 'status', status
  print, errmsg
  print, 'reduced chi squared',  achi / adof
  

;want to overplot the fitted curve
  params0 = pa  ; just give it the answer, and run with overplot
  ph = findgen(100) / 100. - 0.5   ; give it a nice set of phases for a nice plot
  print, ph
  model = mandol_agol(params0, t=ph, flux=fluxarr, err=errarr, p_orbit=p_orbit, mjd_start=mjd_start, mjd_transit=mjd_transit, ar_semimaj=ar_semimaj,inclination=inclination, rp_rstar=rp_rstar,  /overplot)
end




function mandol_agol,params0, t = t, flux = flux, err = err, p_orbit =p_orbit, mjd_start =mjd_start, mjd_transit =mjd_transit, ar_semimaj = ar_semimaj,inclination = inclination, rp_rstar = rp_rstar, overplot = overplot

;; inputs
;p_orbit
;mjd_start  ; XXX do I really need this if using my own phase as input anyway?

;;want to be fitting
;mjd_transit
;ar_semimaj
;inclination
;rp_rstar

;start simple and just try fitting one of these parameters = rp_rstar
; need to be able to take inpit as phase, flux, might be better to
; have one flux value per AOR

;taken from Jim;s exoplanet_light_curve.pro
;nt = 1000.
;nperiod = 1.
;t = DINDGEN(nt) / (nt-1) * nperiod * p_orbit + mjd_start
;tdiff = (t-mjd_transit)/P_ORBIT MOD 1   ;;; number of orbits since nearest transit (can be negative)

;phase = tdiff
;ilow = WHERE(phase LT -0.5,nlow)
;IF nlow NE 0 THEN phase[ilow] += 1
;ihi = WHERE(phase GT 0.5,nhi)
;IF nhi NE 0 THEN phase[ihi] -= 1
 
phase = t
tdiff = t
nt = n_elements(phase)

ineg = WHERE(tdiff LT 0 ,nneg)
IF nneg NE 0 THEN tdiff[ineg]  += 1   ;; "positivize" the number of orbits
phi_orbit = 2*!dPI * tdiff  ;; phi goes from 0 to 2*!pi
z = ar_semimaj * SQRT(1 - COS(phi_orbit)^2 * SIN(inclination/!radeg)^2)

p = rp_rstar
kappa_1 = ACOS( (1-p^2+z^2)/(2*z) )
kappa_2 = ACOS( (p^2+z^2-1)/(2*p*z) )
lambda_2 = (kappa_1 + p^2*kappa_2 - 0.5*SQRT( 4*z^2 - (1 + z^2 - p^2)^2 ))/!dpi

i1 = WHERE( (z GT (1+P)) OR (0.5*!dpi LT phi_orbit AND 1.5*!dpi GE phi_orbit),n1)     ;; Out of transit
i2 = WHERE( z GT (1-P) AND z LE (1+P) AND (phi_orbit GT 1.5*!dpi OR phi_orbit LE 0.5*!dpi),n2)   ;;; Partial transit
i3 = WHERE( z LE (1-P)  AND (phi_orbit GT 1.5*!dpi OR phi_orbit LE 0.5*!dpi),n3)  ;; Full Transit
lambda_star = DBLARR(nt)
IF n1 NE 0 THEN lambda_star[i1] = 0.0
IF n2 NE 0 THEN lambda_star[i2] = lambda_2[i2]
IF n3 NE 0 THEN lambda_star[i3] = p^2

i1 = WHERE( (z GT (1+P)) OR (phi_orbit GT 1.5*!dpi OR phi_orbit LE 0.5*!dpi),n1)   ;; Out of contact
i2 = WHERE( z GT (1-P) AND z LE (1+P) AND (0.5*!dpi LT phi_orbit AND 1.5*!dpi GE phi_orbit),n2)   ;;; Partial occultation
i3 = WHERE( z LE (1-P)  AND (0.5*!dpi LT phi_orbit AND 1.5*!dpi GE phi_orbit),n3)    ;;; full occultaiton
lambda_planet = DBLARR(nt)
IF n1 NE 0 THEN lambda_planet[i1] = 0.0
IF n2 NE 0 THEN lambda_planet[i2] = lambda_2[i2]/P^2
IF n3 NE 0 THEN lambda_planet[i3] = 1.0

alpha = ABS(phi_orbit-!dpi)
phase_curve = (sin(alpha) + (!dpi-alpha)*cos(alpha))/!dpi  ;; Phase curve for a Lambert sphere
rel_flux = (1-lambda_star) + params0[0] * (1-lambda_planet) * phase_curve
;rel_flux = (1-lambda_star) + fp_fstar0 * (1-lambda_planet) * phase_curve

model = rel_flux
model = (flux - model) / err


if keyword_set(overplot) then begin
   test = plot(phase, rel_flux, color = 'Sky Blue', thick = 4, /overplot)
endif


return, model
end


function fpa1_xfunc3, p, FLUX=flux, DX=dx, DY=dy, T=t, ERR=err
; p is parameters, f0, a1..a5
; t is time
    n = n_elements(dx)
    model = dblarr(n) + p[0]

    scale = p[1] * dx + p[2] * dy + p[3] * dx * dy + p[4] * dx * dx + $
            p[5] * dy * dy 
    dt = t - min(t)
    
    model = model * (1. + scale) 
    
    ;now add in the sin curve (XXX)
    model = model + p[6]*sin(t/p[7] + p[8]) 
 

   model = (flux - model) / err

return, model
end
