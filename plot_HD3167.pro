pro plot_HD3167, planetname, bin_level, apradius, chname,

  COMMON bin_block, aorname, planethash, bin_xcen, bin_ycen, bin_bkgd, bin_flux, bin_fluxerr,  bin_timearr, bin_phase, bin_ncorr,bin_np, bin_npcent, bin_xcenp, bin_ycenp, bin_bkgdp, bin_fluxp, bin_fluxerrp,  bin_corrfluxp,  bin_timearrp, bin_corrfluxerrp,  bin_phasep,  bin_ncorrp, bin_nparrp, bin_npcentarrp, bin_bmjdarr, bin_xfwhm, bin_yfwhm,  bin_corrflux_dp, bin_bmjdarrp
  
  colorarr = ['red','blue']
  
  
  
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
  exoplanet_data_file = '/Users/jkrick/idlbin/exoplanets.csv'
  exosystem = strmid(planetname, 0, 8 )+ ' b' ;'HD 209458 b' ;

  if planetname eq 'HD3167' then exosystem = 'HD 3167 b'
  
  print, exosystem, 'exosystem'
  if planetname eq 'WASP-52b' then teq_p = 1315
  if planetname eq 'HD 7924 b' then begin
     inclination = 85.
     rp_rstar = 0.001
  endif
  
  if chname eq '2' then lambdaname  = '4.5'
  if chname eq '1' then lambdaname  = '3.6'
  get_exoplanet_data,EXOSYSTEM=exosystem,MSINI=msini,MSTAR=mstar,TRANSIT_DEPTH=transit_depth,RP_RSTAR=rp_rstar,AR_SEMIMAJ=ar_semimaj,$
                     TEQ_P=1315,TEFF_STAR=teff_star,SECONDARY_DEPTH=secondary_depth,SECONDARY_LAMBDA=lambdaname,$
                     INCLINATION=inclination,MJD_TRANSIT=mjd_transit,P_ORBIT=p_orbit,EXODATA=exodata,RA=ra,DEC=dec,VMAG=vmag,$
                     DISTANCE=distance,ECC=ecc,T14=t14,F36=f36,F45=f45,FP_FSTAR0=fp_fstar0,/verbose
  utmjd_center = planetinfo[planetname, 'utmjd_center']
  period = planetinfo[planetname, 'period']


;---------------
  
  dirname = strcompress(basedir + planetname +'/')                                                            ;+'/hybrid_pmap_nn/')
  if chname eq '2' then  savefilename = strcompress(dirname + planetname +'_phot_ch'+chname+'_'+string(apradius)+'_160126.sav',/remove_all) 
  if chname eq '1' then  savefilename = strcompress(dirname + planetname +'_phot_ch'+chname+'_'+string(apradius)+'_150722.sav',/remove_all) 
  print, 'restoring ', savefilename
  restore, savefilename
  print, 'aorname', aorname(0)
  time_0 = (planethash[aorname(0),'timearr']) 
  time_0 = time_0(0)
 

;for debugging: skip some AORs
  startaor =  0                 ;  n_elements(aorname) -29
  stopaor =    n_elements(aorname) - 2 ; ignore the last AOR


  xsweet = 15.12
  ysweet = 15.00
 

;setup some arrays to hold binned values
  bin_corrfluxfinal = fltarr(n_elements(aorname))
  bin_phasefinal = fltarr(n_elements(aorname))
  bin_corrfluxerrfinal = fltarr(n_elements(aorname))

  mean_corrfluxarr = fltarr(stopaor - startaor + 1,/nozero)
  mean_dsweetarr = mean_corrfluxarr
  stddev_corrfluxarr = mean_corrfluxarr
  stddev_dsweetarr = mean_corrfluxarr
 

;pick the normalization
  phase0 = planethash[aorname(0),'phase']
  corrflux0 = planethash[aorname(0),'corrflux_d']
  se = where(phase0 gt 0.47 and phase0 lt 0.51)
  
  plot_corrnorm =  mean(corrflux0,/nan)
  
  for a = startaor,stopaor do begin
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

;------------------------------------------------------
     ;possible comparison statistic
     ;what is the distribution of standard deviations among the corrfluxes?

     meanclip_jk, planethash[aorname(a),'corrflux'] , mean_corrflux, stddev_corrflux
     stddev_corrfluxarr[a - startaor] = stddev_corrflux
;------------------------------------------------------
     ;save some variables for later
     if a eq startaor then begin
        bin_all_phasep = bin_phasep
        bin_all_corrfluxp = bin_corrfluxp
        bin_all_fluxerrp = bin_fluxerrp
        bin_all_corrfluxerrp = bin_corrfluxerrp
        bin_all_time = bin_timearr
     endif else begin
        bin_all_phasep = [bin_all_phasep, bin_phasep]
        bin_all_corrfluxp = [bin_all_corrfluxp, bin_corrfluxp]
        bin_all_corrfluxerrp = [bin_all_corrfluxerrp, bin_corrfluxerrp]
        bin_all_fluxerrp = [bin_all_fluxerrp, bin_fluxerrp]
        bin_all_time = [bin_all_time,bin_timearr]

     endelse


