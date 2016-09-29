pro plot_track_centroids

  restore, '/Users/jkrick/external/irac_warm/trending/track_centroids.sav'

  ;;sigmax & sigmay &sigmaxy vs. time
  ;;not sure what sigmaxy is?
  aorlist = planethash.keys()
  sigmax = fltarr(n_elements(aorlist))
  sigmay = sigmax
  xjd = sigmax
  for n = 0, n_elements(aorlist) - 1 do begin
     sigmax[n] = stddev(planethash[aorlist(n)].xcen)
     sigmay[n] = stddev(planethash[aorlist(n)].ycen)
     xjd[n] = planethash[aorlist(n)].sclktime_0
     

  ;;initial xdrift vs. y drift
  ;;define drifts first
  ;;want this to be a fit to x vs. time over the preAOR if there is
  ;;one, or over the long AOR if there isn't a preAOR

  endfor
  
  psx = plot(xjd, sigmax,'1s', sym_size = 0.5,   sym_filled = 1,  ytitle = 'Size of cloud (stddev in position)',  xtitle = 'Time (sclk)')

end
