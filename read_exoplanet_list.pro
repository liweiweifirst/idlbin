function read_exoplanet_list, calculate = calculate
  COMMON centroid_block
  ;;figure out where the exoplanet stares are.

  ;;using the webpage that Elena maintains, but this doesn't
  ;;have campaign name which I need to access the data in the archive
;;  planets = webget("http://ssc.spitzer.caltech.edu/warmmission/scheduling/observinglogs/extrasolarplanetsWarm.txt")
;;  planets = planets.text[22:*]
;;  aorname = strmid(planets, 106, 8)  ;; will be screwed if format of this file changes
;;  min_dur = strmid(planets, 71, 6)
;;  start_time = strmid(planets, 79, 21)


  readcol, '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/week749_test.txt', aorname,pid,startUTC,campaign,min_dur,RA,Dec, format = '(L10, I10, A, A, F10.4, F10.6, F10.6 )', delimiter='|', skipline = 1
  
  start_year = fix(strmid(startUTC, 0,4))
  start_month = fix(strmid(startUTC, 5,2))
  start_day = fix(strmid(startUTC, 8,2))
  start_hr = fix(strmid(startUTC, 11, 2))
  start_min = fix(strmid(startUTC, 14, 2))
  ;;convert times to JD in order to compare later
  start_jd = julday(start_month, start_day, start_year, start_hr, start_min)


  ;;convert 3 digit campaign number to string
  campaign_name = strcompress('IRAC0'+ campaign + '00',/remove_all)
  

  ;;make an array which holds the previous 1 hour of AORnames
  ;;make this a pointer array so that the number of elements can vary
  preaor = ptrarr(n_elements(start_jd),/allocate_heap)
  prera =preaor
  predec = preaor
  prejd = preaor
  
  help, preaor
  print, 'preaor[0]',*preaor[0]
  *preaor[0] = 0  ;these first two are set
  *preaor[1] = aorname[0]
  for j = 2, n_elements(start_jd) -1 do begin
     pre = where(start_jd gt start_jd(j) - 0.05 and start_jd lt start_jd(j), n_pre)
     if n_pre gt 0 then begin
        *preaor[j] = aorname[pre]
        *prera[j] = ra[pre]
        *predec[j] = dec[pre]
        *prejd[j] = start_jd[pre]
     endif else begin
        ;;just use the previous single AOR - just means the one before
        ;;                                   it is longer than 1 hour.
        *preaor[j] = aorname[j-1]
        *prera[j] = ra[j-1]
        *predec[j] = dec[j-1]
        *prejd[j] = start_jd[j-1]
     endelse
     
  endfor
  ;;test preaors
  print,'testing pre', *preaor[1]
    print,'testing pre', *preaor[2]
    print,'testing pre', *preaor[10]

  ;;pare down to only include those longer than some threshold
  thresh = 120  ;two hours seems appropriate for now
  longstare = where(min_dur gt thresh, n_longstare)
  aorname = aorname(longstare)
  start_jd = start_jd(longstare)
  campaign_name = campaign_name(longstare)
  pid = pid(longstare)
  
  ;;and want to make sure they really are stares and not dithers
  ;;so compare to Elena's list of exoplanet and BD pids and
  ;;remove those pid's not on the list

  readcol, '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/staring_pids.txt',  spid, name, format = '(L5, A)'
  starepid = intarr(n_elements(pid))
  for i = 0, n_elements(pid) -1 do begin
     a = where(pid(i) eq spid, good)
     starepid[i] = good
  endfor
  print, starepid
  bad = where(starepid lt 1, nbad)
  print, 'bad', pid(bad)
  print, 'nbad', nbad
  if nbad gt 0 then remove, bad, pid, campaign_name, start_jd, aorname
  
    
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
  
return, 0
  
end
  ;;readcol, '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/allstares_07_28_16.txt', TargetName, RA,    Dec,   pid,   AOT, min_dur, start_day, start_time,   AOR_key,   AOR_LABEL, format = '(A, A, A, I10, A, F10.2, A, A, L10, A )'
