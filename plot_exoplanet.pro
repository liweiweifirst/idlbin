pro plot_exoplanet, planetname,bin_level, phaseplot = phaseplot, selfcal=selfcal, centerpixplot = centerpixplot
;example call plot_exoplanet, 'wasp15', 63L

; if keyword_set(phaseplot) then print, 'keyword set phase'
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
  
;  bin_level = 63L               ; 63L;*60
  
  dirname = strcompress(basedir + planetname +'/')
  savefilename = strcompress(dirname + planetname +'_phot_ch'+chname+'.sav')
  restore, savefilename
  
  colorarr = ['blue', 'red','deep_pink', 'magenta', 'medium_purple', 'hot_pink', 'light_pink', 'rosy_brown', 'chocolate', 'saddle_brown', 'maroon', 'orange_red', 'dark_orange', 'peach_puff', 'pale_goldenrod','red',  'aquamarine', 'teal', 'steel_blue', 'dodger_blue', 'dark_blue', 'indigo','dark_slate_blue', 'blue_violet', 'purple','dim_grey', 'slate_grey', 'dark_slate_grey', 'khaki','black', 'tomato', 'lavender','gold', 'green_yellow', 'lime', 'green', 'olive_drab', 'pale_green', 'spring_green','blue', 'red','deep_pink', 'magenta', 'medium_purple' ]

 
;-------------------------------------------------------
  transit_duration = transit_duration /60./24.  ; in days

  for a = 0, n_elements(aorname) - 1 do  begin
;       planetob[a].bmjdarr = ((planetob[a].bmjdarr - utmjd_center) / period) 
;    phase = (((planethash[aorname(a),'bmjdarr']) -  utmjd_center)/period) + intended_phase

     ;print, 'testing (planethash[aorname(0),corrflux])[0:10]',(planethash[aorname(0),'corrflux'])[0:10]



     ;now try to get them all within the same [0,1] phase     
     bmjd = (planethash[aorname(a),'bmjdarr'])
     print, 'bmjd', bmjd(0), format = '(A,F0)'
     bmjd_dist = bmjd - utmjd_center ; how many UTC away from the transit center
     print, 'bmjd- utmjd', bmjd_dist(0), format = '(A,F0)'
     phase =( bmjd_dist / period )- fix(bmjd_dist/period)
                                ;ok, but now I want -0.5 to 0.5, not 0 to 1
                                ;need to be careful here because subtracting half a phase will put things off, need something else
     print, ' before phase',  phase(0), format = '(A,F0)'    
     pa = where(phase gt 0.5,pacount)
;    ;print, 'pa', pa
    if pacount gt 0 then phase[pa] = phase[pa] - 1.0
;    print, ' after phase',  phase(0), format = '(A,F0)'
;    print, 'nphase, corr', n_elements(phase), n_elements(bin_corrflux)
    ;changing the bmjd tag to now house the phases
    planethash[aorname(a),'bmjdarr'] = phase
  endfor



  fits_read, '/Users/jkrick/idlbin/pmap_fits/pmap_ch2_0p1s_x4_500x500_0043_120531.fits', pmapdata, pmapheader
