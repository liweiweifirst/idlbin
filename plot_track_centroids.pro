pro plot_track_centroids, run_data = run_data, periodogram = periodogram

  savenames = [ '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/track_centroids_pixval_2.sav','/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/track_centroids_pixval_3.sav','/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/track_centroids_pixval_4.sav','/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/track_centroids_pixval_5.sav','/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/track_centroids_pixval_6.sav'] ;'/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/track_centroids_pixval.sav',


  
  if keyword_set(run_data) then begin
     starts = 0
     stops = n_elements(savenames) - 1
     totalaorcount = 0
     peraor = 0
     for s = starts, stops do begin

        restore, savenames(s)
        aorlist = planethash.keys()

        if s eq starts then begin
           sigmax = fltarr(2* (stops + 1 - starts) *n_elements(aorlist))*alog10(-1) ; two is the fudge factor to make sure arrays are large enough
           print, n_elements(sigmax)
           sigmay = sigmax
           xjd = sigmax
           xdrift = sigmax      ; *alog10(-1)
           ydrift = sigmax      ;*alog10(-1)
           dpa = sigmax
           pa = sigmax
           exptimearr = sigmax
           short_drift = sigmax
           slope_drift = sigmax
           startyear = sigmax
           pkperiod = sigmax; list(length=2) ;n_elements(aorlist))
           pkstrength =  sigmax; list(length=2) 
           pktime = sigmax     ; list(length=2)
           npmean = sigmax
           npunc = sigmax
        endif
        
        for n = 0,  n_elements(aorlist) - 1 do begin
           print, '--------------'
           print, 'working on ',n, ' ',aorlist(n), n_elements(planethash[aorlist(n)].xcen)
           timearr = planethash[aorlist(n)].timearr
           bmjdarr = planethash[aorlist(n)].bmjdarr
           short_drift[n] =  planethash[aorlist(n)].short_drift
           npmean[n] = mean(planethash[aorlist(n)].npcentroids,/nan)
           npunc[n] = stddev(planethash[aorlist(n)].npcentroids,/nan)
           ;;slope_drift[n] =  planethash[aorlist(n)].slope_drift
           if planethash[aorlist(n)].haskey('slope_drift') gt 0 then slope_drift[n] =  planethash[aorlist(n)].slope_drift else slope_drift[n] = alog10(-1)
           print, 'slope drift', slope_drift[n]
           xjd[n] = bmjdarr(0) + 2400000.5
           CALDAT, xjd[n], Month, Day, year
           startyear[n] = year
           
           time0 = timearr(0)
           timearr = (timearr - time0)/60./60. ; now in hours instead of sclk
           exptimearr[n] = planethash[aorlist(n)].exptime
           
           ;;-------------------------------------
           ;;sigmax & sigmay &sigmaxy vs. time
           ;;not sure what sigmaxy is?
           if max(timearr) gt 1.2 then begin
              sigmax[n] = stddev(planethash[aorlist(n)].xcen,/nan)
              sigmay[n] = stddev(planethash[aorlist(n)].ycen,/nan)
              print, 'sigma x, y ', sigmax[n], sigmay[n]
              
              ;;-------------------------------------
              ;;long term xdrift vs.& y drift
              start = [.05,15.0]
              ;;don't have errors in position, instead, fake it.
              noise = fltarr(n_elements(planethash[aorlist(n)].xcen))
              noise = noise + 1.
              xcenfit= MPFITFUN('linear',timearr, planethash[aorlist(n)].xcen, noise, start,/Quiet)
              xdrift[n] = xcenfit(0)
              ycenfit= MPFITFUN('linear',timearr, planethash[aorlist(n)].ycen, noise, start,/Quiet)
              ydrift[n] = ycenfit(0)
              ;;do some quick paring down of the data
              xnum = findgen(n_elements(timearr))
              i = where(xnum mod 10 lt 1) ;pick out the odd numbers only
              tx = timearr(i)
              ycen = planethash[aorlist(n)].ycen
              ty = ycen(i)
              ;;pl = plot(timearr, ycen, title = aorlist(n), xtitle = 'time(hrs)', yrange = [mean(planethash[aorlist(n)].ycen,/nan) -0.5, mean(planethash[aorlist(n)].ycen,/nan) +0.5])
              ;;pl = plot(timearr, ycenfit(0)*timearr + ycenfit(1), color = 'red', overplot = pl)
              ;;XX don't want to keep this value if dithered.
           endif
           
           ;;-------------------------------------
           ;;short term drift
           ;;want duration and slope.
           
           
           
           ;;-------------------------------------
           ;;delta pitch angle
           prepitchangle = planethash[aorlist(n)].prepitchangle
           dpa[n] = prepitchangle(n_elements(prepitchangle) - 2) - planethash[aorlist(n)].pitchangle
           pa[n] = planethash[aorlist(n)].pitchangle
           
           ;;-------------------------------------
           ;;width of the peak in the power spectrim at 30min
           ;;don't need to do this for pre-AORs
           ;;periodogram
           
           if max(timearr) gt 1.2 and keyword_set(periodogram) then begin
              xday = timearr*60. ;in minutes             
              ycen = planethash[aorlist(n)].ycen
              bad = where(finite(ycen) lt 1,nbad)
              print, 'number of nans ', nbad
              if nbad eq n_elements(ycen) then CONTINUE ; no good data points
              if nbad gt 0  then remove, bad, xday, ycen
              result = LNP_TEST(xday, ycen,/double, WK1 = wk1, WK2 = wk2, JMAX = jmax)
              ;;b = plot(1/wk1, wk2, xtitle = 'Frequency(minutes)', ytitle = 'Power', xrange =[0,100],$
              ;;         thick = 2, color = 'red',name = 'Y centroids', title = 'Y centroids', yrange = [0, max(wk2[10:100])])
              ;;b2 = plot(xday, ycen, '1s', sym_size = 0.5, /sym_filled, xtitle = 'time in minutes', ytitle = 'ycen')
              ;;print, 'LNP result', result

              ;;find the peaks above N* the random level
              ;;but N appears to be a function of the number of data points.
              d0 = wk2 - shift(wk2, 1)
              d1 = wk2 - shift(wk2, -1)
              pk = where(d0 gt 0 and d1 gt 0, npk)
              peakheight = wk2[pk]
              peakfreq = wk1[pk]
              peakperiod = 1/peakfreq

               
              ;;define significance relative to other peaks between 5
              ;;-  60 minutes
              minpkper = 20.
              maxpkper = 80.
              nsig = 8.
                            
              short = where(peakperiod gt minpkper and peakperiod lt maxpkper)
              peakheight = peakheight(short)
              peakfreq = peakfreq(short)
              peakperiod = peakperiod(short)
              mn = robust_mean(peakheight, 4)
              sig = robust_sigma(peakheight)
              realpk = where(peakheight gt mn + nsig*sig and peakperiod gt minpkper and peakperiod le maxpkper, nrealpk)
              realpk = where(peakheight gt (max(peakheight) - 1.))
              print, 'nrealpk', nrealpk, peakperiod(realpk)
              print, 'mean sigma peak', mn, sig, stddev(peakheight), nsig*sig, max(peakheight)


              ;;make this easy for now and take the biggest peak
              maxheight = max(peakheight,ppi)
              pkperiod(peraor) = peakperiod(ppi)
              pkstrength(peraor) = (maxheight - mn )/ sig
              pktime(peraor) = xjd(n)
              peraor++
              ;;concatenating arrays- messy, but not sure how else to do it
              ;;if n eq 0 then begin
              ;;   if nrealpk gt 0 then begin
              ;;      pkperiod = peakperiod(realpk)
              ;;      pkstrength =(peakheight(realpk) -mn) /sig ;in units of some sort of significance
              ;;      pt = fltarr(nrealpk)
              ;;      pt(*) = xjd(n)
              ;;      pktime = pt
              ;;   endif else begin
             ;;       pkperiod = 0
             ;;       pkstrength = 0
             ;;       pktime = xjd(n)
             ;;    endelse
             ;; endif else begin
             ;;    if nrealpk gt 0 then begin
             ;;       pkperiod = [pkperiod, peakperiod(realpk)]
             ;;       pkstrength =[pkstrength, (peakheight(realpk) -mn) /sig ] ;in units of some sort of significance
             ;;       pt = fltarr(nrealpk)
             ;;       pt(*) = xjd(n)
             ;;       pktime = [pktime, pt]
             ;;    endif else begin
             ;;       ;;print, 'pkperiod', pkperiod
             ;;       pkperiod =[pkperiod, 0]
             ;;       pkstrength = [pkstrength,0]
             ;;       pktime = [pktime, xjd(n)]
             ;;    endelse
             ;;    
             ;; endelse
              
           endif
           totalaorcount++  ;;keep track of the total number of aors processed
        endfor
     endfor   ; for each save file restored
     
        save, /variables, filename = '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/plot_track_centroids.sav'
     endif else begin ;;keyword_set run_data
        print, 'restoring data'
        restore, '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/plot_track_centroids.sav'
     
     endelse
     print, 'totalaorcount', totalaorcount
     
  xjd = xjd[0:totalaorcount - 1]
  sigmax = sigmax[0:totalaorcount - 1]
  sigmay = sigmay[0:totalaorcount - 1]
  xdrift = xdrift[0:totalaorcount - 1]
  ydrift = ydrift[0:totalaorcount - 1]
  dpa = dpa[0:totalaorcount - 1]
  pa = pa[0:totalaorcount - 1]
  exptimearr = exptimearr[0:totalaorcount - 1]
  short_drift = short_drift[0:totalaorcount - 1]
  slope_drift = slope_drift[0:totalaorcount - 1]
  startyear = startyear[0:totalaorcount - 1]
  ;;nparr = nparr[0:totalaorcount - 1]
  
  pkperiod = pkperiod[0:peraor - 1]
  pkstrength = pkstrength[0:peraor-1]
  pktime = pktime[0:peraor-1]
  
  ;;set up color coding by exposure time
  colorarr = intarr(3, n_elements(exptimearr))
  zerop02 = where(exptimearr lt 0.05 and exptimearr gt 0., n0p02)
  zerop1 = where(exptimearr lt 0.2 and exptimearr gt 0.05,n0p1)
  zerop4 = where(exptimearr lt 0.4 and exptimearr gt 0.3,n0p4)
  twop0 = where(exptimearr gt 1.0 and exptimearr lt 2.0, n2p0)
  sixp0 = where(exptimearr gt 4.0 and exptimearr lt 7.0, n6p0)
  twelve = where(exptimearr gt 9.0 and exptimearr lt 15,n12)
  thirty = where(exptimearr gt 20 and exptimearr lt 90,n30)
  hundred = where(exptimearr gt 50 and exptimearr lt 200, n100)
  for c = 0, n0p02 - 1 do colorarr[*,zerop02(c)] = [128,0,0];'maroon'
  for c = 0, n0p1 - 1 do colorarr[*,zerop1(c)] = [255,0,0];'red'
  for c = 0, n0p4 - 1 do colorarr[*,zerop4(c)] = [255,69,0];'orange_red'
  for c = 0, n2p0 - 1 do colorarr[*,twop0(c)] = [238,118,33];'dark_orange'
  for c = 0, n6p0 - 1 do colorarr[*,sixp0(c)] = [127,255,0];'lime_green'
  for c = 0, n12 - 1 do colorarr[*,twelve(c)] =[64,224,208]; 'aqua'
  for c = 0, n30 - 1 do colorarr[*,thirty(c)] = [0,0,255];'blue'
  for c = 0, n100 - 1 do colorarr[*,hundred(c)] = [155,48,255];'Purple'

  print, 'set up colorarr'
  ;;set up color coding by year of observation
  ;;coloryear = intarr(3, n_elements(exptimearr))
  coloryear = strarr( n_elements(exptimearr))
  twenty10 = where(startyear eq 2010, n2010)
  twenty11 = where(startyear eq 2011, n2011)
  twenty12 = where(startyear eq 2012, n2012)
  twenty13 = where(startyear eq 2013, n2013)
  twenty14 = where(startyear eq 2014, n2014)
  twenty15 = where(startyear eq 2015, n2015)
  twenty16 = where(startyear eq 2016, n2016)
  twenty17 = where(startyear eq 2017, n2017)
  twenty18 = where(startyear eq 2018, n2018)

  
   print, 'set up coloryear',n_elements(twenty10), n_elements(twenty11), n_elements(twenty12), n_elements(twenty13), n_elements(twenty14), n_elements(twenty15), n_elements(twenty16)
  ;;------------------------------------------------
  ;;sigmax & sigmay &sigmaxy vs. time
  ;;------------------------------------------------

  psx = plot(xjd(zerop02), sigmax(zerop02),'1s', sym_size = 0.5,   /sym_filled , ytitle = 'X Size of cloud (stddev in position)', $
             XTICKFORMAT='(C(CMoA,1x,CYI))', xtickunits = ['Time'], xminor =11, yrange = [0, 0.2],$
             color = 'maroon')
  psx = plot(xjd(zerop1), sigmax(zerop1),'1s', sym_size = 0.5,   /sym_filled , overplot = psx, color = 'red')
  psx = plot(xjd(zerop4), sigmax(zerop4),'1s', sym_size = 0.5,   /sym_filled , overplot = psx, color = 'orange_red')
  psx = plot(xjd(twop0), sigmax(twop0),'1s', sym_size = 0.5,   /sym_filled , overplot = psx, color = 'dark_orange')
  psx = plot(xjd(sixp0), sigmax(sixp0),'1s', sym_size = 0.5,   /sym_filled , overplot = psx, color = 'lime_green')
  psx = plot(xjd(twelve), sigmax(twelve),'1s', sym_size = 0.5,   /sym_filled , overplot = psx, color = 'aqua')
  psx = plot(xjd(thirty), sigmax(thirty),'1s', sym_size = 0.5,   /sym_filled , overplot = psx, color = 'blue')
  if n100 gt 0 then psx = plot(xjd(hundred), sigmax(hundred),'1s', sym_size = 0.5,   /sym_filled , overplot = psx, color = 'purple')

  t1 =text(xjd(0),0.19, '0.02s', color = 'maroon',/data)
  t1 =text(xjd(0),0.18, '0.1s',  color= 'red',/data)    ;'red'
  t1 =text(xjd(0),0.17, '0.4s',  color= 'orange_red' ,/data)  ;'orange_red'
  t1 =text(xjd(0),0.16, '2.0s',  color= 'dark_orange',/data) ;'dark_orange'
  t1 =text(xjd(0),0.15, '6.0s',  color= 'lime_green',/data)  ;'lime_green'
  t1 =text(xjd(0),0.14, '12s',  color='aqua' ,/data) ; 'aqua'
  t1 =text(xjd(0),0.13, '30s',  color= 'blue' ,/data)   ;'blue'
  ;;t1 =text(xjd(0),0.12, '100s',  color= 'pruple',/data) ;'Purple'

  ;----------
  psy = plot(xjd(zerop02), sigmay(zerop02),'1s', sym_size = 0.5,   /sym_filled , ytitle = 'Y Size of cloud (stddev in position)', $
             XTICKFORMAT='(C(CMoA,1x,CYI))', xtickunits = ['Time'], xminor =11, yrange = [0, 0.2],$
             color = 'maroon')
  psy = plot(xjd(zerop1), sigmay(zerop1),'1s', sym_size = 0.5,   /sym_filled , overplot = psy, color = 'red')
  psy = plot(xjd(zerop4), sigmay(zerop4),'1s', sym_size = 0.5,   /sym_filled , overplot = psy, color = 'orange_red')
  psy = plot(xjd(twop0), sigmay(twop0),'1s', sym_size = 0.5,   /sym_filled , overplot = psy, color = 'dark_orange')
  psy = plot(xjd(sixp0), sigmay(sixp0),'1s', sym_size = 0.5,   /sym_filled , overplot = psy, color = 'lime_green')
  psy = plot(xjd(twelve), sigmay(twelve),'1s', sym_size = 0.5,   /sym_filled , overplot = psy, color = 'aqua')
  psy = plot(xjd(thirty), sigmay(thirty),'1s', sym_size = 0.5,   /sym_filled , overplot = psy, color = 'blue')
  if n100 gt 0 then psy = plot(xjd(hundred), sigmay(hundred),'1s', sym_size = 0.5,   /sym_filled , overplot = psy, color = 'purple')

    t1 =text(xjd(0),0.19, '0.02s', color = 'maroon',/data)
  t1 =text(xjd(0),0.18, '0.1s',  color= 'red',/data)    ;'red'
  t1 =text(xjd(0),0.17, '0.4s',  color= 'orange_red' ,/data)  ;'orange_red'
  t1 =text(xjd(0),0.16, '2.0s',  color= 'dark_orange',/data) ;'dark_orange'
  t1 =text(xjd(0),0.15, '6.0s',  color= 'lime_green',/data)  ;'lime_green'
  t1 =text(xjd(0),0.14, '12s',  color='aqua' ,/data) ; 'aqua'
  t1 =text(xjd(0),0.13, '30s',  color= 'blue' ,/data)   ;'blue'
  ;;t1 =text(xjd(0),0.12, '100s',  color= 'pruple',/data) ;'Purple'

  ;-------
  psxy = plot(sigmax(zerop02), sigmay(zerop02),'1s', sym_size = 0.5,   /sym_filled , ytitle = 'Y Size of cloud (stddev in position)', $
              xtitle = 'X Size of cloud (stddev in position)', yrange = [0,0.2], xrange = [0,0.2], color = 'maroon')
  psxy = plot(sigmax(zerop1), sigmay(zerop1),'1s', sym_size = 0.5,   /sym_filled , overplot = psxy, color = 'red')
  psxy = plot(sigmax(zerop4), sigmay(zerop4),'1s', sym_size = 0.5,   /sym_filled , overplot = psxy, color = 'orange_red')
  psxy = plot(sigmax(twop0), sigmay(twop0),'1s', sym_size = 0.5,   /sym_filled , overplot = psxy, color = 'dark_orange')
  psxy = plot(sigmax(sixp0), sigmay(sixp0),'1s', sym_size = 0.5,   /sym_filled , overplot = psxy, color = 'lime_green')
  psxy = plot(sigmax(twelve), sigmay(twelve),'1s', sym_size = 0.5,   /sym_filled , overplot = psxy, color = 'aqua')
  psxy = plot(sigmax(thirty), sigmay(thirty),'1s', sym_size = 0.5,   /sym_filled , overplot = psxy, color = 'blue')
  if n100 gt 0 then psxy = plot(sigmax(hundred), sigmay(hundred),'1s', sym_size = 0.5,   /sym_filled , overplot = psxy, color = 'purple')

  
  pl1 = polyline( [0.0, 0.2], [0.0,0.2], /data, target = psxy, color = 'black')
  
  t1 =text(0.18,0.15, '0.02s', color = 'maroon',/data)
  t1 =text(0.18,0.14, '0.1s',  color= 'red',/data)         ;'red'
  t1 =text(0.18,0.13, '0.4s',  color= 'orange_red' ,/data) ;'orange_red'
  t1 =text(0.18,0.12, '2.0s',  color= 'dark_orange',/data) ;'dark_orange'
  t1 =text(0.18,0.11, '6.0s',  color= 'lime_green',/data)  ;'lime_green'
  t1 =text(0.18,0.10, '12s',  color='aqua' ,/data) ; 'aqua'
  t1 =text(0.18,0.09, '30s',  color= 'blue' ,/data)   ;'blue'
  ;;t1 =text(0.18,0.12, '100s',  color= 'pruple',/data) ;'Purple'


   ;;------------------------------------------------
  ;;noise pixel 
  ;;------------------------------------------------
