pro calstar_stability
!P.multi = [0,2,1]
ps_open, filename='/Users/jkrick/irac_warm/calstars/stability.ps',/portrait,/square,/color


      dirloc = ['/Users/jkrick/iracdata/flight/IWIC/calstars','/Users/jkrick/irac_warm/calstars/r38419200','/Users/jkrick/irac_warm/calstars/r38418432','/Users/jkrick/irac_warm/calstars/r38686976','/Users/jkrick/irac_warm/calstars/r38418944','/Users/jkrick/irac_warm/calstars/r38686208','/Users/jkrick/irac_warm/calstars/r38686720','/Users/jkrick/irac_warm/calstars/r38705920','/Users/jkrick/irac_warm/calstars/r38705664','/Users/jkrick/irac_warm/calstars/r38705152','/Users/jkrick/irac_warm/calstars/r38818048','/Users/jkrick/irac_warm/calstars/r38817280','/Users/jkrick/irac_warm/calstars/r38817792']


;for array dependant photometric correction
fits_read, '/Users/jkrick/iwic/photcorr_cryo/ch1_photcorr_rj.fits', photcor_cryo_ch1, photcorhead_cryo_ch1
fits_read, '/Users/jkrick/iwic/ch1_photcorr_gauss.fits', photcor_warm_ch1, photcorhead_warm_ch1

fits_read, '/Users/jkrick/iwic/photcorr_cryo/ch2_photcorr_rj.fits', photcor_cryo_ch2, photcorhead_cryo_ch2
fits_read, '/Users/jkrick/iwic/ch2_photcorr_gauss.fits', photcor_warm_ch2, photcorhead_warm_ch2


name = ['1812095_cal', 'NPM1p60' ]
ra = [273.04000000 , 261.2178 ]
dec = [63.49508333, 60.430817]
real_flux_ch1 = [8.68,647.38,38.20]
real_flux_ch2 = [5.66,421.19,24.74]

;comparison stars
;HD165459 has no other stars in the field

;npm1p60.   
;two stars that are each visible on 2 of the frames.
ra_comp_2 = [261.32117, 261.26517]
dec_comp_2 = [60.444476, 60.397291]

;1812095
;bright star right next to it so visible on all 5! second one fainter,
;but visible on all frames as well.
ra_comp_1 = [273.05545,273.07844]
dec_comp_1 = [63.493464,63.49424]

for ch = 0, 1 do begin
   print, 'Channel', ch+1
   ratioarr = fltarr(n_elements(ra))

   for r = 0, 0 do begin; n_elements(ra) - 1 do begin
      print, 'working on ra', ra(r), dec(r)
      comp0fluxarr = fltarr(10000)
      comp1fluxarr = fltarr(10000)
      clockarr = fltarr(10000)
      j = 0
      
      ;get the appropriate comparison stars
      if r eq 0 then begin
         ra_comp = ra_comp_1
         dec_comp = dec_comp_1
      endif
      if r eq 1 then begin
         ra_comp = ra_comp_2
         dec_comp = dec_comp_2
      endif
       


      for c = 0, n_elements(dirloc) - 1 do begin ;for each directory with calstars in it
         cd, dirloc(c)
         print, 'working on directory', dirloc(c)
         if ch eq 0 then begin
            if c eq 0 then command  =  "find . -name 'IRAC.1*bcd_fp.fits' > /Users/jkrick/irac_warm/list.txt"
            if c gt 0 then command =  "find . -name 'SPITZER_I1*_bcd.fits' > /Users/jkrick/irac_warm/list.txt"
            spawn, command
         endif
         
         if ch eq 1 then begin
            if c eq 0 then command  =  "find . -name 'IRAC.2*bcd_fp.fits' | grep -v 0000.0000 > /Users/jkrick/irac_warm/list.txt"
            if c gt 0 then command =  "find . -name 'SPITZER_I2*_bcd.fits' > /Users/jkrick/irac_warm/list.txt"
            spawn, command
         endif
         
         readcol,'/Users/jkrick/irac_warm/list.txt', fitsname, format = 'A', /silent
         
         for i =1, n_elements(fitsname) - 1 do begin
            print, 'working on fitsname', fitsname(i)
            fits_read,fitsname(i), bcddata, bcdheader
            adxy, bcdheader, ra(r), dec(r), bcdx, bcdy
;            adxy, bcdheader,  ra_comp(0), dec_comp(0), comp_0_x, comp_0_y
;            adxy, bcdheader,  ra_comp(1), dec_comp(1), comp_1_x, comp_1_y

            clockarr[j]  = sxpar(bcdheader, 'SCLK_OBS')

