pro plot_exoplanet_multiplot, planetname, bin_level, apradius, chname,  timeplot = timeplot
;example call plot_exoplanet, 'wasp15', 2*63L

COMMON bin_block, aorname, planethash, bin_xcen, bin_ycen, bin_bkgd, bin_flux, bin_fluxerr,  bin_timearr, bin_phase, bin_ncorr,bin_np, bin_npcent, bin_xcenp, bin_ycenp, bin_bkgdp, bin_fluxp, bin_fluxerrp,  bin_corrfluxp,  bin_timearrp, bin_corrfluxerrp,  bin_phasep,  bin_ncorrp, bin_nparrp, bin_npcentarrp, bin_bmjdarr, bin_xfwhm, bin_yfwhm

 colorarr = ['blue', 'red','black','green','grey','purple', 'deep_pink','fuchsia', 'magenta', 'medium_purple','medium_orchid', 'orchid', 'violet', 'plum', 'thistle', 'pink', 'orange_red', 'light_pink', 'rosy_brown','pale_violet_red',  'chocolate', 'saddle_brown', 'maroon', 'hot_pink', 'dark_orange', 'peach_puff', 'pale_goldenrod','red',  'aquamarine', 'teal', 'steel_blue', 'dodger_blue', 'dark_blue', 'indigo','dark_slate_blue', 'blue_violet', 'purple','dim_grey', 'slate_grey', 'dark_slate_grey', 'khaki', 'tomato', 'lavender','gold', 'green_yellow', 'lime', 'green', 'olive_drab', 'pale_green', 'spring_green','blue', 'red','deep_pink', 'magenta', 'medium_purple','light_sea_green', 'teal', 'cadet_blue', 'aquamarine', 'dark_turquoise', 'aqua','blue', 'red', 'deep_pink','fuchsia', 'magenta', 'medium_purple','medium_orchid', 'orchid', 'violet', 'plum', 'thistle', 'pink', 'orange_red', 'light_pink', 'rosy_brown','pale_violet_red',  'chocolate', 'saddle_brown', 'maroon', 'hot_pink', 'dark_orange', 'peach_puff', 'pale_goldenrod','red',  'aquamarine', 'teal', 'steel_blue', 'dodger_blue', 'dark_blue', 'indigo','dark_slate_blue', 'blue_violet', 'purple','dim_grey', 'slate_grey', 'dark_slate_grey', 'khaki', 'tomato', 'lavender','gold', 'green_yellow', 'lime', 'green', 'olive_drab', 'pale_green', 'spring_green','blue', 'red','deep_pink', 'magenta', 'medium_purple','light_sea_green', 'teal', 'cadet_blue', 'aquamarine', 'dark_turquoise', 'aqua' ]
;


;run code to read in all the input planet parameters
  planetinfo = create_planetinfo()
  if chname eq '2' then aorname= planetinfo[planetname, 'aorname_ch2'] else aorname = planetinfo[planetname, 'aorname_ch1'] 
  basedir = planetinfo[planetname, 'basedir']
  period =  planetinfo[planetname, 'period']
  stareaor = planetinfo[planetname, 'stareaor']
;for debugging: skip some AORs
  startaor = 1                  ;5
  stopaor =  1;n_elements(aorname) - 1
  print, 'stopaor', stopaor
;  plot_norm= planetinfo[planetname, 'plot_norm']
;  plot_corrnorm = planetinfo[planetname, 'plot_corrnorm']
  
  dirname = strcompress(basedir + planetname +'/');+'/hybrid_pmap_nn/')
  savefilename = strcompress(dirname + planetname +'_phot_ch'+chname+'_'+string(apradius)+'.sav',/remove_all)
  print, 'restoring ', savefilename
  restore, savefilename
  print, 'aorname', aorname(0)
  time_0 = (planethash[aorname(startaor),'timearr']) 
  time_0 = time_0(0)
