function calcpitch, ra, dec, startjd

  ;;read in the ephemeris file of Spitzer positions
  readcol, '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/spitzer_warm_ephemeris.txt',date, spitzer_jd, blank, blank, ra_string, dec_string, skipline = 74, delimiter = ',', format = '(A, D10, A, A, A, A )'

  ;;convert those ra and decs into useful format
  ra = tenv(ra_string)
  dec = tenv(dec_string)

  print, 'testing ra', ra[0:10]
  print, 'testing dec', dec[0:10]
  
  ;;find the time in the ephemeris nearest to the time of observation
  return, pitchangle

end
