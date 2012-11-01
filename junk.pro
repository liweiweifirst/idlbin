pro background_55cnc
;try to see if I can see background blowups as reported by Demory et al 2011

;55cnc staring mode ch2
  ra_ref = 133.14754
  dec_ref = 28.330195

  cd, '/Users/jkrick/irac_warm/pcrs_planets/55cnc/r39524608/ch2/bcd'
  command  =  "find . -name '*_bcd.fits' > /Users/jkrick/irac_warm/pcrs_planets/55cnc/bcdlist.txt"
;  spawn, command
;  readcol,'/Users/jkrick/irac_warm/pcrs_planets/55cnc/bcdlist.txt',fitsname, format = 'A', /silent
  
;  bigim = fltarr(32, 32, n_elements(fitsname)*64)
;  c = 0L
  
;  for i =0.D,  n_elements(fitsname) - 1 do begin 

;     fits_read, fitsname(i), data, header
     
;     if i eq 0 then sclk_0 = sxpar(header, 'SCLK_OBS')

;     for j = 0, 63  do begin
;        bigim(0,0,c) = data[*,*,j]
;        ;print, 'c, j, data,bigim', c, j, data[15, 15, j], bigim[15,15,c]
;        c = c + 1
;     endfor

;  endfor
  
;save, /all, filename = '/Users/jkrick/irac_warm/pcrs_planets/55cnc/r39524608/bigim.sav'

;------------------------------------------------

restore, '/Users/jkrick/irac_warm/pcrs_planets/55cnc/r39524608/rmsim.sav'


For xpix = 0,31 do begin
  
   for ypix = 0,31 do begin

      if (xpix gt 12 and xpix lt 18 and ypix gt 12 and ypix lt 18) then plotcolor = 'red' else plotcolor = 'black'
      if (xpix eq 0 and ypix eq 0) then begin
;         p = plot(xhist, yhist, '1-', xtitle = 'RMS', ytitle = 'Number', color = plotcolor)
         p = plot(findgen(n_elements(rmsarr)), rmsarr, '1-', color = plotcolor, xtitle = 'time (10 min bins)', ytitle = 'RMS')
      endif else begin
;         p = plot(xhist, yhist, '1-', /overplot, color = plotcolor)
         p = plot(findgen(n_elements(rmsarr)), rmsarr, '1-', color = plotcolor,/overplot)
      endelse
      

   endfor                       ;for each ypix
endfor                          ; for each xpix

end
