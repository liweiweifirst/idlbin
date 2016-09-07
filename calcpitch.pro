function calcpitch, ra, dec, startjd

  ;;read in the ephemeris file of Spitzer positions
  readcol, '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/spitzer_warm_ephemeris.txt',date, spitzer_jd, blank, blank, ra, dec, skipline = 74, delimiter = ',', format = '(A, D10, A, A, A, A )'

  ;;convert those ra and decs into useful format
  
  ;;find the time in the ephemeris nearest to the time of observation
  return, pitchangle

end
