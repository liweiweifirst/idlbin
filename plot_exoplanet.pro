pro plot_exoplanet, planetname, bin_level, apradius, phaseplot = phaseplot, selfcal=selfcal, centerpixplot = centerpixplot, errorbars = errorbars, unbinned_xplot = unbinned_xplot, unbinned_yplot = unbinned_yplot, unbinned_fluxplot=unbinned_fluxplot, unbinned_npplot = unbinned_npplot, unbinned_bkgplot = unbinned_bkgplot
;example call plot_exoplanet, 'wasp15', 2*63L

COMMON bin_block, aorname, planethash, bin_xcen, bin_ycen, bin_bkgd, bin_flux, bin_fluxerr,  bin_timearr, bin_phase, bin_ncorr,bin_np, bin_xcenp, bin_ycenp, bin_bkgdp, bin_fluxp, bin_fluxerrp,  bin_corrfluxp,  bin_timearrp, bin_corrfluxerrp,  bin_phasep,  bin_ncorrp, bin_nparrp

;run code to read in all the input planet parameters
  planetinfo = create_planetinfo()
  chname = planetinfo[planetname, 'chname']
  ra_ref = planetinfo[planetname, 'ra']
  dec_ref = planetinfo[planetname, 'dec']
  aorname = planetinfo[planetname, 'aorname']
  basedir = planetinfo[planetname, 'basedir']
  utmjd_center =  planetinfo[planetname, 'utmjd_center']
  transit_duration =  planetinfo[planetname, 'transit_duration']
  period =  planetinfo[planetname, 'period']
  intended_phase = planetinfo[planetname, 'intended_phase']
  stareaor = planetinfo[planetname, 'stareaor']
  print, 'stareaor', stareaor
  plot_norm= planetinfo[planetname, 'plot_norm']
  plot_corrnorm = planetinfo[planetname, 'plot_corrnorm']
  
;XXXXXXXXX cheating
  dirname = strcompress(basedir + planetname +'/hybrid_pmap_nn/')
  savefilename = strcompress(dirname + planetname +'_phot_ch'+chname+'_'+string(apradius)+'.sav',/remove_all)
  restore, savefilename
  
  colorarr = ['blue', 'red', 'deep_pink','fuchsia', 'magenta', 'medium_purple','medium_orchid', 'orchid', 'violet', 'plum', 'thistle', 'pink', 'orange_red', 'light_pink', 'rosy_brown','pale_violet_red',  'chocolate', 'saddle_brown', 'maroon', 'hot_pink', 'dark_orange', 'peach_puff', 'pale_goldenrod','red',  'aquamarine', 'teal', 'steel_blue', 'dodger_blue', 'dark_blue', 'indigo','dark_slate_blue', 'blue_violet', 'purple','dim_grey', 'slate_grey', 'dark_slate_grey', 'khaki', 'tomato', 'lavender','gold', 'green_yellow', 'lime', 'green', 'olive_drab', 'pale_green', 'spring_green','blue', 'red','deep_pink', 'magenta', 'medium_purple','light_sea_green', 'teal', 'cadet_blue', 'aquamarine', 'dark_turquoise', 'aqua','blue', 'red', 'deep_pink','fuchsia', 'magenta', 'medium_purple','medium_orchid', 'orchid', 'violet', 'plum', 'thistle', 'pink', 'orange_red', 'light_pink', 'rosy_brown','pale_violet_red',  'chocolate', 'saddle_brown', 'maroon', 'hot_pink', 'dark_orange', 'peach_puff', 'pale_goldenrod','red',  'aquamarine', 'teal', 'steel_blue', 'dodger_blue', 'dark_blue', 'indigo','dark_slate_blue', 'blue_violet', 'purple','dim_grey', 'slate_grey', 'dark_slate_grey', 'khaki', 'tomato', 'lavender','gold', 'green_yellow', 'lime', 'green', 'olive_drab', 'pale_green', 'spring_green','blue', 'red','deep_pink', 'magenta', 'medium_purple','light_sea_green', 'teal', 'cadet_blue', 'aquamarine', 'dark_turquoise', 'aqua' ]