;;;;vs. time
  ;;pn = plot(xjd(zerop02), nparr(zerop02),'1s', sym_size = 0.5,   /sym_filled , ytitle = 'Mean Noise Pixel', $
  ;;           XTICKFORMAT='(C(CMoA,1x,CYI))', xtickunits = ['Time'], xminor =11, yrange = [0, 0.2],$
  ;;           color = 'maroon')
  ;;pn = plot(xjd(zerop1), nparr(zerop1),'1s', sym_size = 0.5,   /sym_filled , overplot = pn, color = 'red')
  ;;pn = plot(xjd(zerop4), nparr(zerop4),'1s', sym_size = 0.5,   /sym_filled , overplot = pn, color = 'orange_red')
  ;;pn = plot(xjd(twop0), nparr(twop0),'1s', sym_size = 0.5,   /sym_filled , overplot = pn, color = 'dark_orange')
  ;;pn = plot(xjd(sixp0), nparr(sixp0),'1s', sym_size = 0.5,   /sym_filled , overplot = pn, color = 'lime_green')
  ;;pn = plot(xjd(twelve), nparr(twelve),'1s', sym_size = 0.5,   /sym_filled , overplot = pn, color = 'aqua')
  ;;pn = plot(xjd(thirty), nparr(thirty),'1s', sym_size = 0.5,   /sym_filled , overplot = pn, color = 'blue')
  ;;if n100 gt 0 then pn = plot(xjd(hundred), nparr(hundred),'1s', sym_size = 0.5,   /sym_filled , overplot = pn, color = 'purple')


  ;;;;vs exptime
  ;;pn2 = errorplot(exptimearr, npmean, npunc,'1s', /sym_filled, sym_size = 0.5, xtitle ='exposure time', ytitle = 'Mean Noise Pixel')
  
  ;;------------------------------------------------
  ;;Long term xdrift vs. ydrift
  ;;------------------------------------------------
  
  maxdrift = 0.05
  help, xdrift
  help, ydrift
  pxydrift = plot(xdrift, ydrift,  '1s', sym_size = 0.5,   sym_filled = 1,  ytitle = 'Long Term Y drift (px/hr)', $
                  xtitle = 'Long Term X drift (px/hr)', yrange = [-0.04, 0.04], xrange =[-0.04,0.04]);,$;[-1*maxdrift,maxdrift],$
                 ;; vert_colors = colorarr)
  print, 'done plot'
  pl1 = polyline([0.0,0.0], [-0.04, 0.04], /data, target = pxydrift, color = 'black')
  pl1 = polyline( [-0.04, 0.04], [0.0,0.0], /data, target = pxydrift, color = 'black')
  print, 'done long term xdrift vs. ydrift'
  ;;------------------------------------------------
  ;;Long term xdrift & y drift vs. time
  ;;------------------------------------------------

  ;;first get rid of outliers
  ;print, 'xdrift', xdrift
  meanclip,xdrift,  mean, meansig;3 Sigma clipping
  gx = where(xdrift gt (mean - 3*meansig) and xdrift lt (mean + 3*meansig), ngood)
  print, 'num good out of total',ngood, n_elements(xdrift)
  xjdgx = xjd(gx)
  xdriftgx = xdrift(gx)
  xdpa = dpa(gx)
  meanclip,ydrift,  mean, meansig ;3 Sigma clipping
  gy = where(ydrift gt (mean - 3*meansig) and ydrift lt (mean + 3*meansig), ngood)
  print, 'num, ngood',ngood, n_elements(ydrift)
  xjdgy = xjd(gy)
  ydriftgy = ydrift(gy)
  ydpa = dpa(gy)
  print, 'max xjdgx', max(xjdgx)
  pdrift = plot(xjdgx, xdriftgx, '1s', sym_size = 0.7,   sym_filled = 1,  ytitle = 'Long Term Drift (px/hr)', $
                yrange = [-0.04, 0.04],$;[-1*maxdrift, maxdrift+0.01],$
                color = 'blue', XTICKFORMAT='(C(CMoA,1x,CYI))', xtickunits = ['Time'], xminor =11, name='xdrift')
  pdrift2 = plot(xjdgy, ydriftgy, '1s', sym_size = 0.7,   sym_filled = 1,  overplot = pdrift, color = 'red', name = 'ydrift')

  ;;fit a linear function to these data.
  start = [.0005,0.00001]
        ;;don't have errors in drift, instead, fake it.
  xnoise = fltarr(n_elements(xdriftgx))
  xnoise = xnoise + 1.
  xdriftfit= MPFITFUN('linear',xjdgx, xdriftgx, xnoise, start);,/Quiet)
  pdrift3 = plot(xjdgx, xdriftfit(0)*xjdgx + xdriftfit(1), color = 'blue', overplot = pdrift)
  ynoise = fltarr(n_elements(ydriftgy))
  ynoise = ynoise + 1.
  ydriftfit= MPFITFUN('linear',xjdgy, ydriftgy, ynoise, start);,/Quiet)
  pdrift4 = plot(xjdgy, ydriftfit(0)*xjdgy + ydriftfit(1), color = 'red', overplot = pdrift)

  lpd = legend(target = [pdrift, pdrift2], /auto_text_color, position = [xjd[0], maxdrift-0.01],/data)
  
  ;;------------------------------------------------
  ;;delta pitch angle
  ;;------------------------------------------------

  pdpa = plot( xdpa, xdriftgx, '1s', sym_size = 0.5,   sym_filled = 1, xtitle = 'Change in pitch angle from previous observation', $
              ytitle = 'Long Term Drift (px/hr)', color = 'blue',yrange = [-1*maxdrift,maxdrift], name = 'xdrift')
  pdpa2 = plot(ydpa, ydriftgy,'1s', sym_size = 0.5,   sym_filled = 1, overplot = pdpa, color = 'red', name = 'ydrift')
  ldpa = legend(target = [pdpa, pdpa2], /auto_text_color, position = [dpa[20], maxdrift-0.01],/data)

 ;;fit a linear function to these data.
  start = [.0005,-0.01]
        ;;don't have errors in drift, instead, fake it.
  xnoise = fltarr(n_elements(xdpa))
  xnoise = xnoise + 1.
  xdriftfit= MPFITFUN('linear',xdpa, xdriftgx, xnoise, start);,/Quiet)
  pdrift3 = plot(xdpa, xdriftfit(0)*xdpa + xdriftfit(1), color = 'blue', overplot = pdpa)
  ynoise = fltarr(n_elements(ydpa))
  ynoise = ynoise + 1.
  ydriftfit= MPFITFUN('linear',ydpa, ydriftgy, ynoise, start);,/Quiet)
  pdrift4 = plot(ydpa, ydriftfit(0)*ydpa + ydriftfit(1), color = 'red', overplot = pdpa)



  
  ;;------------------------------------------------
  ;;periodogram fun
   ;;------------------------------------------------
  ;;how do I collapse a list into a single array?
  ;;pperiod = bubbleplot(pktime, pkperiod, /shaded, magnitude = pkstrength , exponent = 0.5, $
  ;;                     ytitle = 'Period of the power spectrum peaks (min)',XTICKFORMAT='(C(CMoA,1x,CYI))', $
  ;;                     xtickunits = ['Time'], xminor =11 , yrange =
  ;;                     [20,80])
  print, 'pkperiod', n_elements(pkperiod)
   pperiod = plot(pktime, pkperiod, '1s', /sym_filled, sym_size = 0.5, $
                       ytitle = 'Period of the power spectrum peaks (min)',XTICKFORMAT='(C(CMoA,1x,CYI))', $
                       xtickunits = ['Time'], xminor =11 , yrange = [20,80])
   

  ;;------------------------------------------------
  ;;short term drift plotting
  ;;------------------------------------------------
  ;;worry about zero vs. nan vs. negative.
  drift_dist = slope_drift * short_drift  ;;oops this is what Carl plots

  tencolor = 'brown'
  elevencolor = 'tan'
  twelvecolor = 'cyan'
  thirtcolor = 'blue'
  fourtcolor = 'slate blue'
  fiftcolor = 'dark violet'
  sixtcolor = 'medium violet red'

  timeshortdrift = plot(xjd(twenty10), short_drift(twenty10), '1D', sym_size = 1.0,   /sym_filled , ytitle = 'Duration (hours)', $
                        XTICKFORMAT='(C(CMoA,1x,CYI))', xtickunits = ['Time'], xminor =11,ytickinterval = 0.4,$
                        xshowtext =0, position = [0.2,0.65,0.9,0.9], title = 'Ycen Short Term Drift',color = tencolor )
  timeshortdrift = plot(xjd(twenty11), short_drift(twenty11), '1D', sym_size = 1.0,   /sym_filled , color = elevencolor, $
                        overplot = timeshortdrift )
  timeshortdrift = plot(xjd(twenty12), short_drift(twenty12), '1D', sym_size = 1.0,   /sym_filled , color = twelvecolor, $
                        overplot = timeshortdrift )
  timeshortdrift = plot(xjd(twenty13), short_drift(twenty13), '1D', sym_size = 1.0,   /sym_filled , color = thirtcolor, $
                        overplot = timeshortdrift )
  timeshortdrift = plot(xjd(twenty14), short_drift(twenty14), '1D', sym_size = 1.0,   /sym_filled , color = fourtcolor, $
                        overplot = timeshortdrift )
  timeshortdrift = plot(xjd(twenty15), short_drift(twenty15), '1D', sym_size = 1.0,   /sym_filled , color = fiftcolor, $
                        overplot = timeshortdrift )
  timeshortdrift = plot(xjd(twenty16), short_drift(twenty16), '1D', sym_size = 1.0,   /sym_filled , color = sixtcolor, $
                        overplot = timeshortdrift )
  
  timedriftdist = plot(xjd(twenty10), drift_dist(twenty10), '1D', sym_size = 1.0,   /sym_filled , ytitle = 'Length (pixels)', $
                       XTICKFORMAT='(C(CMoA,1x,CYI))', xtickunits = ['Time'], xminor =11,$
                       xshowtext=0,/current, position = [0.2, 0.38, 0.9, 0.63],ytickinterval = 0.3,color = tencolor)
  timedriftdist = plot(xjd(twenty11), drift_dist(twenty11), '1D', sym_size = 1.0,   /sym_filled ,overplot = timedriftdist, $
                       color = elevencolor)
  timedriftdist = plot(xjd(twenty12), drift_dist(twenty12), '1D', sym_size = 1.0,   /sym_filled ,overplot = timedriftdist, $
                       color = twelvecolor)
  timedriftdist = plot(xjd(twenty13), drift_dist(twenty13), '1D', sym_size = 1.0,   /sym_filled ,overplot = timedriftdist, $
                       color = thirtcolor)
  timedriftdist = plot(xjd(twenty14), drift_dist(twenty14), '1D', sym_size = 1.0,   /sym_filled ,overplot = timedriftdist, $
                       color = fourtcolor)
  timedriftdist = plot(xjd(twenty15), drift_dist(twenty15), '1D', sym_size = 1.0,   /sym_filled ,overplot = timedriftdist, $
                       color = fiftcolor)
  timedriftdist = plot(xjd(twenty16), drift_dist(twenty16), '1D', sym_size = 1.0,   /sym_filled ,overplot = timedriftdist, $
                       color = sixtcolor)
  
  timeslopedrift = plot(xjd(twenty10), slope_drift(twenty10), '1D', sym_size = 1.0,   /sym_filled , ytitle = 'Slope (pix/hr)', $
                        XTICKFORMAT='(C(CMoA,1x,CYI))', xtickunits = ['Time'], xminor =11,color = tencolor,$
                        /current, position = [0.2,0.11, 0.9,0.36])
  timeslopedrift = plot(xjd(twenty11), slope_drift(twenty11), '1D', sym_size = 1.0,   /sym_filled ,overplot = timeslopedrift, $
                        color = elevencolor)
  timeslopedrift = plot(xjd(twenty12), slope_drift(twenty12), '1D', sym_size = 1.0,   /sym_filled ,overplot = timeslopedrift, $
                        color = twelvecolor)
  timeslopedrift = plot(xjd(twenty13), slope_drift(twenty13), '1D', sym_size = 1.0,   /sym_filled ,overplot = timeslopedrift, $
                        color = thirtcolor)
  timeslopedrift = plot(xjd(twenty14), slope_drift(twenty14), '1D', sym_size = 1.0,   /sym_filled ,overplot = timeslopedrift, $
                        color = fourtcolor)
  timeslopedrift = plot(xjd(twenty15), slope_drift(twenty15), '1D', sym_size = 1.0,   /sym_filled ,overplot = timeslopedrift, $
                        color = fiftcolor)
  timeslopedrift = plot(xjd(twenty16), slope_drift(twenty16), '1D', sym_size = 1.0,   /sym_filled ,overplot = timeslopedrift, $
                        color = sixtcolor)
 
  ;;-------------
  timeshortdrift = plot(pa(twenty10), short_drift(twenty10), '1D', sym_size = 1.0,   /sym_filled , ytitle = 'Duration (hours)', $
                        xshowtext =0, position = [0.2,0.65,0.9,0.9], ytickinterval = 0.4,title = 'Ycen Short Term Drift', $
                        color = tencolor)
  timeshortdrift = plot(pa(twenty11), short_drift(twenty11), '1D', sym_size = 1.0,   /sym_filled, overplot = timeshortdrift, $
                        color = elevencolor )
  timeshortdrift = plot(pa(twenty12), short_drift(twenty12), '1D', sym_size = 1.0,   /sym_filled, overplot = timeshortdrift, $
                        color = twelvecolor )
 timeshortdrift = plot(pa(twenty13), short_drift(twenty13), '1D', sym_size = 1.0,   /sym_filled, overplot = timeshortdrift, $
                        color = thirtcolor )
 
  timedriftdist = plot(pa(twenty10), drift_dist(twenty10), '1D', sym_size = 1.0,   /sym_filled , ytitle = 'Length (pixels)', $
                       xshowtext=0,/current, position = [0.2, 0.38, 0.9, 0.63],ytickinterval = 0.3, color = tencolor)
  timedriftdist = plot(pa(twenty11), drift_dist(twenty11), '1D', sym_size = 1.0,   /sym_filled , overplot = timedriftdist, $
                       color = elevencolor)
   timedriftdist = plot(pa(twenty12), drift_dist(twenty12), '1D', sym_size = 1.0,   /sym_filled , overplot = timedriftdist, $
                       color = twelvecolor)
   timedriftdist = plot(pa(twenty13), drift_dist(twenty13), '1D', sym_size = 1.0,   /sym_filled , overplot = timedriftdist, $
                       color = thirtcolor)
 
  timeslopedrift = plot(pa(twenty10), slope_drift(twenty10), '1D', sym_size = 1.0,   /sym_filled , ytitle = 'Slope (pix/hr)', $
                        /current, position = [0.2,0.11, 0.9,0.36], xtitle = 'Pitch Angle', color = tencolor)
  timeslopedrift = plot(pa(twenty11), slope_drift(twenty11), '1D', sym_size = 1.0,   /sym_filled ,overplot = timeslopedrift, $
                        color = elevencolor)
  timeslopedrift = plot(pa(twenty12), slope_drift(twenty12), '1D', sym_size = 1.0,   /sym_filled ,overplot = timeslopedrift, $
                        color = twelvecolor)
  timeslopedrift = plot(pa(twenty13), slope_drift(twenty13), '1D', sym_size = 1.0,   /sym_filled ,overplot = timeslopedrift, $
                        color = thirtcolor)
 
  ;;--------------
  
  timeshortdrift = plot(dpa(twenty10), short_drift(twenty10), '1D', sym_size = 1.0,   /sym_filled , ytitle = 'Duration (hours)', $
                        xshowtext =0, position = [0.2,0.65,0.9,0.9], ytickinterval = 0.4, title = 'Ycen Short Term Drift', $
                        color = tencolor)
  timeshortdrift = plot(dpa(twenty11), short_drift(twenty11), '1D', sym_size = 1.0,   /sym_filled, overplot = timeshortdrift, $
                        color = elevencolor)
  timeshortdrift = plot(dpa(twenty12), short_drift(twenty12), '1D', sym_size = 1.0,   /sym_filled, overplot = timeshortdrift, $
                        color = twelvecolor)
  timeshortdrift = plot(dpa(twenty13), short_drift(twenty13), '1D', sym_size = 1.0,   /sym_filled, overplot = timeshortdrift, $
                        color = thirtcolor)
 
  timedriftdist = plot(dpa(twenty10), drift_dist(twenty10), '1D', sym_size = 1.0,   /sym_filled , ytitle = 'Length (pixels)', $
                       xshowtext=0,/current, position = [0.2, 0.38, 0.9, 0.63],ytickinterval = 0.3, color = tencolor)
  timedriftdist = plot(dpa(twenty11), drift_dist(twenty11), '1D', sym_size = 1.0,   /sym_filled , overplot = timedriftdist,$
                       color = elevencolor)
  timedriftdist = plot(dpa(twenty12), drift_dist(twenty12), '1D', sym_size = 1.0,   /sym_filled , overplot = timedriftdist,$
                       color = twelvecolor)
  timedriftdist = plot(dpa(twenty13), drift_dist(twenty13), '1D', sym_size = 1.0,   /sym_filled , overplot = timedriftdist,$
                       color = thirtcolor)
  
  timeslopedrift = plot(dpa(twenty10), slope_drift(twenty10), '1D', sym_size = 1.0,   /sym_filled , ytitle = 'Slope (pix/hr)', $
                        /current, position = [0.2,0.11, 0.9,0.36], xtitle = 'Delta Pitch Angle', color =tencolor)
  timeslopedrift = plot(dpa(twenty11), slope_drift(twenty11), '1D', sym_size = 1.0,   /sym_filled ,overplot = timeslopedrift, $
                        color = elevencolor)
  timeslopedrift = plot(dpa(twenty12), slope_drift(twenty12), '1D', sym_size = 1.0,   /sym_filled ,overplot = timeslopedrift, $
                        color = twelvecolor)
 timeslopedrift = plot(dpa(twenty13), slope_drift(twenty13), '1D', sym_size = 1.0,   /sym_filled ,overplot = timeslopedrift, $
                       color = thirtcolor)



