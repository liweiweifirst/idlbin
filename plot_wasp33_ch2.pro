pro plot_wasp33_ch2
  colorarr = ['deep_pink', 'magenta', 'medium_purple', 'hot_pink', 'light_pink', 'rosy_brown', 'chocolate', 'saddle_brown', 'maroon', 'orange_red', 'dark_orange', 'peach_puff', 'pale_goldenrod','red',  'aquamarine', 'teal', 'steel_blue', 'dodger_blue', 'dark_blue', 'indigo','dark_slate_blue', 'blue_violet', 'purple','dim_grey', 'slate_grey', 'dark_slate_grey', 'khaki','black', 'light_cyan', 'lavender','gold', 'green_yellow', 'lime', 'green', 'olive_drab', 'pale_green', 'spring_green']

  fits_read, '/Users/jkrick/idlbin/pmap_fits/pmap_ch2_0p1s_x4_500x500_0043_120124.fits', pmapdata, pmapheader

  restore, '/Users/jkrick/irac_warm/pcrs_planets/wasp33/wasp33_phot_ch2.sav'
  aorname = ['r45383424', 'r45384448', 'r45384704'] ;ch2

;-------------------------------------------------------
;need to re-correct with the new pmap
; AORwasp33 = replicate({wasp33ob, ra:0D,dec:0D,xcen:dblarr(nfits),ycen:dblarr(nfits),flux:dblarr(nfits),fluxerr:dblarr(nfits), corrflux:dblarr(nfits), corrfluxerr:dblarr(nfits), sclktime_0:0D, timearr:dblarr(nfits),aor:' ', bmjdarr:dblarr(nfits), utcsarr:dblarr(nfits), bkgd:dblarr(nfits), bkgderr:dblarr(nfits)},n_elements(aorname))

;  file_suffix = ['500x500_0043_120409.fits','0p1s_x4_500x500_0043_120531.fits']
;print, 'starting corrflux ', systime()
;print, AORwasp33[0].corrflux[10:100]
;  AORwasp33.corrflux = iracpc_pmap_corr(AORwasp33.flux,AORwasp33.xcen,AORwasp33.ycen,2,FILE_SUFFIX=file_suffix,/threshold_occ, threshold_val = 20)
;print, 'ending corrflux ', systime()
;print, AORwasp33[0].corrflux[10:100]

;  save, AORwasp33, filename='/Users/jkrick/irac_warm/pcrs_planets/wasp33/wasp33_phot_ch2_pmap2.sav'


;-------------------------------------------------------

;  utjd_center = 2455947.70505 ;2455948.07332 ; center of eclipse
;  jdtomjd = 2400000.5
;  utmjd_center = utjd_center - jdtomjd

 
;  duration = 105.7              ;in minutes
;  duration = duration /60./24.  ; in days
;  period = 0.73654 ;days
  

;set time = 0 in the middle of the transit
;     bin_time = bin_time -tt
 ;AOR55cnc.bmjdarr = AOR55cnc.bmjdarr - utmjd_center

;set time in orbital phase from 0 at eclipse to 1 at next transit
  ;    AOR55cnc.bmjdarr= AOR55cnc.bmjdarr/ (period)

; c = contour(pmapdata, /fill, n_levels = 21, rgb_table = 0, xtitle = 'X (pixel)', ytitle = 'Y (pixel)', aspect_ratio = 1, xrange = [0,500], yrange = [0,500])

