pro track_centroids
;main code to automatically track centroids as a function of pitch
;angle for all warm mission long stares
  COMMON centroid_block, pid, campaign_name, start_jd, aorname, preaor, prera, predec, prejd, prepid, spitzer_jd, ra_string, dec_string,  naxis, xarr, yarr, fluxarr, fluxerrarr, corrfluxarr, corrfluxerrarr, sclk_0, timearr, bmjd,  backarr, backerrarr, npcentroidsarr, exptime, xfwhmarr, yfwhmarr, fdarr, corrflux_d
  apradius = 2.25 ;;fix this for now
  planethash = hash()  

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
           print, 'pitch angle ', pitchangle

           ;;calculate pitch angle of previous aors
           ppra = prera[na]
           ppdec = predec[na]
           ppjd = prejd[na]
           prepitchangle = fltarr(n_elements(ppra))
           for pp = 0, n_elements(prera[na]) - 1 do begin
              prepitchangle[pp] = calcpitch(ppra[pp], ppdec[pp], ppjd[pp])
           endfor
           
           print, 'prior pitch angle(s) ', prepitchangle
           
           ;;do photometry
           phot_exoplanet_aor,starname, apradius,strmid(chname[c],2), ra, dec, aorname(na);, /hybrid

           ;;do photometry on the previous AOR if it is the same
           ;;target/pid
           pppid = prepid[na]
           ppaor = preaor[na]
           print, 'testing pppid', pppid(n_elements(pppid) - 1),  pid[na], ppaor(n_elements(pppid) - 1)
           if pppid(n_elements(pppid) - 1) eq pid[na] then begin
              ;;scp over this aor from the archive
              junk = scpdata(ppaor(n_elements(pppid) - 1), campaign_name(na), chname(c))

              ;;do the photometry
              phot_exoplanet_aor,starname, apradius,strmid(chname[c],2), ra, dec, ppaor(n_elements(pppid) - 1);, /hybrid
           endif
           
        endif ;starname is a real name

            ;;fill in that hash of hashes
        ;;can only be one channel per AOR with this saving technique
        ;;make sure new prepid, etc are in here
        ;;and make sure this is savign all AORs of photometry
        ;;including the preaorXXX
     keys =['ra', 'dec', 'xcen', 'ycen', 'flux','fluxerr', 'corrflux', 'corrfluxerr', 'sclktime_0', 'timearr', 'bmjdarr', 'bkgd', 'bkgderr', 'npcentroids','exptime','xfwhm', 'yfwhm','framedly','corrflux_d','chname','pitchangle','starname','naxis','apradius','prera', 'predec', 'prejd', 'preaor']
     values=list(ra,  dec, xarr, yarr, fluxarr, fluxerrarr, corrfluxarr, corrfluxerrarr, sclk_0, timearr,  bmjd,  backarr, backerrarr,npcentroidsarr, exptime, xfwhmarr, yfwhmarr, fdarr, corrflux_d, chname[c],pitchangle,starname,naxis,apradius,prera, predec, prejd, preaor)
     planethash[aorname(na)] = HASH(keys, values)

     endfor                     ; for each channel
     
 
  endfor                        ; for each AOR

  ;;save
  savename = '/Users/jkrick/external/irac_warm/trending/track_centroids.sav'
  save, planethash, filename=savename

end
