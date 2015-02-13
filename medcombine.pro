pro medcombine

;quick code to median combine a stack of images

cd, '/Users/jkrick/Downloads/aorkey-45957376-1-selected_AORs/r45957376/ch2/bcd/'
command  = strcompress( 'ls SPITZER*_bcd.fits > bcdlist.txt')
spawn, command
readcol,'bcdlist.txt',fitsname, format = 'A', /silent

;bigim = fltarr(32, 32, 128, n_elements(fitsname))  
bigim = fltarr(256,256, n_elements(fitsname))  
for i = 0, n_elements(fitsname) - 1 do begin
;   print, i, fitsname(i)
   fits_read, fitsname(i), data, header
;   bigim(0, 0, 0, i) = data
   bigim(0, 0, i) = data
endfor
 

;medcombine = median(bigim, dimension = 4)
medcombine = median(bigim, dimension = 3)
help, bigim
fits_write, '/Users/jkrick/Downloads/aorkey-45957376-1-selected_AORs/r45957376/ch2/medcombine.fits', medcombine, header

end
