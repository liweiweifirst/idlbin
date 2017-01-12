pro plot_preaor

  savename =  '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/track_centroids_pixval.sav'
  restore, savename
  plotname = '/Users/jkrick/external/irac_warm/trending/centroiding_ycen.pdf'

  aorlist = planethash.keys()
  print, 'n_elements aorlist', n_elements(aorlist)
  loadct, 5
  for n =0,n_elements(aorlist) - 1 do begin
     print, '--------------------------'
     timearr = planethash[aorlist(n)].timearr
     bmjdarr = planethash[aorlist(n)].bmjdarr
     ycen = planethash[aorlist(n)].ycen
     pid = planethash[aorlist(n)].pid
     prepid=planethash[aorlist(n)].prepid
     preaor = planethash[aorlist(n)].preaor
     np = n_elements(preaor) - 1
     print, 'n, aors ', n, ' ', aorlist(n), ' ',preaor
     print, 'aor min_dur',  planethash[aorlist(n)].min_dur
     
     if prepid[-1] eq pid then begin
        if  planethash[aorlist(n)].min_dur gt 60. then begin
           
           ;;make sure we are not looking at the pre-aor itself.
           print, 'got a matched pid set', pid, ' ', aorlist(n)
           ppmin_dur = planethash[preaor(np)].min_dur
           
;;        print, 'preaor min_dur', ppmin_dur(n_elements(ppmin_dur) -1 ), planethash[aorlist(n)].min_dur
;;        print, 'ra, dec',  planethash[aorlist(n)].ra, planethash[aorlist(n)].dec
;;        print, 'pre ra', planethash[preaor(4)].ra , planethash[preaor(4)].dec
           ;; if abs(planethash[preaor(np)].ra - planethash[aorlist(n)].ra) lt 0.001 and abs(planethash[preaor(np)].dec - planethash[aorlist(n)].dec) lt 0.001 and ppmin_dur(n_elements(ppmin_dur) - 1) lt 60.  then begin ;and ppmin_dur(n_elements(ppmin_dur) - 1) gt 9
           preaor = preaor[-1]
           alltime = [planethash[preaor].timearr, timearr]
           allycen = [planethash[preaor].ycen, ycen]
           time0 = alltime(0)
           
           ;;plot,(alltime - time0)/60./60., allycen,psym = 3,xtitle = 'time(hr)', ytitle = 'ycen', title = aorlist(n), yrange = [mean(ycen,/nan) -1.1, mean(ycen,/nan) +1.1], ystyle = 1, xrange = [0, 5], xstyle = 1
           ;;oplot,(planethash[preaor].timearr - time0)/60./60.,planethash[preaor].ycen,psym=1, color = 80 ;,color = 'red'

           p1 = plot((alltime - time0)/60./60., allycen,'1s', sym_size = 0.3, /sym_filled,color = 'black',xtitle = 'time(hr)', ytitle = 'ycen', title = aorlist(n), yrange = [mean(ycen,/nan) -1.1, mean(ycen,/nan) +1.1])
           p2 = plot((planethash[preaor].timearr - time0)/60./60.,planethash[preaor].ycen,'1s',sym_size = 0.3, /sym_filled,color = 'red', overplot = p1)
           p1.Save, plotname,/append,bitmap = 1
           
           ;;CURSOR, X1, Y1, /DOWN,/DATA
           ;;CURSOR, X2, Y2, /DOWN,/DATA
           ;;directions
           ;;negative X1 = pre-aor, value of short and slope = NAN
           ;;negative X2-X1 = no short term drift = 0's
           ;;junk
           X1 = 0
           X2 = X1
           Y1 = X1
           Y2=X1
           
           print, 'cursor position pre-aor', X1, Y1, X2, Y2
           if X1 gt 0 then begin  ;;if nagative then is a preaor so keep at nan
              sd= X2 - X1
              slope = (Y2-Y1) / (X2 - X1) ; preserve direction - could be negative
              if X2 - X1 lt 0 then begin
                 sd = 0 
                 slope = 0
              endif
              print, 'slope', slope
              planethash[aorlist(n)].short_drift = sd
              planethash[aorlist(n)].slope_drift = slope
           endif
           
        endif
        
     endif else begin
     
        ;;just plot single AOR
       ;; plot,(timearr - timearr(0))/60./60., ycen,psym = 3,xtitle = 'time(hr)', ytitle = 'ycen', title = aorlist(n), yrange = [mean(ycen,/nan) -1.1, mean(ycen,/nan) +1.1], ystyle = 1, xrange = [0, 5], xstyle = 1
        ;;CURSOR, X1, Y1, /DOWN,/DATA
        ;;CURSOR, X2, Y2, /DOWN,/DATA
                  ;;junk
           X1 = 0
           X2 = X1
           Y1 = X1
           Y2=X1

        print, 'cursor position single', X1, Y1, X2, Y2

        p1 = plot((timearr - timearr(0))/60./60., ycen,'1s', sym_size = 0.3, /sym_filled,color = 'black',xtitle = 'time(hr)', ytitle = 'ycen', title = aorlist(n), yrange = [mean(ycen,/nan) -1.1, mean(ycen,/nan) +1.1])
        
        p1.Save, plotname,/append,bitmap = 1
 
        if X1 gt 0 then begin  ;;if nagative then is a preaor so keep at nan
           sd= X2 - X1
           slope = (Y2-Y1) / (X2 - X1) ; preserve direction - could be negative
           if X2 - X1 lt 0 then begin
              sd = 0 
              slope = 0
           endif
           print, 'slope', slope
           planethash[aorlist(n)].short_drift = sd
           planethash[aorlist(n)].slope_drift = slope
        endif
        
     endelse
     
     
  endfor
  p1.Save, plotname, /close
  ;;save, planethash, filename=savename
end


       ;; plotname = '/Users/jkrick/external/irac_warm/trending/centroiding_ycen.pdf'
