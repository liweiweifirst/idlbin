PRO exoplanet_transit_eclipse,theta_phase,ar_semimaj,r,rp_rstar,inclination,star_frac,planet_frac,itransit,ieclipse
  ;;  INPUTS:
  ;;       THETA_PHASE   = Array of true anomaly values, phased to the transit, modulo 2*!dpi (radians).  In a circular
  ;;                       orbit, this is the observed orbital phase converted to radians.  In an elliptical orbit this is
  ;;                       the true anomaly minus the value of the anomaly at transit.
  ;;          AR_SEMIMAJ = Orbital semimajor axis, in units of the stellar radius
  ;;               R     = Array of distances from star to planet, in units of the semimajor axis.
  ;;          RP_RSTAR   = Planetary radius, in units of the stellar radius
  ;;          INCLINATION = Orbital Inclination  (measured from axis of revolution), degrees
  ;;
  ;;   OUTPUTS:
  ;;          STAR_FRAC   = Flux of star as a function of THETA_PHASE, relative to unobstructed stellar flux
  ;;          PLANET_FRAC = Flux of planet as a function of THETA_PHASE, relative to unobstructed planetary flux
  ;;          ITRANSIT = indices of input phase array during which planet is in full transit (!null if no transit)
  ;;          IECLIPSE = indices of input phase array during which planet is in full eclipse (!null if no eclipse)
  ;;
  ;;  Based on Mandel & Agol 2002, "Analytic Light Curves for Planetary Transit Searches", ApJ 580, 171

  itransit = !null
  ieclipse = !null
  ;;; Recondition phases to go between 0 and 2pi
  phase2 = (theta_phase / (2*!dpi)) MOD 1
  ineg = WHERE(phase2 LT 0,nneg)
  IF NNEG GT 0 THEN phase2[ineg] += 1
  theta_phase = phase2 * 2 * !dpi

  degrad = !dpi/180d0
  nt = N_ELEMENTS(theta_phase)
  ;;; Projected distance between centers of planet and star (in units of Rstar):  r/rstar * SQRT(sin^2(theta_phase) + cos^2(i)*cos^2(theta_phase))
  z = r * ar_semimaj * SQRT(1 - COS(theta_phase)^2 * SIN(inclination * degrad)^2)
  ;;; Planet radius in units of Rstar:
  p = rp_rstar
  kappa_1 = ACOS( (1-p^2+z^2)/(2*z) )
  kappa_2 = ACOS( (p^2+z^2-1)/(2*p*z) )
  lambda_2 = (kappa_1 + p^2*kappa_2 - 0.5*SQRT( 4*z^2 - (1 + z^2 - p^2)^2 ))/!dpi

  i1 = WHERE( (z GT (1+P)) OR (0.5*!dpi LT theta_phase AND 1.5*!dpi GE theta_phase),n1)     ;; Out of transit
  i2 = WHERE( z GT (1-P) AND z LE (1+P) AND (theta_phase GT 1.5*!dpi OR theta_phase LE 0.5*!dpi),n2)   ;;; Partial transit
  i3 = WHERE( z LE (1-P)  AND (theta_phase GT 1.5*!dpi OR theta_phase LE 0.5*!dpi),n3)  ;; Full Transit
  lambda_star = DBLARR(nt)  ;;; Obscured fraction of stellar area
  IF n1 NE 0 THEN lambda_star[i1] = 0.0
  IF n2 NE 0 THEN lambda_star[i2] = lambda_2[i2]
  IF n3 NE 0 THEN BEGIN
    lambda_star[i3] = p^2
    itransit = i3
  ENDIF

  i1 = WHERE( (z GT (1+P)) OR (theta_phase GT 1.5*!dpi OR theta_phase LE 0.5*!dpi),n1)   ;; Out of contact
  i2 = WHERE( z GT (1-P) AND z LE (1+P) AND (0.5*!dpi LT theta_phase AND 1.5*!dpi GE theta_phase),n2)   ;;; Partial occultation
  i3 = WHERE( z LE (1-P)  AND (0.5*!dpi LT theta_phase AND 1.5*!dpi GE theta_phase),n3)    ;;; full occultaiton
  lambda_planet = DBLARR(nt)   ;;; Obscured fraction of planetary area
  IF n1 NE 0 THEN lambda_planet[i1] = 0.0
  IF n2 NE 0 THEN lambda_planet[i2] = lambda_2[i2]/P^2
  IF n3 NE 0 THEN BEGIN
    lambda_planet[i3] = 1.0
    ieclipse = i3
  ENDIF

  star_frac = 1.0 - lambda_star
  planet_frac = 1.0 - lambda_planet

  RETURN
END

