pro plot_preaor

  savename =  '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/centroids_save/track_centroids_pixval_07.sav'
  restore, savename
  plotname = '/Users/jkrick/external/irac_warm/trending/centroiding_ycen.pdf'
  
  aorlist = planethash.keys()
  print, 'n_elements aorlist', n_elements(aorlist)
  ;;loadct, 5
  short_driftarr = fltarr(n_elements(aorlist))
  slope_driftarr = short_driftarr
  
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
     print, 'pid', pid, prepid[-1]
     
     if n gt 0 and prepid[-1] eq pid then begin
        if planethash[aorlist(n)].min_dur gt 60. then begin
           
           ;;make sure we are not looking at the pre-aor itself.
           print, 'got a matched pid set', pid, ' ', aorlist(n)
           if planethash.HasKey(preaor(np)) eq 1 then begin
              ppmin_dur = planethash[preaor(np)].min_dur
           
              preaor = preaor[-1]
              alltime = [planethash[preaor].timearr, timearr]
              allycen = [planethash[preaor].ycen, ycen]
              time0 = alltime(0)
              
              plot,(alltime - time0)/60./60., allycen,psym = 3,xtitle = 'time(hr)', ytitle = 'ycen', title = aorlist(n), yrange = [mean(ycen,/nan) -1.1, mean(ycen,/nan) +1.1], ystyle = 1, xrange = [0, 5], xstyle = 1
              oplot,(planethash[preaor].timearr - time0)/60./60.,planethash[preaor].ycen,psym=1, color = 80 ;,color = 'red'
              
              ;;p1 = plot((alltime - time0)/60./60., allycen,'1s', sym_size = 0.3, /sym_filled,color = 'black',xtitle = 'time(hr)', ytitle = 'ycen', title = aorlist(n), yrange = [mean(ycen,/nan) -1.1, mean(ycen,/nan) +1.1])
              ;;p2 = plot((planethash[preaor].timearr - time0)/60./60.,planethash[preaor].ycen,'1s',sym_size = 0.3, /sym_filled,color = 'red', overplot = p1)
              ;;p1.Save, plotname,/append,bitmap = 1
              
              CURSOR, X1, Y1, /DOWN,/DATA
              CURSOR, X2, Y2, /DOWN,/DATA
              ;;directions
              ;;negative X1 = pre-aor, or can't measure the
              ;;value due to badish data = value of short and slope = NAN
              ;;negative X2-X1 = no short term drift = 0's
              
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
                 short_driftarr(n) = sd
                 slope_driftarr(n) = slope
                 
              endif
              
           endif
        endif
        
     endif else begin
        
        ;;just plot single AOR
        plot,(timearr - timearr(0))/60./60., ycen,psym = 3,xtitle = 'time(hr)', ytitle = 'ycen', title = aorlist(n), yrange = [mean(ycen,/nan) -1.1, mean(ycen,/nan) +1.1], ystyle = 1, xrange = [0, 5], xstyle = 1
        CURSOR, X1, Y1, /DOWN,/DATA
        CURSOR, X2, Y2, /DOWN,/DATA
        print, 'cursor position single', X1, Y1, X2, Y2

        ;;p1 = plot((timearr - timearr(0))/60./60., ycen,'1s', sym_size = 0.3, /sym_filled,color = 'black',xtitle = 'time(hr)', ytitle = 'ycen', title = aorlist(n), yrange = [mean(ycen,/nan) -1.1, mean(ycen,/nan) +1.1])
        
        ;;p1.Save, plotname,/append,bitmap = 1
 
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
  ;;p1.Save, plotname, /close
  save, planethash, filename=savename
  save, short_driftarr, slope_driftarr, filename = '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/centroids_save/short_drift_07.sav'
end


       ;; plotname = '/Users/jkrick/external/irac_warm/trending/centroiding_ycen.pdf'
