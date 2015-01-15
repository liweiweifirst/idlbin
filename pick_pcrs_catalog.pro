; PURPOSE:
;  This code gives the user more information about available PCRS
;  peakup catalog stars.  It is intended to be used in conjunction
;  with SPOT where the catalog stars must be chosen for observations.  
;
;  IRAC recommends avoiding stars with large position errors.  Position
;  errors in the output are calculated with an epoch of 2009.5, so are
;  actually larger for the current epoch.  Brighter stars are more
;  desirable because then the peakup integration time will be shorter,
;  although all brightnesses are feasible.  Only catalog stars with
;  angular distances less than half a degree are shown as viable
;  catalog stars.  The best star to choose is some combination of
;  position error, V_mag and angular distance.
;
; INPUTS:
;  ra_deg = ra(J2000) in degrees
;  dec_deg = dec(J2000) in degrees
;  pm_ra = proper motion in ra in arcsec/year in J2000
;  pm_dec = proper motion in dec in arcsec/year in J2000
;  pos_epoch = the epoch which describes the ra and dec inputs (most
;    likely 2000)
;  obs_epoch = the planned observing epoch in years eg. 2015.6
;
; OUTPUTS:
;  -RA
;  -DEC
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
;  pick_pcrs_catalog, 330.79488375, 18.884310, 0.029, -0.019, 2000, 2015.5
;
; MODIFICATION HISTORY:
;  January 2015 Original Version  JK
;-
pro pick_pcrs_catalog, ra_deg, dec_deg, pm_ra, pm_dec, pos_epoch, obs_epoch

  ;;do some error checking on the inputs
  if (N_params() lt 6) then begin
     print,'Wrong number of inputs - ' + $
           'PICK_PCRS_CATALOG, ra_deg, dec_deg, pm_ra, pm_dec, pos_epoch, obs_epoch'
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

 
  ;;precess from J2000 to the current location of the target
  if pos_epoch eq obs_epoch then begin
     ;;don't need to change the positions at all
     ra = ra_deg
     dec = dec_deg
  endif else begin
     precess, ra_deg, dec_deg ,pos_epoch, obs_epoch   

     ;;account for proper motion
     ;;assume zero velocity and zero parallax for now
     delta_t = obs_epoch - pos_epoch
     ;;unit conversion between as/yr and arcsec/century
     pm_ra = pm_ra * 100.
     pm_dec = pm_dec * 100.
     ADDPM,ra_deg,dec_deg,pm_ra,pm_dec,0,0,delta_t,outra,outdec
     ra = outra
     dec = outdec
  endelse

  ;;read in the pcrs_catalog
  readcol, '~/external/irac_warm/pcrs_catalog/pcrsguidestarcatalog.txt', star_id, junk, junk, Validity, Q, posEr, pErWk,  vMag, rightAscensn,  declination, prpMtnRA, prpMtnDc,  parllx, magEr,  raErr, declEr, mKER, mKED, plxEr, dOjbE, bkgEr, bstEr, P, M, X,/silent

  ;;calculate the angular distance of the whole catalog from the target
  ;;cos(A) = sin(d1)sin(d2) + cos(d1)cos(d2)cos(ra1-ra2)  spherical trig

  ;;convert all degrees to radians during the process
  cosa = sin(dec*!DTOR)*sin(declination*!DTOR) + cos(dec*!DTOR)*cos(declination*!DTOR)*cos((ra*!DTOR) - (rightAscensn*!DTOR))
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
  n = where(sort_angle lt 0.52, n_angle) ;0.52
  if n_angle eq 0 then print, 'No catalog stars found'
  for i = 0, n_angle - 1 do begin
     if sort_angle[i] le 1.0 then begin
        if i eq 0 then print, 'RA              DEC              PM_RA +-  unc       PM_DEC +- unc      POS_ERR   V_mag   ANG_Dist  SRC'
        e = sixty(sort_ra[i]/15.)
        f = sixty(sort_dec[i],/TrailSign)
        ;;make pretty-er output
        print_ra = strmid(strtrim(string(e[0]),1),0,2) + 'h' + strmid(strtrim(string(e[1]), 1),0,2) + 'm' + $
                   strmid(strtrim(string(e[2]), 1),0,5) + 's' 
        if f[0] gt 0 then print_dec = strmid(strtrim(string(f[0]),1),0,2) + 'd' + strmid(strtrim(string(f[1]), 1),0,2) +  $
                                      'm' + strmid(strtrim(string(f[2]), 1),0,5) + 's' $
        else print_dec = strmid(strtrim(string(f[0]),1),0,3) + 'd' + strmid(strtrim(string(f[1]), 1),0,2) + 'm' +  $
                         strmid(strtrim(string(f[2]), 1),0,5) + 's'
        if sort_m[i] eq 0 then name = 'HIP' else name = 'TYC'

        print, print_ra, print_dec, sort_pm_ra[i], sort_raerr[i], sort_pm_dec[i], sort_decerr[i], $
               sort_poserr[i], sort_vmag[i], sort_angle[i], name, $
               format = '(A, TR3, A, F10.1, F10.1,  F10.1, F10.1, F10.1, F10.2, F10.4, TR3, A)'
     endif

  endfor

end