;  c = contour(pmapdata, /fill, n_levels = 21, rgb_table = 0, xtitle = 'X (pixel)', ytitle = 'Y (pixel)', title = planetname, aspect_ratio = 1, xrange = [0,500], yrange = [0,500])
;  for a = 0, n_elements(aorname) - 1 do begin
;     xcen500 = 500.* ((planethash[aorname(a),'xcen']) - 14.5)
;     ycen500 = 500.* ((planethash[aorname(a),'ycen']) - 14.5)
;     an = plot(xcen500, ycen500, '6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a],/overplot)
; endfor
;  an.save, dirname+'position.png'
;-----
 
  ;print, 'min', min((planetob[a].timearr - planetob[0].timearr(0))/60./60.)

    for a = 0, n_elements(aorname) - 1 do begin
     if a eq 0 then begin
        xmin = mean(planethash[aorname(a),'xcen'])-0.25
        xmax = mean(planethash[aorname(a),'xcen'])+0.25
        ;print, 'xmin.xmax', xmin, xmax

 ;       am = plot( (planethash[aorname(a),'timearr'] - (planethash[aorname(0),'timearr'])(0))/60./60., planethash[aorname(a),'xcen'],'6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a], xtitle = 'Time(hrs)', ytitle = 'X pix', title = planetname, yrange = [xmin,xmax])
     endif else begin
;        am = plot( (planethash[aorname(a),'timearr'] - (planethash[aorname(0),'timearr'])(0))/60./60., planethash[aorname(a),'xcen'],'6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a],/overplot)
     endelse

  endfor
;    am.save, dirname + 'x_time.png'
;------

  for a = 0, n_elements(aorname) - 1 do begin
     if a eq 0 then begin
        ymin = mean(planethash[aorname(a),'ycen'])-0.25
        ymax = mean(planethash[aorname(a),'ycen'])+0.25
        ;print, 'ymin.ymax', ymin, ymax
;       am = plot( (planethash[aorname(a),'timearr'] - (planethash[aorname(0),'timearr'])(0))/60./60., planethash[aorname(a),'ycen'],'6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a], xtitle = 'Time(hrs)', ytitle = 'Y pix',title = planetname, yrange = [ymin, ymax])
     endif else begin
;        am = plot( (planethash[aorname(a),'timearr'] - (planethash[aorname(0),'timearr'])(0))/60./60., planethash[aorname(a),'ycen'],'6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a],/overplot)
     endelse

  endfor
; am.save, dirname +'y_time.png'

;------
;  for a = 0, n_elements(aorname) - 1 do begin
;     if a eq 0 then begin
;        am = plot( (planethash[aorname(a),'timearr'] - (planethash[aorname(0),'timearr'])(0))/60./60., planethash[aorname(a),'bkgd'],'6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a], xtitle = 'Time(hrs)', ytitle = 'Background', title = planetname)
;        print, 'bkgd', n_elements(planethash[aorname(a),'bkgd'])
;     endif else begin
;        am = plot( (planethash[aorname(a),'timearr'] - (planethash[aorname(0),'timearr'])(0))/60./60., planethash[aorname(a),'bkgd'],'6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a],/overplot)
;     endelse

;  endfor

;------
;  for a = 0, n_elements(aorname) - 1 do begin
;     if a eq 0 then begin
;        am = errorplot( (planethash[aorname(a),'timearr'] - (planethash[aorname(0),'timearr'])(0))/60./60., planethash[aorname(a),'flux'],planethash[aorname(a),'fluxerr'], '6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a], xtitle = 'Time(hrs)', ytitle = 'Flux', title = planetname, xrange = [0,10], yrange = [0.03,0.045], errorbar_capsize = 0.)
;        am = errorplot( (planethash[aorname(a),'timearr'] - (planethash[aorname(0),'timearr'])(0))/60./60., planethash[aorname(a),'corrflux']-0.003,planethash[aorname(a),'corrfluxerr'],'6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a], /overplot, errorbar_capsize = 0.)
;     endif else begin
;        am = errorplot( (planethash[aorname(a),'timearr'] - (planethash[aorname(0),'timearr'])(0))/60./60., planethash[aorname(a),'flux'],planethash[aorname(a),'fluxerr'],'6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a],/overplot, errorbar_capsize = 0.)
; am = errorplot( (planethash[aorname(a),'timearr'] - (planethash[aorname(0),'timearr'])(0))/60./60., planethash[aorname(a),'corrflux']-0.003,planethash[aorname(a),'corrfluxerr'],'6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a],/overplot, errorbar_capsize = 0.)
;     endelse

;  endfor

;------


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;try this diffferently, bin within each AOR only, don't want to bin across boundaries.

  for a = 0, n_elements(aorname) - 1 do begin
   
     timearr = [planethash[aorname(a),'timearr']]
     fluxarr = [ planethash[aorname(a),'flux']]
     fluxerrarr = [ planethash[aorname(a),'fluxerr']]
     corrfluxarr = [ planethash[aorname(a),'corrflux']]
     corrfluxerrarr = [planethash[aorname(a),'corrfluxerr']]
     xarr = [ planethash[aorname(a),'xcen']]
     yarr = [planethash[aorname(a),'ycen']]
     bkgd = [ planethash[aorname(a),'bkgd']]
     bmjd = [ planethash[aorname(a),'bmjdarr']]
     centerpixarr = [ planethash[aorname(a),'centerpixarr5']]
     print, 'testing corrfluxarr', corrfluxarr[0:10]

                                ;check if I should be using pmap corr or not
     ncorr = where(finite(corrfluxarr) gt 0)
     ;if 70% of the values are correctable than go with the pmap corr 
     print, 'nflux, ncorr, ', n_elements(fluxarr), n_elements(ncorr)
     if n_elements(ncorr) gt 0.2*n_elements(fluxarr) then pmapcorr = 1 else pmapcorr = 0

     ;remove outliers, 
;     if pmapcorr eq 1 then begin 
        goodpmap = where(xarr lt mean(xarr) + 2.5*stddev(xarr) and xarr gt mean(xarr) -2.5*stddev(xarr) and xarr lt mean(xarr) +3.0*stddev(yarr) and yarr gt mean(yarr) - 3.0*stddev(yarr) and finite(corrfluxarr) gt 0  ,ngood_pmap, complement=badpmap) ;
 ;    endif else begin
        good = where(xarr lt mean(xarr) + 2.5*stddev(xarr) and xarr gt mean(xarr) -2.5*stddev(xarr) and xarr lt mean(xarr) +3.0*stddev(yarr) and yarr gt mean(yarr) - 3.0*stddev(yarr) ,ngood, complement=bad)
 ;    endelse
     
;     print, 'testing good', good[0:10]

     print, 'bad ',n_elements(bad), n_elements(good)
     print, 'badp ',n_elements(badpmap), n_elements(goodpmap)
     xarr = xarr[good]
     yarr = yarr[good]
     timearr = timearr[good]
     flux = fluxarr[good]
     fluxerr = fluxerrarr[good]
     corrflux = corrfluxarr[good]
     corrfluxerr = corrfluxerrarr[good]
     bmjdarr = bmjd[good]
     bkgdarr = bkgd[good]
     phasearr = phase[good]
     centerpixarr = centerpixarr[good]

;and a second set for those that are in the sweet spot
     xarrp = xarr[goodpmap]
     yarrp = yarr[goodpmap]
     timearrp = timearr[goodpmap]
     fluxp = fluxarr[goodpmap]
     fluxerrp= fluxerrarr[goodpmap]
     corrfluxp = corrfluxarr[goodpmap]
     corrfluxerrp = corrfluxerrarr[goodpmap]
     bmjdarrp = bmjd[goodpmap]
     bkgdarrp = bkgd[goodpmap]
     phasearrp = phase[goodpmap]
     centerpixarrp = centerpixarr[goodpmap]

;     print, 'testing after outlier', flux[0:10]
; binning
     numberarr = findgen(n_elements(xarr))
     h = histogram(numberarr, OMIN=om, binsize = bin_level, reverse_indices = ri)
     print, 'omin', om, 'nh', n_elements(h)

     numberarrp = findgen(n_elements(xarrp))
     hp = histogram(numberarrp, OMIN=omp, binsize = bin_level, reverse_indices = rip)
     print, 'ominp', omp, 'nhp', n_elements(hp), n_elements(xarrp)


;mean together the flux values in each phase bin
     bin_flux = dblarr(n_elements(h))
     bin_fluxerr = dblarr(n_elements(h))
     bin_corrflux= dblarr(n_elements(h))
     bin_corrfluxerr= dblarr(n_elements(h))
     bin_ncorr = dblarr(n_elements(h))
     bin_timearr = dblarr(n_elements(h))
     bin_bmjdarr = dblarr(n_elements(h))
     bin_bkgd = dblarr(n_elements(h))
     bin_bkgderr = dblarr(n_elements(h))
     bin_xcen = dblarr(n_elements(h))
     bin_ycen = dblarr(n_elements(h))
     bin_phase = dblarr(n_elements(h))
     bin_centerpix = dblarr(n_elements(h))

     bin_fluxp = dblarr(n_elements(hp))
     bin_fluxerrp = dblarr(n_elements(hp))
     bin_corrfluxp= dblarr(n_elements(hp))
     bin_corrfluxerrp= dblarr(n_elements(hp))
     bin_ncorrp = dblarr(n_elements(hp))
     bin_timearrp = dblarr(n_elements(hp))
     bin_bmjdarrp = dblarr(n_elements(hp))
     bin_bkgdp = dblarr(n_elements(hp))
     bin_bkgderrp = dblarr(n_elements(hp))
     bin_xcenp = dblarr(n_elements(hp))
     bin_ycenp= dblarr(n_elements(hp))
     bin_phasep = dblarr(n_elements(hp))
     bin_centerpixp = dblarr(n_elements(hp))
     c = 0
     for j = 0L, n_elements(h) - 1 do begin

;get rid of the bins with no values and low numbers, meaning low overlap
        if (ri[j+1] gt ri[j] + 2)  then begin ;require 3 elements in the bin
;           print, 'binning together', n_elements(numberarr[ri[ri[j]:ri[j+1]-1]])
        ;print, 'binning', numberarr[ri[ri[j]:ri[j+1]-1]]
        
           meanclip, xarr[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
           bin_xcen[c] = meanx   ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
;           print, 'finished x'

           meanclip, yarr[ri[ri[j]:ri[j+1]-1]], meany, sigmay
           bin_ycen[c] = meany   ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
;           print, 'finished y'

           meanclip, bkgdarr[ri[ri[j]:ri[j+1]-1]], meansky, sigmasky
           bin_bkgd[c] = meansky ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
;           print, 'finished bkgd'

           meanclip, flux[ri[ri[j]:ri[j+1]-1]], meanflux, sigmaflux
           bin_flux[c] = meanflux ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
;           print, 'finished flux'

           junk = where(finite(corrflux[ri[ri[j]:ri[j+1]-1]]) gt 0,ngood)
           bin_ncorr[c] = ngood
           ;can only compute means if there are values in there
;           if pmapcorr eq 1 then begin
;              meanclip, corrflux[ri[ri[j]:ri[j+1]-1]], meancorrflux, sigmacorrflux
;              meancorrflux = mean(corrflux[ri[ri[j]:ri[j+1]-1]],/nan)
;              bin_corrflux[c] = meancorrflux
;           print, 'finished corrfluxx'
;           endif

           meanclip, timearr[ri[ri[j]:ri[j+1]-1]], meantimearr, sigmatimearr
           bin_timearr[c]=meantimearr
;           print, 'finished time'
           
           meanclip, bmjdarr[ri[ri[j]:ri[j+1]-1]], meanbmjdarr, sigmabmjdarr
           bin_phase[c]= meanbmjdarr
;           print, 'finished first bmjd'

           meanclip, centerpixarr[ri[ri[j]:ri[j+1]-1]], meancenterpix, sigmacenterpix
           bin_centerpix[c]= meancenterpix
;           print, 'finished first bmjd'


;            meanclip, phasearr[ri[ri[j]:ri[j+1]-1]], meanphase, sigmaphasearr
;            bin_phase[c]= meanphase

           ;xxxx this could change
           ;right now it is just the scatter in the bins
;           meanclip, corrfluxerr[ri[ri[j]:ri[j+1]-1]], meancorrfluxerr, sigmacorrfluxerr
;           bin_corrfluxerr[c] = sigmacorrfluxerr

           idataerr = fluxerr[ri[ri[j]:ri[j+1]-1]]
           bin_fluxerr[c] =   sqrt(total(idataerr^2))/ (n_elements(idataerr))
;           meanclip, fluxerr[ri[ri[j]:ri[j+1]-1]], meanfluxerr, sigmafluxerr
;           bin_fluxerr[c] = sigmafluxerr

;           meanclip, bkgderrarr[ri[ri[j]:ri[j+1]-1]], meanbkgderrarr, sigmabkgderrarr
 ;          bin_bkgderr[c] = meanbkgderrarr
;           print, 'finished last meanclips'
           c = c + 1
        ;print, 'testing', j, phasearr[ri[ri[j]:ri[j+1]-1]]
        endif
     endfor
     
     bin_xcen = bin_xcen[0:c-1]
     bin_ycen = bin_ycen[0:c-1]
     bin_bkgd = bin_bkgd[0:c-1]
     bin_flux = bin_flux[0:c-1]
     bin_fluxerr = bin_fluxerr[0:c-1]
;     bin_corrflux = bin_corrflux[0:c-1]
     bin_timearr = bin_timearr[0:c-1]
;     bin_bmjdarr = bin_bmjdarr[0:c-1]
;     bin_corrfluxerr = bin_corrfluxerr[0:c-1]
     bin_phase = bin_phase[0:c-1]
     bin_ncorr = bin_ncorr[0:c-1]
     bin_centerpix = bin_centerpix[0:c-1]
;     print, 'bin_phase', bin_phase
;  bin_bkgderr = bin_bkgderr[0:c-1]
     
     ;---------------------------------------------
     ;do it again for the sweet spot points.
     ;xxx should clean this up and make it a function
    cp = 0
     for j = 0L, n_elements(hp) - 1 do begin

;get rid of the bins with no values and low numbers, meaning low overlap
        if (rip[j+1] gt rip[j] + 2)  then begin ;require 3 elements in the bin
;           print, 'binning together', n_elements(numberarr[rip[rip[j]:rip[j+1]-1]])
        ;print, 'binning', numberarr[rip[rip[j]:rip[j+1]-1]]
        
           meanclip, xarrp[rip[rip[j]:rip[j+1]-1]], meanx, sigmax
           bin_xcenp[cp] = meanx   ; mean(fluxarr[rip[rip[j]:rip[j+1]-1]])

           meanclip, yarrp[rip[rip[j]:rip[j+1]-1]], meany, sigmay
           bin_ycenp[cp] = meany   ; mean(fluxarr[rip[rip[j]:rip[j+1]-1]])

           meanclip, centerpixarrp[ri[ri[j]:ri[j+1]-1]], meancenterpix, sigmacenterpix
           bin_centerpixp[cp]= meancenterpix

           meanclip, bkgdarrp[rip[rip[j]:rip[j+1]-1]], meansky, sigmasky
           bin_bkgdp[cp] = meansky ; mean(fluxarr[rip[rip[j]:rip[j+1]-1]])

           meanclip, fluxp[rip[rip[j]:rip[j+1]-1]], meanflux, sigmaflux
           bin_fluxp[cp] = meanflux ; mean(fluxarr[rip[rip[j]:rip[j+1]-1]])

           junk = where(finite(corrfluxp[rip[rip[j]:rip[j+1]-1]]) gt 0,ngood)
           bin_ncorrp[cp] = ngood
           ;can only compute means if there are values in there
           if pmapcorr eq 1 then begin
              meanclip, corrfluxp[rip[rip[j]:rip[j+1]-1]], meancorrflux, sigmacorrflux
;              meancorrflux = mean(corrflux[rip[rip[j]:rip[j+1]-1]],/nan)
              bin_corrfluxp[cp] = meancorrflux
           endif

           meanclip, timearrp[rip[rip[j]:rip[j+1]-1]], meantimearr, sigmatimearr
           bin_timearrp[cp]=meantimearr
           
           meanclip, bmjdarrp[rip[rip[j]:rip[j+1]-1]], meanbmjdarr, sigmabmjdarr
           bin_phasep[cp]= meanbmjdarr

;            meanclip, phasearr[rip[rip[j]:rip[j+1]-1]], meanphase, sigmaphasearr
;            bin_phase[cp]= meanphase

           ;xxxx this could change
           ;ripght now it is just the scatter in the bins
           icorrdataerr = corrfluxerrp[rip[rip[j]:rip[j+1]-1]]
           bin_corrfluxerrp[cp] =   sqrt(total(icorrdataerr^2))/ (n_elements(icorrdataerr))
           idataerr = fluxerrp[rip[rip[j]:rip[j+1]-1]]
           bin_fluxerrp[cp] =   sqrt(total(idataerr^2))/ (n_elements(idataerr))

;           meanclip, corrfluxerrp[rip[rip[j]:rip[j+1]-1]], meancorrfluxerr, sigmacorrfluxerr
;           bin_corrfluxerrp[cp] = sigmacorrfluxerr
;           meanclip, fluxerrp[rip[rip[j]:rip[j+1]-1]], meanfluxerr, sigmafluxerr
;           bin_fluxerrp[cp] = sigmafluxerr

;           meanclip, bkgderrarr[rip[rip[j]:rip[j+1]-1]], meanbkgderrarr, sigmabkgderrarr
 ;          bin_bkgderr[cp] = meanbkgderrarr

           cp = cp + 1
        ;print, 'testing', j, phasearr[ri[ri[j]:ri[j+1]-1]]
        endif
     endfor
     
     bin_xcenp = bin_xcenp[0:cp-1]
     bin_ycenp = bin_ycenp[0:cp-1]
     bin_bkgdp = bin_bkgdp[0:cp-1]
     bin_fluxp = bin_fluxp[0:cp-1]
     bin_fluxerrp = bin_fluxerrp[0:cp-1]
     bin_corrfluxp = bin_corrfluxp[0:cp-1]
     bin_timearrp = bin_timearrp[0:cp-1]
;     bin_bmjdarrp = bin_bmjdarr[0:cp-1]
     bin_corrfluxerrp = bin_corrfluxerrp[0:cp-1]
     bin_phasep = bin_phasep[0:cp-1]
     bin_ncorrp = bin_ncorrp[0:cp-1]
     bin_centerpixp = bin_centerpixp[0:cp-1]
;  bin_bkgderrp = bin_bkgderrp[0:cp-1]
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
     
;now try plotting
 
     if keyword_set(phaseplot) then begin   ;make the plot as a function of phase

        if a eq 0 then begin    ; for the first AOR
           pp = plot(bin_phase, bin_flux/median(bin_flux), '1s', sym_size = 0.1,   sym_filled = 1, xtitle = 'Orbital Phase', ytitle = 'Normalized Flux', title = planetname, color = colorarr[a], yrange = [0.975,1.005]) 
           pp = plot(bin_phasep, bin_corrfluxp/median(bin_corrfluxp)-0.015,/overplot, '1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a]);xtitle = 'Orbital Phase', ytitle = 'Normalized Flux', title = planetname
        endif 
        if a le 4 then begin ;really for the staring mode of wasp14
           pp = plot(bin_phase, bin_flux/median(bin_flux), '1s', sym_size = 0.1,   sym_filled = 1,color = colorarr[a],/overplot) 
           pp = plot(bin_phasep, bin_corrfluxp/median(bin_corrfluxp) -0.015, '1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a],/overplot);-0.015
        endif

        if a gt 4 then begin    ; for the subsequent AORs, use /overplot
           pp = plot(bin_phase, bin_flux/median(bin_flux), '6r1s', sym_size = 0.5, color = colorarr[a],  sym_filled = 1,/overplot) 
           if pmapcorr eq 1 then pp = plot(bin_phase, bin_corrfluxp/.06075 -0.015, '1s', sym_size = 0.5,   sym_filled = 1, color = colorarr[a],/overplot);-0.015
           print, 'median', median(bin_corrfluxp)
        endif

     endif else begin  ;make the plot as a function of time

        if a eq 0 then begin    ;for the first AOR
          ; pl = plot((bin_timearr - bin_timearr(0))/60./60., bin_flux/median(bin_flux), '6r1s', sym_size = 0.2,   sym_filled = 1,   xtitle = 'Time (hrs)', ytitle = 'Normalized Flux', title = planetname) 
          ; pl = plot((bin_timearr - bin_timearr(0))/60./60., bin_corrflux/median(bin_corrflux)-0.004, '1s', sym_size = 0.2,   sym_filled = 1, color = 'black',/overplot)

            pl = errorplot((bin_timearr - bin_timearr(0))/60./60., bin_flux/median(bin_flux), bin_fluxerr/median(bin_flux), '6r1s', errorbar_color = 'red',sym_size = 0.2,   sym_filled = 1,   xtitle = 'Time (hrs)', ytitle = 'Normalized Flux', title = planetname) 
            pl = errorplot((bin_timearrp - bin_timearrp(0))/60./60., bin_corrfluxp/median(bin_corrfluxp)-0.004,bin_corrfluxerrp/ median(bin_corrfluxp),'1s', sym_size = 0.2,   sym_filled = 1, color = 'black',/overplot)
        endif else begin        ;for the subsequent AORs, use /overplot
           pl = plot((bin_timearr - bin_timearr(0))/60./60., bin_flux/median(bin_flux), '6r1s', sym_size = 0.2,   sym_filled = 1,  /overplot) 
           pl = plot((bin_timearr - bin_timearr(0))/60./60., bin_corrflux/median(bin_corrflux)-0.005, '1s', sym_size = 0.2,   sym_filled = 1, color = 'black',/overplot)
           
        endelse

        if keyword_set(selfcal) then begin
           restore, strcompress(dirname + 'selfcal.sav')
           ps = errorplot(x, y-0.01,yerr,'1bo',sym_size = 0.2, sym_filled = 1, errorbar_color = 'blue',color = 'blue',/overplot)
        endif

     endelse

     if keyword_set(centerpixplot) then begin
        if a eq 0 then begin
           cplot = plot((bin_timearr - bin_timearr(0))/60./60., bin_centerpix, '6rs1', sym_size = 0.2, sym_filled = 1, xtitle =  'Time (hrs)', ytitle = 'mean Pixel value', title = planetname) 
        endif else begin
           cplot = plot((bin_timearr - bin_timearr(0))/60./60., bin_centerpix, '6rs1', sym_size = 0.2, sym_filled = 1,/overplot) 
        endelse

     endif


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


  endfor                        ;binning for each AOR

  if keyword_set(phaseplot) then  pp.save, dirname +'binflux_phase.png' else pl.save, dirname +'binflux_time.png'

;make a backgrounds plot as a function of time
;  if a eq 0 then  begin
;     tb = plot((bin_timearr - bin_timearr(0))/60./60., bin_bkgd , '6b1s', sym_size = 0.2,   sym_filled = 1,   xtitle = 'Time (hrs)', ytitle = 'Bkgd', title = planetname) 
;  endif else begin
;     tb = plot((bin_timearr - bin_timearr(0))/60./60., (bin_bkgd/ median(bin_bkgd) ), 'b1',  /overplot) 
;     tb = plot((bin_timearr - bin_timearr(0))/60./60., bin_ycen / median(bin_ycen) + .02 , 'b1s', sym_size = 0.2,  /overplot) 
;     tb = plot((bin_timearr - bin_timearr(0))/60./60., bin_xcen / median(bin_xcen) + .03 , 'b1s', sym_size = 0.2,  /overplot) 
  
;     tb.xrange = [0, 2]
;  endelse
   

end


