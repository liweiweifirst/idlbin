pro plot_preaor


  restore, '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/track_centroids.sav'
  aorlist = planethash.keys()
  
  for n = 0, 20 do begin
     timearr = planethash[aorlist(n)].timearr
     bmjdarr = planethash[aorlist(n)].bmjdarr
     ycen = planethash[aorlist(n)].ycen
     pid = planethash[aorlist(n)].pid
     prepid=planethash[aorlist(n)].prepid
     preaor = planethash[aorlist(n)].preaor

     print, n,'pid', pid
     
     if prepid[-1] eq pid then begin
        print, 'got a matched pair', n
        preaor = preaor[-1]
        alltime = [planethash[preaor].timearr, timearr]
        allycen = [planethash[preaor].ycen, ycen]
        time0 = alltime(0)
        alltime = (alltime - time0)/60./60. ; now in hours instead of sclk
        p1 = plot(alltime, allycen, xtitle = 'time', ytitle = 'ycen','1s', sym_size = 0.5, /sym_filled,$
                  yrange = [mean(allycen,/nan) -0.5, mean(allycen,/nan) +0.5])
     endif
     
  endfor
  

end
