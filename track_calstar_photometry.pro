pro track_calstar_photometry, savefilename, make_plot = make_plot
;savefilename = '/Users/jkrick/irac_warm/calstars/track_calstar.sav'
;XXX need to fix channels
;XXX need to fix for full array and sub array
;XXX need to sort based on starname, color code or something
COMMON track_block, photcor_ch2, photcorhead_ch2, xcenarr,  ycenarr,  starnamearr,  timearr,  fluxarr,  fluxerrarr,  backarr,  corrfluxarr ,  raarr ,  decarr

;look for a save file with photometry
ch = 2
;for array dependant photometric correction warm
fits_read, '/Users/jkrick/irac_warm/calstars/arrayloccorr/ch1_photcorr_ap_5.fits', photcor_ch1, photcorhead_ch1
fits_read, '/Users/jkrick/irac_warm/calstars/arrayloccorr/ch2_photcorr_ap_5.fits', photcor_ch2, photcorhead_ch2

result = file_test(savefilename)
if result eq 1 then begin  ;file exists
;if that file exists then figure out which campaign was last done and
;incrememnt by 1.  + turn into string
;                        to find the right directory
   restore, savefilename
   ti = ti -100                 ; set back since the first thing the while loop does is to increment
endif else begin
;if that file doesn't exist, then start from old campaign
;and increment until there are no more directories
   orig_num = 38500 ;33500
   ti = orig_num
endelse


;error check on existance of directory
good_dir = 1
while good_dir eq 1 do begin  ; while there is data to work with, and not an empty directory
   ti =ti + 100
   dirname = strcompress('/Volumes/iracdata/flight/IWIC/IRAC0' +string(ti),/remove_all)
   print, 'dirname ', dirname
   good_dir = chk_dir(dirname)

   if good_dir eq 1 then begin  ;got a live one
      junk = do_calstar_photometry(ch, dirname)
      if ti eq orig_num + 100 then begin
      ;need to dynamically assaign these arrays since I don't
      ;know how many there are
         bigxcen = xcenarr
         bigycen = ycenarr
         bigstarnamearr = starnamearr
         bigtimearr = timearr
         bigfluxarr = fluxarr
         bigfluxerrarr = fluxerrarr
         bigbackarr = backarr
         bigcorrfluxarr = corrfluxarr
         bigraarr = raarr
         bigdecarr = decarr
      endif else begin
         bigxcen = [bigxcen, xcenarr]
         bigycen = [bigycen,ycenarr]
         bigstarnamearr = [bigstarnamearr,starnamearr]
         bigtimearr = [bigtimearr,timearr]
         bigfluxarr = [bigfluxarr, fluxarr]
         bigfluxerrarr = [bigfluxerrarr,fluxerrarr]
         bigbackarr = [bigbackarr,backarr]
         bigcorrfluxarr = [bigcorrfluxarr, corrfluxarr]
         bigraarr = [bigraarr, raarr]
         bigdecarr = [bigdecarr, decarr]
      endelse
   endif

endwhile


print, 'after while loop ', ti
;save,  ti, bigxcen,  bigycen,  bigstarnamearr,  bigtimearr,  bigfluxarr,  bigfluxerrarr,  bigcorrfluxarr, bigbackarr,  bigraarr,  bigdecarr , filename =savefilename



