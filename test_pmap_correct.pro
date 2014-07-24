pro test_pmap_correct
 t1 = systime(1)

;use HD20003 r48408064 for testing = aor 0
;photometry already run with xfwhm and yfwhm
  planetname = 'HD20003' & chname = '2' & apradius = 2.25 & bin_level = 126L & nn = 50
  planetinfo = create_planetinfo()
  aorname= planetinfo[planetname, 'aorname_ch2'] 
  basedir = planetinfo[planetname, 'basedir']
  dirname = strcompress(basedir + planetname +'/') 
  savefilename = strcompress(dirname + planetname +'_phot_ch'+chname+'_'+string(apradius)+'.sav',/remove_all)
  print, 'restoring ', savefilename
  restore, savefilename
  print, 'aorname', aorname(0)
  pmapfile = '/Users/jkrick/irac_warm/pcrs_planets/pmap_phot/pmap_data_ch2_r2p25_s3_7_0p1s_x4_140716.sav'

  if chname eq '2' then occ_filename =  '/Users/jkrick/irac_warm/pmap/pmap_fits/pmap_ch2_0p1s_x4_500x500_0043_120827_occthresh.fits'$
  else occ_filename = '/Users/jkrick/irac_warm/pmap/pmap_fits/pmap_ch1_500x500_0043_120828_occthresh.fits'
  fits_read,occ_filename, occdata, occheader


;--------------------------------------------------------------------
;3) pmap_correct with x, y, xfwhm, yfwhm
 corrflux3 = pmap_correct((planethash[aorname(0),'xcen']),(planethash[aorname(0),'ycen']),planethash[aorname(0),'flux'],$
                          2,planethash[aorname(0),'xfwhm'],planethash[aorname(0),'yfwhm'],$
                          FUNC=planethash[aorname(0),'fluxerr'],CORR_UNC=corr_unc,$
                          DATAFILE=pmapfile,NNEAREST=nn)
print, 'finished pmap_correct x, y, xyfwhm'
;--------------------------------------------------------------------

;1) pmap_correct with x, y
 corrflux1= pmap_correct((planethash[aorname(0),'xcen']),(planethash[aorname(0),'ycen']),planethash[aorname(0),'flux'],$
                         2,planethash[aorname(0),'xfwhm'],planethash[aorname(0),'yfwhm'],/POSITION_ONLY,$
                         FUNC=planethash[aorname(0),'fluxerr'],CORR_UNC=corr_unc,$
                         DATAFILE=pmapfile,NNEAREST=nn) 
print, 'finished pmap_correct x, y'
;--------------------------------------------------------------------
;2) pmap_correct with x, y, np
 corrflux2 = pmap_correct((planethash[aorname(0),'xcen']),(planethash[aorname(0),'ycen']),planethash[aorname(0),'flux'],$
                          2,planethash[aorname(0),'xfwhm'],planethash[aorname(0),'yfwhm'],NP = planethash[aorname(0),'npcentroids'],$
                          FUNC=planethash[aorname(0),'fluxerr'],CORR_UNC=corr_unc,$
                          DATAFILE=pmapfile,NNEAREST=nn)
corrfluxmult = corrflux2
print, 'finished pmap_correct x, y, np'


;--------------------------------------------------------------------
;4) nearest_neighbors on the data itself with x, y
 pixphasecorr_noisepix, planetname, nn, apradius,chname,/use_fwhm, /use_np
 savename = strcompress(dirname + 'pixphasecorr_ch'+chname+'_'+string(apradius)+'.sav',/remove_all)
 restore, savename
 nnflux1 = flux
;--------------------------------------------------------------------
;5) nearest_neighbors on the data itself with x, y, np
  nnflux2 = flux_np
;--------------------------------------------------------------------
;6) nearest_neightbors on the data itself with x, y, xfwhm, yfwhm
  nnflux3 = flux_fwhm
print, 'finished all nn'

;--------------------------------------------------------------------
;A different comparison of
;1) pmap_correct with x, y, np and addition-weighted gaussian weights

corrfluxadd = pmap_correct_plusweights((planethash[aorname(0),'xcen']),(planethash[aorname(0),'ycen']),planethash[aorname(0),'flux'],$
              2, planethash[aorname(0),'npcentroids'],occdata, corr_unc = corr_unc, func = planethash[aorname(0),'fluxerr'],$
              datafile =pmapfile,/threshold_occ,/use_np) 
print, 'finished pmap_correct plusweights'

;2) pmap_correct with x, y, np and multiply-weighted gaussian weights
 ;already did this as corrflux2, now corrfluxmult
