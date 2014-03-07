pro run_exoplanet, planetname, binning, nnearest, apradius
;example calling sequence run_exoplanet, 'wasp14', 63L, 50, 3.0

;.run nearest_neighbors_DT.pro
;.run nearest_neighbors_np_DT.pro
;.run pixphasecorr_noisepix.pro
;.run selfcal_exoplanet.pro
;.run get_centroids_for_calstar_jk.pro
;.run phot_exoplanet.pro
;.run plot_pixphasecorr.pro
;.run create_planetinfo.pro

;binning and nnearest can either have one value for all planets to be
;run, or they can be arrays with different values for each planet
  if n_elements(binning) lt n_elements(planetname) then binning = intarr(n_elements(planetname)) + binning
  if n_elements(nnearest) lt n_elements(planetname) then nnearest = intarr(n_elements(planetname)) + nnearest
  if n_elements(apradius) lt n_elements(planetname) then apradius = intarr(n_elements(planetname)) + apradius

;---------------------------------------------------------------------
  for n = 0, n_elements(planetname) - 1 do begin
;     phot_exoplanet, planetname(n), apradius(n)
;     selfcal_exoplanet, planetname(n), binning(n), apradius(n), /binning
;     pixphasecorr_noisepix, planetname(n), nnearest(n), apradius(n)
;     plot_pixphasecorr, planetname(n), binning(n), apradius(n), /errorbars, /phaseplot,/selfcal
     plot_exoplanet, planetname(n), binning(n), apradius(n),/phaseplot
  endfor

;---------------------------------------------------------------------


end