if keyword_set(make_plot) then begin
     colorarr = ['blue', 'red','black','green','grey','purple', 'deep_pink','fuchsia', 'magenta', 'medium_purple','medium_orchid', 'orchid', 'violet', 'plum', 'thistle', 'pink', 'orange_red', 'light_pink', 'rosy_brown','pale_violet_red',  'chocolate', 'saddle_brown', 'maroon', 'hot_pink', 'dark_orange', 'peach_puff', 'pale_goldenrod','red',  'aquamarine', 'teal', 'steel_blue', 'dodger_blue', 'dark_blue', 'indigo','dark_slate_blue', 'blue_violet', 'purple','dim_grey', 'slate_grey', 'dark_slate_grey', 'khaki', 'tomato', 'lavender','gold', 'green_yellow', 'lime', 'green', 'olive_drab', 'pale_green', 'spring_green','blue', 'red','deep_pink', 'magenta', 'medium_purple','light_sea_green', 'teal', 'cadet_blue', 'aquamarine', 'dark_turquoise', 'aqua','blue', 'red', 'deep_pink','fuchsia', 'magenta', 'medium_purple','medium_orchid', 'orchid', 'violet', 'plum', 'thistle', 'pink', 'orange_red', 'light_pink', 'rosy_brown','pale_violet_red',  'chocolate', 'saddle_brown', 'maroon', 'hot_pink', 'dark_orange', 'peach_puff', 'pale_goldenrod','red',  'aquamarine', 'teal', 'steel_blue', 'dodger_blue', 'dark_blue', 'indigo','dark_slate_blue', 'blue_violet', 'purple','dim_grey', 'slate_grey', 'dark_slate_grey', 'khaki', 'tomato', 'lavender','gold', 'green_yellow', 'lime', 'green', 'olive_drab', 'pale_green', 'spring_green','blue', 'red','deep_pink', 'magenta', 'medium_purple','light_sea_green', 'teal', 'cadet_blue', 'aquamarine', 'dark_turquoise', 'aqua' ]

   ;need to sort by star
     names = [ '1812095', 'KF08T3_', 'KF06T2_', 'KF06T1_', 'KF09T1_',  'NPM1p67','NPM1p60','BD20_417', 'HD4182', 'HD37725', 'HD55677','HD77823', 'HD89562', 'HD99253', 'HD113745', 'HD131769', 'HD137429', 'HD156896', 'HD184837', 'HD195061', 'HD218528', 'HD284370'];, 'NPM1p68'] ;, 'HD16545']
     
     ;XXX need to add secondary star names
     normvals = fltarr(n_elements(names))
     for n = 0, n_elements(names) - 1 do begin
        
        an = where(bigstarnamearr eq names(n), count)
        ;XXX not finding all the colors?
        if count gt 0 then begin
           print, 'n, name', n, bigstarnamearr(an), colorarr(n)
                                ;XXX want this to be corrflux
           p = errorplot((bigtimearr - bigtimearr(0))/60./60./ 24., bigfluxarr, bigfluxerrarr, '1s', sym_size = 0.5, $
                      sym_filled = 1, xtitle = 'Time (days)', ytitle = 'Flux',color = colorarr(n), overplot = p)
        endif

           
     endfor

  
endif

end






;----------------------------------------
function do_calstar_photometry, ch, dirname
  common track_block

  cd, dirname
  pwd
  command ="find ./bcd/00*/ -name 'IRAC.2*bcd_fp.fits' > /Users/jkrick/irac_warm/calstars/allch2bcdlist.txt "
  spawn, command  
  readcol,strcompress('/Users/jkrick/irac_warm/calstars/allch'+string(ch)+'bcdlist.txt',/remove_all), fitsname, format = 'A', /silent
     
  print, 'nfits', n_elements(fitsname) 
;set up storage arrays
  xcenarr = fltarr(n_elements(fitsname))
  ycenarr = xcenarr
  starnamearr = strarr(n_elements(fitsname))
  timearr = dblarr(n_elements(fitsname))
  fluxarr = xcenarr
  fluxerrarr = xcenarr
  backarr = xcenarr
  corrfluxarr = xcenarr
  raarr = xcenarr
  decarr = xcenarr
     
  startfits = 0L
  stopfits = n_elements(fitsname) - 1
  c = 0L
  for i= startfits, stopfits do begin

     header = headfits(fitsname(i)) ;
     NAXIS= sxpar(header, 'NAXIS')
        
     AORLABEL= sxpar(header, 'AORLABEL')
