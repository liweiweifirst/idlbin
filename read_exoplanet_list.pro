function read_exoplanet_list, calculate = calculate

  ;;figure out where the exoplanet stares are.
  
  planets = webget("http://ssc.spitzer.caltech.edu/warmmission/scheduling/observinglogs/extrasolarplanetsWarm.txt")
  planets = planets.text[22:*]
  aorname = strmid(planets, 106, 8)  ;; will be screwed if format of this file changes
  min_dur = strmid(planets, 71, 6)
  start_time = strmid(planets, 79, 21)
  
  ;;pare down to only include those longer than some threshold
  thresh = 120  ;two hours seems appropriate for now
  longstare = where(min_dur gt thresh, n_longstare)
  aorname = aorname(longstare)
  start_time = start_time(longstare)
  
  if keyword_set(calculate) then begin
     ;;do a few calculations
     ;;print, TargetName(longstare)
     ;print, 'nele', n_elements(planets), n_longstare

     total_min = total(min_dur(longstare))
     total_sec = total_min *60.
     
     ;;assume 1 2s sub image is 128s and 312K
     total_frame = floor(total_sec / 128.)
     total_size = total_frame *312
     print, 'total time', total_min / 60./24.
     print, 'total size', total_size /1E6, 'G'
     
;;find those observations taken this year
     ;longstare = where(min_dur gt 20, n_longstare)
     ;start_day = start_day(longstare)
     ;TargetName = TargetName(longstare)
     ;AOR_key = AOR_key(longstare)
     ;year = where(strmid(start_day, 0,4) eq '2016')
     ;for i = 0, n_elements(year) - 1 do begin
     ;   ;; print,TargetName(year(i)), start_day(year(i)), AOR_Key(year(i))
     ;endfor
  endif
  
return, aorname
  
end
  ;;readcol, '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/allstares_07_28_16.txt', TargetName, RA,    Dec,   pid,   AOT, min_dur, start_day, start_time,   AOR_key,   AOR_LABEL, format = '(A, A, A, I10, A, F10.2, A, A, L10, A )'
