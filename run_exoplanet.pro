pro run_exoplanet
;.run nearest_neighbors_DT.pro
;.run nearest_neighbors_np_DT.pro
;.run pixphasecorr_noisepix.pro
;.run selfcal_exoplanet.pro
;.run get_centroids_for_calstar_jk.pro
;.run phot_exoplanet.pro
;.run plot_pixphasecorr.pro

;set up to run for all of my secondaries so they get equal treatment

;---------------------------------------------------------------------
;  phot_exoplanet, 'wasp15'
;  selfcal_exoplanet, 'wasp15', 200L, /binning
;  pixphasecorr_noisepix, 'wasp15', 50
;  plot_pixphasecorr, 'wasp15', 200L, /errorbars, /phaseplot,/selfcal
;  plot_exoplanet, 'wasp15', 200L, /phaseplot
;---------------------------------------------------------------------
;  phot_exoplanet, 'wasp38'
;  selfcal_exoplanet, 'wasp38', 200L, /binning
;  pixphasecorr_noisepix, 'wasp38', 50
;  plot_pixphasecorr, 'wasp38', 200L, /errorbars, /phaseplot,/selfcal
;  plot_exoplanet, 'wasp38', 200L, /phaseplot
;---------------------------------------------------------------------
;  phot_exoplanet, 'wasp16'
;  selfcal_exoplanet, 'wasp16', 200L, /binning
;  pixphasecorr_noisepix, 'wasp16', 50
;  plot_pixphasecorr, 'wasp16', 200L, /errorbars, /phaseplot,/selfcal
;  plot_exoplanet, 'wasp16', 200L, /phaseplot
;---------------------------------------------------------------------
  phot_exoplanet, 'wasp13'
  selfcal_exoplanet, 'wasp13', 200L, /binning
  pixphasecorr_noisepix, 'wasp13', 50
  plot_pixphasecorr, 'wasp13', 200L, /errorbars, /phaseplot,/selfcal
  plot_exoplanet, 'wasp13', 200L, /phaseplot
;---------------------------------------------------------------------
;  phot_exoplanet, 'hat22'
;  selfcal_exoplanet, 'hat22', 200L, /binning
;  pixphasecorr_noisepix, 'hat22', 50
;  plot_pixphasecorr, 'hat22', 200L, /errorbars, /phaseplot,/selfcal
;  plot_exoplanet, 'hat22', 200L, /phaseplot
;---------------------------------------------------------------------
;  phot_exoplanet, 'hd7924'
;  selfcal_exoplanet, 'hd7924', 200L, /binning
;  pixphasecorr_noisepix, 'hd7924', 50
;  plot_pixphasecorr, 'hd7924', 200L, /errorbars, /phaseplot,/selfcal
;  plot_exoplanet, 'hd7924', 200L, /phaseplot
;---------------------------------------------------------------------
;  phot_exoplanet, 'wasp62'  ; just running the snaps for now
;  selfcal_exoplanet, 'wasp62', 200L, /binning
;  pixphasecorr_noisepix, 'wasp62', 50
;  plot_pixphasecorr, 'wasp62', 200L, /errorbars, /phaseplot,/selfcal
;  plot_exoplanet, 'wasp62', 200L, /phaseplot
;---------------------------------------------------------------------
  phot_exoplanet, 'hatp8'  ; just running the snaps for now
  selfcal_exoplanet, 'hatp8', 200L, /binning
  pixphasecorr_noisepix, 'hatp8', 50
  plot_pixphasecorr, 'hatp8', 200L, /errorbars, /phaseplot,/selfcal
  plot_exoplanet, 'hatp8', 200L, /phaseplot
;---------------------------------------------------------------------
;  phot_exoplanet, 'wasp14'  ; just running the snaps for now
;  selfcal_exoplanet, 'wasp14', 200L, /binning
;  pixphasecorr_noisepix, 'wasp14', 50
;  plot_pixphasecorr, 'wasp14', 200L, /errorbars, /phaseplot,/selfcal
;  plot_exoplanet, 'wasp14', 200L, /phaseplot

end
