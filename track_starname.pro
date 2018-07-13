pro track_starname

  savenames = [ '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/centroids_save/track_centroids_pixval_01.sav','/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/centroids_save/track_centroids_pixval_02.sav','/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/centroids_save/track_centroids_pixval_03.sav','/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/centroids_save/track_centroids_pixval_04.sav','/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/centroids_save/track_centroids_pixval_05.sav','/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/centroids_save/track_centroids_pixval_06.sav','/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/centroids_save/track_centroids_pixval_07.sav','/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/centroids_save/track_centroids_pixval_08.sav'] ;'/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/track_centroids_pixval.sav',
  
  starts = 0
  stops = n_elements(savenames) - 1
  totalaorcount = 0
  for s = starts, stops do begin
     
     restore, savenames(s)
     aorlist = planethash.keys()
     
     if s eq starts then begin
        sigmax = fltarr(2* (stops + 1 - starts) *n_elements(aorlist))*alog10(-1) ; two is the fudge factor to make sure arrays are large enough
        print, n_elements(sigmax)
        aorname = lonarr(n_elements(sigmax)) ;strarr(n_elements(sigmax))
        starname = strarr(n_elements(sigmax))
        duration = fltarr(n_elements(sigmax))
     endif
     for n = 0,  n_elements(aorlist) - 1 do begin
        ;print, '--------------'
        ;print, 'working on ',n, ' ', totalaorcount, ' ', aorlist(n), n_elements(planethash[aorlist(n)].xcen)
        starnamestr = planethash[aorlist(n)].starname
        ;;min_dur = planethash[aorlist(n)].min_dur - crap
        timearr = planethash[aorlist(n)].timearr
        min_dur = timearr(n_elements(timearr) - 1) - timearr(0)
        
        aorname[totalaorcount] = aorlist(n)
        ;print, 'aorname should be long', aorname[totalaorcount]

        duration[totalaorcount] = min_dur/60.
        
        starname[totalaorcount] = starnamestr(0)
        ;print, 'starname', starname[totalaorcount]
        totalaorcount++  ;;keep track of the total number of aors processed
     endfor
  endfor
  starname = starname[0:totalaorcount - 1]
  aorname = aorname[0:totalaorcount - 1]
  duration = duration[0:totalaorcount - 1]
  
 
  pre = where(duration lt 30, n_pre)
  transit = where((duration gt 90) and (duration le 660), n_transit)
  phase = where(duration gt 660,n_phase)
  
  print, 'total ', n_elements(duration)
  print, 'total pre ', n_pre 
  print, 'number of 90 - 650min AORs', n_transit
  print, 'number of longer AORs', n_phase

  ;;plot distribution of min_dur
  plothist, duration/60., xhist, yhist,/noplot, bin = 0.1
  p1 = plot(xhist, yhist,  xtitle = 'Duration of AOR (hrs.)', ytitle = 'Number', thick =3, color = 'blue', yrange = [0,100])

  ;;set up for wordle
  ;;remove pre-aors
  a = where(starname.Contains('preaor'), complement = b)
  wordle = starname(b)
  duration = duration(b)
  c = where(duration gt 90)
  
 ;; print, 'starnames', wordle(c)

  
  
end


