pro curveofgrowth
  !p.multi = [0, 1, 1]

;what size aperture are we using for photometry?
  aprad = [2,3,5,8,9,10]

  psymarr= [2,5,6]
  ps_open, filename = '/Users/jkrick/iwic/cog_ch2.ps', /portrait,/square,/color
  
  
  name = ['1812095_cal', 'HD165459', 'NPM1p60','HD184837','HD156896' ]
  ra = [273.04000000 ,270.628089 , 261.2178] ;,294.318477,260.231135 ]
  dec = [63.49508333, 58.627264, 60.430817]  ;, -24.669625,-20.359752]
  real_flux_ch1 = [8.68,647.38,38.20, 40.74,50.40]
  real_flux_ch2 = [5.66,421.19,24.74, 26.28,32.54]
  
  for ch = 1, 1 do begin
     print, 'Channel', ch+1
       
     
     for r = 0,  n_elements(ra) - 1 do begin
        print, 'working on ra', ra(r), dec(r)
        aparr = fltarr(n_elements(aprad))
        stddevarr = fltarr(n_elements(aprad))
        stdarr = fltarr(n_elements(aprad))
        ratioarr = fltarr(n_elements(aprad))
        count = 0

        for apcount = 0,  n_elements(aprad) - 1 do begin
           print, 'working on aperture', aprad(apcount)
           fluxarr = fltarr(10000)
           j = 0
           
           dirloc = ['/Users/jkrick/iracdata/flight/IWIC/S18.16/calstars']
           cd, dirloc
           if ch eq 0 then command  =  "find . -name 'IRAC.1*bcd_fp.fits' > /Users/jkrick/irac_warm/list.txt"
           if ch eq 1 then command  =  "find . -name 'IRAC.2*bcd_fp.fits' > /Users/jkrick/irac_warm/list.txt"
           spawn, command
           
           readcol,'/Users/jkrick/irac_warm/list.txt', fitsname, format = 'A', /silent
           
           for i =1, n_elements(fitsname) - 1 do begin
;            print, 'working on fitsna', fitsname(i)
              fits_read,fitsname(i), bcddata, bcdheader
              adxy, bcdheader, ra(r), dec(r), bcdx, bcdy
              
              if bcdx gt 20 and bcdy gt 20 and bcdy lt 240 and bcdx lt 240 then begin
                 
                                ;do the photometry
                 get_centroids, fitsname(i), t, dt, bcdxcen, bcdycen, bcdflux, xs, ys, fs, b, /WARM, /APER, APRAD = aprad(apcount), RA=ra(r), DEC=dec(r),/silent
                 
                                ;make a correction for pixel phase 
                                ;corrected_flux =
                                ;correct_pixel_phase(ch+1,bcdxcen,bcdycen,bcdflux)
                 pixap = strcompress(string(aprad(apcount)) + '_12_20',/remove_all)
                 corrected_flux = pixel_phase_correct_gauss(bcdflux,bcdxcen,bcdycen,ch+1,pixap)
                 
                                ;apply array dependent correction
                 filename1 = strcompress('/Users/jkrick/iwic/ch1_photcorr_ap_' + string(aprad(apcount)) + '.fits',/remove_all)
                 fits_read,filename1, photcor_warm_ch1, photcorhead_warm_ch1
                 filename2 = strcompress('/Users/jkrick/iwic/ch2_photcorr_ap_' + string(aprad(apcount)) + '.fits',/remove_all)
                 fits_read, filename2, photcor_warm_ch2, photcorhead_warm_ch2
                 photcor_ch1 = photcor_warm_ch1(bcdxcen, bcdycen)
                 photcor_ch2 = photcor_warm_ch2(bcdxcen, bcdycen)
;                  print, 'photcor', photcor_ch1, photcor_ch2
                 if ch eq 0 then corrected_flux = corrected_flux * photcor_ch1
                 if ch eq 1 then corrected_flux = corrected_flux * photcor_ch2
                 
                 
                                ; fluxes off by a factor of 100 (mJy)     
                 fluxarr(j) = corrected_flux*1000. ; in mJy
                 j = j + 1
              endif
              
           endfor               ;end for each fits image
           
           fluxarr = fluxarr[0:j-1]
           print, 'fluxarr',fluxarr
;         print, 'stddev', stddev(fluxarr)
                                ;plothist, fluxarr, bin = 0.1
                                ;clip any high sigma values out of the mean
           meanclip, fluxarr, meanflux, sigmaflux, clipsig = 3
           MMM, fluxarr,skymde, sigma, skew
           stdarr[count] = sigma
           
           if ch eq 0 then begin
              ratioarr[count] =median(fluxarr)/ real_flux_ch1(r) 
              print, 'mean',  meanflux, median(fluxarr), real_flux_ch1(r),  median(fluxarr)/ real_flux_ch1(r)
           endif
           
           if ch eq 1 then begin
              ratioarr[count] = median(fluxarr) / real_flux_ch2(r) 
              print,'mean',  median(fluxarr), real_flux_ch2(r),  median(fluxarr)/ real_flux_ch2(r)
           endif
           
           
           count = count+1
        endfor               ; for each aperture   
        
        print, 'ratio', ratioarr
        print, 'apcor', ratioarr(n_elements(ratioarr) - 1) / ratioarr
 ;       aparr[apcount] = ratioarr(0) ; mean(ratioarr) if 3 stars.
 ;       stddevarr[apcount] = stdarr(0)
        print, 'stdarr', stdarr
        yerr = stdarr / (real_flux_ch1(r)*ratioarr) 
        if r eq 0 then ploterror, aprad, ratioarr, yerr, yrange = [0.5, 1.2], psym = psymarr[r], xrange = [0,12], xtitle = 'aper radius', $
                   ytitle = 'fraction of predicted flux', thick = 3, xthick = 3, ythick = 3, charthick = 3, title = 'PC5 - 20'
        if r gt 0 then oploterror, aprad, ratioarr, yerr, psym = psymarr[r]

     endfor                     ; end for each ra, for each star
     
  endfor                        ;for each channel
  save, /variables, filename = '/Users/jkrick/iwic/cog_ch2.sav'
  ps_close, /noprint, /noid
  
end
