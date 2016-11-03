pro plot_track_centroids, run_data = run_data

  if keyword_set(run_data) then begin
     
     restore, '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/track_centroids.sav'
     
     aorlist = planethash.keys()
     sigmax = fltarr(n_elements(aorlist))
     sigmay = sigmax
     xjd = sigmax
     xdrift = sigmax
     ydrift = sigmax
     dpa = sigmax
     pkperiod = list(length=2)  ;n_elements(aorlist))
     pkstrength =  list(length=2) 
     pktime = list(length=2) 
     for n = 0, 17 do begin     ; n_elements(aorlist) - 1 do begin
        print, '--------------'
        print, 'working on ',n, ' ',aorlist(n), n_elements(planethash[aorlist(n)].xcen)
        ;;sigmax & sigmay &sigmaxy vs. time
        ;;not sure what sigmaxy is?
        sigmax[n] = stddev(planethash[aorlist(n)].xcen,/nan)
        sigmay[n] = stddev(planethash[aorlist(n)].ycen,/nan)
        print, 'sigma x, y ', sigmax[n], sigmay[n]
        timearr = planethash[aorlist(n)].timearr
        bmjdarr = planethash[aorlist(n)].bmjdarr
        xjd[n] = bmjdarr(0) + 2400000.5
        time0 = timearr(0)
        timearr = (timearr - time0)/60./60. ; now in hours instead of sclk
        
        ;;-------------------------------------
        ;;initial xdrift vs.& y drift
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
        ;;pl = plot(tx, ty, title = aorlist(n), xtitle = 'time(hrs)', yrange = [mean(planethash[aorlist(n)].ycen,/nan) -0.5, mean(planethash[aorlist(n)].ycen,/nan) +0.5])
        ;; pl = plot(timearr, ycenfit(0)*timearr + ycenfit(1), color = 'red', overplot = pl)
        ;;XX don't want to keep this value if dithered.
        
        ;;-------------------------------------
        ;;delta pitch angle
        prepitchangle = planethash[aorlist(n)].prepitchangle
        dpa[n] = prepitchangle(n_elements(prepitchangle) - 2) - planethash[aorlist(n)].pitchangle
        
        ;;-------------------------------------
        ;;width of the peak in the power spectrim at 30min
        ;;don't need to do this for pre-AORs
        ;;periodogram
        if max(timearr) gt 1.2 then begin
           xday = timearr*60.   ;in minutes             
           ycen = planethash[aorlist(n)].ycen
           bad = where(finite(ycen) lt 1,nbad)
           print, 'number of nans ', nbad
           if nbad gt 0 and nbad lt n_elements(ycen) then remove, bad, xday, ycen
           result = LNP_TEST(xday, ycen,/double, WK1 = wk1, WK2 = wk2, JMAX = jmax)
           
           ;;find the peaks above N* the random level
           ;;but N appears to be a function of the number of data points.
           d0 = wk2 - shift(wk2, 1)
           d1 = wk2 - shift(wk2, -1)
           pk = where(d0 gt 0 and d1 gt 0, npk)
           peakheight = wk2[pk]
           peakfreq = wk1[pk]
           peakperiod = 1/peakfreq
           ;;print, 'npk', npk
           
           ;;define significance relative to other peaks between 5 -  60 minutes
           short = where(peakperiod gt 5 and peakperiod lt 60)
           peakheight = peakheight(short)
           peakfreq = peakfreq(short)
           peakperiod = peakperiod(short)
           mn = robust_mean(peakheight, 4)
           sig = robust_sigma(peakheight)
           nsig = 3
           realpk = where(peakheight gt mn + nsig*sig and peakperiod gt 30. and peakperiod le 50., nrealpk)
           
           ;;concatenating arrays- messy, but not sure how else to do it
           if n eq 0 then begin
              if nrealpk gt 0 then begin
                 pkperiod = peakperiod(realpk)
                 pkstrength =(peakheight(realpk) -mn) /sig ;in units of some sort of significance
                 pt = fltarr(nrealpk)
                 pt(*) = xjd(n)
                 pktime = pt
              endif else begin
                 pkperiod = 0
                 pkstrength = 0
                 pktime = xjd(n)
              endelse
           endif else begin
              if nrealpk gt 0 then begin
                 pkperiod = [pkperiod, peakperiod(realpk)]
                 pkstrength =[pkstrength, (peakheight(realpk) -mn) /sig ] ;in units of some sort of significance
                 pt = fltarr(nrealpk)
                 pt(*) = xjd(n)
                 pktime = [pktime, pt]
              endif else begin
                 pkperiod =[pkperiod, 0]
                 pkstrength = [pkstrength,0]
                 pktime = [pktime, xjd(n)]
              endelse
              
              
           endelse
           
        endif
        
     endfor
     
  endif else begin;;keyword_set run_data
     restore, '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/plot_track_centroids.sav'

  endelse
  
  ;;sigmax & sigmay &sigmaxy vs. time
  xjd = xjd[0:n-1]
  sigmax = sigmax[0:n-1]
  sigmay = sigmay[0:n-1]
  xdrift = xdrift[0:n-1]
  ydrift = ydrift[0:n-1]
  dpa = dpa[0:n-1]
  
  psx = plot(xjd, sigmax,'1s', sym_size = 0.5,   sym_filled = 1, ytitle = 'X Size of cloud (stddev in position)', $
              XTICKFORMAT='(C(CMoA,1x,CYI))', xtickunits = ['Time'], xminor =11, yrange = [0, 1])
  psy = plot(xjd, sigmay,'1s', sym_size = 0.5,   sym_filled = 1, ytitle = 'Y Size of cloud (stddev in position)', $
             XTICKFORMAT='(C(CDI,1x,CMoA,1x,CYI))', xtickunits = ['Time'], xminor = 11, yrange = [0, 1])

  ;;initial xdrift vs.& y drift vs. time
  pxydrift = plot(xdrift, ydrift,  '1s', sym_size = 0.5,   sym_filled = 1,  ytitle = 'Y drift',  xtitle = 'X drift',$
                yrange = [-1, 1], xrange =[-1,1])
  pdrift = plot(xjd, xdrift, '1s', sym_size = 0.5,   sym_filled = 1,  ytitle = 'Drift', yrange = [-0.2, 0.2],$
                color = 'blue', XTICKFORMAT='(C(CMoA,1x,CYI))', xtickunits = ['Time'], xminor =11)
  pdrift = plot(xjd, ydrift, '1s', sym_size = 0.5,   sym_filled = 1,  overplot = pdrift, color = 'red')

  ;;delta pitch angle
  pdpa = plot(xdrift, dpa, '1s', sym_size = 0.5,   sym_filled = 1, ytitle = 'Change in pitch angle from previous observation', $
              xtitle = 'Drift', color = 'blue',xrange = [-0.1,0.1])
  pdpa = plot(ydrift, dpa, '1s', sym_size = 0.5,   sym_filled = 1, overplot = pdpa, color = 'red')

  ;;periodogram fun
  ;;how do I collapse a list into a single array?
  pperiod = bubbleplot(pktime, pkperiod, /shaded, magnitude = pkstrength , exponent = 0.5, $
                       ytitle = 'Period of the power spectrum peaks (min)',XTICKFORMAT='(C(CMoA,1x,CYI))', $
                       xtickunits = ['Time'], xminor =11 , yrange = [20,60])
     

  save, /variables, filename = '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/plot_track_centroids.sav'
  
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
     ;;pl = plot(tx, ty, title = aorlist(n), xtitle = 'time(hrs)', yrange = [mean(planethash[aorlist(n)].ycen,/nan) -0.5, mean(planethash[aorlist(n)
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
