function calcpitch, ra, dec, startjd

  ;;read in the ephemeris file of Spitzer positions
  readcol, '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/spitzer_warm_ephemeris.txt',date, spitzer_jd, blank, blank, ra_string, dec_string, skipline = 74, delimiter = ',', format = '(A, D10, A, A, A, A )'

  ;;convert those ra and decs into useful format
  spitzer_ra = 15*tenv(ra_string)
  spitzer_dec = tenv(dec_string)

  
  ;;find the time in the ephemeris nearest to the time of observation
  near = Min(Abs(spitzer_jd - startjd), index)
  tel_jd = spitzer_jd[index]
  tel_ra = spitzer_ra[index]
  tel_dec = spitzer_dec[index]

  ;;do some spherical astronomy
  ;;taken from John Stauffer's code
  raddeg = 360.0/(2.0*!PI)
  ra1 = ra/raddeg
  dec1 = dec/raddeg
  ra2 = tel_ra/raddeg
  dec2 = tel_dec/raddeg
  cd1 = cos(dec1)
  cd2 = cos(dec2)
  dra = ra1-ra2
  cdra = cos(dra)
  sd1 = sin(dec1)
  sd2 = sin(dec2)
  coschi = cd1*cd2*cdra + sd1*sd2
  chi = acos(coschi)
  xpitch = chi*raddeg
  xpitch = 90.0 - xpitch


  
  return, xpitch

end
