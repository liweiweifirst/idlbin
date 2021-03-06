pro latent
  ;look at the latent tests in pc2
                                ;ps_start,filename='/Users/jkrick/iwic/latent_repeatability.ps'
  !P.multi =[0,0,1]
  !P.charthick = 1
  !P.thick = 3
  !X.thick = 3
  !Y.thick = 3

  redcolor = FSC_COLOR("Red", !D.Table_Size-2)
  bluecolor = FSC_COLOR("Blue", !D.Table_Size-3)
  greencolor = FSC_COLOR("Green", !D.Table_Size-4)
 
;read in the flats for later
;  fits_read, '/Users/jkrick/Irac_pc/pc2/IRAC022300/irac_b1_fa_superskyflat_070709.fits', ch1flat, ch1flathead
;  fits_read, '/Users/jkrick/irac_pc/pc2/IRAC022300/irac_b2_fa_superskyflat_070709.fits', ch2flat, ch2flathead

  dir_name = ['/Users/jkrick/iracdata/jkrick/IRAC022400/bcd/0037862400']
 
  CD,dir_name
     
  command1 =  ' ls IRAC.1*bcd_fp.fits >  bcd_ch1.txt'
  command2 = ' ls IRAC.2*bcd_fp.fits >  bcd_ch2.txt'
  ;command3 = 'cat bcd_list.txt | grep IRAC.2. | grep -v IRAC.1 > bcd_ch2.txt'
     
  commands = [command1, command2];, command3]
  for i = 0, n_elements(commands) -1 do spawn, commands(i)

;  print, 'test', strcompress(dir_name + '/bcd_ch1.txt', /remove_all)

  readcol,strcompress(dir_name + '/bcd_ch1.txt', /remove_all), bcdch1list, format='A', /silent;, skipline = 2
  readcol,strcompress(dir_name + '/bcd_ch2.txt', /remove_all), bcdch2list, format='A', /silent;, skipline = 2 ;skip the .6s and 12s frames
 
  xcen = 87.5 - 1
  ycen = 92.2 - 1

  bcdlist = bcdch1list  ;can only look at ch1 because ch2 has overlapping latents

  ;only want certain images not contaminated by the bright star
  ;a = [4,6,7,9,11,13,15]
  ;bcdlist = bcdlist(a)
  
  flux1arr_12 =fltarr(n_elements(bcdlist))
  flux2arr_12 =fltarr(n_elements(bcdlist))
  time_12 = dblarr(n_elements(bcdlist))
  count_12 = 0
  
  for i = 319, n_elements(bcdlist) - 1 , 2 do begin
     fits_read, bcdlist(i), data, imheader
     print,  bcdlist(i)

     ;make the background positive
     ;data = data * ch1flat
     ;data = data + 0.9   ;empirical
     ;data = data / ch1flat

     ;get rid of NaN's
     data[where(finite(data) lt 1)] = 0
   
      ;do aperture photometry on star position 
     object = data[xcen-2:xcen+2,ycen-2:ycen+2]
     nobject = n_elements(object)
     sky = total(data[xcen-23:xcen+23, ycen-23:ycen+23])- total(data[xcen-15:xcen+15,ycen-15:ycen+15])  
     nannulus = n_elements(data[xcen-23:xcen+23, ycen-23:ycen+23]) - n_elements(data[xcen-15:xcen+15,ycen-15:ycen+15])    
     sky = sky / nannulus       ;mean sky flux
     mmm, data[170:255, 30:120], skymode, sigma, skw
     flux1 =  total( object)  - skymode*nobject

     ;keep track of time of observation
     time = double(0)
     time= fxpar(imheader, 'SCLK_OBS')
 ;    print, 'working on image', bcdlist(i), time - 935627616.156

     flux1arr_12(count_12) = flux1
     time_12(count_12) = time
     count_12 = count_12+ 1
     
     print, flux1
  endfor

  flux1arr_12 = flux1arr_12[0:count_12 - 1]
  time_12 = time_12[0:count_12 - 1]

;  print, 'time', time_12(0) + 0.1

 print, 'flux1arr_12', flux1arr_12
 print, 'time_12', (time_12 - time_12(0))/3600.

        ;plot
;plot, (time_12 - time_12(0))/3600., flux1arr_12, psym = 2,$ 
;      xtitle = 'hours', ytitle = 'Flux (counts in 12s)', title = 'hd166780 Kmag = 4.0',   $
;      color = colorname, xrange=[.01,2.0], yrange= [0.1,1200],/ylog,/xlog

time = (time_12 - time_12(0))/3600.;[0:n_elements(ch1_x) - 2];(a)
;flux = ch1_y[2:*]
flux =  flux1arr_12;[0:n_elements(ch1_y) - 2];(a)

plot, 1/flux, time, psym = 2, /xlog, xrange=[.0001,100],$;,/ylog, yrange =[0.001,100]
       xtitle = '1/flux', ytitle = 'time (hrs)'

;plot,  time, flux, /ylog,psym = 2;, /xlog,/ylog, yrange =[0.01,100], xrange=[.0001,100],$
;       xtitle = '1/flux', ytitle = 'time (hrs)'
 
start = [1,-1]
noise = fltarr(n_elements(flux))
noise[*] = 1                                                ;equally weight the values
result= MPFITFUN('exponential',1/flux,time, noise, start,/quiet)   ;./quiet    
  
xarr = findgen(10000)/100
oplot, xarr, result(0)*exp(-(xarr)/(result(1)))
oplot, xarr, .078825*exp(-(xarr)/(-1.13909)), linestyle = 1
 
;so at what time does the latent equal background
print, 'time at flux = 0.1', result(0)*exp(-(1/0.1)/(result(1)))

 ; ps_close, /noprint,/noid
;  ps_end,/png

;save, filename = '/Users/jkrick/iwic/latent_vs78.sav', time, flux
end

