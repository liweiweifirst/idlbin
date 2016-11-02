pro track_centroids, pixval=pixval
  
;main code to automatically track centroids as a function of pitch
;angle for all warm mission long stares
  COMMON centroid_block, pid, campaign_name, start_jd, aorname, preaor, prera, predec, prejd, prepid, spitzer_jd, ra_string, dec_string,  naxis, xarr, yarr, fluxarr, fluxerrarr, corrfluxarr, corrfluxerrarr, bmjd_0, timearr, bmjd,  backarr, backerrarr, npcentroidsarr, exptime, xfwhmarr, yfwhmarr, fdarr, corrflux_d, datacollect36, datacollect45, piarr, pre36, pre45, planethash, ra, dec
  apradius = 2.25 ;;fix this for now
  ;;planethash = hash()  

  tic
  journal,  '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/track_out.txt'
  ;;read in the ephemeris file of Spitzer positions only once 
  readcol, '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/spitzer_warm_ephemeris.txt',date, spitzer_jd, blank, blank, ra_string, dec_string, skipline = 74, delimiter = ',', format = '(A, D10, A, A, A, A )'

  ;;warning: be careful of earth point and s2pcals and other
  ;;non-listed observations which could occur directly before a long stare

  
  ;;find which AORs need to be examined
  ;;need to also return JD and campaign
  zero = read_exoplanet_list(/calculate)
 ;; print, string(n_elements(aorname)),  ' aors: ',  aorname
   ;;will need to figure out which ones are new
  ;;compare JD of new lists
  
  chname = ['ch1','ch2']

  for na = 0, 1 - 1 do begin ;n_elements(aorname) 
     print, '---------------'
     print, 'starting on ',aorname(na), ' ', na
     chname = ['ch1','ch2']
     pchname = ['ch1','ch2']
     
     if datacollect36(na) eq 'f' then chname = ['ch2']
     if datacollect45(na) eq 'f' then chname = ['ch1']
     for c = 0, n_elements(chname) - 1 do begin
        ;;will need to get this AOR from the archive
        junk = scpdata(aorname(na), campaign_name(na), chname(c))
        
        
        ;;choose the first image to examine the header
        command  = strcompress( "find . -name 'SPITZER*_bcd.fits' > bcdlist.txt")
        spawn, command
        readcol,'bcdlist.txt',fitsname, format = 'A', /silent
        
        ;;get what I need from the header
        if n_elements(fitsname) gt 0 then begin  ;there is data in that channel
           header = headfits(fitsname(0))
           ra_rqst = sxpar(header, 'RA_RQST')  ;need to use these so that I know when there is a blank channel
           dec_rqst = sxpar(header, 'DEC_RQST')
           naxishere = sxpar(header, 'NAXIS')
           ra = ra_rqst
           dec = dec_rqst
           if naxishere eq 2 then begin
              ;;full array, want to search around the sweet spot
              ;;pixel, not the central pixel.
              xyad, header, 24., 232., ra, dec
           endif
           
           ;;figure out what the target of the AOR likely is:
           ;;ra and dec are in the common block so don't need
           ;;to send them here
           starname = Query_starid( naxishere, ra_rqst, dec_rqst);, /Verbose)
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
           phot_exoplanet_aor,starname, apradius,strmid(chname[c],2), aorname(na);, /hybrid

           ;;save relevant info
           ;;can only be one channel per AOR with this saving
           ;;technique

           if keyword_set(pixval) then begin
              ;;keep track of central pixel values for PLD type analysis
              keys_long =['ra', 'dec', 'xcen', 'ycen', 'flux','fluxerr', 'corrflux', 'corrfluxerr', 'bmjd_0', 'timearr', 'bmjdarr', 'bkgd', 'bkgderr', 'npcentroids','exptime','xfwhm', 'yfwhm','framedly','corrflux_d','chname','pitchangle','prepitchangle','starname','naxis','apradius','prera', 'predec', 'prejd', 'preaor', 'prepid','piarr','pid']

              values_long = list( ra,  dec, xarr, yarr, fluxarr, fluxerrarr, corrfluxarr, corrfluxerrarr, bmjd_0, timearr,  bmjd,  backarr, backerrarr,npcentroidsarr, exptime, xfwhmarr, yfwhmarr, fdarr, corrflux_d, chname[c],pitchangle,prepitchangle, starname,naxis,apradius,prera[na], predec[na], prejd[na], preaor[na], prepid[na], piarr,pid)
              planethash[aorname(na)] = dictionary(keys_long, values_long)

           endif else begin
              keys =['ra', 'dec', 'xcen', 'ycen', 'flux','fluxerr', 'corrflux', 'corrfluxerr', 'bmjd_0', 'timearr', 'bmjdarr', 'bkgd', 'bkgderr', 'npcentroids','exptime','xfwhm', 'yfwhm','framedly','corrflux_d','chname','pitchangle','prepitchangle','starname','naxis','apradius','prera', 'predec', 'prejd', 'preaor', 'prepid','pid']
              values=list(ra,  dec, xarr, yarr, fluxarr, fluxerrarr, corrfluxarr, corrfluxerrarr, bmjd_0, timearr,  bmjd,  backarr, backerrarr,npcentroidsarr, exptime, xfwhmarr, yfwhmarr, fdarr, corrflux_d, chname[c],pitchangle,prepitchangle, starname,naxis,apradius,prera[na], predec[na], prejd[na], preaor[na], prepid[na], pid)
              planethash[aorname(na)] = dictionary(keys, values)
           endelse
           
     
           ;;do photometry on the previous AOR if it is the same
           ;;target/pid
           pppid = prepid[na]
           ppaor = preaor[na]
           preaorname = ppaor(n_elements(pppid) - 1)
           if pppid(n_elements(pppid) - 1) eq pid[na] then begin

              ;;figure out which channel it is.
              if pre36(n_elements(pppid) - 1) eq 'f' then pchname = ['ch2']
              if pre45(n_elements(pppid) - 1) eq 'f' then pchname = ['ch1']

              ;;scp over this aor from the archive
              junk = scpdata(ppaor(n_elements(pppid) - 1), campaign_name(na), pchname)

              ;;do the photometry
              phot_exoplanet_aor,starname, apradius,strmid(pchname,2), ra, dec, preaorname ;, /hybrid

              ;;save relevant info
              ;;can only be one channel per AOR with this saving technique    
              values=list(ra,  dec, xarr, yarr, fluxarr, fluxerrarr, corrfluxarr, corrfluxerrarr, bmjd_0, timearr,  bmjd,  backarr, backerrarr,npcentroidsarr, exptime, xfwhmarr, yfwhmarr, fdarr, corrflux_d, pchname,pitchangle,prepitchangle[0:(n_elements(pp) - 2)], strcompress(starname+'preaor',/remove_all),naxis,apradius,ppra[0:(n_elements(pp) - 2)], ppdec[0:(n_elements(pp) - 2)], ppjd[0:(n_elements(pp) - 2)], ppaor[0:(n_elements(pp) - 2)], pppid[0:(n_elements(pp) - 2)], pid)
              planethash[preaorname] = dictionary(keys, values)
              
           endif                ; pre aor photometry
           
        endif                   ; starname is a real name

     endfor                     ; for each channel
     
  endfor                        ; for each AOR

  ;;save
  savename =  '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/track_centroids.sav'
 ;; savename = '/Users/jkrick/track_centroids.sav'
  save, planethash, filename=savename

  toc
  journal
end