;  plothist, planethash[aorname(0),'npcentroids'], xhist, yhist, /noplot, bin = 0.01
;  testplot = plot(xhist, yhist,  xtitle = 'NP', ytitle = 'Number', thick =3, color = 'blue')

  ;print, 'testing phase', (planethash[aorname(0),'phase'] )[0:10], (planethash[aorname(0),'phase'] )[600:610]

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
 
  for a = startaor,stopaor do begin
     print, '------------------------------------------------------'
     print, 'working on AOR', a, '   ', aorname(a)

     ;check if I should be using pmap corr or not
     ncorr = where(finite([ planethash[aorname(a),'corrflux']]) gt 0, corrcount,/L64)
     ;if 20% of the values are correctable than go with the pmap corr 
     print, '0.2nflux, ncorr, ', 0.2*n_elements([planethash[aorname(a),'flux']]), corrcount
     if corrcount gt 0.2*n_elements([planethash[aorname(a),'flux']]) then pmapcorr = 1 else pmapcorr = 0
     print, 'pmapcorr', pmapcorr
     peakpixDN = planethash[aorname(a), 'peakpixDN']
     print, 'median peakpixDN', median(peakpixDN)

; bin within each AOR only, don't want to bin across boundaries.
     junkpar = binning_function(a, bin_level, pmapcorr)
;     print, 'testing phase', (planethash[aorname(a),'phase'] )[0:10], (planethash[aorname(a),'phase'] )[600:610]
;     print, 'testing x', bin_xcen[0:10]
;     print, 'testing y', bin_ycen[0:10]
;     print, 'testing npcent', bin_npcent[0:10]
;------------------------------------------------------
     ;possible comparison statistic
     ;what is the distribution of standard deviations among the corrfluxes?

     meanclip_jk, planethash[aorname(a),'corrflux'] , mean_corrflux, stddev_corrflux
     stddev_corrfluxarr[a- startaor] = stddev_corrflux
;------------------------------------------------------
;now try plotting
     xcen = planethash[aorname(a),'xcen']
     ycen = planethash[aorname(a),'ycen']
     flux = planethash[aorname(a),'flux']
     print, 'first', xcen[350:360], ycen[350:360], flux[350:360]
     print, 'second', xcen[6395:6405], ycen[6395:6405], flux[6395:6405]
;------------------------------------------------------
     print, 'n_elements time', n_elements(bin_timearr), n_elements(bin_xcen), n_elements(bin_phase)
     if keyword_set(timeplot) then begin ;make the plot as a function of time
        print, 'making plot as a function of time'
        extra={xthick: 2, ythick:2, margin: 0.2, sym_size: 0.2,   sym_filled: 1, xstyle:1}
        corrnormoffset = 0;0.02
        corroffset = 0.001
        setynormfluxrange = [0.98, 1.01];[0.97, 1.005]
       
        if a eq startaor then begin    ; for the first AOR
                                ;set the normalization values from the
                                ;medians of the first AOR...is close enough
           plot_norm = median(bin_flux)
           plot_corrnorm = mean(bin_corrfluxp,/nan)
           bkgd_norm = mean(bin_bkgd,/nan)
;           print, 'bin_xcen', bin_xcen
           print, 'plot_corrnorm', plot_corrnorm, mean(bin_corrfluxp)

           
           pp = plot((bin_timearr-  time_0)/60./60., bin_xcen, '1s',  $;title = planetname, $
                     color = colorarr[a], ytitle = 'X position', position = [0.2,0.78,0.9,0.91], ytickinterval = 0.5, $
                     xshowtext = 0, ytickformat = '(F10.1)', dimensions = [600, 900], _extra = extra, yminor = 0) ;, $, ymajor = 4
 
          ;turn off refreshing to make this quicker hopefully
