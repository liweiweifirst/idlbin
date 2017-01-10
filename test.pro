pro test

  savename =  '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/track_centroids_pixval.sav'
  restore, savename
  aorlist = planethash.keys()
  print, 'n_elements aorlist', n_elements(aorlist)

  ;for n =1, n_elements(aorlist) - 1 do begin
  ;   planethash[aorlist(n)].test = n
  ;endfor
 a = plot(planethash.pitchangle, planethash.short_drift,'1s', xtitle = 'bmjd_0', ytitle = 'duration of short drift') 
  ;save, planethash, filename=savename

end
