pro track_centroids
;main code to automatically track centroids as a function of pitch
;angle for all warm mission long stares
  COMMON centroid_block, pid, campaign_name, start_jd, aorname, preaor, prera, predec, prejd, spitzer_jd, ra_string, dec_string,  naxis

  apradius = 2.25 ;;fix this for now
  
  ;;read in the ephemeris file of Spitzer positions only once 
  readcol, '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/spitzer_warm_ephemeris.txt',date, spitzer_jd, blank, blank, ra_string, dec_string, skipline = 74, delimiter = ',', format = '(A, D10, A, A, A, A )'

  ;;warning: be careful of earth point and s2pcals and other
  ;;non-listed observations which could occur directly before a long stare

  
  ;;find which AORs need to be examined
  ;;need to also return JD and campaign
  zero = read_exoplanet_list()
  print, 'aor', campaign_name(0), aorname(0)
   
  ;;will need to figure out which ones are new
  ;;compare JD of new lists
  
  chname = ['ch1','ch2']

  for na = 0, 0 do begin;  n_elements(aorname) - 1 do begin

     for c = 0, n_elements(chname) - 1 do begin
        ;;will need to get this AOR from the archive
        junk = scpdata(aorname(na), campaign_name(na), chname(c))
        
        
        ;;choose the first image to examine the header
        command  = strcompress( "find . -name 'SPITZER*_bcd.fits' > bcdlist.txt")
        print, 'command', command
        spawn, command
        readcol,'bcdlist.txt',fitsname, format = 'A', /silent
        
        ;;get what I need from the header
        if n_elements(fitsname) gt 0 then begin  ;there is data in that channel
           header = headfits(fitsname(0))
           ra = sxpar(header, 'RA_RQST')  ;need to use these so that I know when there is a blank channel
           dec = sxpar(header, 'DEC_RQST')
           ;naxis = sxpar(header, 'NAXIS')
           
           ;;figure out what the target of the AOR likely is:
           starname = Query_starid( ra, dec,naxis(na), /Verbose)
           print, 'starname: ', starname

         endif

        
        if starname ne 'nostar' then begin  ;;got a live one
           
           
           ;;calculate pitch angle of the ra and dec
           pitchangle = calcpitch(ra, dec, start_jd(na))
           print, 'pitch angle', pitchangle

           ;;do photometry
           phot_exoplanet_aor,starname, apradius,strmid(chname[c],2), ra, dec, /hybrid 
        endif
        
     endfor                     ; for each channel
     
  endfor                        ; for each AOR
  
  
end
