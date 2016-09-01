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


  readcol, '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/week749_test.txt', aorname,pid,startUTC,campaign,min_dur,RA,Dec, format = '(L10, I10, A, A, F10.4, D10.6, D10.6 )', delimiter='|', skipline = 1
  
  start_year = fix(strmid(startUTC, 0,4))
  start_month = fix(strmid(startUTC, 5,2))
  start_day = fix(strmid(startUTC, 8,2))
  start_hr = fix(strmid(startUTC, 11, 2))
  start_min = fix(strmid(startUTC, 14, 2))
  ;;convert times to JD in order to compare later
  start_jd = julday(start_month, start_day, start_year, start_hr, start_min)


  ;;convert 3 digit campaign number to string
  campaign_name = strcompress('IRAC0'+ campaign + '00',/remove_all)
  

  ;;make an array which holds the previous 1 hour of AORnames, ra,
  ;;dec, and start times
  ;;make this a pointer array so that the number of elements can vary
  ;;since we don't know ahead of time how many AORs will fill that 1 hour
  preaor = ptrarr(n_elements(start_jd),/allocate_heap)
  prera = ptrarr(n_elements(start_jd),/allocate_heap)
  predec =ptrarr(n_elements(start_jd),/allocate_heap)
  prejd = ptrarr(n_elements(start_jd),/allocate_heap)

  ;;these first two are set
  *preaor[0] = 0  
  *preaor[1] = aorname[0]
  *prera[0] = 0               
  *prera[1] = ra[0]
  *predec[0] = 0               
  *predec[1] = dec[0]
  *prejd[0] = 0               
  *prejd[1] = start_jd[0]

  for j = 2, n_elements(start_jd) -1 do begin
     pre = where(start_jd gt start_jd(j) - 0.05 and start_jd lt start_jd(j), n_pre)
     if n_pre gt 0 then begin
        *preaor[j] = aorname(pre)
        *prera[j] = ra(pre)
        *predec[j] = dec(pre)
        *prejd[j] = start_jd(pre)
     endif else begin
        ;;just use the previous single AOR - just means the one before
        ;;                                   it is longer than 1 hour.
        *preaor[j] = aorname(j-1)
        *prera[j] = ra(j-1)
        *predec[j] = dec(j-1)
        *prejd[j] = start_jd(j-1)
     endelse
     
  endfor

  ;;pare down to only include those longer than some threshold
  thresh = 120  ;two hours seems appropriate for now
  longstare = where(min_dur gt thresh, n_longstare)
  aorname = aorname(longstare)
  start_jd = start_jd(longstare)
  campaign_name = campaign_name(longstare)
  pid = pid(longstare)
  *preaor = *preaor(longstare)
  *prera = *prera(longstare)
  *predec = *predec(longstare)
  *prejd = *prejd(longstare)
  
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
  if nbad gt 0 then remove, bad, pid, campaign_name, start_jd, aorname, *preaor, *prera, *predec, *prejd
  
    
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
     
  endif
  
return, 0
  
end
  ;;readcol, '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/allstares_07_28_16.txt', TargetName, RA,    Dec,   pid,   AOT, min_dur, start_day, start_time,   AOR_key,   AOR_LABEL, format = '(A, A, A, I10, A, F10.2, A, A, L10, A )'