;--------------------------------------------------------------------
;binning
 timearr =  (planethash[aorname(0),'timearr'] - (planethash[aorname(0),'timearr'])(0))
 fluxarr = planethash[aorname(0),'flux'] 
 numberarr = findgen(n_elements(corrflux1))
 h = histogram(numberarr, OMIN=om, binsize = bin_level, reverse_indices = ri)
 
 bin_time = dblarr(n_elements(h))
 bin_flux = bin_time
 bin_corrflux1= bin_time
 bin_corrflux2= bin_time
 bin_corrflux3= bin_time
 bin_nn1 = bin_time
 bin_nn2 = bin_time
 bin_nn3 = bin_time
 bin_corrfluxadd = bin_time
 bin_corrfluxmult = bin_time

 c = 0
 for j = 0L, n_elements(h) - 1 do begin
        if (ri[j+1] gt ri[j] + 2)  then begin ;require 3 elements in the bin
       bin_time[c] = median(timearr[ri[ri[j]:ri[j+1]-1]])
       meanclip, fluxarr[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
       bin_flux[c] = meanx    ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
       meanclip, corrflux1[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
       bin_corrflux1[c] = meanx    ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
       meanclip, corrflux2[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
       bin_corrflux2[c] = meanx    ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
       meanclip, corrflux3[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
       bin_corrflux3[c] = meanx    ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
       meanclip, nnflux1[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
       bin_nn1[c] = meanx    ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
       meanclip, nnflux2[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
       bin_nn2[c] = meanx    ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
       meanclip, nnflux3[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
       bin_nn3[c] = meanx    ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
       meanclip, corrfluxadd[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
       bin_corrfluxadd[c] = meanx    ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
       meanclip, corrfluxmult[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
       bin_corrfluxmult[c] = meanx    ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
       c = c + 1
    endif
 endfor
 bin_time = bin_time[0:c-1]
 bin_flux = bin_flux[0:c-1]
 bin_corrflux1 = bin_corrflux1[0:c-1]
 bin_corrflux2 = bin_corrflux2[0:c-1]
 bin_corrflux3 = bin_corrflux3[0:c-1]
 bin_nn1 = bin_nn1[0:c-1]
 bin_nn2 = bin_nn2[0:c-1]
 bin_nn3 = bin_nn3[0:c-1]
 bin_corrfluxadd = bin_corrfluxadd[0:c-1]
 bin_corrfluxmult = bin_corrfluxmult[0:c-1]
print, 'finished binning'
;--------------------------------------------------------------------
;plot the raw fluxes
p = plot(bin_time, bin_flux / mean(bin_flux), xtitle = 'Time', ytitle = 'Normalized flux', '1s', sym_size = 0.2,sym_filled = 1,color = 'black')
;plot the  corrected fluxes
p1= plot(bin_time, (bin_corrflux1 / mean(bin_corrflux1)) + 0.01,  '1s', sym_size = 0.2,sym_filled = 1,color = 'midnight blue', overplot = p)
p2= plot(bin_time, (bin_corrflux2 / mean(bin_corrflux2)) + 0.02,  '1s', sym_size = 0.2,sym_filled = 1,color = 'blue', overplot = p)
p3= plot(bin_time, (bin_corrflux3 / mean(bin_corrflux3)) + 0.03,  '1s', sym_size = 0.2,sym_filled = 1,color = 'cyan', overplot = p)
p4= plot(bin_time, (bin_nn1 / mean(bin_nn1)) - 0.01,  '1s', sym_size = 0.2,sym_filled = 1,color = 'maroon', overplot = p)
p5= plot(bin_time, (bin_nn2 / mean(bin_nn2)) - 0.02,  '1s', sym_size = 0.2,sym_filled = 1,color = 'red', overplot = p)
p6= plot(bin_time, (bin_nn3 / mean(bin_nn3)) - 0.03,  '1s', sym_size = 0.2,sym_filled = 1,color = 'magenta', overplot = p)
print, 'the first part took ', systime(1) - t1, ' seconds'

;--------------------------------------------------------------------
;make another plot with comparison between added and multiplied weights

q = plot(bin_time, bin_flux / mean(bin_flux), xtitle = 'Time', ytitle = 'Normalized flux', '1s', sym_size = 0.2,sym_filled = 1,color = 'black')
qa = plot(bin_time, (bin_corfluxadd / mean(bin_corrfluxadd)) + 0.01, '1s',  sym_size = 0.2,sym_filled = 1,color = 'dark green', overplot = q)
qm = plot(bin_time, bin_corfluxmult/ mean(bin_corrfluxmult) + 0.02,  '1s', sym_size = 0.2,sym_filled = 1,color = 'spring green', overplot = q)


;--------------------------------------------------------------------
;--------------------------------------------------------------------

print, 'the whole thing took ', systime(1) - t1, ' seconds'

end
