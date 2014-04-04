pro superdark, expname

;exptime can be 's0p1s' or 's2s'
  case expname OF
     's0p1s': exptime = 0.08
     's2s': exptime = 2.0
  endcase

  dirname = '/Users/jkrick/irac_warm/darks/superdarks/'
  expdir = dirname + expname
  cd, expdir
  command1 =  ' ls *skydark.fits >  darklist.txt'
  spawn, command1
  readcol,'darklist.txt',fitsname, format = 'A', /silent
  print, 'n darks', n_elements(fitsname)
  
;ugh 4 dimensions
  bigim = fltarr(32, 32, 128, n_elements(fitsname))
  count = 0

  for i =0, n_elements(fitsname) - 1 do begin ;read each cbcd file, find centroid, keep track
     header = headfits(fitsname(i))           ;
     ch = sxpar(header, 'CHNLNUM')
     framtime = sxpar(header, 'FRAMTIME')
     naxis = sxpar(header, 'NAXIS')

                                ;make sure I really pulled the correct darks
     if ch eq 2 and naxis eq 3 and framtime eq exptime then begin
        fits_read, fitsname(i), data, header
        bigim(0, 0, 0, count) = data
        count = count + 1
     endif
  endfor
  print, 'count', count
  if count ne n_elements(fitsname) then bigim= bigim[*,*,*,count]

;now make a median
  superdark = median(bigim, dimension = 4)
  fits_write, dirname+ 'superdark_'+expname+'.fits', superdark, header  ; just use the last header

;and next somehow compare to the individual darks.
;maybe divide and then "look" at the residuals.  maybe a histogram, if not gaussian , then not just straight noise?
; how do I decide if an image is smooth?

end
 
