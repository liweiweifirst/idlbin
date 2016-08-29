pro track_centroids
;main code to automatically track centroids as a function of pitch
;angle for all warm mission long stares

;;need the AOR_keys and campaign numbers of long stares
  ;;AND need the ra and dec of the AORs that are 30min prior to those
  ;;observations
  
  ;;warning: be careful of earth point and s2pcals and other
  ;;non-listed observations which could occur directly before a long stare



  
  ;;find which AORs need to be examined
  aorname = read_exoplanet_list()
  ;; for now just focus on one AOR
  aorname = '45675776'
  
  ;;will need to figure out which ones are new
  ;;read in old list: need to be saving these
  ;;is it the same?  array_equal
  ;;if not then find the new ones: ??? sort on AORname and look for
  ;;greater numbers, but this won't always work.
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/WASP-15b/r'
  dirname = strcompress(basedir + aorname,/remove_all)
  ;;find which channels are in this AOR
  chname = find_chname(dirname)
  
  for c = 0, n_elements(chname) - 1 do begin
     ;;choose the first image to examine the header
     command  = strcompress( 'find '+chname[c]+"/bcd -name 'SPITZER*_bcd.fits' > "+dirname+'bcdlist.txt')
     spawn, command
     readcol,strcompress(dirname +'bcdlist.txt'),fitsname, format = 'A', /silent
     
     ;;get what I need from the header
     header = headfits(fitsname(0))
     ra = sxpar(header, 'RA_RQST')
     dec = sxpar(header, 'DEC_RQST')
     naxis = sxpar(header, 'NAXIS')
     
     ;;figure out what the target of the AOR likely is:
     starname = Query_starid( ra, dec,naxis, /Verbose)
     print, 'starname: ', starname
  endfor
  
  
     
end