pro read_pmap

  restore, '/Users/jkrick/irac_warm/pmap/pmap_ch2_0p1s_x4_rmulti_s3_7_photometry.sav'

  ;clean the data a bit; only keep sweet spot data
  ss = where(ch2dat.xpos ge 14.5 and ch2dat.xpos le 16.5 and ch2dat.ypos ge 14.5 and ch2dat.ypos le 16.5)
  xpos = ch2dat.xpos(ss)
  xerr = ch2dat.xerr(ss)
  ypos = ch2dat.ypos(ss)
  yerr = ch2dat.yerr(ss)
  xycov = ch2dat.xycov(ss)
  flux = ch2dat.flux[*,5]
  flux = flux(ss)
  
  ;;make a 2D array to hold variables instead of struct

  all_arr = [[xpos],[xerr], [ypos],[yerr],[xycov], [flux], [ch2dat.sigma_flux[*,5]], [ch2dat.noise_pix], [ch2dat.xfwhm], [ch2dat.yfwhm], [ch2dat.dn_peak], [ch2dat.bmjd], [ch2dat.t_cernox], [ch2dat.bg_flux], [ch2dat.sigma_bg_flux], [reform(ch2dat.pix7x7[2,2,*])] , [reform(ch2dat.pix7x7[2,3,*])], [reform(ch2dat.pix7x7[2,4,*])], [reform(ch2dat.pix7x7[3,2,*])], [reform(ch2dat.pix7x7[3,3,*])], [reform(ch2dat.pix7x7[3,4,*])], [reform(ch2dat.pix7x7[4,2,*])], [reform(ch2dat.pix7x7[4,3,*])], [reform(ch2dat.pix7x7[4,4,*])] ]
  help, all_arr

  trans_arr = transpose(all_arr)
  help, trans_arr
  header = ['xpos','xerr','ypos','yerr','xycov','flux', 'fluxerr','np', 'xfwhm','yfwhm','dn_peak', 'bmjd', 't_cernox', 'bg_flux', 'sigma_bg_flux','pix1','pix2', 'pix3','pix4','pix5','pix6','pix7','pix8','pix9']


  
  

  
  ;;use write_csv
  
  write_csv, '//Users/jkrick/irac_warm/pmap/pmap_ch2_0p1s_x4_rmulti_s3_7.csv', trans_arr, header = header
  

end