;            if bcdx gt 20 and bcdy gt 20 and bcdy lt 240 and bcdx lt 240 then begin
            if bcdx gt 120 and bcdy gt 120 and bcdy lt 140 and bcdx lt 140 then begin

                                ;do the photometry
               get_centroids, fitsname(i), t, dt, bcdxcen, bcdycen, bcdflux, xs, ys, fs, b, /WARM, /APER, RA=ra(r), DEC=dec(r),/silent
               get_centroids, fitsname(i), t, dt, comp_0_x, comp_0_y, comp_0_flux, xs, ys, fs, b, /WARM, /APER, RA=ra_comp(0), DEC=dec_comp(0),/silent
               get_centroids, fitsname(i), t, dt, comp_1_x, comp_1_y, comp_1_flux, xs, ys, fs, b, /WARM, /APER, RA=ra_comp(1), DEC=dec_comp(1),/silent
               print, 'bcdxcen, bcdycen', bcdxcen, bcdycen
;               print, '0', comp_0_x, comp_0_y, comp_0_flux
;               print, '1', comp_1_x, comp_1_y, comp_1_flux

                             ;make a correction for pixel phase 
               corrected_flux = pixel_phase_correct_gauss(bcdflux,bcdxcen,bcdycen,ch+1)
               corrected_comp0flux = pixel_phase_correct_gauss(comp_0_flux, comp_0_x, comp_0_y,ch+1)
               corrected_comp1flux = pixel_phase_correct_gauss(comp_1_flux, comp_1_x, comp_1_y,ch+1)

                      ;apply array dependent correction
               photcor_ch1 = photcor_warm_ch1(bcdxcen, bcdycen)
               photcor_ch2 = photcor_warm_ch2(bcdxcen, bcdycen)

               photcor_comp0_ch1 = photcor_warm_ch1(comp_0_x, comp_0_y)
               photcor_comp0_ch2 = photcor_warm_ch2(comp_0_x, comp_0_y)

               photcor_comp1_ch1 = photcor_warm_ch1(comp_1_x, comp_1_y)
               photcor_comp1_ch2 = photcor_warm_ch2(comp_1_x, comp_1_y)

               if ch eq 0 then begin
                  corrected_flux = corrected_flux * photcor_ch1
                  corrected_comp0flux = corrected_comp0flux * photcor_comp0_ch1
                  corrected_comp1flux = corrected_comp1flux * photcor_comp1_ch1
               endif

               if ch eq 1 then begin
                  corrected_flux = corrected_flux * photcor_ch2
                  corrected_comp0flux = corrected_comp0flux * photcor_comp0_ch2
                  corrected_comp1flux = corrected_comp1flux * photcor_comp1_ch2
               endif
               
                 ; fluxes off by a factor of 1000 (mJy)     
               comp0fluxarr(j) = 1000*(corrected_flux - corrected_comp0flux) ; in mJy
               comp1fluxarr(j) = 1000*(corrected_flux - corrected_comp1flux) ; in mJy

               j = j + 1
            endif
            
         endfor                 ;end for each fits image
      endfor    ;end for each directory

         
         comp0fluxarr = comp0fluxarr[0:j-1]
         comp1fluxarr = comp1fluxarr[0:j-1]
         clockarr = clockarr[0:j-1]

         ;clip any high sigma values out of the mean
         meanclip, comp0fluxarr, mean0flux, sigma0flux, clipsig = 3
         meanclip, comp1fluxarr, mean1flux, sigma1flux, clipsig = 3

         ;plot something
         print, '0', comp0fluxarr, mean0flux
         print, '1', comp1fluxarr, mean1flux


         plot, (clockarr - clockarr(0))/ (86400.), comp0fluxarr, psym = 2, yrange = [-5,10], xtitle = 'days', ytitle = 'delta flux', title = 'ch' + string(ch+1), xrange = [-50, 150]
         oplot, (clockarr - clockarr(0)) / (86400.), comp1fluxarr, psym =4

         yarr = fltarr(n_elements(clockarr))
         yarr[*] = mean0flux
         oplot,  (clockarr - clockarr(0)) / (86400.), yarr, linestyle = 2
         yarr[*] = mean1flux
         oplot,  (clockarr - clockarr(0)) / (86400.), yarr, linestyle = 2

         xyouts, 0,-3, sigma0flux
         xyouts, 0,8, sigma1flux

      endfor                    ; end for each ra, for each star
   
endfor  ;for each channel


ps_close, /noprint,/noid

end
