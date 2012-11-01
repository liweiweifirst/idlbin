pro test_aper
  fits_read, '/Users/jkrick/Virgo/IRAC/globulars/prfs/IRAC1_col129_row129.fits', psfdata, psfheader

  cntrd, psfdata, 65,65, xcen, ycen, 5.0
  aper, psfdata, xcen, ycen, flux, ferrap, sky, skyerr, 500, [12], [50,60],/nan, /exact,/flux

  

end
