pro run_exoplanet, planetname, binning, nnearest, apradius, chname

;example calling sequence 
;run_exoplanet, ('WASP-14b','HD158460'), 63L, 50, 2.25, '2'
;run_exoplanet, [ 'WASP-13b', 'WASP-15b', 'WASP-16b', 'WASP-16b', 'WASP-38b', 'WASP-62b', 'WASP-62b', 'HAT-P-22','HAT-P-22'], 63L, 50, [2.25, 1.75, 2.0, 2.25, 2.25, 2.25, 2.5, 1.75,2.25], [ '2', '2', '1', '2', '2', '1', '2', '1','2']

;run_exoplanet, ['HD20003', 'WASP-52b'], 63L, 50, 2.25, '2'

;.run nearest_neighbors_DT.pro
;.run nearest_neighbors_np_DT.pro
;.run nearest_neighbors_xyfwhm_DT.pro
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
;  if n_elements(apradius) lt n_elements(planetname) then apradius = intarr(n_elements(planetname)) + apradius
;  if n_elements(chname) lt n_elements(planetname) then chname = intarr(n_elements(planetname)) + chname


;phot_exoplanet_sdcorr, 'HD158460', 2.25,'2', /hybrid

;---------------------------------------------------------------------
  for n = 0, n_elements(planetname) - 1 do begin
;   help, chname(n)
;     snap_darkcorr,chname(n)
     phot_exoplanet, planetname(n), apradius(n),chname(n), /hybrid
;     phot_exoplanet_sdcorr, planetname(n), apradius(n),chname(n), /hybrid

;     selfcal_exoplanet, planetname(n), binning(n), apradius(n), chname(n), /binning
     pixphasecorr_noisepix, planetname(n), nnearest(n), apradius(n), chname(n),/use_np
;     plot_pixphasecorr_staring, planetname(n), binning(n), apradius(n), chname(n), /errorbars, /phaseplot;,/selfcal
;     plot_exoplanet_multiplot, planetname(n), binning(n), apradius(n),chname(n), /timeplot
  endfor

;---------------------------------------------------------------------


end
