pro track_centroids, pixval=pixval
  
;main code to automatically track centroids as a function of pitch
;angle for all warm mission long stares
  COMMON centroid_block, pid, campaign_name, start_jd, aorname, preaor, prera, predec, prejd, prepid, spitzer_jd, ra_string, dec_string,  naxis, xarr, yarr, fluxarr, fluxerrarr, corrfluxarr, corrfluxerrarr, bmjd_0, timearr, bmjd,  backarr, backerrarr, npcentroidsarr, exptime, xfwhmarr, yfwhmarr, fdarr, corrflux_d, datacollect36, datacollect45, piarr, pre36, pre45, premin_dur, planethash, ra, dec, startnaor, min_dur, ra_rqst, dec_rqst, start_year
  apradius = 2.25 ;;fix this for now
  planethash = hash()  

  tic
  journal,  '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/track_out.txt'
  ;;read in the ephemeris file of Spitzer positions only once 
  readcol, '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/spitzer_warm_ephemeris.txt',date, spitzer_jd, blank, blank, ra_string, dec_string, skipline = 74, delimiter = ',', format = '(A, D10, A, A, A, A )'

  ;;warning: be careful of earth point and s2pcals and other
  ;;non-listed observations which could occur directly before a long stare

  startnaor = 0  ;; start at the beginning unless this gets changed in read_exoplanet_list
  ;;find which AORs need to be examined
  ;;need to also return JD and campaign
  zero = read_exoplanet_list(/calculate)
 ;; print, string(n_elements(aorname)),  ' aors: ',  aorname
   ;;will need to figure out which ones are new
  ;;compare JD of new lists
  ;;startnaor = 0 ;;;remove when done testingXXXXXX
  chname = ['ch1','ch2']
  for na =startnaor,400 do begin; n_elements(aorname) -1 do begin
     print, '---------------'
     print, 'starting on ',aorname(na), ' ', na
     chname = ['ch1','ch2']
     pchname = ['ch1','ch2']
     if datacollect36(na) eq 'f' then chname = ['ch2']
     if datacollect45(na) eq 'f' then chname = ['ch1']
     ;;for now just work on one channel
     for c = 0,1 -1 do begin;  n_elements(chname) - 1 do begin
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
           date_obs = sxpar(header, 'DATE_OBS')
           year_obs = float(date_obs.substring(0,3))
           ra = ra_rqst
           dec = dec_rqst
           starname = Query_starid_v2( header, /Verbose)
           print, 'starname: ', starname, ra, dec

        endif
        
        if starname ne 'nostar' then begin  ;;got a live one
                     
           ;;calculate pitch angle of the ra and dec
           pitchangle = calcpitch(ra, dec, start_jd(na))
           print, 'pitch angle ', pitchangle

           ;;calculate pitch angle of previous aors
           ppra = prera[na,*]
           ppdec = predec[na,*]
           ppjd = prejd[na,*]
           prepitchangle = fltarr(n_elements(ppra))
           for pp = 0, n_elements(ppra) - 1 do begin
              prepitchangle[pp] = calcpitch(ppra[pp], ppdec[pp], ppjd[pp])
           endfor
           
           print, 'prior pitch angle(s) ', prepitchangle
           
           ;;do photometry
           if keyword_set(pixval) then phot_exoplanet_aor,starname, apradius,strmid(chname[c],2), aorname(na),/pixval $
           else phot_exoplanet_aor,starname, apradius,strmid(chname[c],2), aorname(na) ;, /hybrid
           
           ;;save relevant info
           ;;can only be one channel per AOR with this saving
           ;;technique

           if keyword_set(pixval) then begin
              ;;keep track of central pixel values for PLD type analysis
              keys =['ra', 'dec', 'xcen', 'ycen', 'flux','fluxerr', 'corrflux', 'corrfluxerr', 'bmjd_0', 'timearr', 'bmjdarr', 'bkgd', 'bkgderr', 'npcentroids','exptime','xfwhm', 'yfwhm','framedly','corrflux_d','chname','pitchangle','prepitchangle','starname','naxis','apradius','prera', 'predec', 'prejd', 'preaor', 'prepid','piarr','pid', 'naor_index','short_drift', 'slope_drift', 'min_dur']

              values = list( ra,  dec, xarr, yarr, fluxarr, fluxerrarr, corrfluxarr, corrfluxerrarr, bmjd_0, timearr,  bmjd,  backarr, backerrarr,npcentroidsarr, exptime, xfwhmarr, yfwhmarr, fdarr, corrflux_d, chname[c],pitchangle,prepitchangle, starname,naxis,apradius,prera[na,*], predec[na,*], prejd[na,*], preaor[na,*], prepid[na,*], piarr,pid[na],na, alog10(-1),alog10(-1), min_dur(na))
              planethash[aorname(na)] = dictionary(keys, values)
              savename =  '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/track_centroids_pixval_2.sav'
              ;;figure out dates and save file names
