pro read_exoplanet_list

  ;readcol, '/Users/jkrick/irac_warm/pcrs_planets/allstares_07_28_16.txt', TargetName, RA,    Dec,   pid,   AOT, min_dur, start_day, start_time,   AOR_key,   AOR_LABEL, format = '(A, A, A, I10, A, F10.2, A, A, I10, A )'
readcol, '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/allstares_07_28_16.txt', TargetName, RA,    Dec,   pid,   AOT, min_dur, start_day, start_time,   AOR_key,   AOR_LABEL, format = '(A, A, A, I10, A, F10.2, A, A, L10, A )'
print, 'ne', n_elements(TargetName)


  longstare = where(min_dur gt 120, n_longstare)
  print, 'nlongstare', n_longstare
  ;;print, TargetName(longstare)
  total_min = total(min_dur(longstare))
  total_sec = total_min *60.

  ;;assume 1 2s sub image is 128s and 312K
  total_frame = floor(total_sec / 128.)
  total_size = total_frame *312
  print, 'total time', total_min / 60./24.
  print, 'total size', total_size /1E6, 'G'

;;find those observations taken this year
  longstare = where(min_dur gt 20, n_longstare)
  start_day = start_day(longstare)
  TargetName = TargetName(longstare)
  AOR_key = AOR_key(longstare)
  year = where(strmid(start_day, 0,4) eq '2016')
  for i = 0, n_elements(year) - 1 do begin
    ;; print,TargetName(year(i)), start_day(year(i)), AOR_Key(year(i))
  endfor
  

  
end
