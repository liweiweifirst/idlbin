pro track_centroids
;main code to automatically track centroids as a function of pitch
;angle for all warm mission long stares

;;  COMMON centroid_block, data, header
  
  dirname = '/Users/jkrick/irac_warm/pcrs_planets/WASP-15b/r45675776/'
  ;;find which channels are in this AOR
  ;;figure out what to do when this returns both channels
  chname = find_chname(dirname)
  
  ;;choose the first image to examine the header
  command  = strcompress( 'find '+chname+"/bcd -name 'SPITZER*_bcd.fits' > "+dirname+'bcdlist.txt')
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

  
     
end