;       print, i, strmid(AORLABEL, 0, 12), naxis
                                ;cut on full array calstars only (for now)

     if strmid(AORLABEL, 0, 12) eq 'IRAC_calstar' and NAXIS lt 3 then begin ;got a good one
           
        fits_read,fitsname(i), im, h
        inter = strmid(fitsname(i), 0, 48)
        uncname = strcompress(inter + 'sig_dntoflux.fits',/remove_all)
;        print, 'uncname',i,  uncname, fitsname(i)
        fits_read, uncname, unc, hunc, /no_abort ; so it won't crash if the file isn't there but should use the last unc file.
           
        chnlnum = sxpar(h, 'CHNLNUM')
        ra_ref = sxpar(h, 'RA_REF')
        dec_ref = sxpar(h, 'DEC_REF')
        sos_ver = sxpar(h, 'SOS_VER')

        ;make sure it is on the frame
        ADXY, h, ra_ref, dec_ref, xcen, ycen
        if xcen gt 5 and ycen gt 5 and xcen lt 250 and ycen lt 250 then begin
           timearr[c]  = sxpar(h, 'SCLK_OBS')
           raarr[c] = ra_ref
           decarr[c] = dec_ref
           starnamearr[c] = strmid(AORLABEL, 13, 7)
              
           get_centroids_for_calstar_jk,im, h, unc, ra_ref, dec_ref,  t, dt, hjd, xft, x3, y3, $
                                        x5, y5, x7, y7, xg, yg, xh, yh, f, b, x3s, y3s, x5s, y5s, $
                                        x7s, y7s, fs, bs, xp3, yp3, xp5, yp5, xp7, yp7, xp3s, yp3s, $
                                        xp5s, yp5s, xp7s, yp7s, fp, fps, np, flag, ns, sf, $
                                        xfwhm, yfwhm, /WARM
              
                                ;make a correction for pixel phase 
           arraycorr = pixel_phase_correct_gauss(f[0],x3,y3,ch+1, '3_3_7')
           corrflux = f[0]*arraycorr
          ;XXXX why corrflux isn't working?
                                ;apply array dependent correction
           if chnlnum eq '1' then photcorr = photcor_ch1(x3, y3) else photcorr = photcor_ch2(x3, y3)
           corrflux= corrflux * photcorr
              
                                ;save them
           xcenarr[c]  = x3 &  ycenarr[c] = y3
           fluxarr[c] = f[0] & fluxerrarr[c] = fs[0] & backarr[c]= b[0] & corrfluxarr[c] = corrflux
           c = c + 1
        endif                   ; if the target is on the frame
           
     endif                      ; if full array calstar
  endfor                        ; for each fits image
  print, 'final c', c
  xcenarr = xcenarr[0:c-1] 
  ycenarr = ycenarr[0:c-1] 
  fluxarr = fluxarr[0:c-1] 
  corrfluxarr = corrfluxarr[0:c-1]
  fluxerrarr = fluxerrarr[0:c-1] 
  backarr = backarr[0:c-1] 
  timearr = timearr[0:c-1] 
  starnamearr = starnamearr[0:c-1] 
  raarr = raarr[0:c-1] 
  decarr = decarr[0:c-1] 
                               
  return, 0
end


;for each channel
  

; read in the files from the iracdata/flight/IWIC/*campaigname/*/ bcd directory

; if AORlabel is calstar

;find centroids based on header info
;do photometry - and corrections for array dependent photometric and
;                pixel_phase_correct_gauss

;update a save file with photometry, aornames, and completed campaign name so i
;know where to start again


;------

;then need to sort all the photometry and plot 
;redo this every campaign.

;plot could be normalized phtoometry with error bars as a function of
;time for all calstars including the secondaries, where each star has
;a different color, or maybe all secondaries have the same color, but
;different symbols.  - this could get crowded. but there is only one
;                      secondary at a time so maybe it will be ok.


;save this plot to a file that is in a directory which puts it online.

