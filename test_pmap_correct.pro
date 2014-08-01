pro test_pmap_correct, planetname, run_photometry = run_photometry,make_plots = make_plots
 t1 = systime(1)

;use HD20003 r48408064 for testing = aor 0
;photometry already run with xfwhm and yfwhm
;  planetname = 'HD7924b';'HD20003'
  chname = '2' & apradius = 2.25 & bin_level = 63L*2 & nn = 50
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

  if keyword_set(run_photometry) then begin
;--------------------------------------------------------------------
;3) pmap_correct with x, y, xfwhm, yfwhm
     corrflux3 = pmap_correct((planethash[aorname(0),'xcen']),(planethash[aorname(0),'ycen']),planethash[aorname(0),'flux'],$
                              2,planethash[aorname(0),'xfwhm'],planethash[aorname(0),'yfwhm'],$
                              FUNC=planethash[aorname(0),'fluxerr'],CORR_UNC=corr_unc,$
                              DATAFILE=pmapfile,NNEAREST=nn)
     save, corrflux3, filename = '/Users/jkrick/irac_warm/pcrs_planets/' + planetname + '/corrflux3.sav'
     print, 'finished pmap_correct x, y, xyfwhm'
;--------------------------------------------------------------------
     
;1) pmap_correct with x, y
     corrflux1= pmap_correct((planethash[aorname(0),'xcen']),(planethash[aorname(0),'ycen']),planethash[aorname(0),'flux'],$
                             2,planethash[aorname(0),'xfwhm'],planethash[aorname(0),'yfwhm'],/POSITION_ONLY,$
                             FUNC=planethash[aorname(0),'fluxerr'],CORR_UNC=corr_unc,$
                             DATAFILE=pmapfile,NNEAREST=nn) 
     save, corrflux1, filename = '/Users/jkrick/irac_warm/pcrs_planets/' + planetname + '/corrflux1.sav'
     print, 'finished pmap_correct x, y'
;--------------------------------------------------------------------
;2) pmap_correct with x, y, np
     corrflux2 = pmap_correct((planethash[aorname(0),'xcen']),(planethash[aorname(0),'ycen']),planethash[aorname(0),'flux'],$
                              2,planethash[aorname(0),'xfwhm'],planethash[aorname(0),'yfwhm'],NP = planethash[aorname(0),'npcentroids'],$
                              FUNC=planethash[aorname(0),'fluxerr'],CORR_UNC=corr_unc,$
                              DATAFILE=pmapfile,NNEAREST=nn)
     corrfluxmult = corrflux2
     save, corrflux2, filename = '/Users/jkrick/irac_warm/pcrs_planets/' + planetname + '/corrflux2.sav'
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
     
;     corrfluxadd = pmap_correct_plusweights((planethash[aorname(0),'xcen']),(planethash[aorname(0),'ycen']),planethash[aorname(0),'flux'],$
;                                            2, planethash[aorname(0),'npcentroids'],occdata, corr_unc = corr_unc, func = planethash[aorname(0),'fluxerr'],$
;                                            datafile =pmapfile,/threshold_occ,/use_np) 
;     save, corrfluxadd,  filename ='/Users/jkrick/irac_warm/pcrs_planets/HD20003/corrfluxadd.sav'
;     print, 'finished pmap_correct plusweights'
     
;2) pmap_correct with x, y, np and multiply-weighted gaussian weights
                                ;already did this as corrflux2, now corrfluxmult
;--------------------------------------------------------------------
  endif else begin              ;keyword_set(run_photometry)
     restore, '/Users/jkrick/irac_warm/pcrs_planets/'+planetname+'/corrflux3.sav'
     restore, '/Users/jkrick/irac_warm/pcrs_planets/'+planetname+'/corrflux2.sav'
     restore, '/Users/jkrick/irac_warm/pcrs_planets/'+planetname+'/corrflux1.sav'
