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
     print, 'sigma x, y ', sigmax[n], sigmay[n]
     timearr = planethash[aorlist(n)].timearr
     xjd[n] = timearr(0)
     time0 = timearr(0)
     timearr = (timearr - time0)/60./60. ; now in hours instead of sclk
          
      ;;initial xdrift vs.& y drift
     ;;XXXwant this to be a fit to x vs. time over the preAOR if there is
     ;;one, or over the long AOR if there isn't a preAOR
     start = [.05,15.0]
     ;;don't have errors in position, instead, fake it.
     noise = fltarr(n_elements(planethash[aorlist(n)].xcen))
     noise = noise + 1.
     xcenfit= MPFITFUN('linear',timearr, planethash[aorlist(n)].xcen, noise, start)
     xdrift[n] = xcenfit(0)
     ycenfit= MPFITFUN('linear',timearr, planethash[aorlist(n)].ycen, noise, start)
     ydrift[n] = ycenfit(0)
     ;;make some plots to make sure this is working
    ;; pl = plot(timearr, planethash[aorlist(n)].ycen, '1s', sym_size = 0.5,   sym_filled = 1, title = aorlist(n), xtitle = 'time(hrs)', yrange = [mean(planethash[aorlist(n)].ycen,/nan) -1, mean(planethash[aorlist(n)].ycen,/nan) +1])
    ;; pl = plot(timearr, ycenfit(0)*timearr + ycenfit(1), color = 'red', overplot = pl)
     ;;XX don't want to keep this value if dithered.
     
     ;;delta pitch angle
     ;;really want change in pitch angle from 30 min prior, but watch
     ;;out for pre-AORXXX
     ;;XXhow does Carl calculate this?
    ;; pa[n] = planethash[aorlist(n)].prepitchangle - planethash[aorlist(n)].pitchangle
  endfor
  
  psx = plot(xjd, sigmax,'1s', sym_size = 0.5,   sym_filled = 1, ytitle = 'X Size of cloud (stddev in position)', $
             xtitle = 'Time (sclk)', yrange = [0, 1])
  psy = plot(xjd, sigmay,'1s', sym_size = 0.5,   sym_filled = 1, ytitle = 'Y Size of cloud (stddev in position)', $
             xtitle = 'Time (sclk)', yrange = [0, 1])

  pxdrift = plot(xjd, xdrift, '1s', sym_size = 0.5,   sym_filled = 1,  ytitle = 'X drift',  xtitle = 'Time (sclk)',$
                yrange = [-1, 1])
  pxdrift = plot(xjd, ydrift, '1s', sym_size = 0.5,   sym_filled = 1,  ytitle = 'Y drift',  xtitle = 'Time (sclk)',$
                yrange = [-1, 1])
end
