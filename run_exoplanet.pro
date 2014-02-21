pro run_exoplanet
;.run nearest_neighbors_DT.pro
;.run nearest_neighbors_np_DT.pro
;.run pixphasecorr_noisepix.pro
;.run selfcal_exoplanet.pro
;.run get_centroids_for_calstar_jk.pro
;.run phot_exoplanet.pro
;.run plot_pixphasecorr.pro
;.run create_planetinfo.pro

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
;  phot_exoplanet, 'wasp13'
;  selfcal_exoplanet, 'wasp13', 200L, /binning
;  pixphasecorr_noisepix, 'wasp13', 50
;  plot_pixphasecorr, 'wasp13', 200L, /errorbars, /phaseplot,/selfcal
;  plot_exoplanet, 'wasp13', 200L, /phaseplot
;---------------------------------------------------------------------
;  phot_exoplanet, 'hat22'
;  selfcal_exoplanet, 'hat22', 500L, /binning
;  pixphasecorr_noisepix, 'hat22', 50
;  plot_pixphasecorr, 'hat22', 500L, /errorbars, /phaseplot,/selfcal
;  plot_exoplanet, 'hat22', 500L, /phaseplot
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
  selfcal_exoplanet, 'hatp8', 63L, /binning
  pixphasecorr_noisepix, 'hatp8', 50
  plot_pixphasecorr, 'hatp8', 63L, /errorbars, /phaseplot,/selfcal
  plot_exoplanet, 'hatp8', 63L, /phaseplot
;---------------------------------------------------------------------
;  phot_exoplanet, 'wasp14'  ; just running the snaps for now
;  selfcal_exoplanet, 'wasp14', 200L, /binning
;  pixphasecorr_noisepix, 'wasp14', 50
;  plot_pixphasecorr, 'wasp14', 200L, /errorbars, /phaseplot,/selfcal
;  plot_exoplanet, 'wasp14', 200L, /phaseplot
;---------------------------------------------------------------------
;  phot_exoplanet, '55cnc'  ; just running the snaps for now
;  selfcal_exoplanet, '55cnc', 200L, /binning
;  pixphasecorr_noisepix, '55cnc', 50
;  plot_pixphasecorr, '55cnc', 200L, /errorbars, /phaseplot,/selfcal
;  plot_exoplanet, '55cnc', 200L, /phaseplot
;---------------------------------------------------------------------
;  phot_exoplanet, 'hd189733' 
;  selfcal_exoplanet, 'hd189733', 200L, /binning
;  pixphasecorr_noisepix, 'hd189733', 50
;  plot_pixphasecorr, 'hd189733', 200L, /errorbars, /phaseplot,/selfcal
;  plot_exoplanet, 'hd189733', 200L, /phaseplot
;---------------------------------------------------------------------
;  phot_exoplanet, 'wasp12' 
;  selfcal_exoplanet, 'wasp12', 8L, /binning
;  pixphasecorr_noisepix, 'wasp12', 50
;  plot_pixphasecorr, 'wasp12', 8L, /errorbars, /phaseplot,/selfcal
;  plot_exoplanet, 'wasp12', 8L, /phaseplot
;---------------------------------------------------------------------
;  phot_exoplanet, 'hat3' 
;  selfcal_exoplanet, 'hat3', 200L, /binning
;  pixphasecorr_noisepix, 'hat3', 50
;  plot_pixphasecorr, 'hat3', 200L, /errorbars, /phaseplot,/selfcal
;  plot_exoplanet, 'hat3', 200L, /phaseplot
;---------------------------------------------------------------------
;  phot_exoplanet, 'corot2' 
;  selfcal_exoplanet, 'corot2', 63L, /binning
;  pixphasecorr_noisepix, 'corot2', 50
;  plot_pixphasecorr, 'corot2', 63L, /errorbars, /phaseplot,/selfcal
;  plot_exoplanet, 'corot2', 63L, /phaseplot
;---------------------------------------------------------------------
;  phot_exoplanet, 'xo4' 
;  selfcal_exoplanet, 'xo4', 63L, /binning
;  pixphasecorr_noisepix, 'xo4', 50
;  plot_pixphasecorr, 'xo4', 63L, /errorbars, /phaseplot,/selfcal
;  plot_exoplanet, 'xo4', 63L, /phaseplot
;---------------------------------------------------------------------
;  phot_exoplanet, 'hat6'  ; just running the snaps for now
;  selfcal_exoplanet, 'hat6', 63L, /binning
;  pixphasecorr_noisepix, 'hat6', 50
;  plot_pixphasecorr, 'hat6', 63L, /errorbars, /phaseplot,/selfcal
;  plot_exoplanet, 'hat6', 63L, /phaseplot
;---------------------------------------------------------------------
;  phot_exoplanet, 'wasp43'  ; just running the snaps for now
;  selfcal_exoplanet, 'wasp43', 63L, /binning
;  pixphasecorr_noisepix, 'wasp43', 50
;  plot_pixphasecorr, 'wasp43', 63L, /errorbars, /phaseplot,/selfcal
;  plot_exoplanet, 'wasp43', 63L, /phaseplot
;---------------------------------------------------------------------
;  phot_exoplanet, 'NoisePixTest2'  ; just running the snaps for now
;  selfcal_exoplanet, 'NoisePixTest2', 126L, /binning
;  pixphasecorr_noisepix, 'NoisePixTest2', 50
;  plot_pixphasecorr, 'NoisePixTest2', 126L, /errorbars, /phaseplot,/selfcal
;  plot_exoplanet, 'NoisePixTest2', 126L, /phaseplot



end
