pro plot_wasp14_snaps, bin_level, time_plot = time_plot, position_plot=position_plot, unbinned_bkgplot=unbinned_bkgplot, normalize = normalize

  COMMON bin_block, aorname, planethash, bin_xcen, bin_ycen, bin_bkgd, bin_flux, bin_fluxerr,  bin_timearr, bin_phase, bin_ncorr,bin_np, bin_npcent, bin_xcenp, bin_ycenp, bin_bkgdp, bin_fluxp, bin_fluxerrp,  bin_corrfluxp,  bin_timearrp, bin_corrfluxerrp,  bin_phasep,  bin_ncorrp, bin_nparrp, bin_npcentarrp, bin_bmjdarr, bin_xfwhm, bin_yfwhm, bin_corrflux_dp

  colorarr = ['gray', 'gray','gray','gray','gray','burlywood','sandy_brown', 'rosy_brown','saddle_brown', 'brown', 'maroon', 'firebrick', 'crimson', 'salmon', 'orange_red', 'dark_orange', 'orange', 'goldenrod', 'gold', 'yellow','khaki', 'green_yellow', 'lime', 'lime_green', 'green', 'dark_green', 'olive', 'olive_drab', 'sea_green', 'light_green', 'medium_spring_green', 'medium_sea_green', 'teal', 'cadet_blue', 'aquamarine', 'cyan', 'light_sky_blue', 'dodger_blue', 'steel_blue', 'blue', 'dark_blue', 'indigo', 'medium_slate_blue', 'purple', 'blue_violet', 'dark_orchid', 'orchid', 'pink', 'pale_violet_red', 'deep_pink', 'fuchsia']



  exosystem = 'WASP-14 b'
  planetname = 'WASP-14b'
;run code to read in all the input planet parameters
  planetinfo = create_planetinfo()
  aorname= planetinfo[planetname, 'aorname_ch2'] 
  basedir = planetinfo[planetname, 'basedir']
  period =  planetinfo[planetname, 'period']
  stareaor = planetinfo[planetname, 'stareaor']
  exoplanet_data_file = '/Users/jkrick/idlbin/exoplanets.csv'
  
  lambdaname  = '4.5'
  get_exoplanet_data,EXOSYSTEM=exosystem,MSINI=msini,MSTAR=mstar,TRANSIT_DEPTH=transit_depth,RP_RSTAR=rp_rstar,AR_SEMIMAJ=ar_semimaj,$
                     TEQ_P=1315,TEFF_STAR=teff_star,SECONDARY_DEPTH=secondary_depth,SECONDARY_LAMBDA=lambdaname,$
                     INCLINATION=inclination,MJD_TRANSIT=mjd_transit,P_ORBIT=p_orbit,EXODATA=exodata,RA=ra,DEC=dec,VMAG=vmag,$
                     DISTANCE=distance,ECC=ecc,T14=t14,F36=f36,F45=f45,FP_FSTAR0=fp_fstar0,/verbose

  dirname = strcompress(basedir + planetname +'/')                                                            ;+'/hybrid_pmap_nn/')
  savefilename = strcompress(dirname + planetname +'_phot_ch2_2.25000.sav',/remove_all) ;
  restore, savefilename

  startaor =  0;0                 ;  n_elements(aorname) -29
  stopaor =   n_elements(aorname) - 1
  time_0 = (planethash[aorname(startaor),'timearr']) 
  time_0 = time_0(0)
  stareaor = 5

  if keyword_set(time_plot) then begin
  for a = 0, stopaor do begin
     print, '------------------------------------------------------'
     print, 'working on AOR', a, '   ', aorname(a), startaor, colorarr[a]
     ;check if I should be using pmap corr or not
     ncorr = where(finite([ planethash[aorname(a),'corrflux']]) gt 0, corrcount,/L64)
     ;if 20% of the values are correctable than go with the pmap corr 
     print, '0.2nflux, ncorr, ', 0.2*n_elements([planethash[aorname(a),'flux']]), corrcount
     if corrcount gt 0.2*n_elements([planethash[aorname(a),'flux']]) then pmapcorr = 1 else pmapcorr = 0
     print, 'pmapcorr', pmapcorr

     if a ge stareaor then begin
        ;;variable binning
        junkpar = binning_function(a, bin_level, pmapcorr,/set_nbins, n_nbins = 4)
     endif else begin
        
        junkpar = binning_function(a, bin_level, pmapcorr,/set_nbins, n_nbins = 95)
     endelse

     corroffset = 0.002
     snapcorroffset = 0.002


     ;use the time degraded corrfluxes
     bin_corrfluxp = bin_corrflux_dp

                                ;save some arrays for later
     CASE 1 of 
        ;;take the  stare AORs and make one array of phase and corrflux
        ;;and corrfluxerr
        
        (a eq 0):BEGIN
           stare_phasearr = bin_phasep
           stare_corrfluxarr = bin_corrfluxp
           stare_corrfluxerrarr = bin_corrfluxerrp
           stare_colorarr = 'gray'
        END
        
        (a gt 0) and (a lt stareaor): BEGIN
           stare_phasearr = [stare_phasearr,bin_phasep]
           stare_corrfluxarr = [stare_corrfluxarr,bin_corrfluxp]
           stare_corrfluxerrarr = [stare_corrfluxerrarr,bin_corrfluxerrp]
           stare_colorarr = [stare_colorarr, 'gray']
        end

        (a eq stareaor):BEGIN

           ;;make stare_phasearr all positive
           stare_phasearr = stare_phasearr + 1.0
 
           ;;then duplicate that array with phasexN          
           ;;there are 170 periods in 1 years
           n_phases = 170
           ext_phasearr = fltarr(n_elements(stare_phasearr) *n_phases)
           ext_corrfluxarr = ext_phasearr
           ext_corrfluxerrarr = ext_phasearr
           for i = 1, n_phases  do begin
              ext_phasearr[(i - 1)*n_elements(stare_phasearr):(i*n_elements(stare_phasearr)) - 1] = stare_phasearr + (i-1)
              ext_corrfluxarr[(i - 1)*n_elements(stare_phasearr):(i*n_elements(stare_phasearr)) - 1] = stare_corrfluxarr
              ext_corrfluxerrarr[(i - 1)*n_elements(stare_phasearr):(i*n_elements(stare_phasearr)) - 1] = stare_corrfluxerrarr
           endfor
           stare_norm = mean(planethash[aorname(0),'corrflux'],/nan)
           pt = plot(ext_phasearr, ext_corrfluxarr/stare_norm + corroffset, '1s', sym_size = 0.2,   sym_filled = 1, color = 'grey', yrange = [0.989, 1.005], xrange = [0,10])
           

           ;;need a new phasing for the snapshots
           ;;phase =( bmjd_dist / period )
           snap_phasearr = ( (bin_bmjdarr-mjd_transit) / p_orbit )
           snap_corrfluxarr = bin_corrfluxp
           snap_corrfluxerrarr = bin_corrfluxerrp
           snap_colorarr = colorarr(a)

           ;;overplot the snaps
           snap_norm =  stare_norm
           pt = plot(snap_phasearr - 763.0, snap_corrfluxarr/snap_norm + snapcorroffset, '1s', sym_size = 0.5,   sym_filled = 1, color = colorarr[a], overplot = pt, xtitle = 'Number of Periods', ytitle = 'Normalized Corrected Flux')


        end
     
        (a gt stareaor):BEGIN

           snap_phasearr = [snap_phasearr,( (bin_bmjdarr-mjd_transit) / p_orbit )]

           pt = plot(( (bin_bmjdarr-mjd_transit) / p_orbit )- 763.0, bin_corrfluxp/snap_norm+ snapcorroffset, '1s', sym_size = 0.5,   sym_filled = 1, color = colorarr[a], overplot = pt)

           snap_corrfluxarr = [snap_corrfluxarr,bin_corrfluxp]
           snap_corrfluxerrarr = [snap_corrfluxerrarr,bin_corrfluxerrp]
           snap_colorarr = [snap_colorarr, colorarr(a)]
        end
     endcase
  endfor