;           pp.Refresh, /Disable

           
           pq= plot((bin_timearr - time_0)/60./60., bin_ycen, '1s',  color = colorarr[a], $
                     ytitle = 'Y position',  position = [0.2, 0.64, 0.9, 0.77],/current,  ytickinterval = 1.0,$
                    xshowtext = 0,ytickformat = '(F10.1)', _extra = extra, yminor = 0);, yrange = [15.5, 17.5]) ;, $, title = planetname , ymajor = 4
                     ;xrange = setxrange)


           if keyword_set(errorbars) then begin
              pr= errorplot((bin_timearr - time_0)/60./60., bin_flux/plot_norm,bin_fluxerr/plot_norm,  '1s',  color =colorarr[a], $
                             ytitle = 'Normalized Flux' , yminor = 5, $ ;, title = planetname,,yrange = setynormfluxrange
                             xrange = setxrange ,  position = [0.2,0.08, 0.9, 0.21],/current, ymajor = 4, _extra = extra)
           endif else begin
              pr = plot((bin_timearr - time_0)/60./60., bin_flux/plot_norm, '1s',  $
                        color = colorarr[a],   ytitle = 'Norm. Flux', xtitle = 'Time(hrs)',$ 
                         position = [0.2,0.08, 0.9, 0.21], /current, _extra = extra, ytickinterval = 0.02, yminor = 0);, yrange = [0.98, 1.02]
           endelse  ;/errorbars
          if pmapcorr eq 1 then begin
              print, 'inside pmapcorr eq 1', median( (bin_corrfluxp/plot_corrnorm) ), median(bin_flux)
              if keyword_set(errorbars) then begin
                 pr = errorplot((bin_timearr - time_0)/60./60., (bin_corrfluxp/plot_corrnorm) -corrnormoffset,  $
                        bin_corrfluxerrp/plot_corrnorm ,/overplot, '1s', sym_size = 0.2, $
                        sym_filled = 1, color = colorarr[a])
              endif else begin
                 pr = plot((bin_timearr - time_0)/60./60., (bin_corrfluxp/plot_corrnorm) -corrnormoffset ,/overplot, '1s', $
                           sym_size = 0.2,   sym_filled = 1, color = colorarr[a])
              endelse           ;/errorbars

           endif  ;enough pmap corrections

 
           ps= plot((bin_timearr - time_0)/60./60., bin_npcent, '1s', color = colorarr[a], $
                     ytitle = 'Noise Pixel',  position = [0.2, 0.36, 0.9, 0.49], /current, $
                    xshowtext = 0,ytickformat = '(F10.1)', _extra = extra, ytickinterval = 1.0, yminor = 0, yrange = [2.5, 8.0]) ;,$ title = planetname,, ymajor = 4
                    ;xrange = setxrange)

           pt = plot((bin_timearr - time_0)/60./60., bin_bkgd/ bkgd_norm, '1s' , color = colorarr[a], $
                     ytitle = 'Norm. Bkgd',  margin = 0.2, position = [0.2, 0.22, 0.9, 0.35], /current, xshowtext = 0,$
                    ytickformat = '(F10.2)', _extra = extra, ytickinterval = 0.5, yminor = 0, yrange = [0.5, 1.8])           ;, $ title = planetname,ymajor = 4,

           pxy = plot((bin_timearr - time_0)/60./60., bin_xfwhm, '1s', color = 'blue', $
                     ytitle = 'X & Y FWHM',  position = [0.2, 0.50, 0.9, 0.63], /current, $
                    xshowtext = 0,ytickformat = '(F10.2)', _extra = extra, ytickinterval = 0.5, yminor = 0) ;
           pxy = plot((bin_timearr - time_0)/60./60., bin_yfwhm, '1s', color = 'black', $
                     overplot = pxy, _extra = extra) ;

           ;setup a plot for just the snaps
 ;          if n_elements(aorname) gt 10 then begin
 ;             pu = plot((bin_timearr - time_0)/60./60., (bin_corrfluxp/plot_corrnorm) + corroffset, xtitle = 'Time(hrs)', $
 ;                       title = planetname, ytitle = 'Normalized Flux',  yrange = [0.989, 1.005], aspect_ratio = 0.0, margin = 0.2);, xrange = setxrange, /nodata) ;
 ;          endif

        endif                   ; if a = 0

      ;  test_med(a) = median(bin_corrfluxp)
        print,'median bin_corrfluxp ',  median(bin_corrfluxp), median(bin_flux)
        if (a gt 0) and (a le stareaor) then begin
           print, 'inside a gt 0 a le stareaor', a
;           pp.window.SetCurrent
           pp = plot((bin_timearr - time_0)/60./60., bin_xcen, '1s', sym_size = 0.2,   sym_filled = 1,color = colorarr[a],  overplot = pp,/current)
