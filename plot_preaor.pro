pro plot_preaor


  restore, '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/track_centroids_copy.sav'
  aorlist = planethash.keys()
  print, 'n_elements aorlist', n_elements(aorlist)
  for n =0,5 do begin
     print, '--------------------------'
     timearr = planethash[aorlist(n)].timearr
     bmjdarr = planethash[aorlist(n)].bmjdarr
     ycen = planethash[aorlist(n)].ycen
     pid = planethash[aorlist(n)].pid
     prepid=planethash[aorlist(n)].prepid
     preaor = planethash[aorlist(n)].preaor
     ;;piarr =  planethash[aorlist(n)].piarr
     ;;print, n,aorlist(n), ' pid ', pid, 'prepid', prepid
     ;p1 = plot(timearr, ycen, xtitle = 'time', ytitle = 'ycen','1s', sym_size = 0.5, /sym_filled,$
     ;          yrange = [mean(ycen,/nan) -0.5, mean(ycen,/nan) +0.5], title = pid)
     print, 'timearrr 0', n_elements(timearr)
     if prepid[-1] eq pid then begin
        print, 'got a matched pair', n
        preaor = preaor[-1]
        alltime = [planethash[preaor].timearr, timearr]
        allycen = [planethash[preaor].ycen, ycen]
        time0 = alltime(0)
                                ;alltime = (alltime - time0)/60./60. ;
                                ;                     now in hours instead of sclk
        print, 'alltime 0', n_elements(alltime)
        plot,(alltime - time0)/60./60., allycen,psym = 3,color = 'black',xtitle = 'time(hr)', ytitle = 'ycen', title = aorlist(n), yrange = [mean(ycen,/nan) -1.5, mean(ycen,/nan) +1.5]
        oplot,(planethash[preaor].timearr - time0)/60./60.,planethash[preaor].ycen,psym=3,color = 'red'
;;       p1 = plot((alltime - time0)/60./60., allycen,'1s', sym_size = 0.3, /sym_filled,color = 'black',xtitle = 'time(hr)', ytitle = 'ycen', title = aorlist(n), yrange = [mean(ycen,/nan) -1.5, mean(ycen,/nan) +1.5])
;;        p2 = plot((planethash[preaor].timearr - time0)/60./60.,planethash[preaor].ycen,'1s',sym_size = 0.3, /sym_filled,color = 'red', overplot = p1)
       ;; plotname = '/Users/jkrick/external/irac_warm/trending/centroiding_ycen.pdf'
                                ;p1.Save, plotname,/append,bitmap = 1
        CURSOR, X1, Y1, /DOWN,/DATA
        print, 'cursor position', X1, Y1
     endif
    
  endfor
  ;p1.Save, plotname, /close

end
