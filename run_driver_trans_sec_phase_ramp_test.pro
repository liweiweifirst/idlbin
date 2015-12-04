pro run_driver_trans_sec_phase_ramp_test
  dirname = '/Users/jkrick/irac_warm/pcrs_planets/WASP-14b/'
  outfile = dirname + 'fitting_output_phot_ch2_2.25000_150723.sav'
  infile = dirname +'fitting_input_phot_ch2_2.25000_150723.sav'
  restore, infile

  ;;plot the data
  p1 = errorplot(bjd_tot, flux_tot, err_tot, xtitle = 'bjd', ytitle = 'flux', yrange = [0.987, 1.005])
 
  ;;call Nikole's fitting code
;;  driver_trans_sec_phase_ramp_jk, 2, 'flat', 0, 0, outfile
  driver_trans_sec_phase_ramp_jk, 2, 'cowan', 0, 0, outfile

  ;;overplot the results
  restore, outfile
  pfit = plot(bjd_tot, trans,  overplot = p1, color = 'cyan', thick = 2)

end