endif ; time_plot

;;-------------------------------------------------


;print out some simple facts for others to play with.
;  openw, outlun, '/Users/jkrick/irac_warm/pcrs_planets/WASP-14b/wasp14_data.txt', /GET_LUN
;  for a = 0, stopaor do begin
;     for i = 0, n_elements(planethash[aorname(a),'xcen']) - 1 do begin
;        printf, outlun, (planethash[aorname(a),'bmjdarr'])(i), (planethash[aorname(a),'phase'])(i), (planethash[aorname(a),'corrflux'])(i), (planethash[aorname(a),'corrflux'])(i), format = '(D, F10.3, F10.4, F10.4)'
;     endfor

;  endfor
;  free_lun, outlun

;;-------------------------------------------------


  if keyword_set(position_plot) then begin
     fits_read, '/Users/jkrick/irac_warm/pmap/pmap_fits/pmap_ch2_0p1s_x4_500x500_0043_121120.fits', pmapdata, pmapheader
     c = contour(pmapdata, /fill, n_levels = 21, rgb_table = 0, xtitle = 'X (pixel)', ytitle = 'Y (pixel)', title = planetname, aspect_ratio = 1, xrange = [0,500], yrange = [0,500])

     for a = stareaor ,  stopaor  do begin
        xcen500 = 500.* ((planethash[aorname(a),'xcen']) - 14.5)
        ycen500 = 500.* ((planethash[aorname(a),'ycen']) - 14.5)
        an = plot(xcen500, ycen500, '1s', sym_size = 0.05,   sym_filled = 1, color = colorarr[a],/overplot)
     endfor
;     xs = 500.*(xsweet - 14.5)
;     ys = 500.*(ysweet - 14.5)
;   an = text(xs, ys, 'X', /data, alignment = 0.5, vertical_alignment = 0.5)
     an.save, dirname+'position_ch2.png'
  endif 