;;make this for the SUP presentation
 supplot = plot(pa(twenty10), slope_drift(twenty10), '1D', sym_size = 1.0,   /sym_filled , ytitle = 'Short Term Drift Slope (pix/hr)', $
                       xtitle = 'Pitch Angle', color = tencolor)
  supplot = plot(pa(twenty11), slope_drift(twenty11), '1D', sym_size = 1.0,   /sym_filled ,overplot = supplot, $
                        color = elevencolor)
  supplot = plot(pa(twenty12), slope_drift(twenty12), '1D', sym_size = 1.0,   /sym_filled ,overplot = supplot, $
                        color = twelvecolor)
  supplot = plot(pa(twenty13), slope_drift(twenty13), '1D', sym_size = 1.0,   /sym_filled ,overplot = supplot, $
                        color = thirtcolor)

 ;;  
 ;;-------------
 ;;do some fitting of the short term drift
 slope = fltarr(4)              ; start with first four years
 slopeerr = slope
 start = [1./40.,-0.001]
 
 for s = 0, n_elements(slope) - 1 do begin
    case s of
       0: year = twenty10
       1: year = twenty11
       2: year = twenty12
       3: year = twenty13
       4: year = twenty14
       5: year = twenty15
       6: year = twenty16
       7: year = twenty17
       8: year = twenty18
       9: year = twenty19
    endcase
    
    xnoise = fltarr(n_elements(dpa(year)))
    xnoise = xnoise + 1.
    lfitresult= MPFITFUN('linear',dpa(year), slope_drift(year), xnoise, start, bestnorm = bestnorm, perror = perror, dof = dof,/nan) ;,/Quiet)    
    reduced_chi2 = SQRT(BESTNORM/DOF)
    param_err = perror*reduced_chi2
    slope(s) = lfitresult(0)
    slopeerr(s) = param_err(0)

 endfor
 ;;splot = errorplot(indgen(n_elements(slope)) + 2010, slope, slopeerr,'1s', /sym_filled, sym_size = 0.5, $
 ;;                  xtitle ='Year', ytitle = 'short term drift slope as a function of delta pitch', xminor = 0, $
 ;;                 xtickinterval = 1, xrange = [2009.5, 2016])



 ;;;;;;;;;;;;;;;;;;;;;;
 basedir = '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/'
 psx.Save, strcompress(basedir + "stddevx_time.png",/remove_all)
 psy.save, strcompress(basedir + "stddevy_time.png",/remove_all)