;           pq.window.SetCurrent
           pq = plot((bin_timearr - time_0)/60./60., bin_ycen, '1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[a], overplot = pq,/current)
;           pr.window.SetCurrent
           pr = plot((bin_timearr - time_0)/60./60., bin_flux/plot_norm , '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[a], overplot = pr,/current)
 ;          if pmapcorr eq 1 then begin
;              pr = plot((bin_timearr - time_0)/60./60., (bin_corrfluxp/plot_corrnorm)-corrnormoffset, /overplot, 's1', sym_size = 0.2,   sym_filled = 1, color = colorarr[a],/current,overplot = pr)
;           endif

;           ps.window.SetCurrent
           ps = plot((bin_timearr - time_0)/60./60., bin_npcent, '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[a], overplot = ps,/current) ;, xtitle = 'Time(hrs)', ytitle = 'Normalized Flux',) 

;           pt.window.SetCurrent
           pt = plot((bin_timearr - time_0)/60./60., bin_bkgd/ bkgd_norm, '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[a], overplot = pt,/current) 

           pxy = plot((bin_timearr - time_0)/60./60., bin_xfwhm, '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[a], overplot = pxy,/current)
           pxy = plot((bin_timearr - time_0)/60./60., bin_yfwhm, '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[a], overplot = pxy,/current)


        endif



        if a gt stareaor then begin
           print, 'inside a gt stareaor', a
           pp.window.SetCurrent
           pp = plot((bin_timearr - time_0)/60./60., bin_xcen, '1s', sym_size = 0.2,   sym_filled = 1,color = colorarr[a],$
                     overplot = pp,/current, layout = [1,5,1])

           pp.window.SetCurrent
           pp = plot((bin_timearr - time_0)/60./60., bin_ycen, '1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[a],$
                     /overplot,/current, layout = [1,5,2])

           pp.window.SetCurrent
           if keyword_set(errorbars) then begin
              pp= errorplot((bin_timearr - time_0)/60./60., bin_flux/(plot_norm) , bin_fluxerr/plot_norm, '1s', $
                        sym_size = 0.2,   sym_filled = 1,  color = colorarr[a], /overplot,/current, layout = [1,5,3]) 
           endif else begin
              pp = plot((bin_timearr - time_0)/60./60., bin_flux/(plot_norm) , '1s', sym_size = 0.2,   sym_filled = 1,  $
                        color = colorarr[a], /overplot,/current,/nodata, layout = [1,5,3])
           endelse


           if pmapcorr eq 1 then begin
              print, 'inside pmapcorr eq 1, a gt stareaor', median( (bin_corrfluxp/plot_corrnorm) +corroffset)

               if keyword_set(errorbars) then begin
                  pr = errorplot((bin_timearr - time_0)/60./60., (bin_corrfluxp/plot_corrnorm)- corrnormoffset,$
                            bin_corrfluxerrp/ plot_corrnorm, '1s', sym_size = 0.2,   $
                            sym_filled = 1, color = colorarr[a],/overplot,/current)
               endif else begin
                  pr = plot((bin_timearr - time_0)/60./60., (bin_corrfluxp/plot_corrnorm) - corrnormoffset, '1s', $
                            sym_size = 0.2,   sym_filled = 1, color = colorarr[a],/overplot,/current)
               endelse
               if n_elements(aorname) gt 10 then begin
                  pu.window.SetCurrent
                  pu = plot((bin_timearr - time_0)/60./60., (bin_corrfluxp/plot_corrnorm) + corroffset, '1s', $
                            sym_size = 0.2,   sym_filled = 1, color = colorarr[a],/overplot,/current)
               endif
            endif

           pp.window.SetCurrent
           pp = plot((bin_timearr - time_0)/60./60., bin_npcent, '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[a],$
                     /overplot,/current, layout = [1,5,4]) 

           pp.window.SetCurrent
           pp = plot((bin_timearr - time_0)/60./60., bin_bkgd, '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[a], $
                     /overplot,/current, layout = [1,5,5]) 

        endif

;        pp.Refresh
;        pp.save, dirname +'binxcen_time_ch'+chname+'.eps'
;        pq.save, dirname +'binycen_time_ch'+chname+'.eps'
;        pt.save, dirname +'binbkg_time_ch'+chname+'.eps'
;        ps.save, dirname + 'binnp_time_ch'+chname+'.eps'
;        pr.save, dirname + 'binflux_time_ch'+chname+'.eps'

        pp.save, dirname +'multiplot_time_ch'+chname+'.eps'
     endif

 
  endfor                        ;binning for each AOR

end