;
;  z = pp_multiplot(multi_layout=[1,3], global_xtitle='Orbital Phase')



;-------------------------------------------------------
;make a bunch of plots before binning
;-------------------------------------------------------

;this one overlays the positions on the pmap contours

;  fits_read, '/Users/jkrick/irac_warm/pmap/pmap_fits/pmap_ch2_0p1s_x4_500x500_0043_121120.fits', pmapdata, pmapheader
;  fits_read, '/Users/jkrick/irac_warm/pmap/pmap_fits/pmap_ch1_500x500_0043_120409.fits', pmapdata, pmapheader
;  c = contour(pmapdata, /fill, n_levels = 21, rgb_table = 0, xtitle = 'X (pixel)', ytitle = 'Y (pixel)', title = planetname, aspect_ratio = 1, xrange = [0,500], yrange = [0,500])
  print, 'naor', n_elements(aorname)
;  for a = 0 ,  n_elements(aorname) - 1, 2 do begin
;     print, 'testing aors', a, colorarr[a]

;     xcen500 = 500.* ((planethash[aorname(a),'xcen']) - 14.5)
;     ycen500 = 500.* ((planethash[aorname(a),'ycen']) - 14.5)
;     an = plot(xcen500, ycen500, '1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[a],/overplot)

;     npmax = [4.8, 37., 4.5]
;     testnp = where((planethash[aorname(a),'np']) gt npmax(a) , complement = nospike)
;     xcen500 = ((planethash[aorname(a),'xcen'])[nospike] )
;     ycen500 = ((planethash[aorname(a),'ycen'])[nospike])
;     print, 'mean np', mean((planethash[aorname(a),'np'])[nospike])
;     an = plot(xcen500, ycen500, '1s', sym_size = 0.2,   sym_filled = 1, color = 'blue', xtitle = 'xcen', ytitle = 'ycen', xrange = [14.9, 15.2], yrange = [14.75, 15.25]) 
 ;    xcen500 = ((planethash[aorname(a),'xcen'])[testnp] )
 ;    ycen500 = ((planethash[aorname(a),'ycen'])[testnp])
 ;    print, 'mean np', mean((planethash[aorname(a),'np'])[testnp])
 ;    an = plot(xcen500, ycen500, '1s', sym_size = 0.4,   sym_filled = 1, color = 'red',/overplot)

; ;    print, 'xcen500', xcen500
; ;    print, 'ycen500', ycen500
;  endfor
;  an.save, dirname+'position_ch'+chname+'.png'
;GOTO, Jumpend

;-----
 
  ;print, 'min', min((planetob[a].timearr - planetob[0].timearr(0))/60./60.)
 ; z = pp_multiplot(multi_layout=[1,3], global_xtitle='Time (hrs) ')
  if keyword_set(unbinned_xplot) then begin
     for a =  0, n_elements(aorname) - 1 do begin
        if a eq 0 then begin
           xmin = 14.0          ; mean(planethash[aorname(a),'xcen'])-0.25
           xmax = 15.5          ; mean(planethash[aorname(a),'xcen'])+0.25
                                ;print, 'xmin.xmax', xmin, xmax

           am = plot( (planethash[aorname(a),'timearr'] - (planethash[aorname(a),'timearr'])(0))/60./60., planethash[aorname(a),'xcen'],'1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[a], ytitle = 'X pix', title = planetname) ;, xtitle = 'Time(hrs)'
        endif else begin
;           am = plot( (planethash[aorname(a),'timearr'] - (planethash[aorname(0),'timearr'])(0))/60./60., planethash[aorname(a),'xcen'],'6r1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[a],/overplot)
           am = plot( (planethash[aorname(a),'bmjdarr'] - (planethash[aorname(a),'bmjdarr'])(0)), planethash[aorname(a),'xcen'],'6r1s-', sym_size = 0.3,   sym_filled = 1, color = colorarr[a],yrange = [14.47, 14.62], xrange = [0.1501,0.15018], ytitle = 'xcen');,/overplot)
        endelse
        
     endfor
     am.save, dirname + 'x_time_ch'+chname+'.png'
  endif

;------
  if keyword_set(unbinned_yplot) then begin
     for a = 0,n_elements(aorname) -1 do begin ; 0, n_elements(aorname) - 1 do begin
        if a eq 0 then begin
           ymin = 14.9          ; mean(planethash[aorname(a),'ycen'])-0.25
           ymax = 16.0          ;mean(planethash[aorname(a),'ycen'])+0.25
                                ;print, 'ymin.ymax', ymin, ymax
           ay = plot( (planethash[aorname(a),'timearr'] - (planethash[aorname(a),'timearr'])(0))/60./60., planethash[aorname(a),'ycen'],'1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[a], ytitle = 'Y pix') ;,title = planetname, xtitle = 'Time(hrs)'
        endif else begin
;           ay = plot( (planethash[aorname(a),'timearr'] - (planethash[aorname(0),'timearr'])(0))/60./60., planethash[aorname(a),'ycen'],'1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[a],/overplot)
           ay = plot( (planethash[aorname(a),'bmjdarr'] - (planethash[aorname(a),'bmjdarr'])(0)), planethash[aorname(a),'ycen'],'6r1s-', sym_size = 0.3,   sym_filled = 1, color = colorarr[a] , yrange = [14.3, 14.45], xrange = [0.1501,0.15018], ytitle = 'ycen');,/overplot)
        endelse
        
     endfor
     ay.save, dirname +'y_time_ch'+chname+'.png'
  endif
 
;------
  if keyword_set(unbinned_fluxxplot) then begin

     for a = 0,n_elements(aorname) -1 do begin ; 0, n_elements(aorname) - 1 do begin
        if a eq 0 then begin
                                ;       ymin = 14.9             ; mean(planethash[aorname(a),'ycen'])-0.25
                                ;       ymax = 16.0             ;mean(planethash[aorname(a),'ycen'])+0.25
                                ;print, 'ymin.ymax', ymin, ymax
           ay = plot( (planethash[aorname(a),'timearr'] - (planethash[aorname(0),'timearr'])(0))/60./60., planethash[aorname(a),'flux'],'1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[a], ytitle = 'Flux', xtitle = 'Time(hrs)') ;,title = planetname, xtitle = 'Time(hrs)'
        endif else begin
           ay = plot( (planethash[aorname(a),'timearr'] - (planethash[aorname(0),'timearr'])(0))/60./60., planethash[aorname(a),'flux'],'1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[a],/overplot)
        endelse
        
     endfor
     ay.save, dirname +'raw_flux_time_ch'+chname+'.png'
  endif

;------
  if keyword_set(unbinned_bkgplot) then begin

     for a = 0,n_elements(aorname) -1 do begin ; 0, n_elements(aorname) - 1 do begin
        if a eq 0 then begin
           ay = plot( (planethash[aorname(a),'timearr'] - (planethash[aorname(0),'timearr'])(0))/60./60., planethash[aorname(a),'bkgd'],'1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[a], ytitle = 'Bkgd', xtitle = 'Time(hrs)') ;,title = planetname
        endif else begin
           ay = plot( (planethash[aorname(a),'timearr'] - (planethash[aorname(0),'timearr'])(0))/60./60., planethash[aorname(a),'bkgd'],'1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[a],/overplot)
        endelse
        
     endfor
     ay.save, dirname +'bkgd_time_ch'+chname+'.png'
  endif

;------
  if keyword_set(unbinned_npplot) then begin

     for a = 0 ,n_elements(aorname) -1 do begin ; 0, n_elements(aorname) - 1 do begin
        if a eq 0 then begin
           ay = plot( (planethash[aorname(a),'timearr'] - (planethash[aorname(a),'timearr'])(0))/60./60., planethash[aorname(a),'np'],'1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[a], ytitle = 'NP') ;,title = planetname, xtitle = 'Time(hrs)'
        endif else begin
;           ay = plot( (planethash[aorname(a),'timearr'] - (planethash[aorname(a),'timearr'])(0))/60./60., planethash[aorname(a),'np'],'1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[a], xrange = [4,4.01], yrange = [6,9]);,/overplot)
           ay = plot( (planethash[aorname(a),'bmjdarr'] - (planethash[aorname(a),'bmjdarr'])(0)), planethash[aorname(a),'np'],'6r1s-', sym_size = 0.3,   sym_filled = 1, color = colorarr[a], xrange = [0.1501,0.15018], yrange = [7.3,8.5], ytitle = 'NP');,/overplot)
        endelse
        
     endfor
     ay.save, dirname +'np_time_ch'+chname+'.png'
  endif

;------
  
;------
     
     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;goto, jumpend
  for a = 0,n_elements(aorname) - 1 do begin
     print, '------------------------------------------------------'
     print, 'working on AOR', a, '   ', aorname(a)

     ;check if I should be using pmap corr or not
     ncorr = where(finite([ planethash[aorname(a),'corrflux']]) gt 0, corrcount)
     ;if 20% of the values are correctable than go with the pmap corr 
     print, 'nflux, ncorr, ', n_elements([planethash[aorname(a),'flux']]), corrcount
     if corrcount gt 0.2*n_elements([planethash[aorname(a),'flux']]) then pmapcorr = 1 else pmapcorr = 0

; bin within each AOR only, don't want to bin across boundaries.
     junkpar = binning_function(a, bin_level, pmapcorr)

;------------------------------------------------------
;now try plotting

     if keyword_set(phaseplot) then begin ;make the plot as a function of phase

;        print, 'test phase', bin_phase(0)
;        print, 'test normflux', bin_flux/plot_norm
        
;   setxrange = [-0.022,-0.0205]
;   setxrange =[-0.0127, -0.0112]
        setxrange = [-0.5, 0.5]
        corrnormoffset = 0.02
        corroffset = 0.002
        setynormfluxrange = [0.97, 1.005]
        if a eq 0 then begin    ; for the first AOR
                                ;set the normalization values from the
                                ;medians of the first AOR...is close enough
;           plot_norm = median(bin_flux)
;           plot_corrnorm = mean(bin_corrfluxp)
           print, 'plot_corrnorm', plot_corrnorm, mean(bin_corrfluxp)
           pp = plot(bin_phase, bin_xcen, '1s', sym_size = 0.1,   sym_filled = 1, title = planetname, $
                     color = 'black', xtitle = 'Orbital Phase', ytitle = 'X position', $
                     xrange = setxrange)

           pq = plot(bin_phase, bin_ycen, '1s', sym_size = 0.1,   sym_filled = 1, color = 'black', $
                     xtitle = 'Orbital Phase', ytitle = 'Y position', title = planetname, $
                     xrange = setxrange)

           if keyword_set(errorbars) then begin
              pr = errorplot(bin_phase, bin_flux/plot_norm,bin_fluxerr/plot_norm,  '1s', sym_size = 0.1,   $
                             sym_filled = 1,  color ='black',  xtitle = 'Orbital Phase', $
                             ytitle = 'Normalized Flux', title = planetname, yrange = setynormfluxrange, $
                             xrange = setxrange) 
           endif else begin
              pr = plot(bin_phase, bin_flux/plot_norm, '1s', sym_size = 0.1,   sym_filled = 1,  $
                        color = 'black',  xtitle = 'Orbital Phase', ytitle = 'Normalized Flux', $
                        title = planetname, yrange = setynormfluxrange, xrange = setxrange) 
           endelse  ;/errorbars

           if pmapcorr eq 1 then begin
              print, 'inside pmapcorr eq 1', median( (bin_corrfluxp/plot_corrnorm) ), median(bin_flux)
              if keyword_set(errorbars) then begin
                 pr = errorplot(bin_phasep, (bin_corrfluxp/plot_corrnorm) -corrnormoffset,  $
                        bin_corrfluxerrp/plot_corrnorm ,/overplot, '1s', sym_size = 0.1, $
                        sym_filled = 1, color = 'black')
              endif else begin
                 pr = plot(bin_phasep, (bin_corrfluxp/plot_corrnorm) -corrnormoffset ,/overplot, '1s', $
                           sym_size = 0.1,   sym_filled = 1, color = 'black')
              endelse           ;/errorbars

           endif  ;enough pmap corrections

           ps= plot(bin_phase, bin_np, '1s', sym_size = 0.1,   sym_filled = 1,  color = 'black', $
                    xtitle = 'Orbital Phase', ytitle = 'Noise Pixel', title = planetname,$
                    xrange = setxrange)

           pt = plot(bin_phase, bin_bkgd, '1s', sym_size = 0.1,   sym_filled = 1,  color = 'black', $
                     xtitle = 'Orbital Phase', ytitle = 'Background', title = planetname, $
                     xrange =setxrange)

           ;setup a plot for just the snaps
           if n_elements(aorname) gt 10 then begin
              pu = plot(bin_phase, (bin_corrfluxp/plot_corrnorm) + corroffset, xtitle = 'Orbital Phase', $
                        ytitle = 'Normalized Flux', title = planetname, yrange = [0.985, 1.005], xrange = setxrange, /nodata)
           endif

        endif                   ; if a = 0

      ;  test_med(a) = median(bin_corrfluxp)
        print,'median bin_corrfluxp ',  median(bin_corrfluxp), median(bin_flux)
        if (a gt 0) and (a le stareaor) then begin
           print, 'inside a gt 0 a le stareaor', a
           pp.window.SetCurrent
           pp = plot(bin_phase, bin_xcen, '1s', sym_size = 0.1,   sym_filled = 1,color = 'black',  /overplot,/current)
           pq.window.SetCurrent
           pq = plot(bin_phase, bin_ycen, '1s', sym_size = 0.1,   sym_filled = 1, color = 'black', /overplot,/current)
           pr.window.SetCurrent
           pr = plot(bin_phase, bin_flux/plot_norm , '1s', sym_size = 0.1,   sym_filled = 1,  color = 'black', /overplot,/current) 
           if pmapcorr eq 1 then begin
              pr = plot(bin_phasep, (bin_corrfluxp/plot_corrnorm)-corrnormoffset, /overplot, 's1', sym_size = 0.1,   sym_filled = 1, color = 'black',/current)
           endif

           ps.window.SetCurrent
           ps = plot(bin_phase, bin_np, '1s', sym_size = 0.1,   sym_filled = 1,  color = 'black', /overplot,/current) ;, xtitle = 'Orbital Phase', ytitle = 'Normalized Flux',) 
        endif



        if a gt stareaor then begin
           print, 'inside a gt stareaor', a
           pp.window.SetCurrent
           pp = plot(bin_phase, bin_xcen, '1s', sym_size = 0.4,   sym_filled = 1,color = colorarr[a],$
                     /overplot,/current)

           pq.window.SetCurrent
           pq = plot(bin_phase, bin_ycen, '1s', sym_size = 0.4,   sym_filled = 1, color = colorarr[a],$
                     /overplot,/current)

           pr.window.SetCurrent
           if keyword_set(errorbars) then begin
              pr = errorplot(bin_phase, bin_flux/(plot_norm) , bin_fluxerr/plot_norm, '1s', $
                        sym_size = 0.4,   sym_filled = 1,  color = colorarr[a], /overplot,/current) 
           endif else begin
              pr = plot(bin_phase, bin_flux/(plot_norm) , '1s', sym_size = 0.4,   sym_filled = 1,  $
                        color = colorarr[a], /overplot,/current) 
           endelse


           if pmapcorr eq 1 then begin
              print, 'inside pmapcorr eq 1', median( (bin_corrfluxp/plot_corrnorm) - 0.01)

               if keyword_set(errorbars) then begin
                  pr = errorplot(bin_phasep, (bin_corrfluxp/plot_corrnorm)- corrnormoffset,$
                            bin_corrfluxerrp/ plot_corrnorm, '1s', sym_size = 0.4,   $
                            sym_filled = 1, color = colorarr[a],/overplot,/current)
               endif else begin
                  pr = plot(bin_phasep, (bin_corrfluxp/plot_corrnorm) - corrnormoffset, '1s', $
                            sym_size = 0.4,   sym_filled = 1, color = colorarr[a],/overplot,/current)
               endelse

               pu.window.SetCurrent
               pu = plot(bin_phasep, (bin_corrfluxp/plot_corrnorm)+corroffset , '1s', $
                            sym_size = 0.4,   sym_filled = 1, color = colorarr[a],/overplot,/current)
            endif

           ps.window.SetCurrent
           ps = plot(bin_phase, bin_np, '1s', sym_size = 0.4,   sym_filled = 1,  color = colorarr[a],$
                     /overplot,/current) 

           pt.window.SetCurrent
           pt = plot(bin_phase, bin_bkgd, '1s', sym_size = 0.4,   sym_filled = 1,  color = colorarr[a], $
                     /overplot,/current) 


        endif

        ps.save, dirname +'binnp_phase_ch'+chname+'.png'
        pt.save, dirname +'binbkg_phase_ch'+chname+'.png'
 ;       pu.save, dirname + 'binsnaps_phase_ch'+chname+'.png'
        pr.save, dirname + 'binflux_phase_ch'+chname+'.png'

        if keyword_set(selfcal) then begin
         ;  restore, strcompress(dirname + 'selfcal.sav')          
          ; print, 'test selfcal', y[0:10], 'x', x[0:10]
          ; pr.window.SetCurrent
           ;pr = errorplot(x, y-0.01,yerr,'1bo',sym_size = 0.2, sym_filled = 1, errorbar_color = 'black',color = 'black',/overplot,/current)
           ;pr = plot(x, y -0.01, '1s', sym_size = 0.3,   sym_filled = 1, color = 'black',/overplot,/current)
        endif




        if a eq n_elements(aorname) - 1 and planetname eq 'hd209458' then begin
           ;plot curves from Lewis
           restore, '/Users/jkrick/irac_warm/hd209458/hd209_ch2_for_jessica.sav'
           ;need to get time in phase
           time = time / period ; now in phase

           ;need to bin
           numberarr = findgen(n_elements(time))
           h = histogram(numberarr, OMIN=om, binsize = bin_level, reverse_indices = ri)
           print, 'omin', om, 'nh', n_elements(h)
           bin_corr_flux = dblarr(n_elements(h))
           bin_time = dblarr(n_elements(h))
           c = 0
           for j = 0L, n_elements(h) - 1 do begin

              if (ri[j+1] gt ri[j] + 2)  then begin ;require 3 elements in the bin
                 
                 meanclip, time[ri[ri[j]:ri[j+1]-1]], meant, sigmat
                 bin_time[c] = meant

                 meanclip, corr_flux[ri[ri[j]:ri[j+1]-1]], meanc, sigmac
                 bin_corr_flux[c] = meanc

                 c = c + 1
                
              endif
           endfor

           bin_time = bin_time[0:c-1]
           bin_corr_flux = bin_corr_flux[0:c-1]

           pr.window.SetCurrent
           pk = plot(bin_time, bin_corr_flux - 0.017, '1s', sym_size =  0.3, sym_filled = 1, color = 'black', /overplot, /current)
        endif
        

     endif else begin  ;make the plot as a function of time
        print, 'making plot as a function of time'
        if a eq 0 then begin    ;for the first AOR
          ; pl = plot((bin_timearr - bin_timearr(0))/60./60., bin_flux/median(bin_flux), '6r1s', sym_size = 0.2,   sym_filled = 1,   xtitle = 'Time (hrs)', ytitle = 'Normalized Flux', title = planetname) 
          ; pl = plot((bin_timearr - bin_timearr(0))/60./60., bin_corrflux/median(bin_corrflux)-0.004, '1s', sym_size = 0.2,   sym_filled = 1, color = 'black',/overplot)

            pl = errorplot((bin_timearr - bin_timearr(0))/60./60., bin_flux/median(bin_flux), bin_fluxerr/median(bin_flux), '1', errorbar_color = 'black',sym_size = 0.2,   sym_filled = 1,   xtitle = 'Time (hrs)', ytitle = 'Normalized Flux', title = planetname) 
            pl = errorplot((bin_timearrp - bin_timearrp(0))/60./60., bin_corrfluxp/median(bin_corrfluxp)-0.01,bin_corrfluxerrp/ median(bin_corrfluxp),'1s', sym_size = 0.2,   sym_filled = 1, color = 'grey',/overplot)
        endif else begin        ;for the subsequent AORs, use /overplot
           pl = plot((bin_timearr - bin_timearr(0))/60./60., bin_flux/median(bin_flux), '6r1s', sym_size = 0.2,   sym_filled = 1,  /overplot) 
           pl = plot((bin_timearr - bin_timearr(0))/60./60., bin_corrflux/median(bin_corrflux)-0.005, '1s', sym_size = 0.2,   sym_filled = 1, color = 'black',/overplot)
           
        endelse


        if keyword_set(selfcal) then begin
           restore, strcompress(dirname + 'selfcal.sav')
           print, 'test selfcal', y[0:10], 'x', x[0:10]
           ps = errorplot(x, y-0.01,yerr,'1bo',sym_size = 0.2, sym_filled = 1, errorbar_color = 'black',color = 'black',/overplot)
        endif

     endelse

     if keyword_set(centerpixplot) then begin
        if a eq 0 then begin
           cplot = plot((bin_timearr - bin_timearr(0))/60./60., bin_centerpix, '6rs1', sym_size = 0.2, sym_filled = 1, xtitle =  'Time (hrs)', ytitle = 'mean Pixel value', title = planetname) 
        endif else begin
           cplot = plot((bin_timearr - bin_timearr(0))/60./60., bin_centerpix, '6rs1', sym_size = 0.2, sym_filled = 1,/overplot) 
        endelse
     endif

  endfor                        ;binning for each AOR

 ;if keyword_set(phaseplot) then  pr.save, dirname +'binflux_phase.png' else pl.save, dirname +'binflux_time.png'

 ;test

;;;;;;;-----------------------------------------------------------------
;overplot predicted light curve
;XXX change this to fitting next

 exoplanet_light_curve, t, rel_flux, exosystem = "WASP-14 b",/verbose, /tphase
 pu.window.SetCurrent
 pu = plot(t, rel_flux,'4', color = 'Sky Blue', /overplot,/current)

;;;;;;;-----------------------------------------------------------------


  savename = strcompress(dirname + planetname +'_plot_ch'+chname+'.sav')
  save, /all, filename=savename
  print, 'saving planethash', savename

jumpend: print, 'ending early for just easy plots'
end


;  pl.yrange = [0.985, 1.005]
     
     ;try looking for specific binned data points.  
;     ap = where(bin_corrfluxp/median(bin_corrfluxp) lt 0.997)

;     c = contour(pmapdata, /fill, n_levels = 21, rgb_table = 0, xtitle = 'X (pixel)', ytitle = 'Y (pixel)', title = planetname, aspect_ratio = 1, xrange = [0,500], yrange = [0,500])
 
 ;    xcen500p = 500.* ((bin_xcenp(ap)) - 14.5)
 ;    ycen500p = 500.* ((bin_ycenp(ap)) - 14.5)
 ;    xcen500 = 500.* ((bin_xcenp) - 14.5)
 ;    ycen500 = 500.* ((bin_ycenp) - 14.5)
 ;    an = plot(xcen500, ycen500, '6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a],/overplot)
 ;    an = plot(xcen500p, ycen500p, '6r1s', sym_size = 0.1,   sym_filled = 1, /overplot)


;make a backgrounds plot as a function of time
;  if a eq 0 then  begin
;     tb = plot((bin_timearr - bin_timearr(0))/60./60., bin_bkgd , '6b1s', sym_size = 0.2,   sym_filled = 1,   xtitle = 'Time (hrs)', ytitle = 'Bkgd', title = planetname) 
;  endif else begin
;     tb = plot((bin_timearr - bin_timearr(0))/60./60., (bin_bkgd/ median(bin_bkgd) ), 'b1',  /overplot) 
;     tb = plot((bin_timearr - bin_timearr(0))/60./60., bin_ycen / median(bin_ycen) + .02 , 'b1s', sym_size = 0.2,  /overplot) 
;     tb = plot((bin_timearr - bin_timearr(0))/60./60., bin_xcen / median(bin_xcen) + .03 , 'b1s', sym_size = 0.2,  /overplot) 
  
;     tb.xrange = [0, 2]
;  endelse
   

;look for a specific time
;s = where (bin_corrfluxp/median(bin_corrfluxp)-0.004 lt 0.992)
;print, bin_corrfluxp/median(bin_corrfluxp)-0.004
;print, 'spike tiumes in hours', (bin_timearrp(s) - bin_timearrp(0))/60./60.

;s2 = where( (bin_timearr - bin_timearrp(0))/60./60. lt 3.1 and (bin_timearr - bin_timearrp(0))/60./60. gt 2.75)

;c = contour(pmapdata, /fill, n_levels = 21, rgb_table = 0, xtitle = 'X (pixel)', ytitle = 'Y (pixel)', title = planetname, aspect_ratio = 1, xrange = [0,500], yrange = [0,500])
 
;xcen500 = 500.* ((bin_xcen(s2)) - 14.5)
;ycen500 = 500.* ((bin_ycen(s2)) - 14.5)
;axcen500 = 500.* ((bin_xcen) - 14.5)
;aycen500 = 500.* ((bin_ycen) - 14.5)

;an = plot(axcen500, aycen500, '6b1s', sym_size = 0.1,   sym_filled = 1, /overplot)
;an = plot(xcen500, ycen500, '6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a],/overplot)



;a = where(bin_xcen gt 15.)
;print, 'time in hours of spike', (bin_timearr(a) - bin_timearr(0))/60./60.
;print, 'time in sclk of spike', bin_timearr(a) 

;if there are 1700 images in 4 hours
;that is 850 binned images




;-------------------------------------

 ;try getting rid of flux outliers.
  ;do some running mean with clipping
;     start = 0
;     print, 'nflux', n_elements(bin_corrflux)
;     for ni = 50, n_elements(bin_corrflux) -1, 50 do begin
;        meanclip,bin_corrflux[start:ni], m, s, subs = subs ;,/verbose
                                ;print, 'good', subs+start
                                ;now keep a list of the good ones
;        if ni eq 50 then good_ni = subs+start else good_ni = [good_ni, subs+start]
;        start = ni
;     endfor
                                ;see if it worked
     ;xarr = xarr[good_ni]
     ;yarr = yarr[good_ni]
;     bin_timearr = bin_timearr[good_ni]
;     bin_bmjdarr = bin_bmjdarr[good_ni]
;     bin_corrfluxerr = bin_corrfluxerr[good_ni]
;     bin_flux = bin_flux[good_ni]
;     bin_fluxerr = bin_fluxerr[good_ni]
;     bin_corrflux = bin_corrflux[good_ni]
;     bin_bkgd = bin_bkgd[good_ni]

;     print, 'nflux', n_elements(bin_flux)
;------------------------------------------------------

;some debugging looking for electronic ramp
;print, 'xcen', (planethash[aorname(0),'xcen'])[0:60];
;print, 'ycen', (planethash[aorname(0),'ycen'])[0:60]
;print, 'raw flux', (planethash[aorname(0),'flux'])[0:60]
;print, 'binned x, y, flux', bin_xcen[0:1], bin_ycen[0:1], bin_flux[0:1]
;print, 'median x, y, flux', median((planethash[aorname(0),'xcen'])[0:30]), median((planethash[aorname(0),'xcen'])[30:60]),  median((planethash[aorname(0),'ycen'])[0:30]), median((planethash[aorname(0),'ycen'])[30:60]),  median((planethash[aorname(0),'flux'])[0:30]), median((planethash[aorname(0),'flux'])[30:60])