end

    ;;plothist, planethash[aorlist(n)].xcen, xhist, yhist, bin = 0.05,/noplot
     ;;pg = barplot(xhist, yhist, title = aorlist(n))
     ;;start = [0.,10., 2.]
     ;;noise = fltarr(n_elements(yhist))
     ;;noise[*] = 1                                              ;equally weight the values
     ;;result= MPFITFUN('mygauss',xhist,yhist, noise, start) ;/quiet   ; fit a gaussian to the histogram sorted data


       ;; xnum = findgen(n_elements(xday))
       ;; i = where(xnum mod 10 lt 1) ;pick out the odd numbers only
;;        xday = xday(i)
;;        ycen = ycen(i)
;;pl = plot(tx, ty, title = aorlist(n), xtitle = 'time(hrs)', yrange =
;;[mean(planethash[aorlist(n)].ycen,/nan) -0.5,
;;mean(planethash[aorlist(n)



       ;;b = plot(1/wk1, wk2, xtitle = 'Frequency(minutes)', ytitle = 'Power', xrange =[0,100],$
        ;;         thick = 2, color = 'red',name = 'Y centroids', title = 'Y centroids', yrange = [0, max(wk2[10:100])])
        ;;print, 'LNP result', result
        ;;test = where(1/wk1 gt 40 and 1/wk1 lt 50,ntest)
        ;;if ntest gt 0 then print, 'values around 45', wk2[test]
        ;;want to know if there is a real peak between 30 - 50 minutes
        ;;try monte carloing the noise periodogram
        ;;randomize the order of the photometry while keeping the time
        ;;information the same.
        ;;nwk2 = n_elements(wk2)  ;which is bin_flux cut down
        ;;ny2= n_elements(ycen)
        ;;make a randomly ordered array with nel elements
        ;;nmc = 3
        ;;final_max = fltarr(nmc)

        ;;for rcount = 0, nmc - 1 do begin
        ;;   rand = randomu(seed, ny2)
           ;;now use that as the pointer/orderer for the photometry
        ;;   randflux = ycen[sort(rand)]
        ;;   rr = LNP_TEST(xday, randflux, /double,  WK1 = rrwk1, WK2 = rrwk2, JMAX = jmax)
           ;;print, 'random result', rr
        ;;   final_max(rcount) = rr(0)
           ;;randp = plot(wk1, wk2,overplot=b, color = 'gray')
        ;;endfor
;;print, 'max finalmax', max(final_max)  ;; this is the same as
;;max(rr(0))
 ;realpk = where(peakheight gt
                                ;5.*max(final_max)  and peakperiod gt
                                ;30. and peakperiod le 50.,nrealpk)
 ;;plothist, peakheight, xhist, yhist, bin = 0.1, /noplot
        ;;pb = barplot(xhist, yhist, xtitle = 'peakheight', xrange = [0, 10])
        ;;print, 'mean ,sig', mn , sig
        ;;print, 'nrealpk', nrealpk
        ;;print, 'periods'
        ;;print,peakperiod(realpk)
        ;;print, 'strengths'
        ;;print,(peakheight(realpk) -mn) /sig
        ;;want to keep the period and strength of these peaks



 ;;for c = 0, n2010 - 1 do coloryear[*,twenty10(c)] = [128,0,0]   ;'maroon'
  ;;for c = 0, n2011 - 1 do coloryear[*,twenty11(c)] = [255,0,0];'red'
  ;;for c = 0, n2012 - 1 do coloryear[*,twenty12(c)] = [255,69,0];'orange_red'
  ;;for c = 0, n2013 - 1 do coloryear[*,twenty13(c)] = [238,118,33];'dark_orange'
  ;;for c = 0, n2014 - 1 do coloryear[*,twenty14(c)] = [127,255,0];'lime_green'
  ;;for c = 0, n2015 - 1 do coloryear[*,twenty15(c)] =[64,224,208]; 'aqua'
  ;;for c = 0, n2016 - 1 do coloryear[*,twenty16(c)] = [0,0,255];'blue'
  ;;for c = 0, n2017 - 1 do coloryear[*,twenty17(c)] = [155,48,255];'Purple'
  ;;for c = 0, n2018 - 1 do coloryear[*,twenty18(c)] = [51,0,102];'Purple'

 ;;t1 =text(0.02,0.034, '0.02s', color = [128,0,0],/data)
  ;;t1 =text(0.02,0.029, '0.1s',  color= [255,0,0],/data)    ;'red'
  ;;t1 =text(0.02,0.024, '0.4s',  color= [255,69,0] ,/data)  ;'orange_red'
  ;;t1 =text(0.02,0.019, '2.0s',  color= [238,118,33],/data) ;'dark_orange'
  ;;t1 =text(0.02,0.014, '6.0s',  color= [127,255,0],/data)  ;'lime_green'
  ;;t1 =text(0.02,0.009, '12s',  color=[64,224,208] ,/data) ; 'aqua'
  ;;t1 =text(0.02,0.004, '30s',  color= [0,0,255] ,/data)   ;'blue'
  ;;t1 =text(0.02,-0.001, '100s',  color= [155,48,255],/data) ;'Purple'
;;  print, 'done text'


 ;;print, 'n short drift', n_elements(short_drift), n_elements(xjd), n_elements(pa), n_elements(dpa)
  ;;ss = sort(xjd)
  ;;sshort_drift = short_drift(ss)
  ;;sxjd = xjd(ss)
  ;;caldat, sxjd, smonth, sday, syear
  ;;for s = 0, n_elements(sxjd) - 1 do print, syear(s),smonth(s), sday(s), sshort_drift(s)


 
  ;;timeshortdrift = plot(xjd, short_drift, '1D', sym_size = 1.0,   /sym_filled , ytitle = 'Duration (hours)', $
  ;;                      XTICKFORMAT='(C(CMoA,1x,CYI))', xtickunits = ['Time'], xminor =11,ytickinterval = 0.4,$
  ;;                      xshowtext =0, position = [0.2,0.65,0.9,0.9], title = 'Ycen Short Term Drift');,vertcolors = coloryear)
  ;;timedriftdist = plot(xjd, drift_dist, '1D', sym_size = 1.0,   /sym_filled , ytitle = 'Length (pixels)', $
  ;;                     XTICKFORMAT='(C(CMoA,1x,CYI))', xtickunits = ['Time'], xminor =11,$
  ;;                     xshowtext=0,/current, position = [0.2, 0.38, 0.9, 0.63],ytickinterval = 0.3);,vertcolors = coloryear)
  ;;timeslopedrift = plot(xjd, slope_drift, '1D', sym_size = 1.0,   /sym_filled , ytitle = 'Slope (pix/hr)', $
  ;;                      XTICKFORMAT='(C(CMoA,1x,CYI))', xtickunits = ['Time'], xminor =11,$
  ;;                      /current, position = [0.2,0.11, 0.9,0.36]);,vertcolors = coloryear)
  ;;
  ;;timeshortdrift = plot(pa, short_drift, '1D', sym_size = 1.0,   /sym_filled , ytitle = 'Duration (hours)', $
  ;;                      xshowtext =0, position = [0.2,0.65,0.9,0.9], ytickinterval = 0.4,title = 'Ycen Short Term Drift')
  ;;timedriftdist = plot(pa, drift_dist, '1D', sym_size = 1.0,   /sym_filled , ytitle = 'Length (pixels)', $
  ;;                     xshowtext=0,/current, position = [0.2, 0.38, 0.9, 0.63],ytickinterval = 0.3)
  ;;timeslopedrift = plot(pa, slope_drift, '1D', sym_size = 1.0,   /sym_filled , ytitle = 'Slope (pix/hr)', $
  ;;                      /current, position = [0.2,0.11, 0.9,0.36], xtitle = 'Pitch Angle')

  ;;timeshortdrift = plot(dpa, short_drift, '1D', sym_size = 1.0,   /sym_filled , ytitle = 'Duration (hours)', $
  ;;                      xshowtext =0, position = [0.2,0.65,0.9,0.9], ytickinterval = 0.4, title = 'Ycen Short Term Drift')
  ;;timedriftdist = plot(dpa, drift_dist, '1D', sym_size = 1.0,   /sym_filled , ytitle = 'Length (pixels)', $
  ;;                     xshowtext=0,/current, position = [0.2, 0.38, 0.9, 0.63],ytickinterval = 0.3)
  ;;timeslopedrift = plot(dpa, slope_drift, '1D', sym_size = 1.0,   /sym_filled , ytitle = 'Slope (pix/hr)', $
  ;;                      /current, position = [0.2,0.11, 0.9,0.36], xtitle = 'Delta Pitch Angle')

  
  ;;sdrift = plot(dpa, short_drift, '1s', sym_size = 0.5,   /sym_filled , ytitle = 'duration of ycen short term drift', $
  ;;              xtitle = 'Change in pitch angle from previous observation', vert_colors = colorarr)
  ;;sdrift = plot(pa, short_drift, '1s', sym_size = 0.5,   /sym_filled , ytitle = 'duration of ycen short term drift', $
  ;;              xtitle = 'Pitch angle', vert_colors = colorarr)
  ;;sdrift = plot(dpa, slope_drift, '1s', sym_size = 0.5,   /sym_filled , ytitle = 'slope of ycen short term drift', $
  ;;              xtitle = 'Change in pitch angle from previous observation', vert_colors = colorarr)
  ;;sdrift = plot(pa, slope_drift, '1s', sym_size = 0.5,   /sym_filled , ytitle = 'slope of ycen short term drift', $
  ;;              xtitle = 'Pitch angle', vert_colors = colorarr)

  ;;sdrift = plot(dpa, drift_dist, '1s', sym_size = 0.5,   /sym_filled , ytitle = 'total drift (pixels)', $
  ;;              xtitle = 'Change in pitch angle from previous observation', vert_colors = colorarr)
  ;;sdrift = plot(pa, drift_dist, '1s', sym_size = 0.5,   /sym_filled , ytitle = 'total drift (pixels)', $
  ;;              xtitle = 'Pitch angle', vert_colors = colorarr)

  
  
  ;;if keyword_set(run_data) then save, /variables, filename = '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/plot_track_centroids.sav'
 
