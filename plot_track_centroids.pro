pro plot_track_centroids

  restore, '/Users/jkrick/external/irac_warm/trending/track_centroids.sav'

   aorlist = planethash.keys()
  sigmax = fltarr(n_elements(aorlist))
  sigmay = sigmax
  xjd = sigmax
  xdrift = sigmax
  ydrift = sigmax
  for n = 0, n_elements(aorlist) - 1 do begin

     ;;sigmax & sigmay &sigmaxy vs. time
     ;;not sure what sigmaxy is?     
     sigmax[n] = stddev(planethash[aorlist(n)].xcen)
     sigmay[n] = stddev(planethash[aorlist(n)].ycen)
     xjd[n] = planethash[aorlist(n)].sclktime_0
     

     ;;initial xdrift vs. y drift
     ;;XXXwant this to be a fit to x vs. time over the preAOR if there is
     ;;one, or over the long AOR if there isn't a preAOR
     start = [.05,15.0]
     ;;don't have errors in position, instead, fake it.
     noise = fltarr(n_elements(xcen))
     noise = noise + 1.
     xcenfit= MPFITFUN('linear',xcen,timearr, noise, start)
     xdrift[n] = xcenfit(0)
     ycenfit= MPFITFUN('linear',ycen,timearr, noise, start)
     ydrift[n] = ycenfit(0)

     ;;drifts vs. pitch angle
     
  endfor
  
  psx = plot(xjd, sigmax,'1s', sym_size = 0.5,   sym_filled = 1,  ytitle = 'Size of cloud (stddev in position)',  xtitle = 'Time (sclk)')
  
  pdrift = plot(xdrift, ydrift, '1s', sym_size = 0.5,   sym_filled = 1,  ytitle = 'Y drift',  xtitle = 'X drift')
end
