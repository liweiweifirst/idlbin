pro read_staring_dark
  
;what is the mean level as a function of frame number and amplifier and frame delay

;  aorname = 'r40151040'        ; this one has a dark change in the middle of it.
  
  aorname = ['/Users/jkrick/irac_warm/hd189733/r40152064/' ,'/Users/jkrick/irac_warm/hd189733/r40151040/'  , '/Users/jkrick/irac_warm/hd189733/r40150016/', '/Users/jkrick/irac_warm/hd189733/r40150528/', '/Users/jkrick/irac_warm/hd189733/r40151552/', '/Users/jkrick/irac_warm/HD209458/r44201728/', '/Users/jkrick/irac_warm/HD209458/r44201216/', '/Users/jkrick/irac_warm/HD209458/r44201472/', '/Users/jkrick/irac_warm/pcrs_planets/HD158460/r42051584/', '/Users/jkrick/irac_warm/pcrs_planets/HD158460/r42506496/']
  
  chname =[  '2',  '2', '2', '2', '2', '1',  '1', '1', '1', '1']
  
  a = findgen(32)
  b = a mod 4
  amp0 = where(b eq 0)
  amp1 = where(b eq 1)
  amp2 = where(b eq 2)
  amp3 = where(b eq 3)
  
                                ;for each aor I need to carry around
 ; fitsname, framenumber(0: n_elements(fitsname)), imagenum[0:63,0:63,...)], mean & stddev in each amplifier[0:63], framedelay[0:n_elements(fitsname)]
  biashash = hash()
 
  for a = 0, n_elements(aorname) - 1 do begin
     print, 'working on aor', aorname(a)
     skyflatname = strcompress( aorname(a) + 'ch' + chname(a) + '/cal/*superskyflat*.fits',/remove_all)
     print, 'skyflatname', skyflatname
     fits_read, skyflatname, flatdata, flatheader
                                ;need to make this [32,32,64]
     flat64 = fltarr(32,32,64)
     flatsingle = flatdata[*,*,0]
     for f = 0, 63 do flat64[*,*,f] = flatsingle
     
    
     CD, aorname(a)             ; change directories to the correct AOR directory
     command  = strcompress( 'find ch'+chname(a)+"/bcd -name 'SPITZER*_bcd.fits' > "+aorname(a)+'bcdlist.txt')
     spawn, command
     readcol,strcompress(aorname(a) +'bcdlist.txt'),fitsname, format = 'A', /silent
     
     ;arrays over all subframes in the AOR
     meanarr_0 = fltarr(n_elements(fitsname)*64)
     meanarr_1 = meanarr_0
     meanarr_2 = meanarr_0
     meanarr_3 = meanarr_0
     stddevarr_0 = meanarr_0
     stddevarr_1 = meanarr_1
     stddevarr_2 = meanarr_2
     stddevarr_3 = meanarr_3
     framedelayarr = meanarr_0
     subimagenum = meanarr_0
     ;want this to run from 0 to 63 for n_elements(fitsname)
     for si = 0, n_elements(fitsname)*63, 64 do subimagenum(si) = findgen(64)
    
     c = 0L
     
     for i = 0,  n_elements(fitsname) - 1 do begin
        fits_read, fitsname(i), data, header
        
                                ;back out the flux conversion
        fluxconv = sxpar(header, 'FLUXCONV')
        data = data / fluxconv
        
                                ; flip the image
        data = reverse(data, 2)
        
                                ;remove the flat
        data = data * flat64
        
                                ;remove the dark that was already used in the image
        darkname = sxpar(header, 'SKDKRKEY')
        darkepid = sxpar(header, 'SDRKEPID')
        framedelay = sxpar(header, 'FRAMEDLY')
        aorkey = sxpar(header, 'AORKEY')

        fits_read, strcompress(aorname(a) + 'ch' + chname(a)+'/cal/SPITZER_I'+chname(a)+'_'+string(darkname)+ '_0000_*_C'+string(darkepid)+'_sdark.fits',/remove_all), darkdata, darkheader
        data = data + darkdata
        
        for j = 0, 63 do begin
           meanclip, data[amp0,*,j], m0, sm0
           meanarr_0(c) = m0
           stddevarr_0(c) = sm0
           meanclip, data[amp1,*,j], m1, sm1
           meanarr_1(c) = m1
           stddevarr_1(c) = sm1
           meanclip, data[amp2,*,j], m2, sm2
           meanarr_2(c) = m2
           stddevarr_2(c) = sm2
           meanclip, data[amp3,*,j], m3, sm3
           meanarr_3(c) = m3
           stddevarr_3(c) = sm3
           
           framedelayarr(c) = framedelay;keep track of  delaytime for later use
           c = c + 1
        endfor
                                

     endfor ; for each fitsname
;  print, 'n', n_elements(fitsname), n_elements(fitsname)*64, c - 1
     framnumber = findgen(n_elements(meanarr_0))
     framtime = sxpar(header, 'FRAMTIME')
     aorlabel = sxpar(header, 'AORLABEL')
     
                                ;remove outliers from the y range
     meansort = meanarr_0(sort(meanarr_0))
     ns= .001*n_elements(meansort)
     clipsort = meansort[ns:n_elements(meansort) - ns]
     myrange = [min(clipsort), max(clipsort)]
     
     ;plot whole time range for each amplifier
     p = plot(framnumber, meanarr_0, '1s', xtitle = 'Frame Number', ytitle = 'Mean level in Frame (DN)', $
              title = aorlabel+ ' ch' + chname(a)+'  '+string(framtime), $
              sym_size = 0.1,   sym_filled = 1, yrange = myrange)
     p1= plot(framnumber, meanarr_1, '1s', sym_size = 0.1,   sym_filled = 1, color = 'gray',/overplot)
     p2= plot(framnumber, meanarr_2, '1s', sym_size = 0.1,   sym_filled = 1, color = 'dark slate grey',/overplot)
     p3= plot(framnumber, meanarr_3 ,'1s', sym_size = 0.1,   sym_filled = 1, color = 'light cyan',/overplot)
     t1 = text(2E4, 170, aorlabel)

     plotsavename = strcompress('/Users/jkrick/irac_warm/darks/staring/r'+string(aorkey)+ '_ch'+chname(a) +'_'+string(framtime)+'.png',/remove_all)
     p.save, plotsavename
  
     keys =['aorname','aorlabel','aorkey', 'framtime', 'chname', 'fitsname', 'framenumber', 'subimagenum', 'mean_0', 'stddev_0','mean_1', 'stddev_1','mean_2', 'stddev_2','mean_3', 'stddev_3','framedelay']
     values=list(aorname(a),aorlabel, aorkey, framtime,chname(a), fitsname, findgen(n_elements(fitsname)), subimagenum, meanarr_0, stddevarr_0, meanarr_1, stddevarr_1,meanarr_2, stddevarr_2,meanarr_3, stddevarr_3,framedelayarr)
     biashash[aorname(a)] = HASH(keys, values)

     
  endfor                        ; for each aorname
  
  save, biashash, filename='/Users/jkrick/irac_warm/darks/staring/staring_darks.sav'
end
