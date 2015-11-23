pro run_driver_trans_sec_phase_ramp, planetname, chname, apradius, pmapname, bin_level
  ;;run_driver_trans_sec_phase_ramp, 'WASP-14b', '2', 2.25, '150723',63L
  COMMON bin_block, aorname, planethash, bin_xcen, bin_ycen, bin_bkgd, bin_flux, bin_fluxerr,  bin_timearr, bin_phase, bin_ncorr,bin_np, bin_npcent, bin_xcenp, bin_ycenp, bin_bkgdp, bin_fluxp, bin_fluxerrp,  bin_corrfluxp,  bin_timearrp, bin_corrfluxerrp,  bin_phasep,  bin_ncorrp, bin_nparrp, bin_npcentarrp, bin_bmjdarr, bin_xfwhm, bin_yfwhm,  bin_corrflux_dp

  COMMON data, bjd_tot, flux_tot, nbr_ind, gw, err, time_tot, nonlin_c

  
  ;;---------------------------------------------------------------
  ;;make the appropriate save file as input to Nikole's code
  ;;---------------------------------------------------------------
  savename1 = strcompress('/Users/jkrick/irac_warm/pcrs_planets/' + planetname + '/'+ planetname +'_phot_ch'+chname+'_'+string(apradius)+'_' + pmapname + '.sav',/remove_all)
  savename2 = strcompress('/Users/jkrick/irac_warm/pcrs_planets/' + planetname + '/'+ 'fitting_input_phot_ch'+chname+'_'+string(apradius)+'_' + pmapname + '.sav',/remove_all)
  restore, savename1
  nonlin_c=[0.0225, 0.3828, -0.2748, -0.0522] ; from wong et al. 2015 for WASP-14b
  
  aorname = [ 'r45426688','r45428224', 'r45428480', 'r45428736','r45428992' ] ; start with stares only
  
  for a = 0, n_elements(aorname) - 1 do begin
     ;;check if I should be using pmap corr or not
     ncorr = where(finite([ planethash[aorname(a),'corrflux']]) gt 0, corrcount,/L64)
     ;;if 20% of the values are correctable than go with the pmap corr 
     print, '0.2nflux, ncorr, ', 0.2*n_elements([planethash[aorname(a),'flux']]), corrcount
     if corrcount gt 0.2*n_elements([planethash[aorname(a),'flux']]) then pmapcorr = 1 else pmapcorr = 0
     
     ;;do some binning at least for the tests
     junkpar = binning_function(a, bin_level, pmapcorr,chname)
     ;;print, 'bin_bmjdarr', bin_bmjdarr[0:10]
     if a eq 0 then bin_corrflux_dp = bin_corrflux_dp + 0.0001
     print, 'pmapcorr', pmapcorr
     if pmapcorr gt 0 then begin
        if a eq 0 then begin
           bjd_tot = bin_bmjdarr
           flux_tot = bin_corrflux_dp 
           err_tot = bin_corrfluxerrp
           phase_tot = bin_phasep
           ;;to switch back to unbinned
           ;;bjd_tot = planethash[aorname(a),'bmjdarr']
           ;;flux_tot = planethash[aorname(a),'corrflux_d']
           ;;err_tot = planethash[aorname(a),'corrfluxerr']
        endif else begin
           bjd_tot = [bjd_tot, bin_bmjdarr]
           flux_tot = [flux_tot, bin_corrflux_dp]
           err_tot = [err_tot, bin_corrfluxerrp]
           phase_tot = [phase_tot, bin_phasep]
           ;;bjd_tot = [bjd_tot, planethash[aorname(a),'bmjdarr']]
           ;;flux_tot = [flux_tot, planethash[aorname(a),'corrflux_d']]
           ;;err_tot = [err_tot, planethash[aorname(a),'corrfluxerr']]
        endelse
     endif
     
  endfor
  ;;normalize
  se = where(phase_tot gt 0.47 and phase_tot lt 0.51, secount)
  ph = where(phase_tot lt 0.6 and phase_tot gt 0.55, phcount)
  plot_corrnorm =  mean(flux_tot(ph),/nan)
  plot_corrnorm = 0.05775
  ;;print, 'plot_corrnorm', plot_corrnorm
  flux_tot = flux_tot / plot_corrnorm
  err_tot = err_tot/plot_corrnorm
  ;;print, 'flux_tot', flux_tot[0:10]
  ;;print, 'err_tot', err_tot[0:10]
  ;;print, 'bjd_tot', bjd_tot[0:10]
  ;;test inputs
  p1 = errorplot(bjd_tot, flux_tot, err_tot, xtitle = 'bjd', ytitle = 'flux', yrange = [0.987, 1.003])
  ;print, 'flux_tot', flux_tot[0:20]
  ;print, 'bjd_tot', bjd_tot[0:20]
  ;print, 'err_tot', err_tot[0:20]
  
   ;;I don't really need the rest so make them up for now
  nbr_ind = findgen(n_elements(bjd_tot))
  gw = 1.0
  time_tot = bjd_tot
     
 
  save, bjd_tot, flux_tot, nbr_ind, gw, err_tot, time_tot, nonlin_c, filename=savename2

  ;;---------------------------------------------------------------
  ;;call Nikole's code
  ;;---------------------------------------------------------------
  outfile = strcompress('/Users/jkrick/irac_warm/pcrs_planets/' + planetname + '/'+ 'fitting_output_phot_ch'+chname+'_'+string(apradius)+'_' + pmapname + '.sav',/remove_all)
  driver_trans_sec_phase_ramp_jk, 2, 'flat', 0, 0, outfile
;;  driver_trans_sec_phase_ramp_jk, 2, 'cowan', 0, 0, outfile

  restore, outfile
  pfit = plot(bjd_tot, trans,  overplot = p1, color = 'cyan', thick = 2)

end
