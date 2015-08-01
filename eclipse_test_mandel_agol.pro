pro eclipse_test_mandel_agol, planetname, bin_level, apradius, chname
;planetname = 'XO3'

  COMMON bin_block, aorname, planethash, bin_xcen, bin_ycen, bin_bkgd, bin_flux, bin_fluxerr,  bin_timearr, bin_phase, bin_ncorr,bin_np, bin_npcent, bin_xcenp, bin_ycenp, bin_bkgdp, bin_fluxp, bin_fluxerrp,  bin_corrfluxp,  bin_timearrp, bin_corrfluxerrp,  bin_phasep,  bin_ncorrp, bin_nparrp, bin_npcentarrp, bin_bmjdarr, bin_xfwhm, bin_yfwhm,  bin_corrflux_dp

aornum = 11

;run code to read in all the input planet parameters
  planetinfo = create_planetinfo()
  if chname eq '2' then aorname= planetinfo[planetname, 'aorname_ch2'] else aorname = planetinfo[planetname, 'aorname_ch1'] 
  basedir = planetinfo[planetname, 'basedir']
  period =  planetinfo[planetname, 'period']
  stareaor = planetinfo[planetname, 'stareaor']
  print, 'stareaor', stareaor
  exoplanet_data_file = '/Users/jkrick/idlbin/exoplanets.csv'
  exosystem = strmid(planetname, 0, 8 )+ ' b' ;'HD 209458 b' ;
  
  planetinfo = create_planetinfo()
  if chname eq '2' then aorname= planetinfo[planetname, 'aorname_ch2'] else aorname = planetinfo[planetname, 'aorname_ch1'] 
  basedir = planetinfo[planetname, 'basedir']
  period =  planetinfo[planetname, 'period']
  stareaor = planetinfo[planetname, 'stareaor']

  dirname = strcompress(basedir + planetname +'/')       
  savefilename = strcompress(dirname + planetname +'_phot_ch'+chname+'_'+string(apradius)+'_150226.sav',/remove_all) ;
  print, 'restoring ', savefilename
  restore, savefilename
  print, 'aorname', aorname(0)
  time_0 = (planethash[aorname(0),'timearr']) 
  time_0 = time_0(0)

  modelfilename = strcompress(dirname + planetname +'_model_ch'+chname+'_'+string(apradius)+'.sav',/remove_all)


;pick the normalization
  phase0 = planethash[aorname(aornum),'phase']
  corrflux0 = planethash[aorname(aornum),'corrflux_d']
  se = where(phase0 gt 0.47 and phase0 lt 0.51)
  
  plot_corrnorm =  mean(corrflux0,/nan)
  startaor = 11
  stopaor = 20
  for a = startaor,stopaor, 2 do begin
     print, '------------------------------------------------------'
     print, 'working on AOR', a, '   ', aorname(a), startaor
 
     ;check if I should be using pmap corr or not
     ncorr = where(finite([ planethash[aorname(a),'corrflux']]) gt 0, corrcount,/L64)
     ;if 20% of the values are correctable than go with the pmap corr 
     print, '0.2nflux, ncorr, ', 0.2*n_elements([planethash[aorname(a),'flux']]), corrcount
     if corrcount gt 0.2*n_elements([planethash[aorname(a),'flux']]) then pmapcorr = 1 else pmapcorr = 0
     print, 'pmapcorr', pmapcorr
     
     junkpar = binning_function(a, bin_level, pmapcorr,chname)

     ;use time degraded corrfluxes
     bin_corrfluxp = bin_corrflux_dp

     ;fake that this is a transit/ not eclipse
     bin_phasep = bin_phasep - 0.585
     pu = errorplot(bin_phasep, (bin_corrfluxp/plot_corrnorm), $
                             bin_corrfluxerrp/plot_corrnorm,  '1s', sym_size = 0.3,  $
                              sym_filled = 1,color ='black' ,xtitle = 'Orbital Phase',$
                             errorbar_color =  scolor, title = aorname(a), ytitle = 'Pmap Corrected Flux')


     test = function_fit_lightcurve(planetname, bin_phasep, bin_corrfluxp/plot_corrnorm,  bin_corrfluxerrp/plot_corrnorm, modelfilename)
     p2 = plot(findgen(20) - 5, fltarr(20) + 1.0 - 0.001696, overplot = pu, xrange = [-0.08, 0.06])
  endfor

end
