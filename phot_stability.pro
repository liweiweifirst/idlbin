pro phot_stability, chname
;use BD+67_1044 to see what the photometric stability is on year-long timescales.
;will need to only look at one channel, one frametime, one narrow position.


t1 = systime(1)
dirname =  '/Users/jkrick/irac_warm/calstars/pmap_star/'
ra_ref= 269.72731
dec_ref = 67.793348
planethash = hash()

;need a list of all relevant AORs.
cd,dirname
command = 'ls -d */ > aorlist.txt'
spawn, command
readcol, 'aorlist.txt', aorname, format = 'A', /silent

for a = 0,  n_elements(aorname) -1 do begin
   undefine, fitsname
   undefine, buncname
   print, 'working on aorname ', aorname(a) , a, n_elements(aorname)
   cd, aorname(a)
   command1 = 'ls ch1/bcd/*_bcd.fits > ch1bcdnames.txt'
   command2 = 'ls ch2/bcd/*_bcd.fits > ch2bcdnames.txt'
   command3 =  'ls ch1/bcd/*_bunc.fits > ch1buncnames.txt'
   command4 =  'ls ch2/bcd/*_bunc.fits > ch2buncnames.txt'
   spawn, command1
   spawn, command2
   spawn, command3
   spawn, command4

   readcol, strcompress(chname + 'bcdnames.txt',/remove_all), fitsname, format = 'A', /silent, count = bcdcount
   readcol, strcompress(chname + 'buncnames.txt',/remove_all), buncname, format = 'A', /silent
   print, 'n count', bcdcount
   if bcdcount gt 0 then begin  ; got some correct channel data
      header = headfits(fitsname(0))        ;
      naxis = sxpar(header, 'NAXIS')
      framtime = sxpar(header, 'FRAMTIME')

      if naxis gt 2 and framtime eq 0.1 then begin  ; got some subarray 0.1s data
         fluxarr = fltarr(64*n_elements(fitsname))
         fluxerrarr = fluxarr
         backarr = fluxarr
         backerrarr = fluxarr
         nparr = fluxarr
         bmjdarr = fluxarr
         xarr = fluxarr
         yarr = fluxarr

      for i = 0, n_elements(fitsname) - 1 do begin

         fits_read, fitsname(i), im, h
         fits_read, buncname(i), unc, hunc
         bmjdarr[i] = sxpar(header, 'BMJD_OBS')
         get_centroids_for_calstar_jk,im, h, unc, ra_ref, dec_ref,  t, dt, hjd, xft, x3, y3, $
                                      x5, y5, x7, y7, xg, yg, xh, yh, f, b, x3s, y3s, x5s, y5s, $
                                      x7s, y7s, fs, bs, xp3, yp3, xp5, yp5, xp7, yp7, xp3s, yp3s, $
                                      xp5s, yp5s, xp7s, yp7s, fp, fps, np, flag, ns, sf, $
                                      xfwhm, yfwhm, /WARM,/silent
         fluxarr[i*64] = f[*,1]      ; chose 2 pixel aperture size
         fluxerrarr[i*64] = fs[*,1]
         backarr[i*64] = b[*,0]
         backerrarr[i*64] = bs[*,0]
         nparr[i*64] = np
         xarr[i*64] = x3
         yarr[i*64] = y3
       
      endfor  ; for each fits image

   endif  ; for subarray 0.1s data

   endif ; for the right channel data

   keys =['xarr', 'yarr', 'fluxarr','fluxerrarr',  'bmjdarr',  'backarr', 'backerrarr','np']
   values=list(xarr, yarr, fluxarr, fluxerrarr, bmjdarr,  backarr, backerrarr, nparr)
   planethash[aorname(a)] = HASH(keys, values)


   cd, dirname  ;reset for the next AOR
endfor  ; for each AOR
savename = strcompress(dirname + 'bd67_1044_phot_'+chname+'.sav',/remove_all)
save, planethash, filename=savename
print, 'saving planethash', savename
print, 'time check', systime(1) - t1




end
