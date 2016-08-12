function find_starid
  ;;COMMON centroid_block
  ;;given an observation, try to find the position and starname that SIMBAD/NExScI will use
  
  
  ;;read in a bcd, grab ra and dec from header
  ;;or, find RA and DEC of pixel 15,15 (subarray) or 24,232 (full)
  fitsname = '/Users/jkrick/irac_warm/pcrs_planets/WASP-15b/r45675776/ch2/bcd/SPITZER_I2_45675776_0002_0000_1_bcd.fits'
  header = headfits(fitsname)
  ra_rqst = sxpar(header, 'RA_RQST')
  dec_rqst = sxpar(header, 'DEC_RQST')
  naxis = sxpar(header, 'NAXIS')
  
  ;;turn that RA and Dec into a SIMBAD API request
  ;;curl --output test.txt
  ;;"http://simbad.u-strasbg.fr/simbad/sim-coo?Coord=10h30+%2B12d20&Radius=5&Radius.unit=arcmin&output.format=ASCII&coodisp1=d"
  webaddress = "http://simbad.u-strasbg.fr/simbad/sim-coo?Coord=208.92788-32.159852&Radius=5&Radius.unit=arcmin&output.format=ASCII&coodisp1=d"
  command = strcompress("curl --output test.txt '"+ webaddress + "'")
  print, 'command', command
  spawn, command
  ;;read in the resulting file, choose which star id to use

  readcol, 'test.txt', num, dist, id, typ, coord1, MagU, MagB, MagV, MagR, MagI, spectype, bib, note

  print, 'id', id
return, 0

end
