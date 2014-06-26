pro plot_exoplanet, planetname, bin_level, apradius, chname, phaseplot = phaseplot, sclkplot = sclkplot, timeplot = timeplot, Dsweet = dsweet, selfcal=selfcal, centerpixplot = centerpixplot, errorbars = errorbars, unbinned_xplot = unbinned_xplot, unbinned_yplot = unbinned_yplot, unbinned_fluxplot=unbinned_fluxplot, unbinned_npplot = unbinned_npplot, unbinned_bkgplot = unbinned_bkgplot, Position_plot = position_plot, DN_plot = DN_plot
;example call plot_exoplanet, 'wasp15', 2*63L

COMMON bin_block, aorname, planethash, bin_xcen, bin_ycen, bin_bkgd, bin_flux, bin_fluxerr,  bin_timearr, bin_phase, bin_ncorr,bin_np, bin_npcent, bin_xcenp, bin_ycenp, bin_bkgdp, bin_fluxp, bin_fluxerrp,  bin_corrfluxp,  bin_timearrp, bin_corrfluxerrp,  bin_phasep,  bin_ncorrp, bin_nparrp, bin_npcentarrp, bin_bmjdarr

 colorarr = ['blue', 'red','black','green','grey','purple', 'deep_pink','fuchsia', 'magenta', 'medium_purple','medium_orchid', 'orchid', 'violet', 'plum', 'thistle', 'pink', 'orange_red', 'light_pink', 'rosy_brown','pale_violet_red',  'chocolate', 'saddle_brown', 'maroon', 'hot_pink', 'dark_orange', 'peach_puff', 'pale_goldenrod','red',  'aquamarine', 'teal', 'steel_blue', 'dodger_blue', 'dark_blue', 'indigo','dark_slate_blue', 'blue_violet', 'purple','dim_grey', 'slate_grey', 'dark_slate_grey', 'khaki', 'tomato', 'lavender','gold', 'green_yellow', 'lime', 'green', 'olive_drab', 'pale_green', 'spring_green','blue', 'red','deep_pink', 'magenta', 'medium_purple','light_sea_green', 'teal', 'cadet_blue', 'aquamarine', 'dark_turquoise', 'aqua','blue', 'red', 'deep_pink','fuchsia', 'magenta', 'medium_purple','medium_orchid', 'orchid', 'violet', 'plum', 'thistle', 'pink', 'orange_red', 'light_pink', 'rosy_brown','pale_violet_red',  'chocolate', 'saddle_brown', 'maroon', 'hot_pink', 'dark_orange', 'peach_puff', 'pale_goldenrod','red',  'aquamarine', 'teal', 'steel_blue', 'dodger_blue', 'dark_blue', 'indigo','dark_slate_blue', 'blue_violet', 'purple','dim_grey', 'slate_grey', 'dark_slate_grey', 'khaki', 'tomato', 'lavender','gold', 'green_yellow', 'lime', 'green', 'olive_drab', 'pale_green', 'spring_green','blue', 'red','deep_pink', 'magenta', 'medium_purple','light_sea_green', 'teal', 'cadet_blue', 'aquamarine', 'dark_turquoise', 'aqua' ]
;


;run code to read in all the input planet parameters
  planetinfo = create_planetinfo()
  if chname eq '2' then aorname= planetinfo[planetname, 'aorname_ch2'] else aorname = planetinfo[planetname, 'aorname_ch1'] 
  basedir = planetinfo[planetname, 'basedir']
  period =  planetinfo[planetname, 'period']
  stareaor = planetinfo[planetname, 'stareaor']
  print, 'stareaor', stareaor
;  plot_norm= planetinfo[planetname, 'plot_norm']
;  plot_corrnorm = planetinfo[planetname, 'plot_corrnorm']
  
  dirname = strcompress(basedir + planetname +'/');+'/hybrid_pmap_nn/')
  savefilename = strcompress(dirname + planetname +'_phot_ch'+chname+'_'+string(apradius)+'.sav',/remove_all)
  print, 'restoring ', savefilename
  restore, savefilename
  print, 'aorname', aorname(0)
  time_0 = (planethash[aorname(0),'timearr']) 
  time_0 = time_0(0)
;  plothist, planethash[aorname(0),'npcentroids'], xhist, yhist, /noplot, bin = 0.01
;  testplot = plot(xhist, yhist,  xtitle = 'NP', ytitle = 'Number', thick =3, color = 'blue')

  ;print, 'testing phase', (planethash[aorname(0),'phase'] )[0:10], (planethash[aorname(0),'phase'] )[600:610]

 

;for debugging: skip some AORs
startaor = 0;5
stopaor =  n_elements(aorname) - 1


 xsweet = 15.12
 ysweet = 15.00
 
