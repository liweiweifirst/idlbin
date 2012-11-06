pro stack_images , planetname
;mean combine images into bins to make a movie as a function of time
  print, systime()
;run code to read in all the planet parameters
  planetinfo = create_planetinfo()
  chname = planetinfo[planetname, 'chname']
  ra_ref = planetinfo[planetname, 'ra']
  dec_ref = planetinfo[planetname, 'dec']
  aorname = planetinfo[planetname, 'aorname']
  basedir = planetinfo[planetname, 'basedir']
  
;---------------
  dirname = strcompress(basedir + planetname +'/')
  a = 0
  
  print, 'working on ',aorname(a)
  dir = dirname+ string(aorname(a) ) 
  CD, dir                       ; change directories to the correct AOR directory
  command  = strcompress( 'find ch'+chname+"/bcd -name '*_bcd.fits' > "+dirname+'bcdlist.txt')
  spawn, command
  command2 =  strcompress('find ch'+chname+"/bcd -name '*bunc.fits' > "+dirname + 'bunclist.txt')
  spawn, command2
  
  readcol,strcompress(dirname +'bcdlist.txt'),fitsname, format = 'A', /silent
  readcol,strcompress(dirname+'bunclist.txt'),buncname, format = 'A', /silent
  
  nfits = 1700L; n_elements(fitsname)
  stackimage = fltarr(32, 32, nfits*63)
  c = 0L
  for i =0.D,  nfits - 1 do begin      ;read each cbcd file, find centroid, keep track
                                ;print, 'working on ', fitsname(i)         
     header = headfits(fitsname(i)) ;
     
     fits_read, fitsname(i), im, h
     
     for j = 1 , 63 do begin    ;for each subarray frame
        slice = im[*,*,j]
;           print,'j,slice',  j, slice[10,10]
        stackimage(0,0,c) = slice
;           print, stackimage(10,10,c)
        c = c + 1
     endfor
     
     
  endfor                        ; for each fits file
  
  save, stackimage,filename = '/Users/jkrick/irac_warm/pcrs_planets/hd7924/stackimage.sav'
  print, 'testing lengths', c, nfits*63

  ;ok, make one big median image
;  medarr, stackimage, allmed
;  fits_write, '/Users/jkrick/irac_warm/pcrs_planets/hd7924/bin_stack.fits', allmed, xtension = 'IMAGE'
  
 ;generate median images from binned stackimage

  numberarr = findgen(nfits*63)
  bin_level = 2*63L
  h = histogram(numberarr, OMIN=om, binsize = bin_level, reverse_indices = ri)
  print, 'omin', om, 'nh', n_elements(h)
  bin_stack = dblarr(32,32,n_elements(h))

  ;open the fits file for writing the exgtensions as they get binned up
; fits_open, '/Users/jkrick/irac_warm/pcrs_planets/hd7924/bin_stack.fits', fcbo

  for j = 0L, n_elements(h) - 1 do begin

;get rid of the bins with no values and low numbers, meaning low overlap
     if (ri[j+1] gt ri[j] + 2)  then begin ;require 3 elements in the bin
       ; print, 'binning together', n_elements(numberarr[ri[ri[j]:ri[j+1]-1]])
        ;print, 'binning', numberarr[ri[ri[j]:ri[j+1]-1]]
        
        medarr, stackimage[*,*,ri[ri[j]:ri[j+1]-1]], medimage
        bin_stack(0,0,j) = medimage   

        ;write to a multi-extension fits file
 ;       fits_write, fcbo, medimage, extver = j + 1
        mwrfits, medimage, '/Users/jkrick/irac_warm/pcrs_planets/hd7924/bin_stack.fits'
     endif
  endfor
;  fits_close, fcbo
  save, bin_stack, filename =  '/Users/jkrick/irac_warm/pcrs_planets/hd7924/bin_stack.sav'
  
;  fits_write, '/Users/jkrick/irac_warm/pcrs_planets/hd7924/medimage.fits',medimage, h
  
                                ;attempt to display
;  im = image(medimage, image_dimensions = [32,32], margin = 0)
  
  print, 'ending', systime()
end