;     restore, '/Users/jkrick/irac_warm/pcrs_planets/'+planetname+'/corrfluxadd.sav'
    
     savename = strcompress(dirname + 'pixphasecorr_ch'+chname+'_'+string(apradius)+'.sav',/remove_all)
     restore, savename
     nnflux1 = flux
     nnflux2 = flux_np
     nnflux3 = flux_fwhm
     corrfluxmult = corrflux2
  endelse                       ;not running the photometry
  
 
;binning
  timearr =  (planethash[aorname(0),'timearr'] - (planethash[aorname(0),'timearr'])(0))
  fluxarr = planethash[aorname(0),'flux'] 
  numberarr = findgen(n_elements(fluxarr))
  h = histogram(numberarr, OMIN=om, binsize = bin_level, reverse_indices = ri)
  
   bin_time = dblarr(n_elements(h))
  bin_flux = bin_time
  bin_corrflux1= bin_time
  bin_corrflux2= bin_time
  bin_corrflux3= bin_time
  bin_nn1 = bin_time
  bin_nn2 = bin_time
  bin_nn3 = bin_time
;  bin_corrfluxadd = bin_time
;  bin_corrfluxmult = bin_time

  c = 0
  for j = 0L, n_elements(h) - 1 do begin
     if (ri[j+1] gt ri[j] + 2)  then begin ;require 3 elements in the bin
        bin_time[c] = median(timearr[ri[ri[j]:ri[j+1]-1]])
        meanclip_jk, fluxarr[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
        bin_flux[c] = meanx     ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
        meanclip_jk, corrflux1[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
        bin_corrflux1[c] = meanx ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
        meanclip_jk, corrflux2[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
        bin_corrflux2[c] = meanx ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
        meanclip_jk, corrflux3[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
        bin_corrflux3[c] = meanx ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
        meanclip_jk, nnflux1[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
        bin_nn1[c] = meanx      ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
        meanclip_jk, nnflux2[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
        bin_nn2[c] = meanx      ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
        meanclip_jk, nnflux3[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
        bin_nn3[c] = meanx      ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
;        meanclip_jk, corrfluxadd[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
;        bin_corrfluxadd[c] = meanx ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
;        meanclip_jk, corrfluxmult[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
;        bin_corrfluxmult[c] = meanx ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
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
;  bin_corrfluxadd = bin_corrfluxadd[0:c-1]
;  bin_corrfluxmult = bin_corrfluxmult[0:c-1]
  print, 'finished binning'
;--------------------------------------------------------------------
;plot the raw fluxes
;make histograms to compare widths for the different methods
    print, 'n_elements nn', n_elements(where(finite(fluxarr))), n_elements(where(finite(nnflux1))), n_elements(where(finite(nnflux2))), n_elements(where(finite(nnflux3)))
    print, 'n_elements corr', n_elements(where(finite(fluxarr))), n_elements(where(finite(corrflux1))), n_elements(where(finite(corrflux2))), n_elements(where(finite(corrflux3)))

;    cgPS_Open, '/Users/jkrick/irac_warm/pcrs_planets/'+planetname+'/test_pmap_hist.ps'

    cgHistoplot, fluxarr/ mean(fluxarr,/nan),/nan , thick = 2, xtitle = 'Flux', ytitle = 'Number',  $
                 datacolorname = 'black', title = planetname,/outline,xrange = [0.985, 1.015] , $
                 HISTDATA=h, LOCATIONS=loc, BINSIZE=binsize ;, yrange = [1E-5, 1] , peak_height = 1.0
    binCenters = loc + (binsize / 2.0)
    yfit = GaussFit(binCenters, h, coeff, NTERMS=3)
    fwhmraw = 2*SQRT(2*ALOG(2))*coeff(2)
;    cgPlot, binCenters, yfit, COLOR='black', THICK=3, /OVERPLOT
    cgtext, 0.985, 3100, string(fwhmraw), color = 'black'


    cgHistoplot, nnflux1/ mean(nnflux1,/nan),/nan, thick = 2 , datacolorname = 'gray',/oplot,/outline,HISTDATA=h, LOCATIONS=loc, BINSIZE=binsize
    binCenters = loc + (binsize / 2.0)
    yfit = GaussFit(binCenters, h, coeff, NTERMS=3)
    fwhmnn1 = 2*SQRT(2*ALOG(2))*coeff(2)
 ;   cgPlot, binCenters, yfit, COLOR='gray', THICK=3, /OVERPLOT
    cgtext, 0.985, 2900, string(fwhmnn1), color = 'gray'

    cgHistoplot, nnflux2/ mean(nnflux2,/nan),/nan , thick = 2 ,datacolorname = 'red',/oplot,/outline,HISTDATA=h, LOCATIONS=loc, BINSIZE=binsize
    binCenters = loc + (binsize / 2.0)
    yfit = GaussFit(binCenters, h, coeff, NTERMS=3)
    fwhmnn2 = 2*SQRT(2*ALOG(2))*coeff(2)
;    cgPlot, binCenters, yfit, COLOR='red', THICK=3, /OVERPLOT
    cgtext, 0.985, 2700, string(fwhmnn2), color = 'red'

    cgHistoplot, nnflux3/ mean(nnflux3,/nan),/nan, thick = 2 , datacolorname = 'salmon',/oplot,/outline,HISTDATA=h, LOCATIONS=loc, BINSIZE=binsize
    binCenters = loc + (binsize / 2.0)
    yfit = GaussFit(binCenters, h, coeff, NTERMS=3)
    fwhmnn3 = 2*SQRT(2*ALOG(2))*coeff(2)
;    cgPlot, binCenters, yfit, COLOR='salmon', THICK=3, /OVERPLOT
    cgtext, 0.985, 2500, string(fwhmnn3), color = 'salmon'

    cgHistoplot, corrflux1/ mean(corrflux1,/nan),/nan, thick = 2 , datacolorname = 'gray',/oplot,/outline,HISTDATA=h, LOCATIONS=loc, BINSIZE=binsize
    binCenters = loc + (binsize / 2.0)
    yfit = GaussFit(binCenters, h, coeff, NTERMS=3)
    fwhmc1 = 2*SQRT(2*ALOG(2))*coeff(2)
;    cgPlot, binCenters, yfit, COLOR='gray', THICK=3, /OVERPLOT
    cgtext, 0.985, 2300,string(fwhmc1), color = 'gray'

    cgHistoplot, corrflux2/ mean(corrflux2,/nan),/nan, thick = 2 ,datacolorname = 'blue',/oplot,/outline,HISTDATA=h, LOCATIONS=loc, BINSIZE=binsize
    binCenters = loc + (binsize / 2.0)
    yfit = GaussFit(binCenters, h, coeff, NTERMS=3)
    fwhmc2 = 2*SQRT(2*ALOG(2))*coeff(2)
;    cgPlot, binCenters, yfit, COLOR='blue', THICK=3, /OVERPLOT
    cgtext,0.985, 2100,string(fwhmc2), color = 'blue'

    cgHistoplot, corrflux3/ mean(corrflux3,/nan),/nan, thick = 2 , datacolorname = 'cyan',/oplot,/outline,HISTDATA=h, LOCATIONS=loc, BINSIZE=binsize
    binCenters = loc + (binsize / 2.0)
    yfit = GaussFit(binCenters, h, coeff, NTERMS=3)
    fwhmc3 =  2*SQRT(2*ALOG(2))*coeff(2)
;    cgPlot, binCenters, yfit, COLOR='cyan', THICK=3, /OVERPLOT
    cgtext, 0.985, 1900,string(fwhmc3), color = 'cyan'



;   cgPS_Close
  

  if keyword_set(make_plots) then begin
;pmap_correct
     p = plot(bin_time/60./60., bin_flux / mean(bin_flux), xtitle = 'Time', ytitle = 'Normalized flux', '1s', title = planetname +  ' pmap correct', sym_size = 0.2,sym_filled = 1,color = 'black', name = 'raw'+ string(fwhmraw))
     p1= plot(bin_time/60./60., (bin_corrflux1 / mean(bin_corrflux1,/nan)) + 0.005,  '1s', sym_size = 0.3,sym_filled = 1,color = 'gray', overplot = p, name = 'X Y' + string(fwhmc1))
     p2= plot(bin_time/60./60., (bin_corrflux2 / mean(bin_corrflux2,/nan)) + 0.005,  '1s', sym_size = 0.3,sym_filled = 1,color = 'blue', overplot = p, name = 'X Y NP'+ string(fwhmc2))
     p3= plot(bin_time/60./60., (bin_corrflux3 / mean(bin_corrflux3,/nan)) + 0.005,  '1s', sym_size = 0.3,sym_filled = 1,color = 'cyan', overplot = p, name = 'X Y XYFWHM'+ string(fwhmc3))
     l = legend(target = [p, p1, p2, p3], position = [4, 1.018], /data, /auto_text_color)
     
;pixphasecorr_noisepix = nn
     p = plot(bin_time/60./60., bin_flux / mean(bin_flux), xtitle = 'Time', ytitle = 'Normalized flux', title = planetname + ' nearest neighbor', '1s', sym_size = 0.2,sym_filled = 1,color = 'black', name = 'raw' + string(fwhmraw))
     p4= plot(bin_time/60./60., (bin_nn1 / mean(bin_nn1,/nan)) + 0.005,  '1s', sym_size = 0.3,sym_filled = 1,color = 'gray', overplot = p, name = 'X Y'+ string(fwhmnn1))
     p5= plot(bin_time/60./60., (bin_nn2 / mean(bin_nn2,/nan)) + 0.005,  '1s', sym_size = 0.3,sym_filled = 1,color = 'red', overplot = p, name = 'X Y NP'+ string(fwhmnn2))
     p6= plot(bin_time/60./60., (bin_nn3 / mean(bin_nn3,/nan)) + 0.005,  '1s', sym_size = 0.3,sym_filled = 1,color = 'salmon', overplot = p, name = 'X Y XYFWHM'+ string(fwhmnn3))
     l = legend(target = [p, p4, p5, p6], position = [6, 0.998], /data, /auto_text_color)
     
 endif   ;make_plots
;--------------------------------------------------------------------
;make another plot with comparison between added and multiplied weights
  
;  q = plot(bin_time/60./60., bin_flux / mean(bin_flux), xtitle = 'Time', ytitle = 'Normalized flux', '1s', sym_size = 0.2,sym_filled = 1,color = 'black')
;  qa = plot(bin_time/60./60., (bin_corrfluxadd / mean(bin_corrfluxadd)) + 0.005, '1s',  sym_size = 0.2,sym_filled = 1,color = 'dark green', overplot = q)
;  qm = plot(bin_time/60./60., bin_corrfluxmult/ mean(bin_corrfluxmult) + 0.005,  '1s', sym_size = 0.2,sym_filled = 1,color = 'spring green', overplot = q)
  
  
;--------------------------------------------------------------------
;--------------------------------------------------------------------
  

    
   ;now fit these with gaussians to see what the fwhm of the gaussian model is.
    ;smaller fwhm = better
    ;or just plot normalized histograms

 end

;;look at HD7924 
;    planetname = 'HD7924b'
;    planetinfo = create_planetinfo()
;    aorname= planetinfo[planetname, 'aorname_ch2'] 
;    basedir = planetinfo[planetname, 'basedir']
;    dirname = strcompress(basedir + planetname +'/') 
;    savename = strcompress(dirname + 'pixphasecorr_ch'+chname+'_'+string(apradius)+'.sav',/remove_all)
;    restore, savename
;    nnflux1 = flux;
;    nnflux2 = flux_np
;    nnflux3 = flux_fwhm
    
;;binning
;    timearr =  (planethash[aorname(0),'timearr'] - (planethash[aorname(0),'timearr'])(0))
;    fluxarr = planethash[aorname(0),'flux'] 
;    numberarr = findgen(n_elements(nnflux1));
;    h = histogram(numberarr, OMIN=om, binsize = bin_level, reverse_indices = ri)
    
;    bin_time = dblarr(n_elements(h))
;    bin_flux = bin_time
;    bin_corrflux1= bin_time
;    bin_corrflux2= bin_time
;    bin_corrflux3= bin_time
;    bin_nn1 = bin_time
;    bin_nn2 = bin_time
;    bin_nn3 = bin_time
;    bin_corrfluxadd = bin_time
;    bin_corrfluxmult = bin_time
    
;    c = 0
;    for j = 0L, n_elements(h) - 1 do begin
;       if (ri[j+1] gt ri[j] + 2)  then begin ;require 3 elements in the bin
;          bin_time[c] = median(timearr[ri[ri[j]:ri[j+1]-1]])
;          meanclip, fluxarr[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
;          bin_flux[c] = meanx   ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
;;          meanclip, corrflux1[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
;;          bin_corrflux1[c] = meanx ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
;;          meanclip, corrflux2[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
;;          bin_corrflux2[c] = meanx ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
;;          meanclip, corrflux3[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
;;          bin_corrflux3[c] = meanx ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
;          meanclip, nnflux1[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
;          bin_nn1[c] = meanx    ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
;          meanclip, nnflux2[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
;          bin_nn2[c] = meanx    ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
;          meanclip, nnflux3[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
;          bin_nn3[c] = meanx    ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
;;          meanclip, corrfluxadd[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
;;          bin_corrfluxadd[c] = meanx ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
;;          meanclip, corrfluxmult[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
;;          bin_corrfluxmult[c] = meanx ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
;          c = c + 1
;       endif
;    endfor
;    bin_time = bin_time[0:c-1]
;    bin_flux = bin_flux[0:c-1]
;    bin_corrflux1 = bin_corrflux1[0:c-1]
 ;   bin_corrflux2 = bin_corrflux2[0:c-1]
 ;   bin_corrflux3 = bin_corrflux3[0:c-1]
;    bin_nn1 = bin_nn1[0:c-1]
;    bin_nn2 = bin_nn2[0:c-1]
;    bin_nn3 = bin_nn3[0:c-1]
;    bin_corrfluxadd = bin_corrfluxadd[0:c-1]
;    bin_corrfluxmult = bin_corrfluxmult[0:c-1]
;    print, 'finished binning'
;--------------------------------------------------------------------
;plot the raw fluxes
        
;pixphasecorr_noisepix = nn
;    p = plot(bin_time/60./60., bin_flux / mean(bin_flux), xtitle = 'Time', ytitle = 'Normalized flux', title = planetname + ' nearest neighbor', '1s', sym_size = 0.2,sym_filled = 1,color = 'black', name = 'raw');
;    p4= plot(bin_time/60./60., (bin_nn1 / mean(bin_nn1)) + 0.007,  '1s', sym_size = 0.3,sym_filled = 1,color = 'gray', overplot = p, name = 'X Y')
;    p5= plot(bin_time/60./60., (bin_nn2 / mean(bin_nn2)) + 0.007,  '1s', sym_size = 0.3,sym_filled = 1,color = 'red', overplot = p, name = 'X Y NP')
;    p6= plot(bin_time/60./60., (bin_nn3 / mean(bin_nn3)) + 0.007,  '1s', sym_size = 0.3,sym_filled = 1,color = 'salmon', overplot = p, name = 'X Y XYFWHM')
;    l = legend(target = [p, p4, p5, p6], position = [2.5, 0.995], /data, /auto_text_color)
    
    
    
