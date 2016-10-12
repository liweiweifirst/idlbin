pro plot_track_centroids

  restore, '/Users/jkrick/external/irac_warm/trending/track_centroids.sav'

  aorlist = planethash.keys()
  sigmax = fltarr(n_elements(aorlist))
  sigmay = sigmax
  xjd = sigmax
  xdrift = sigmax
  ydrift = sigmax
  pa = sigmax
  for n = 0, n_elements(aorlist) - 1 do begin
     print, 'working on ', aorlist(n), n_elements(planethash[aorlist(n)].xcen)
     ;;sigmax & sigmay &sigmaxy vs. time
     ;;not sure what sigmaxy is?
     ;;plothist, planethash[aorlist(n)].xcen, xhist, yhist, bin = 0.05,/noplot
     ;;pg = barplot(xhist, yhist, title = aorlist(n))
     ;;start = [0.,10., 2.]
     ;;noise = fltarr(n_elements(yhist))
     ;;noise[*] = 1                                              ;equally weight the values
     ;;result= MPFITFUN('mygauss',xhist,yhist, noise, start) ;/quiet   ; fit a gaussian to the histogram sorted data
     sigmax[n] = stddev(planethash[aorlist(n)].xcen,/nan)
     sigmay[n] = stddev(planethash[aorlist(n)].ycen,/nan)
     xjd[n] = planethash[aorlist(n)].sclktime_0
     print, 'sigma x, y ', sigmax[n], sigmay[n]
     timearr = planethash[aorlist(n)].timearr
     time0 = timearr(0)
     pl = plot((timearr - time0)/60./60., planethash[aorlist(n)].xcen, '1s', sym_size = 0.5,   sym_filled = 1, title = aorlist(n), xtitle = 'time(hrs)')
     ;;initial xdrift vs.& y drift
     ;;XXXwant this to be a fit to x vs. time over the preAOR if there is
     ;;one, or over the long AOR if there isn't a preAOR
     start = [.05,15.0]
     ;;don't have errors in position, instead, fake it.
     noise = fltarr(n_elements(planethash[aorlist(n)].xcen))
     noise = noise + 1.
 ;;    xcenfit= MPFITFUN('linear',planethash[aorlist(n)].timearr, planethash[aorlist(n)].xcen, noise, start)
 ;;    xdrift[n] = xcenfit(0)
 ;;    ycenfit= MPFITFUN('linear',planethash[aorlist(n)].timearr, planethash[aorlist(n)].ycen, noise, start)
 ;;    ydrift[n] = ycenfit(0)

     ;;delta pitch angle
     ;;really want change in pitch angle from 30 min prior, but watch
     ;;out for pre-AORXXX
     ;;XXhow does Carl calculate this?
    ;; pa[n] = planethash[aorlist(n)].prepitchangle - planethash[aorlist(n)].pitchangle
  endfor
  
  ps = plot(xjd, sigmax,'1s', sym_size = 0.5,   sym_filled = 1, color = blue, ytitle = 'Size of cloud (stddev in position)',  xtitle = 'Time (sclk)')
 ;; ps = plot(xjd, sigmay,'1s', sym_size = 0.5,   sym_filled = 1,  overplot = ps, color = red)

;;  pdrift = plot(xdrift, ydrift, '1s', sym_size = 0.5,   sym_filled = 1,  ytitle = 'Y drift',  xtitle = 'X drift')
end