;  for a = 0, n_elements(aorname) - 1 do begin
;     xcen500 = 500.* (AORwasp33[a].xcen - 14.5)
;     ycen500 = 500.* (AORwasp33[a].ycen - 14.5)
;     an = plot(xcen500, ycen500, '6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a],/overplot)
; endfor

;-----
 
;    for a = 0, n_elements(aorname) - 1 do begin
;     if a eq 0 then begin
;        am = plot( (AORwasp33[a].timearr - AORwasp33[0].timearr(0))/60./60., AORwasp33[a].xcen,'6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a], xtitle = 'Time(hrs)', ytitle = 'X pix', yrange = [14.8, 15.3], xrange = [0,40])
;     endif else begin
;        am = plot( (AORwasp33[a].timearr - AORwasp33[0].timearr(0))/60./60., AORwasp33[a].xcen,'6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a],/overplot)
;     endelse

;  endfor

;------

;  for a = 0, n_elements(aorname) - 1 do begin
;     if a eq 0 then begin
;        am = plot( (AORwasp33[a].timearr - AORwasp33[0].timearr(0))/60./60., AORwasp33[a].ycen,'6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a], xtitle = 'Time(hrs)', ytitle = 'Y pix',  yrange = [14.8, 15.3], xrange = [0,40])
;     endif else begin
;        am = plot( (AORwasp33[a].timearr - AORwasp33[0].timearr(0))/60./60., AORwasp33[a].ycen,'6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a],/overplot)
;     endelse

;  endfor

;------
;  for a = 0, n_elements(aorname) - 1 do begin
;     if a eq 0 then begin
;        am = plot( (AORwasp33[a].timearr - AORwasp33[0].timearr(0))/60./60., AORwasp33[a].bkgd,'6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a], xtitle = 'Time(hrs)', ytitle = 'Background', xrange = [0,40])
;     endif else begin
;        am = plot( (AORwasp33[a].timearr - AORwasp33[0].timearr(0))/60./60., AORwasp33[a].bkgd,'6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a],/overplot)
;     endelse
;
;  endfor

;------

  for a = 0, n_elements(aorname) - 1 do begin
;sort by time
     s = sort(AORwasp33[a].bmjdarr)
     sorttime = AORwasp33[a].timearr[s]
     sortxcen= AORwasp33[a].xcen[s]
     sortycen = AORwasp33[a].ycen[s]
     sortflux = AORwasp33[a].flux[s]
     sortcorrflux = AORwasp33[a].corrflux[s]
     sortcorrfluxerr = AORwasp33[a].corrfluxerr[s]
     sortbmjd = AORwasp33[a].bmjdarr[s]
     sortutcs = AORwasp33[a].utcsarr[s]
     sortbkgd = AORwasp33[a].bkgd[s]

      ;remove outliers
     good = where(sortxcen lt mean(sortxcen) + 2.5*stddev(sortxcen) and sortxcen gt mean(sortxcen) -2.5*stddev(sortxcen) and sortycen lt mean(sortycen) +3.0*stddev(sortycen) and sortycen gt mean(sortycen) - 3.0*stddev(sortycen),ngood_pmap, complement=bad) 
     print, 'bad ',n_elements(bad)
     xarr = sortxcen[good]
     yarr = sortycen[good]
     timearr = sorttime[good]
     flux = sortflux[good]
     corrflux = sortcorrflux[good]
     corrfluxerr = sortcorrfluxerr[good]
     bmjdarr = sortbmjd[good]
     bkgdarr = sortbkgd[good]
     
     
; binning
     bin_level = 63L;*60
     nframes = bin_level
     nfits = long(n_elements(corrflux)) / nframes
     print, 'nframes, nfits', n_elements(corrflux), nframes, nfits
     bin_flux = dblarr(nfits)
     bin_corrflux= dblarr(nfits)
     bin_corrfluxerr= dblarr(nfits)
     bin_timearr = dblarr(nfits)
     bin_bmjdarr = dblarr(nfits)
     bin_bkgd = dblarr(nfits)

     for si = 0L, long(nfits) - 1L do begin
                                ;print, 'working on si', n_elements(AORwasp33[a].corrflux), si, si*nframes, si*nframes + (nframes - 1)
        idata = corrflux[si*nframes:si*nframes + (nframes - 1)]
        id = flux[si*nframes:si*nframes + (nframes - 1)]
        idataerr = corrfluxerr[si*nframes:si*nframes + (nframes - 1)]
        ib = bkgdarr[si*nframes:si*nframes + (nframes - 1)]
       ; if si lt 2 then print, 'ib', ib
       ; print, 'mean', mean(ib,/nan)
        bin_flux[si] = mean(id, /nan)
        bin_corrflux[si] = mean(idata,/nan)
        bin_corrfluxerr[si] =   sqrt(total(idataerr^2))/ (n_elements(idataerr))
        bin_timearr[si]= mean(timearr[si*nframes:si*nframes + (nframes - 1)])
        bin_bmjdarr[si]= mean(bmjdarr[si*nframes:si*nframes + (nframes - 1)])
        bin_bkgd[si] = mean(ib,/nan)

     endfor                     ;for each fits image
     
 ;try getting rid of flux outliers.
  ;do some running mean with clipping
     start = 0
     print, 'nflux', n_elements(bin_flux)
     for ni = 50, n_elements(bin_flux) -1, 50 do begin
        meanclip,flux[start:ni], m, s, subs = subs ;,/verbose
                                ;print, 'good', subs+start
                                ;now keep a list of the good ones
        if ni eq 50 then good_ni = subs+start else good_ni = [good_ni, subs+start]
        start = ni
     endfor
                                ;see if it worked
     ;xarr = xarr[good_ni]
     ;yarr = yarr[good_ni]
     bin_timearr = bin_timearr[good_ni]
     bin_bmjdarr = bin_bmjdarr[good_ni]
     bin_corrfluxerr = bin_corrfluxerr[good_ni]
     bin_flux = bin_flux[good_ni]
     bin_corrflux = bin_corrflux[good_ni]
     bin_bkgd = bin_bkgd[good_ni]

     print, 'nflux', n_elements(bin_flux)
     
 
;     if a eq 0 then begin
;        am = plot( (AORwasp33[a].timearr - AORwasp33[0].timearr(0))/60./60., AORwasp33[a].flux,'6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a], xtitle = 'Time(hrs)', ytitle = 'Flux', xrange = [0,40], yrange = [0.16,0.18])
;        am = plot( (AORwasp33[a].timearr - AORwasp33[0].timearr(0))/60./60., AORwasp33[a].corrflux-0.01,'6r1s', sym_size = 0.1,   sym_filled = 1, color = 'black', /overplot)

;     endif else begin
;        am = plot( (AORwasp33[a].timearr - AORwasp33[0].timearr(0))/60./60., AORwasp33[a].flux,'6r1s', sym_size = 0.1,   sym_filled = 1, color = colorarr[a],/overplot)
;        am = plot( (AORwasp33[a].timearr - AORwasp33[0].timearr(0))/60./60., AORwasp33[a].corrflux-0.01,'6r1s', sym_size = 0.1,   sym_filled = 1, color = 'black', /overplot)
;     endelse


  endfor
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;try this diffferently, try putting the AORs togetether as one array; then bin

timearr = [AORwasp33[0].timearr, AORwasp33[1].timearr, AORwasp33[2].timearr]
fluxarr = [AORwasp33[0].flux, AORwasp33[1].flux, AORwasp33[2].flux]
corrfluxarr = [AORwasp33[0].corrflux, AORwasp33[1].corrflux, AORwasp33[2].corrflux]
corrfluxerrarr = [AORwasp33[0].corrfluxerr, AORwasp33[1].corrfluxerr, AORwasp33[2].corrfluxerr]
xarr = [AORwasp33[0].xcen, AORwasp33[1].xcen, AORwasp33[2].xcen]
yarr = [AORwasp33[0].ycen, AORwasp33[1].ycen, AORwasp33[2].ycen]
bkgd = [AORwasp33[0].bkgd, AORwasp33[1].bkgd, AORwasp33[2].bkgd]
bmjd = [AORwasp33[0].bmjdarr, AORwasp33[1].bmjdarr, AORwasp33[2].bmjdarr]

print, 'n', n_elements(timearr), n_elements(AORwasp33[0].timearr), n_elements(AORwasp33[1].timearr), n_elements(AORwasp33[2].timearr)
;now for the binning

      ;remove outliers
good = where(xarr lt mean(xarr) + 2.5*stddev(xarr) and xarr gt mean(xarr) -2.5*stddev(xarr) and xarr lt mean(xarr) +3.0*stddev(yarr) and yarr gt mean(yarr) - 3.0*stddev(yarr),ngood_pmap, complement=bad) 
     print, 'bad ',n_elements(bad)
     xarr = xarr[good]
     yarr = yarr[good]
     timearr = timearr[good]
     flux = fluxarr[good]
     corrflux = corrfluxarr[good]
     corrfluxerr = corrfluxerrarr[good]
     bmjdarr = bmjd[good]
     bkgdarr = bkgd[good]
     
     
; binning
     bin_level = 63L;*60
     nframes = bin_level
     nfits = long(n_elements(corrflux)) / nframes
     print, 'nframes, nfits', n_elements(corrflux), nframes, nfits
     bin_flux = dblarr(nfits)
     bin_corrflux= dblarr(nfits)
     bin_corrfluxerr= dblarr(nfits)
     bin_timearr = dblarr(nfits)
     bin_bmjdarr = dblarr(nfits)
     bin_bkgd = dblarr(nfits)

     for si = 0L, long(nfits) - 1L do begin
                                ;print, 'working on si', n_elements(AORwasp33[a].corrflux), si, si*nframes, si*nframes + (nframes - 1)
        idata = corrflux[si*nframes:si*nframes + (nframes - 1)]
        id = flux[si*nframes:si*nframes + (nframes - 1)]
        idataerr = corrfluxerr[si*nframes:si*nframes + (nframes - 1)]
        ib = bkgdarr[si*nframes:si*nframes + (nframes - 1)]
       ; if si lt 2 then print, 'ib', ib
       ; print, 'mean', mean(ib,/nan)
        bin_flux[si] = mean(id, /nan)
        bin_corrflux[si] = mean(idata,/nan)
        bin_corrfluxerr[si] =   sqrt(total(idataerr^2))/ (n_elements(idataerr))
        bin_timearr[si]= mean(timearr[si*nframes:si*nframes + (nframes - 1)])
        bin_bmjdarr[si]= mean(bmjdarr[si*nframes:si*nframes + (nframes - 1)])
        bin_bkgd[si] = mean(ib,/nan)

     endfor                     ;for each fits image
     
 ;try getting rid of flux outliers.
  ;do some running mean with clipping
     start = 0
     print, 'nflux', n_elements(bin_flux)
     for ni = 50, n_elements(bin_flux) -1, 50 do begin
        meanclip,flux[start:ni], m, s, subs = subs ;,/verbose
                                ;print, 'good', subs+start
                                ;now keep a list of the good ones
        if ni eq 50 then good_ni = subs+start else good_ni = [good_ni, subs+start]
        start = ni
     endfor
                                ;see if it worked
     ;xarr = xarr[good_ni]
     ;yarr = yarr[good_ni]
     bin_timearr = bin_timearr[good_ni]
     bin_bmjdarr = bin_bmjdarr[good_ni]
     bin_corrfluxerr = bin_corrfluxerr[good_ni]
     bin_flux = bin_flux[good_ni]
     bin_corrflux = bin_corrflux[good_ni]
     bin_bkgd = bin_bkgd[good_ni]

     print, 'nflux', n_elements(bin_flux)
     
;now try plotting

;     pl = plot((bin_timearr - bin_timearr(0))/60./60., bin_flux, '6r1s', sym_size = 0.1,   sym_filled = 1, xrange = [0,40], yrange = [0.165, 0.180], xtitle = 'Time (hrs)', ytitle = 'Flux (Jy)')
;     pl = plot((bin_timearr - bin_timearr(0))/60./60., bin_corrflux-0.002, '6r1s', sym_size = 0.1,   sym_filled = 1, color = 'black',/overplot)


;------------------------------------------------------------
;periodogram
print, 'starting periodogram'
;X = (bin_timearr - bin_timearr(0))/60./60. ;in hours
X = (bin_timearr - bin_timearr(0))/60./60./24. ;in days
Y = bin_corrflux
t = plot(x, y)
;ok, try cutting this down in phase to between eclipses
;a = where(x gt 7 and x lt 17)  ;in hours
a1 = where(x gt 0.25 and x lt 0.7) ; in days
a2 = where(x gt 0.9 and x lt 1.33) ; in days

x = [x(a1),x(a2)]
y = [y(a1),y(a2)]
print, 'na', n_elements(x)
badx = where(finite(x) lt 1, badxcount)
bady = where(finite(y) lt 1, badycount)
print,'badycount', badycount
;print, x(bady), y(bady)
if badycount gt 0 then y(bady) = y(bady-1) 
;print, x(bady), y(bady)
;print, y[0:100]

;set the mean to zero
;doesn't seem to make a difference.
;y = y - mean(y)

;try taking out the phase variation
;which also takes out the mean
start =  [0.001,0.001]
noise = fltarr(n_elements(x)) + 1. ;set all noises equal
fitres= MPFITFUN('linear',x,y, noise, start)    ;ICL
ap = plot(x, y)
ap = plot(x, fitres(0)*x + fitres(1),color = 'green',/overplot)
;ap = plot(x, fitres(0) + fitres(1)*x^2 + fitres(2)*y^2, color = 'green', /overplot)

flaty = y - (fitres(0)*x + fitres(1))
;flaty = y - (fitres(0) + fitres(1)*x^2 + fitres(2)*y^2)
;ap = plot(x, flaty, color = 'blue', /overplot)

;print, y[0:100]
; Test the hypothesis that X and Y represent a significant periodic
; signal against the hypothesis that they represent random noise:
result = LNP_TEST(X, flaty, WK1 = wk1, WK2 = wk2, JMAX = jmax)
PRINT, result

b = plot(wk1, wk2, xtitle = 'frequency(1/days)', ytitle = 'power', xrange =[0,50], yrange = [0,130])

;------
;now try overplotting uncorrected periodogram
Y2 = bin_flux
;ok, try cutting this down in phase to between eclipses
y2 = [Y2(a1),Y2(a2)]
badx = where(finite(x) lt 1, badxcount)
bady = where(finite(y2) lt 1, badycount)
print,'badycount', badycount
if badycount gt 0 then y2(bady) = y2(bady-1) 
;print, y2[0:100]

;set the mean to zero
;doesn't seem to make a difference.
;y2 = y2 - mean(y2)
;print, y2[0:100]

;try taking out the phase variation
;which also takes out the mean
start = [0.001,0.001]
noise = fltarr(n_elements(x)) + 1. ;set all noises equal
fitres= MPFITFUN('linear',x,y2, noise, start)    ;ICL
;ap = plot(x, y2)
;ap = plot(x, fitres(0)*x + fitres(1),color = 'green',/overplot)

flaty2 = y2- (fitres(0)*x + fitres(1))
;ap = plot(x, flaty2, color = 'blue', /overplot)

; Test the hypothesis that X and Y represent a significant periodic
; signal against the hypothesis that they represent random noise:
result = LNP_TEST(X, flatY2, WK1 = wk1, WK2 = wk2, JMAX = jmax)
PRINT, result

b = plot(wk1, wk2, /overplot, color = 'red', linestyle = '2')



end