;;-------------------------------------------------


  if keyword_set(unbinned_bkgplot) then begin

     for a = stareaor,n_elements(aorname) -1 do begin ; 0, n_elements(aorname) - 1 do begin
        if a eq stareaor then begin
           ay = plot( planethash[aorname(a),'phase'] , planethash[aorname(a),'bkgd'],'1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[a], ytitle = 'Bkgd', xtitle = 'Phase') ;,title = planetname
        endif else begin
           ay = plot( planethash[aorname(a),'phase'] , planethash[aorname(a),'bkgd'],'1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[a],/overplot)
        endelse
        
     endfor
     ay.save, dirname +'bkgd_time_ch2.png'
  endif
;;-------------------------------------------------

  if keyword_set(normalize) then begin
     normval = fltarr(n_elements(aorname))
     time_0 = (planethash[aorname(0),'timearr']) 
     time_0 = time_0(0)

     for a = 0, n_elements(aorname) - 1 do begin


        ;;----------------------
        ;;make a correction for flux degradation over time
        
        ;;0.05% per year or 0.0005*(time in
        ;;years since start of observation)
        deltatime = planethash[aorname(a),'timearr'] - time_0 ; in seconds
        deltatime = deltatime / 60./60./24./365.
        degrade = .0005*deltatime
        planethash[aorname(a),'corrflux'] =  planethash[aorname(a),'corrflux'] + (planethash[aorname(a),'corrflux'] * degrade)
        
        ;;----------------------


        ;;try with binning
        ncorr = where(finite([ planethash[aorname(a),'corrflux']]) gt 0, corrcount,/L64)
        if corrcount gt 0.2*n_elements([planethash[aorname(a),'flux']]) then pmapcorr = 1 else pmapcorr = 0
        if a ge stareaor then begin
           ;;variable binning
           junkpar = binning_function(a, bin_level, pmapcorr, '2', /set_nbins, n_nbins = 4)
        endif else begin
           junkpar = binning_function(a, bin_level, pmapcorr,'2', /set_nbins, n_nbins = 95)
        endelse

        normval[a] =mean(planethash[aorname(a),'corrflux'],/nan) ; mean(bin_corrfluxp);
;        x = planethash[aorname(a),'phase']
;        y =  planethash[aorname(a),'corrflux']
;        g = where(finite(y) gt 0 )
;        x = x(g)
;        y =  y(g)
;        pnn = plot(x, y, '1s', sym_size=0.2, sym_filled =1, overplot = pnn

        if a lt stareaor then c = 'grey' else c = 'blue'
       
        pnn = plot(bin_phasep, bin_corrfluxp, '1s', sym_size=0.2, sym_filled =1, overplot = pnn, yrange = [0.056, 0.06])
     endfor
     print, 'normval', normval
     plothist, normval, xhist, yhist, bin = 0.0001, /noplot
;     print, 'xhist', xhist
     pn = barplot(xhist, yhist, fill_color = 'green', xrange = [0.056, 0.06]) 

endif


end



;     if a eq startaor then begin ; for the first AOR
                                ;set the normalization values from the
                                ;medians of the first AOR...is close enough
;        plot_corrnorm = median(bin_corrfluxp)
;        plot_norm = median(bin_flux)
        
;        if pmapcorr eq 1 then begin
;           print, 'inside pmapcorr eq 1', median(bin_corrfluxp), median(bin_flux)
           
;           pu = errorplot(((bin_timearr - time_0)/60./60.) , (bin_corrfluxp/plot_corrnorm) + corroffset,$ ;- 5.E3)/24.
;                          bin_corrfluxerrp/plot_corrnorm, '1s' , sym_size = 0.2,   sym_filled = 1 ,$
;                          color = colorarr[a] ,xtitle = 'Time (Hours)', errorbar_color =  colorarr[a], $
;                          title = planetname, ytitle = 'Pmap Corrected Flux') ;
           
;           endif  ; if pmapcorr eq 1
;     endif        ; if a = startaor
     
;     if (a gt 0) and (a le stareaor) then begin
;        print, 'inside a gt 0 a le stareaor', a
        
;        if pmapcorr eq 1 then begin
;           pu =  errorplot(((bin_timearr - time_0)/60./60.) , (bin_corrfluxp/plot_corrnorm) + corroffset, $ ;- 5.5E3)/24.
;                           bin_corrfluxerrp/plot_corrnorm, '1s' , sym_size = 0.2,   sym_filled = 1, $
;                          color = colorarr[a], errorbar_color =  colorarr[a], overplot = pu, /current)
;        endif
        
;     endif 
     

;     if a gt stareaor then begin
;        print, 'inside a gt stareaor', a
        
;        if pmapcorr eq 1 then begin
;           pu =  errorplot(((bin_timearr - time_0)/60./60.) , (bin_corrfluxp/plot_corrnorm) + corroffset, $ ;- 5.5E3)/24.
;                           bin_corrfluxerrp/plot_corrnorm, '1s' , sym_size = 0.2,   sym_filled = 1, $
;                           color = colorarr[a], errorbar_color =  colorarr[a], overplot = pu)
           
;        endif
        
;     endif