;-------------------------------------------------------
;make a bunch of plots before binning
;-------------------------------------------------------

;this one overlays the positions on the pmap contours
if keyword_set(position_plot) then begin
   fits_read, '/Users/jkrick/irac_warm/pmap/pmap_fits/pmap_ch2_0p1s_x4_500x500_0043_121120.fits', pmapdata, pmapheader
;  fits_read, '/Users/jkrick/irac_warm/pmap/pmap_fits/pmap_ch1_500x500_0043_120409.fits', pmapdata, pmapheader
   c = contour(pmapdata, /fill, n_levels = 21, rgb_table = 0, xtitle = 'X (pixel)', ytitle = 'Y (pixel)', title = planetname, aspect_ratio = 1, xrange = [0,500], yrange = [0,500])
;  print, 'naor', n_elements(aorname)
   for a = startaor ,  stopaor  do begin
;     print, 'testing aors', a, colorarr[a]
      
      xcen500 = 500.* ((planethash[aorname(a),'xcen']) - 14.5)
      ycen500 = 500.* ((planethash[aorname(a),'ycen']) - 14.5)
      an = plot(xcen500, ycen500, '1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a],/overplot)
      
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
   endfor
   xs = 500.*(xsweet - 14.5)
   ys = 500.*(ysweet - 14.5)
   an = text(xs, ys, 'X', /data, alignment = 0.5, vertical_alignment = 0.5)
   an.save, dirname+'position_ch'+chname+'.png'
endif 
;GOTO, Jumpend

;-----

  ;print, 'min', min((planetob[a].timearr - planetob[0].timearr(0))/60./60.)
 ; z = pp_multiplot(multi_layout=[1,3], global_xtitle='Time (hrs) ')
  if keyword_set(unbinned_xplot) then begin
     for a =  startaor,stopaor do begin
        if a eq startaor then begin
           xmin = 14.0          ; mean(planethash[aorname(a),'xcen'])-0.25
           xmax = 15.5          ; mean(planethash[aorname(a),'xcen'])+0.25
                                ;print, 'xmin.xmax', xmin, xmax

           am = plot( (planethash[aorname(a),'timearr'] - (planethash[aorname(a),'timearr'])(0))/60./60., planethash[aorname(a),'xcen'],'1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a], ytitle = 'X pix', title = planetname, xtitle = 'Time(hrs)', xrange = [0.,40], yrange = [15, 15.3])
        endif else begin
           am = plot( (planethash[aorname(a),'timearr'] - (planethash[aorname(0),'timearr'])(0))/60./60., planethash[aorname(a),'xcen'],'6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a],/overplot)
;           am = plot( (planethash[aorname(a),'bmjdarr'] - (planethash[aorname(a),'bmjdarr'])(0)), planethash[aorname(a),'xcen'],'6r1s-', sym_size = 0.3,   sym_filled = 1, color = colorarr[a],yrange = [14.47, 14.62], xrange = [0.1501,0.15018], ytitle = 'xcen');,/overplot)
        endelse
        
     endfor
     am.save, dirname + 'x_time_ch'+chname+'.png'
  endif

;------
  if keyword_set(unbinned_yplot) then begin
     for a = startaor,stopaor do begin ; 0, n_elements(aorname) - 1 do begin
        if a eq startaor then begin
           ymin = 14.9          ; mean(planethash[aorname(a),'ycen'])-0.25
           ymax = 16.0          ;mean(planethash[aorname(a),'ycen'])+0.25
                                ;print, 'ymin.ymax', ymin, ymax
           ay = plot( (planethash[aorname(a),'timearr'] - (planethash[aorname(a),'timearr'])(0))/60./60., planethash[aorname(a),'ycen'],'1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a], ytitle = 'Y pix', title = planetname, xtitle = 'Time(hrs)', xrange = [0.,40], yrange = [14.9, 15.2])
        endif else begin
           ay = plot( (planethash[aorname(a),'timearr'] - (planethash[aorname(0),'timearr'])(0))/60./60., planethash[aorname(a),'ycen'],'1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a],/overplot)
;           ay = plot( (planethash[aorname(a),'bmjdarr'] - (planethash[aorname(a),'bmjdarr'])(0)), planethash[aorname(a),'ycen'],'6r1s-', sym_size = 0.3,   sym_filled = 1, color = colorarr[a] , yrange = [14.3, 14.45], xrange = [0.1501,0.15018], ytitle = 'ycen');,/overplot)
        endelse
        
     endfor
     ay.save, dirname +'y_time_ch'+chname+'.png'
  endif
 
;------
  if keyword_set(unbinned_fluxplot) then begin

     for a =0, n_elements(aorname) - 1 do begin
        if a eq 0 then begin
                                ;       ymin = 14.9             ; mean(planethash[aorname(a),'ycen'])-0.25
                                ;       ymax = 16.0             ;mean(planethash[aorname(a),'ycen'])+0.25
                                ;print, 'ymin.ymax', ymin, ymax
           ay = plot( (planethash[aorname(a),'timearr'] - (planethash[aorname(0),'timearr'])(0))/60./60., planethash[aorname(a),'flux'],'1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a], ytitle = 'Flux', xtitle = 'Time(hrs)',title = planetname, yrange = [0.160, 0.172], xrange = [0,40])
           ;ay = plot( (planethash[aorname(a),'phase']), (planethash[aorname(a),'flux'])/plot_corrnorm - 0.001,'1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[a], ytitle = 'Raw Flux', xtitle = 'Phase', yrange = [0.985, 1.015], xrange = [-0.5, 0.5]) ;,title = planetname, xtitle = 'Time(hrs)'
        endif else begin
           ay = plot( (planethash[aorname(a),'timearr'] - (planethash[aorname(0),'timearr'])(0))/60./60., planethash[aorname(a),'flux'],'1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a],/overplot)
          ; ay = plot( (planethash[aorname(a),'phase']), (planethash[aorname(a),'flux'])/plot_corrnorm - 0.001,'1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[a],/overplot)
        endelse
        
     endfor
;     ay.xrange =[0,54]
;     ay.yrange = [0.0168, 0.0183]
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
           ay = plot( (planethash[aorname(a),'timearr'] - (planethash[aorname(a),'timearr'])(0))/60./60., planethash[aorname(a),'np'],'1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a], ytitle = 'NP',title = planetname, xtitle = 'Time(hrs)')
        endif else begin
           ay = plot( (planethash[aorname(a),'timearr'] - (planethash[aorname(0),'timearr'])(0))/60./60., planethash[aorname(a),'np'],'1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a], /overplot)
;           ay = plot( (planethash[aorname(a),'bmjdarr'] - (planethash[aorname(a),'bmjdarr'])(0)), planethash[aorname(a),'np'],'6r1s-', sym_size = 0.3,   sym_filled = 1, color = colorarr[a], xrange = [0.1501,0.15018], yrange = [7.3,8.5], ytitle = 'NP');,/overplot)
        endelse
        
     endfor
     ay.save, dirname +'np_time_ch'+chname+'.png'

;compare to np coming from box_centroider
     for a = 0 ,n_elements(aorname) -1 do begin ; 0, n_elements(aorname) - 1 do begin
        print, 'should be plotting npcent'
        if a eq 0 then begin
           ayc = plot( (planethash[aorname(a),'timearr'] - (planethash[aorname(a),'timearr'])(0))/60./60., planethash[aorname(a),'npcentroids'],'1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a], ytitle = 'NP',title = planetname, xtitle = 'Time(hrs)')
        endif else begin
           ayc = plot( (planethash[aorname(a),'timearr'] - (planethash[aorname(0),'timearr'])(0))/60./60., planethash[aorname(a),'npcentroids'],'1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a], /overplot)
;           ay = plot( (planethash[aorname(a),'bmjdarr'] - (planethash[aorname(a),'bmjdarr'])(0)), planethash[aorname(a),'np'],'6r1s-', sym_size = 0.3,   sym_filled = 1, color = colorarr[a], xrange = [0.1501,0.15018], yrange = [7.3,8.5], ytitle = 'NP');,/overplot)
        endelse
        
     endfor
  endif
;------
  if keyword_set(DN_plot) then begin
     fluxconv = 0.1469 ;MJy/sr / DN/s;
;     exptime = planethash[aorname(a),'exptime']
     exptime = 1.92 ;XXX
     gain = 3.71
     nch = 2 ; XXX
     pxscal1 = [-1.22334117768332D, -1.21641835430637D, -1.22673962032422D, -1.2244968325831D]
     pxscal1 = abs(pxscal1)
     pxscal2 = [1.22328355209902D, 1.21585676679388D, 1.22298117494211D, 1.21904995758086D]
     pscale2 = pxscal1[nch-1] * pxscal2[nch-1]
     scale = pscale2 * !DPI * !DPI / (3600.D * 3600.D * 180.D * 180.D) * 1.0D+06

   for a = 0,n_elements(aorname) -1 do begin ; 0, n_elements(aorname) - 1 do begin

      mjy = planethash[aorname(a),'flux']
      mjypersr = mjy/ scale
      DNpers = mjypersr / fluxconv
      DN = DNpers *exptime
      e = DN * gain
        if a eq 0 then begin
           ay = plot( (planethash[aorname(a),'timearr'] - (planethash[aorname(0),'timearr'])(0))/60./60., e,'1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[a], ytitle = 'Electrons', xtitle = 'Time(hrs)') ;,title = planetname
        endif else begin
           ay = plot( (planethash[aorname(a),'timearr'] - (planethash[aorname(0),'timearr'])(0))/60./60., e,'1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[a],/overplot)
        endelse
        
     endfor
    ay.save, dirname +'e_time_ch'+chname+'.png'

  endif

;------
  
;------
     
     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;goto, jumpend

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
; bin within each AOR only, don't want to bin across boundaries.
     junkpar = binning_function(a, bin_level, pmapcorr)
;     print, 'testing phase', (planethash[aorname(a),'phase'] )[0:10], (planethash[aorname(a),'phase'] )[600:610]
;     print, 'testing x', bin_xcen[0:10]
;     print, 'testing y', bin_ycen[0:10]
;     print, 'testing npcent', bin_npcent[0:10]
;------------------------------------------------------
     ;possible comparison statistic
     ;what is the distribution of standard deviations among the corrfluxes?

     meanclip, planethash[aorname(a),'corrflux'] , mean_corrflux, stddev_corrflux
     stddev_corrfluxarr[a] = stddev_corrflux
;------------------------------------------------------
;now try plotting

     if keyword_set(dsweet) then begin
        ;measure mean distance from the sweet spot
        xdist = (planethash[aorname(a),'xcen'] - xsweet)
        ydist = (planethash[aorname(a),'ycen'] - ysweet)
        meanclip, ydist, meany, stddevy
        meanclip, xdist, meanx, stddevx

        dsweet = sqrt(xdist^2 + ydist^2)
        meanclip, dsweet, mean_dsweet, stddev_dsweet
        
        meanclip, planethash[aorname(a),'corrflux'] , mean_corrflux, stddev_corrflux

        theta = 180./!Pi*ATAN(ydist, xdist) ; in degrees
        
        ;ahhh quadrants
;        if xdist gt 0 and ydist gt 0 then theta = theta
;        if mean(xdist) ge 0 and mean(ydist) lt 0 then theta = theta + 360
;        if mean(xdist) lt 0 then theta = theta +180

       meanclip, theta, mean_theta, stddev_theta

        if a eq startaor then begin 
           normfactor = mean_corrflux
;           sweetplot = errorplot([mean_theta],[mean_corrflux/normfactor],  [stddev_theta], [stddev_corrflux/normfactor],$
;                                 '1s', sym_size = 0.4,   sym_filled = 1,  xtitle = 'Theta', ytitle = 'Corrflux', title = planetname,$
;                                color = colorarr[a],  yrange = [0.99, 1.01]) 
;           stddevplot = plot([mean_theta],[stddev_corrflux/normfactor], '1s', sym_size = 2.0, color = colorarr[a],  $
;                             sym_filled = 1,  xtitle = 'Theta', ytitle = 'Stddev Corrflux', title = planetname) 
           dtheta = plot([mean_theta], [stddevx],$
                                 '1s', sym_size = 1.0,   sym_filled = 1,  xtitle = 'Theta', ytitle = 'Stddev X centroids', title = planetname,$
                                color = colorarr[a]) 
        endif else begin
;           sweetplot.window.SetCurrent
;           sweetplot = errorplot([mean_theta],[mean_corrflux/normfactor],  [stddev_theta], [stddev_corrflux/normfactor],$
;                                 '1s', sym_size = 0.4,  sym_filled = 1, color = colorarr[a],/overplot) 
;           stddevplot.window.SetCurrent
;           stddevplot = plot([mean_theta],[stddev_corrflux/normfactor], '1s', sym_size = 2.0, color = colorarr[a],  $
;                             sym_filled = 1,/overplot) 
;           dtheta.window.SetCurrent
           dtheta = plot([mean_theta], [stddevx],$
                                 '1s', sym_size = 1.0,   sym_filled = 1, color = colorarr[a],/overplot) 
        endelse


     endif

;------------------------------------------------------


     if keyword_set(sclkplot) then begin

        sclk_0 = planethash[aorname(a),'sclktime_0']  ; in seconds
        
        ;turn bmjd into sclk
        elapsed_days= bin_bmjdarr(n_elements(bin_bmjdarr)-1) - bin_bmjdarr(0)
        elapsed_secs = elapsed_days*24.*60.*60.
        bin_sclk = dindgen(n_elements(bin_bmjdarr))*elapsed_secs / n_elements(bin_bmjdarr)
        bin_sclk = bin_sclk + sclk_0

        print, 'testing sclk', bin_sclk[0:10], bin_sclk(n_elements(bin_sclk)-1)
        print, 'showing bmjd', bin_bmjdarr[0:10], bin_bmjdarr(n_elements(bin_bmjdarr)-1)

        ;psn= plot(bin_sclk, bin_np, '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[a], $
        ;            xtitle = 'Sclk_time', ytitle = 'Noise Pixel', title = planetname)
        psx = plot(bin_sclk, bin_xcen, '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[a], $
                    xtitle = 'Sclk_time', ytitle = 'Xcen', title = planetname)
        psy= plot(bin_sclk, bin_ycen, '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[a], $
                    xtitle = 'Sclk_time', ytitle = 'Ycenl', title = planetname)
     endif

;------------------------------------------------------


     if keyword_set(phaseplot) then begin ;make the plot as a function of phase
        
        setxrange = [-0.5, 0.5]
        corrnormoffset =  0.02
        corroffset = 0;0.001
        setynormfluxrange = [0.97, 1.005];[0.97, 1.005]
        if a eq startaor then begin    ; for the first AOR
                                ;set the normalization values from the
                                ;medians of the first AOR...is close enough
           plot_norm = median(bin_flux)
           plot_corrnorm = mean(bin_corrfluxp,/nan)
           print, 'plot_corrnorm', plot_corrnorm, mean(bin_corrfluxp)
           pp = plot(bin_phase, bin_xcen, '1s', sym_size = 0.2,   sym_filled = 1, title = planetname, $
                     color = colorarr[a], xtitle = 'Orbital Phase', ytitle = 'X position', $
                     xrange = setxrange)

           pq = plot(bin_phase, bin_ycen, '1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[a], $
                     xtitle = 'Orbital Phase', ytitle = 'Y position', title = planetname, $
                     xrange = setxrange)

           if keyword_set(errorbars) then begin
              pr = errorplot(bin_phase, bin_flux/plot_norm,bin_fluxerr/plot_norm,  '1s', sym_size = 0.2,   $
                             sym_filled = 1,  color =colorarr[a],  xtitle = 'Orbital Phase', $
                             ytitle = 'Normalized Flux', title = planetname, yrange = setynormfluxrange, $
                             xrange = setxrange )
           endif else begin
              print, 'testing bin_flux', bin_flux[1:10]/plot_norm
              pr = plot(bin_phase, bin_flux/plot_norm, '1s', sym_size = 0.2,   sym_filled = 1,  $
                        color = 'green',  xtitle = 'Orbital Phase', ytitle = 'Normalized Flux', $
                        title = planetname, yrange = setynormfluxrange, xrange = setxrange,/nodata) 
           endelse  ;/errorbars
           if pmapcorr eq 1 then begin
              print, 'inside pmapcorr eq 1', median( (bin_corrfluxp/plot_corrnorm) ), median(bin_flux)
              if keyword_set(errorbars) then begin
                 pr = errorplot(bin_phasep, (bin_corrfluxp/plot_corrnorm) -corrnormoffset,  $
                        bin_corrfluxerrp/plot_corrnorm ,/overplot, '1s', sym_size = 0.2, $
                        sym_filled = 1, color = colorarr[a])
              endif else begin
                 print, 'plotting corrfluxp',  (bin_corrfluxp(1)/plot_corrnorm) -corrnormoffset
                 pr = plot(bin_phasep, (bin_corrfluxp/plot_corrnorm) -corrnormoffset ,/overplot, '1s', $
                           sym_size = 0.2,   sym_filled = 1, color = colorarr[a])
              endelse           ;/errorbars

           endif  ;enough pmap corrections

           ps= plot(bin_phase, bin_npcent, '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[a], $
                    xtitle = 'Orbital Phase', ytitle = 'Noise Pixel', title = planetname,$
                    xrange = setxrange)

           pt = plot(bin_phase, bin_bkgd, '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[a], $
                     xtitle = 'Orbital Phase', ytitle = 'Background', title = planetname, $
                     xrange =setxrange)

           ;setup a plot for just the snaps
           if n_elements(aorname) gt 10 then begin
              pu = plot(bin_phase, (bin_corrfluxp/plot_corrnorm) + corroffset, xtitle = 'Orbital Phase', $
                        title = planetname, ytitle = 'Normalized Flux',  yrange = [0.989, 1.005], xrange = setxrange, /nodata) ;
           endif

        endif                   ; if a = 0

      ;  test_med(a) = median(bin_corrfluxp)
        print,'median bin_corrfluxp ',  median(bin_corrfluxp), median(bin_flux)
        if (a gt 0) and (a le stareaor) then begin
           print, 'inside a gt 0 a le stareaor', a
           pp.window.SetCurrent
           pp = plot(bin_phase, bin_xcen, '1s', sym_size = 0.2,   sym_filled = 1,color = colorarr[a],  /overplot,/current)
           pq.window.SetCurrent
           pq = plot(bin_phase, bin_ycen, '1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[a], /overplot,/current)
           pr.window.SetCurrent
           pr = plot(bin_phase, bin_flux/plot_norm , '1s', sym_size = 0.2,   sym_filled = 1,  color = 'green', /overplot,/current,/nodata)
           print, 'just before pmapcorr',mean(bin_flux/plot_norm)

           if pmapcorr eq 1 then begin
              print, 'inside pmapcorr agt 0 a le stareaor'
              print, 'mean levle', mean((bin_corrfluxp/plot_corrnorm)-corrnormoffset)
              pr = plot(bin_phasep, (bin_corrfluxp/plot_corrnorm)-corrnormoffset, /overplot, 's1', sym_size = 0.2,   sym_filled = 1, color = colorarr[a],/current)
           endif

           ps.window.SetCurrent
           ps = plot(bin_phase, bin_npcent, '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[a], /overplot,/current) ;, xtitle = 'Orbital Phase', ytitle = 'Normalized Flux',) 

           pt.window.SetCurrent
           pt = plot(bin_phase, bin_bkgd, '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[a],/overplot,/current) 
        endif



        if a gt stareaor then begin
           print, 'inside a gt stareaor', a
           pp.window.SetCurrent
           pp = plot(bin_phase, bin_xcen, '1s', sym_size = 0.2,   sym_filled = 1,color = colorarr[a],$
                     /overplot,/current)

           pq.window.SetCurrent
           pq = plot(bin_phase, bin_ycen, '1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[a],$
                     /overplot,/current)

           pr.window.SetCurrent
           if keyword_set(errorbars) then begin
              pr = errorplot(bin_phase, bin_flux/(plot_norm) , bin_fluxerr/plot_norm, '1s', $
                        sym_size = 0.2,   sym_filled = 1,  color = colorarr[a], /overplot,/current) 
           endif else begin
              pr = plot(bin_phase, bin_flux/(plot_norm) , '1s', sym_size = 0.2,   sym_filled = 1,  $
                        color = colorarr[a], /overplot,/current,/nodata)
           endelse


           if pmapcorr eq 1 then begin
              print, 'inside pmapcorr eq 1', median( (bin_corrfluxp/plot_corrnorm) +corroffset)

               if keyword_set(errorbars) then begin
                  pr = errorplot(bin_phasep, (bin_corrfluxp/plot_corrnorm)- corrnormoffset,$
                            bin_corrfluxerrp/ plot_corrnorm, '1s', sym_size = 0.2,   $
                            sym_filled = 1, color = colorarr[a],/overplot,/current)
               endif else begin
                  pr = plot(bin_phasep, (bin_corrfluxp/plot_corrnorm) - corrnormoffset, '1s', $
                            sym_size = 0.2,   sym_filled = 1, color = colorarr[a],/overplot,/current)
               endelse


          ;setup a plot for just the snaps
               if n_elements(aorname) gt 10 then begin
                  
                  pu.window.SetCurrent
                  pu = plot(bin_phasep, (bin_corrfluxp/plot_corrnorm) + corroffset, '1s', $
                            sym_size = 0.2,   sym_filled = 1, color = colorarr[a],/overplot,/current)
               endif
            endif
           
           ps.window.SetCurrent
           ps = plot(bin_phase, bin_npcent, '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[a],$
                     /overplot,/current) 

           pt.window.SetCurrent
           pt = plot(bin_phase, bin_bkgd, '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[a], $
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
           pk = plot(bin_time, bin_corr_flux - 0.017, '1s', sym_size =  0.3, sym_filled = 1, color = colorarr[a], /overplot, /current)
        endif
        

     endif 

;------------------------------------------------------
     print, 'n_elements time', n_elements(bin_timearr), n_elements(bin_xcen), n_elements(bin_phase)
     if keyword_set(timeplot) then begin ;make the plot as a function of time
        print, 'making plot as a function of time'
        corrnormoffset = 0;0.02
        corroffset = 0.001
        setynormfluxrange = [0.98, 1.01];[0.97, 1.005]
        if a eq startaor then begin    ; for the first AOR
                                ;set the normalization values from the
                                ;medians of the first AOR...is close enough
           plot_norm = median(bin_flux)
           plot_corrnorm = mean(bin_corrfluxp,/nan)
           print, 'plot_corrnorm', plot_corrnorm, mean(bin_corrfluxp)
           pp = plot((bin_timearr - time_0)/60./60., bin_xcen, '1s', sym_size = 0.2,   sym_filled = 1, $;title = planetname, $
                     color = colorarr[a], xtitle = 'Time(hrs)', ytitle = 'X position', aspect_ratio = 0.0, margin = 0.2);, $
                     ;xrange = setxrange)
                     

           pq = plot((bin_timearr - time_0)/60./60., bin_ycen, '1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[a], $
                     xtitle = 'Time(hrs)', ytitle = 'Y position', aspect_ratio = 0.0, margin = 0.2);, $, title = planetname
                     ;xrange = setxrange)

           if keyword_set(errorbars) then begin
              pr = errorplot((bin_timearr - time_0)/60./60., bin_flux/plot_norm,bin_fluxerr/plot_norm,  '1s', sym_size = 0.2,   $
                             sym_filled = 1,  color =colorarr[a],  xtitle = 'Time(hrs)', $
                             ytitle = 'Normalized Flux' ,yrange = setynormfluxrange, $ ;, title = planetname,
                             xrange = setxrange , aspect_ratio = 0.0, margin = 0.2)
           endif else begin
              pr = plot((bin_timearr - time_0)/60./60., bin_flux/plot_norm, '1s', sym_size = 0.2,   sym_filled = 1,  $
                        color = colorarr[a],  xtitle = 'Time(hrs)', ytitle = 'Normalized Flux', $ ;title = planetname, 
                        yrange = setynormfluxrange, aspect_ratio = 0.0, margin = 0.2);, xrange = setxrange);,/nodata) 
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

           ps= plot((bin_timearr - time_0)/60./60., bin_npcent, '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[a], $
                    xtitle = 'Time(hrs)', ytitle = 'Noise Pixel',  aspect_ratio = 0.0, margin = 0.2);,$ title = planetname,
                    ;xrange = setxrange)

           pt = plot((bin_timearr - time_0)/60./60., bin_bkgd, '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[a], $
                     xtitle = 'Time(hrs)', ytitle = 'Background',  aspect_ratio = 0.0, margin = 0.2);, $ title = planetname,
                    ; xrange =setxrange)

           ;setup a plot for just the snaps
           if n_elements(aorname) gt 10 then begin
              pu = plot((bin_timearr - time_0)/60./60., (bin_corrfluxp/plot_corrnorm) + corroffset, xtitle = 'Time(hrs)', $
                        title = planetname, ytitle = 'Normalized Flux',  yrange = [0.989, 1.005], aspect_ratio = 0.0, margin = 0.2);, xrange = setxrange, /nodata) ;
           endif

        endif                   ; if a = 0

      ;  test_med(a) = median(bin_corrfluxp)
        print,'median bin_corrfluxp ',  median(bin_corrfluxp), median(bin_flux)
        if (a gt 0) and (a le stareaor) then begin
           print, 'inside a gt 0 a le stareaor', a
           pp.window.SetCurrent
           pp = plot((bin_timearr - time_0)/60./60., bin_xcen, '1s', sym_size = 0.2,   sym_filled = 1,color = colorarr[a],  /overplot,/current)
           pq.window.SetCurrent
           pq = plot((bin_timearr - time_0)/60./60., bin_ycen, '1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[a], /overplot,/current)
           pr.window.SetCurrent
           pr = plot((bin_timearr - time_0)/60./60., bin_flux/plot_norm , '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[a], /overplot,/current,/nodata)
           if pmapcorr eq 1 then begin
              pr = plot((bin_timearr - time_0)/60./60., (bin_corrfluxp/plot_corrnorm)-corrnormoffset, /overplot, 's1', sym_size = 0.2,   sym_filled = 1, color = colorarr[a],/current)
           endif

           ps.window.SetCurrent
           ps = plot((bin_timearr - time_0)/60./60., bin_npcent, '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[a], /overplot,/current) ;, xtitle = 'Time(hrs)', ytitle = 'Normalized Flux',) 

           pt.window.SetCurrent
           pt = plot((bin_timearr - time_0)/60./60., bin_bkgd, '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[a],/overplot,/current) 
        endif



        if a gt stareaor then begin
           print, 'inside a gt stareaor', a
           pp.window.SetCurrent
           pp = plot((bin_timearr - time_0)/60./60., bin_xcen, '1s', sym_size = 0.2,   sym_filled = 1,color = colorarr[a],$
                     /overplot,/current)

           pq.window.SetCurrent
           pq = plot((bin_timearr - time_0)/60./60., bin_ycen, '1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[a],$
                     /overplot,/current)

           pr.window.SetCurrent
           if keyword_set(errorbars) then begin
              pr = errorplot((bin_timearr - time_0)/60./60., bin_flux/(plot_norm) , bin_fluxerr/plot_norm, '1s', $
                        sym_size = 0.2,   sym_filled = 1,  color = colorarr[a], /overplot,/current) 
           endif else begin
              pr = plot((bin_timearr - time_0)/60./60., bin_flux/(plot_norm) , '1s', sym_size = 0.2,   sym_filled = 1,  $
                        color = colorarr[a], /overplot,/current,/nodata)
           endelse


           if pmapcorr eq 1 then begin
              print, 'inside pmapcorr eq 1', median( (bin_corrfluxp/plot_corrnorm) +corroffset)

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

           ps.window.SetCurrent
           ps = plot((bin_timearr - time_0)/60./60., bin_npcent, '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[a],$
                     /overplot,/current) 

           pt.window.SetCurrent
           pt = plot((bin_timearr - time_0)/60./60., bin_bkgd, '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[a], $
                     /overplot,/current) 

        endif

        pp.save, dirname +'binxcen_time_ch'+chname+'.eps'
        pq.save, dirname +'binycen_time_ch'+chname+'.eps'
        pt.save, dirname +'binbkg_time_ch'+chname+'.eps'
        ps.save, dirname + 'binnp_time_ch'+chname+'.eps'
        pr.save, dirname + 'binflux_time_ch'+chname+'.eps'

     endif

     if keyword_set(centerpixplot) then begin
        if a eq 0 then begin
           cplot = plot((bin_timearr - time_0)/60./60., bin_centerpix, '6rs1', sym_size = 0.2, sym_filled = 1, xtitle =  'Time (hrs)', ytitle = 'mean Pixel value', title = planetname) 
        endif else begin
           cplot = plot((bin_timearr - time_0)/60./60., bin_centerpix, '6rs1', sym_size = 0.2, sym_filled = 1,/overplot) 
        endelse
     endif

;keep these for fitting later
;     (bin_timearr - bin_timearr(0))/60./60.final(a) = bin_phasep
;     bin_corrfluxfinal(a) = (bin_corrfluxp/plot_corrnorm) 
;    bin_corrfluxerrfinal(a) = bin_corrfluxerrp / plot_corrnorm

  endfor                        ;binning for each AOR

;what is the distrubition of standard deviations in the corrfluxes?
;plothist, stddev_corrfluxarr, xhist, yhist, /autobin, /noplot,/nan
;di = plot(xhist, yhist, thick = 2, xtitle = 'standard deviation of corrflux', ytitle = 'Number', title = planetname, yrange = [0,20], xrange = [2.1E-4, 2.6E-4])

 ;if keyword_set(phaseplot) then  pr.save, dirname +'binflux_phase.png' else pl.save, dirname +'binflux_time.png'

 ;test

;;;;;;;-----------------------------------------------------------------
;overplot predicted light curve
;XXX change this to fitting next
;  exosystemname = "WASP-14 b"
;;  exoplanet_light_curve, t, rel_flux, exosystem = exosystemname,/verbose, /tphase
;  fit_exoplanet_light_curve, exosystemname, apradius
;  strput, savefilename, 'model',69
;  print, 'savefilename', savefilename
;  restore, savefilename
;  pu.window.SetCurrent
;  pu = plot(phase, rel_flux,'4', color = 'Sky Blue', /overplot,/current)
;  pu.save,dirname + 'snap_bin_corrflux_fit.png'
;;;;;;;-----------------------------------------------------------------


  savename = strcompress(dirname + planetname +'_plot_ch'+chname+'.sav')
  save, /all, filename=savename
  print, 'saving planethash', savename

jumpend: print, 'ending '
end


;  pl.yrange = [0.985, 1.005]
     
     ;try looking for specific binned data points.  
;     ap = where(bin_corrfluxp/median(bin_corrfluxp) lt 0.997)

;     c = contour(pmapdata, /fill, n_levels = 21, rgb_table = 0, xtitle = 'X (pixel)', ytitle = 'Y (pixel)', title = planetname, aspect_ratio = 1, xrange = [0,500], yrange = [0,500])
 
 ;    xcen500p = 500.* ((bin_xcenp(ap)) - 14.5)
 ;    ycen500p = 500.* ((bin_ycenp(ap)) - 14.5)
 ;    xcen500 = 500.* ((bin_xcenp) - 14.5)
 ;    ycen500 = 500.* ((bin_ycenp) - 14.5)
 ;    an = plot(xcen500, ycen500, '6r1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[a],/overplot)
 ;    an = plot(xcen500p, ycen500p, '6r1s', sym_size = 0.2,   sym_filled = 1, /overplot)


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

;an = plot(axcen500, aycen500, '6b1s', sym_size = 0.2,   sym_filled = 1, /overplot)
;an = plot(xcen500, ycen500, '6r1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[a],/overplot)



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
