pro superdark
  expname = ['s0p1s', 's2s']


  for e = 0, n_elements(expname) -1 do begin
;for now exptime can be 's0p1s' or 's2s'
     case expname(e) OF
        's0p1s': exptime = 0.1
        's2s': exptime = 2.0
     endcase
     
     dirname = '/Users/jkrick/irac_warm/darks/superdarks/'
     expdir = dirname + expname(e)
     cd, expdir
     command1 =  ' ls *skydark.fits >  darklist.txt'
     spawn, command1
     readcol,'darklist.txt',fitsname, format = 'A', /silent
     print, 'n darks', n_elements(fitsname)
     
     caldir = '/Users/jkrick/irac_warm/pcrs_planets/wasp-14b/calibration/'
     fits_read, strcompress(caldir + 'irac_b2_sa_superskyflat_100426.fits',/remove_all), flatdata, flatheader
                                ;need to make this [32,32,64]
     flat64 = fltarr(32,32,64)
     flatsingle = flatdata[*,*,0]
     for f = 0, 63 do flat64[*,*,f] = flatsingle
     
     
     fluxconv = .1469           ;MJY/sr / DN/s
     
     
;ugh 4 dimensions
     bigim = fltarr(32, 32, 128, n_elements(fitsname))
     count = 0
     
     for i =0, n_elements(fitsname) - 1 do begin ;
        header = headfits(fitsname(i))           ;
        ch = sxpar(header, 'CHNLNUM')
        framtime = sxpar(header, 'FRAMTIME')
        naxis = sxpar(header, 'NAXIS')
        
                                ;make sure I really pulled the correct darks
        if ch eq 2 and naxis eq 3 and framtime eq exptime then begin
           fits_read, fitsname(i), data, header
           bigim(0, 0, 0, count) = data
           count = count + 1
           if i eq n_elements(fitsname) - 1 then savedata = data
        endif
     endfor
     print, 'count', count
     if count ne n_elements(fitsname) then bigim= bigim[*,*,*,0:count-1]
     
;now make a median
     superdark = median(bigim, dimension = 4)
     fits_write, dirname+ 'superdark_'+expname(e)+'.fits', superdark, header ; just use the last header
     
;and next somehow compare to the individual darks.
;;darks are still in DN, so are quantized. => histograms won't help
     fluxarr = fltarr(64*count)
     c = 0
     for i = 0, n_elements(bigim[0,0,0,*]) - 1 do begin
                                ;divide superdark by individual darks
;   divim = superdark / bigim[*,*,*,i]
;   fits_write, strcompress(dirname+ 'divdark_'+expname(e)+'_'+ string(i) + '.fits',/remove_all), divim, header ; won't be the correct header
        
                                ;try getting rid of the flat and the zodi level
        subim =    bigim[*,*,*,i] - superdark
        subim = subim / flat64
 ;       subim = subim - mean(subim,/nan) ; get rid of the zodi (or any constant level in the image)
        subim = subim*fluxconv
        fits_write, strcompress(dirname+ 'subdark_'+expname(e)+'_'+ string(i) + '.fits',/remove_all), subim, header ; won't be the correct header
        
                                ;do aperture photometry at the center 
        for j = 0, 63 do begin
           aper, subim[*,*,j], 15.5, 15.5, flux, fluxerr, sky, skyerr, 1., 3., [3, 6],/nan, /exact,/flux,/silent
           fluxarr(c) = flux
           c = c + 1
        endfor
        
     endfor
     
;make a histogram of the empty fluxes
     plothist, fluxarr, xhist, yhist, /autobin,/noplot

     start = [0.0, 2.5, 1000]
     error = fltarr(n_elements(xhist)) + 0.1          ; uniform errors
     result= MPFITFUN('mygauss',xhist,yhist, error, start) ;ICL
;     h = plot(xhist, result(2)/sqrt(2.*!Pi) * exp(-0.5*((xhist - result(0))/result(1))^2.), thick = 2, color = 'green', /overplot)

     ;normalize
     yhist = yhist / float(n_elements(yhist))

     if e eq 0 then h = plot(xhist, yhist, xtitle = 'Empty Aperture Flux(MJy/sr)', ytitle = 'Number', title = 'Test Super Darks', color = 'blue', thick = 2, xrange = [-10, 10], name = '0.1s')
     if e ne 0 then h2 = plot(xhist, yhist, color = 'green',thick = 2,/overplot, name = '2s')

     
  endfor   ; for each expname
  l = legend(target = [h, h2], position = [9, 3.6], /data, /auto_text_color)

  end
  