;now try plotting

 ;------------------------------------------------------
     plotsym = 's'
     setyrange = [0.994, 1.005]

;------------------------------------------------------
     corroffset = 0.0000
     print, 'making plot as a function of time'
     corrnormoffset = .008
     setynormfluxrange = [0.995, 1.008] ;[0.97, 1.005]
     time_0 = bin_timearr(0)
     if a eq startaor then begin ; for the first AOR
        ;;set the normalization values from the
        ;;medians of the first AOR...is close enough
        ;;plot_corrnorm = median(bin_corrfluxp)
        print, 'plot_corrnorm', plot_corrnorm, mean(bin_corrfluxp,/nan), corroffset
        plot_norm = median(bin_flux)
        pp = plot((bin_timearr - time_0)/60./60., bin_xcen, '1s', sym_size = 0.3,   sym_filled = 1, $ ;title = planetname, $
                  color = colorarr[a], xtitle = 'Time(hrs)', ytitle = 'X position', aspect_ratio = 0.0, margin = 0.2) ;, $
                                ;xrange = setxrange)
        
        
        pqy = plot((bin_timearr - time_0)/60./60., bin_ycen, '1s', sym_size = 0.3, sym_filled = 1, color = colorarr[a], $
                   xtitle = 'Time(hrs)', ytitle = 'Y position', aspect_ratio = 0.0, margin = 0.2) ;, $, title = planetname
                                ;xrange = setxrange)
        
        
        if pmapcorr eq 1 then begin
           print, 'inside pmapcorr eq 1', median(bin_corrfluxp), median(bin_flux)
           pr = plot((bin_timearr - time_0)/60./60., (bin_corrfluxp/plot_corrnorm) ,  '1s', $
                     sym_size = 0.3,   sym_filled = 1, color = colorarr[a],  xtitle = 'Time(hrs)', $
                     ytitle = 'Normalized Corrected Flux', title = planetname, $
                     yrange = setynormfluxrange, aspect_ratio = 0.0, margin = 0.2)
           
        endif                   ;enough pmap corrections
        
        ps= plot((bin_timearr - time_0)/60./60., bin_npcent, '1s', sym_size = 0.3,   sym_filled = 1,  color = colorarr[a], $
                 xtitle = 'Time(hrs)', ytitle = 'Noise Pixel',  aspect_ratio = 0.0, margin = 0.2) ;,$ title = planetname,
                                ;xrange = setxrange)
        
        pt = plot((bin_timearr - time_0)/60./60., bin_bkgd, '1s', sym_size = 0.3,   sym_filled = 1,  color = colorarr[a], $
                  xtitle = 'Time(hrs)', ytitle = 'Background',  aspect_ratio = 0.0, margin = 0.2) ;, $ title = planetname,
                                ; xrange =setxrange)
        
        pxf = plot((bin_timearr - time_0)/60./60., bin_xfwhm, '1s', sym_size = 0.3,   sym_filled = 1,  color = colorarr[a], $
                   xtitle = 'Time(hrs)', ytitle = 'XFWHM',  aspect_ratio = 0.0, margin = 0.2) ;, $ title = planetname,
        
        pyf = plot((bin_timearr - time_0)/60./60., bin_yfwhm, '1s', sym_size = 0.3,   sym_filled = 1,  color = colorarr[a], $
                   xtitle = 'Time(hrs)', ytitle = 'YFWHM',  aspect_ratio = 0.0, margin = 0.2) ;, $ title = planetname,
        

     endif                      ; if a = 0

     if (a gt 0)  then begin
        print, 'inside a gt 0 ', a
        pp = plot((bin_timearr - time_0)/60./60., bin_xcen, '1s', sym_size = 0.3,   sym_filled = 1,color = colorarr[a],  overplot=pp)
        pqy = plot((bin_timearr - time_0)/60./60., bin_ycen, '1s', sym_size = 0.3,   sym_filled = 1, color = colorarr[a], overplot=pq)
        ps = plot((bin_timearr - time_0)/60./60., bin_npcent, '1s', sym_size = 0.3,   sym_filled = 1,  color = colorarr[a], overplot=ps) 
        pt = plot((bin_timearr - time_0)/60./60., bin_bkgd, '1s', sym_size = 0.3,   sym_filled = 1,  color = colorarr[a],overplot=pt) 

        if pmapcorr eq 1 then begin
           pr =  plot(((bin_timearrp - time_0)/60./60.) , (bin_corrfluxp/plot_corrnorm) - corrnormoffset, $ ;bin_corrfluxerrp/plot_corrnorm,
                      sym_size = 0.7, symbol = plotsym, sym_filled = 1,$
                      color = colorarr[a], errorbar_color =  colorarr[a], overplot = pr) ;pu
           
        endif
        
     endif
     


 
  endfor                        ;binning for each AOR


 
end


