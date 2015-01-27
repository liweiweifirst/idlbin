; PURPOSE:
;  This code gives the user more information about available PCRS
;  peakup catalog stars.  It is intended to be used in conjunction
;  with Spot where the catalog stars must be chosen for observations.  
;
;  The IRAC instrument support team recommends avoiding stars with
;  large position errors.  Position errors in the output are
;  calculated with an epoch of 2009.5, so are actually larger for the
;  current epoch.  Brighter stars are more desirable because then the
;  peakup integration time will be shorter, although all brightnesses
;  are feasible.  Only catalog stars with angular distances less than
;  ~half a degree are shown as viable catalog stars.  The best star to
;  choose is some combination of position error, V_mag and angular
;  distance.  If this tool shows a star which is not listed in Spot,
;  and it is your choice for the best catalog star, you can always
;  enter it manually as a PCRS peakup star.  The catalog used here is
;  exactly the same as that used in Spot.
;
; INPUTS:
;  ra_deg = ra(J2000) in degrees
;  dec_deg = dec(J2000) in degrees
;  pm_ra = proper motion in ra in arcsec/year in J2000
;  pm_dec = proper motion in dec in arcsec/year in J2000
;  pos_epoch = the epoch which describes the ra and dec inputs (most
;    likely 2000.0)
;  obs_epoch = the planned observing epoch in years eg. 2015.6
;  dirloc = full path to the location of the catalog
;
; OUTPUTS:
;  -RA J2000
;  -DEC J2000
;  -PM RA +/- uncertainty(mas/yr)
;  -PM DEC +/- uncertainty(mas/yr)
;  -Total position error from the PCRS catalog in mas  (mainly pm errors)
;  -Angular distance from target in degrees
;  -Vmag
;  -Source of the position errors = TYCho or HIPpparcos
; 
; *See catalog documentation for how these quantities are derived
;  http://proceedings.spiedigitallibrary.org/proceeding.aspx?articleid=847055
;
; EXAMPLE:
;  pick_pcrs_catalog, 330.79488375, 18.884310, 0.029, -0.019, 2000,
;  2015.5,  '~/external/irac_warm/pcrs_catalog/pubdb_pcrs.unl'
;
; MODIFICATION HISTORY:
;  January 2015 Original Version  JK
;-
pro pick_pcrs_catalog,ra_deg, dec_deg, pm_ra, pm_dec, pos_epoch, obs_epoch, dirloc
;  t = systime(1)
  ;;do some error checking on the inputs
  if (N_params() lt 7) then begin
     print,'Wrong number of inputs - ' + $
           'PICK_PCRS_CATALOG, ra_deg, dec_deg, pm_ra, pm_dec, pos_epoch, obs_epoch, dirloc'
     return
  endif 
  if size(ra_deg,/TYPE) gt 5 then begin
     print, 'RA must be a FLOAT with units of degrees'
     return
  endif
  if size(dec_deg,/TYPE) gt 5 then begin
     print, 'DEC must be a FLOAT with units of degrees'
     return
  endif
  if size(pm_ra,/TYPE) gt 5 then begin
     print, 'Proper Motion RA must be a FLOAT with units of degrees'
     return
  endif
  if size(dec_ra,/TYPE) gt 5 then begin
     print, 'Proper Motion DEC must be a FLOAT with units of degrees'
     return
  endif
  if size(pos_epoch,/TYPE) gt 5 then begin
     print, 'Position Epoch must be an INTeger or FLOAT with units of degrees'
     return
  endif
  if size(obs_epoch,/TYPE) gt 5 then begin
     print, 'Observing Epoch must be an INTeger or FLOAT with units of degrees'
     return
  endif
  if size(dirloc,/TYPE) ne 7 then begin
     print, 'Directory Location must be a string'
     return
  endif
  if obs_epoch le 2004.5 then begin
     print, 'must have an observation epoch after 2004.5'
     return
  endif

     
   ;;read in the pcrs_catalog  
  read_pcrs_catalog, dirloc, star_id, Validity, Q, posEr, pErWk,  vMag, rightAscensn,  declination, prpMtnRA, prpMtnDc,  parllx, magEr,  raErr, declEr, mKER, mKED, plxEr, dOjbE, bkgEr, bstEr, P, M, L, epoch, x, y, z, spt_ind, CNTR
 
  ;;adjust the positions for proper motion from given epoch to the
  ;;planned observation epoch of the target
  if pos_epoch eq obs_epoch then begin
     ;;don't need to change the positions at all
     ra = ra_deg
     dec = dec_deg
     cat_ra = rightAscensn
     cat_dec = declination
  endif else begin
     ;;account for proper motion
     ;;assume zero velocity and zero parallax for now
     delta_t = obs_epoch - pos_epoch
     delta_cat = obs_epoch - 2004.5

     ;;work on the target star proper motion conversion
     ;;unit conversion between as/yr and arcsec/century
     pm_ra = pm_ra * 100.
     pm_dec = pm_dec * 100.
     ADDPM,ra_deg,dec_deg,pm_ra,pm_dec,0,0,delta_t,outra,outdec
     ra = outra
     dec = outdec
     
     ;;work on the catalog stars proper motion conversions
     ;;mas/year to arcsec/century
     cat_pm_ra = prpMtnRA  / 10.
     cat_pm_dec = prpMtnDc  / 10.
     ADDPM,rightAscensn,declination,cat_pm_ra,cat_pm_dec,0,0,delta_cat,cat_ra,cat_dec

  endelse


  ;;calculate the angular distance of the whole catalog from the target
  ;;cos(A) = sin(d1)sin(d2) + cos(d1)cos(d2)cos(ra1-ra2)  spherical trig

  ;;convert all degrees to radians during the process
  cosa = sin(dec*!DTOR)*sin(cat_dec*!DTOR) + cos(dec*!DTOR)*cos(cat_dec*!DTOR)*cos((ra*!DTOR) - (cat_ra*!DTOR))
  angle = acos(cosa) * !RADEG   ; then convert back to degrees

  ;;sort on angular distance to find the nearest catalog stars
  sortangle = sort(angle)
  sort_angle = angle[sortangle]
  sort_id = star_id[sortangle]
  sort_M = M[sortangle]
  sort_ra = rightAscensn[sortangle]
  sort_dec = declination[sortangle]
  sort_pm_ra = prpMtnRA[sortangle]
  sort_pm_dec = prpMtnDc[sortangle]
  sort_raerr = raErr[sortangle]
  sort_decerr = declEr[sortangle]
  sort_poserr = posEr[sortangle]
  sort_vmag = vMag[sortangle]
  
  ;;display a list of the stars with 
  n = where(sort_angle le 0.5, n_angle) ;0.52
  if n_angle eq 0 then print, 'No catalog stars found'
  for i = 0, n_angle - 1 do begin
     if sort_angle[i] le 1.0 then begin
        if i eq 0 then print, '   RA            DEC     EPOCH       PM_RA +-  unc       PM_DEC +- unc      POS_ERR   V_mag   ANG_Dist  SRC'
        if sort_m[i] eq 0 then name = 'HIP' else name = 'TYC'

        print, adstring(sort_ra[i], sort_dec[i]), '2004.5', sort_pm_ra[i], sort_raerr[i], sort_pm_dec[i], sort_decerr[i], $
               sort_poserr[i], sort_vmag[i], sort_angle[i], name, $
               format = '(A, TR3, A, F10.1, F10.1,  F10.1, F10.1, F10.1, F10.2, F10.4, TR3, A)'
     endif

  endfor
;print, 'time check', systime(1) - t
end