;;              caldat, bmjd_0 + 2400000.5, jmonth, jday, jyear
;;              case 1 of
;;                 (jyear = 2010) : savename =  '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/track_centroids_pixval_2010.sav'
;;                 (jyear = 2011) : savename =  '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/track_centroids_pixval_2011.sav'
;;                 (jyear = 2012) : savename =  '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/track_centroids_pixval_2012.sav'
;;                 (jyear = 2013) : savename =  '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/track_centroids_pixval_2013.sav'
;;                 (jyear = 2014) : savename =  '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/track_centroids_pixval_2014.sav'
;;                 (jyear = 2015) : savename =  '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/track_centroids_pixval_2015.sav'
;;                 (jyear = 2016) : savename =  '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/track_centroids_pixval_2016.sav'
;;                 (jyear = 2017) : savename =  '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/track_centroids_pixval_2017.sav'
;;                 (jyear = 2018) : savename =  '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/track_centroids_pixval_2018.sav'
;;                 (jyear = 2019) : savename =  '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/track_centroids_pixval_2019.sav'
                 
;;              endcase

              ;;savename =  savename + '_pixval.sav'
           endif else begin
;;              print,na, 'pid at end', pid[na]
              keys =['ra', 'dec', 'xcen', 'ycen', 'flux','fluxerr', 'corrflux', 'corrfluxerr', 'bmjd_0', 'timearr', 'bmjdarr', 'bkgd', 'bkgderr', 'npcentroids','exptime','xfwhm', 'yfwhm','framedly','corrflux_d','chname','pitchangle','prepitchangle','starname','naxis','apradius','prera', 'predec', 'prejd', 'preaor', 'prepid','pid','naor_index', 'short_drift', 'slope_drift',  'min_dur']
              values=list(ra,  dec, xarr, yarr, fluxarr, fluxerrarr, corrfluxarr, corrfluxerrarr, bmjd_0, timearr,  bmjd,  backarr, backerrarr,npcentroidsarr, exptime, xfwhmarr, yfwhmarr, fdarr, corrflux_d, chname[c],pitchangle,prepitchangle, starname,naxis,apradius,prera[na,*], predec[na,*], prejd[na,*], preaor[na,*], prepid[na,*], pid[na],na, alog10(-1), alog10(-1),min_dur(na))
              planethash[aorname(na)] = dictionary(keys, values)
              savename =  '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/track_centroids.sav'

           endelse
           
     
           ;;do photometry on the previous AOR if it is the same
           ;;target/pid
           pppid = prepid[na,*]
           preaorname = preaor[na,*]
           ppre36 = pre36[na, *]
           ppre45 = pre45[na, *]
           ppmin_dur = premin_dur[na, *]
           pppitch = prepitchangle
           if pppid(n_elements(pppid) - 1) eq pid[na] then begin

              ;;figure out which channel it is.
              if ppre36(n_elements(pppid) - 1) eq 'f' then pchname = ['ch2']
              if ppre45(n_elements(pppid) - 1) eq 'f' then pchname = ['ch1']
              if n_elements(chname) gt 1 then pchname = 'ch1' ;just guess
              ;;scp over this aor from the archive
              junk = scpdata(preaorname(n_elements(pppid) - 1), campaign_name(na), pchname)

              ;;do the photometry
              print, 'about to do photometry on preaor'
              phot_exoplanet_aor,starname, apradius, pchname.Substring(-1), preaorname(n_elements(pppid) - 1) ;, /hybrid

              ;;save relevant info
              if keyword_set(pixval) then begin
                 values =list(ra_rqst,  dec_rqst, xarr, yarr, fluxarr, fluxerrarr, corrfluxarr, corrfluxerrarr, bmjd_0, timearr,  bmjd,  backarr, backerrarr,npcentroidsarr, exptime, xfwhmarr, yfwhmarr, fdarr, corrflux_d, pchname,pitchangle,pppitch[0:(n_elements(pp) - 3)], strcompress(starname+'preaor',/remove_all),naxis,apradius,ppra[0:(n_elements(pp) - 3)], ppdec[0:(n_elements(pp) - 3)], ppjd[0:(n_elements(pp) - 3)], preaorname[0:(n_elements(pp) - 3)], pppid[0:(n_elements(pp) - 3)], piarr,pid[na],na, alog10(-1),alog10(-1),ppmin_dur[0:(n_elements(pp) - 4)])
              endif else begin
                 values=list(ra_rqst,  dec_rqst, xarr, yarr, fluxarr, fluxerrarr, corrfluxarr, corrfluxerrarr, bmjd_0, timearr,  bmjd,  backarr, backerrarr,npcentroidsarr, exptime, xfwhmarr, yfwhmarr, fdarr, corrflux_d, pchname,pitchangle,pppitch[0:(n_elements(pp) - 3)], strcompress(starname+'preaor',/remove_all),naxis,apradius,ppra[0:(n_elements(pp) - 3)], ppdec[0:(n_elements(pp) - 3)], ppjd[0:(n_elements(pp) - 3)], preaorname[0:(n_elements(pp) - 3)], pppid[0:(n_elements(pp) - 3)], pid[na],na,alog10(-1),alog10(-1),ppmin_dur[0:(n_elements(pp) - 4)])
              endelse
              
              thepreaorname = preaorname(n_elements(pppid) - 1)
              planethash[thepreaorname] = dictionary(keys, values)
              
           endif                ; pre aor photometry
           
        Endif                   ; starname is a real name

     endfor                     ; for each channel

     ;;periodically save so that we have a copy if this crashes
     if na mod 20 eq 0 then  save, planethash, filename=savename
  endfor                        ; for each AOR

  ;;use the original list of AORs to set the observation durations
  ;;into planethash
  aorlist = planethash.keys()
  print, 'n_elements aorlist', n_elements(aorlist)
  
  readcol, '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/out_centroiding_allWarmMissionToDate.txt', aorname,pid,startUTC,campaign,min_dur_cat,RA,Dec,readoutfull,datacollect36,datacollect45, format = '(L10, L10, A, A, F10.4, D10.6, D10.6,A,A,A )', delimiter='|', skipline =7520
  
  for n =1, n_elements(aorlist) - 1 do begin
     a = where(aorname eq aorlist(n))
     print, aorlist(n), aorname(a)
     premin_dur = min_dur_cat(a-1)
     ;; print, 'a, min_dur, premin_dur', a, min_dur_cat(a), premin_dur
     planethash[aorlist(n)].min_dur = min_dur_cat(a)
  endfor
  



  
  ;;save
 ;; savename = '/Users/jkrick/track_centroids.sav'
  save, planethash, filename=savename

  toc
  journal
end
