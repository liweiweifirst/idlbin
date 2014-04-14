pro plot_staring_darks

restore,  '/Users/jkrick/irac_warm/darks/staring/staring_darks.sav'
 aorname = ['/Users/jkrick/irac_warm/hd189733/r40152064/' ,'/Users/jkrick/irac_warm/hd189733/r40151040/'  , '/Users/jkrick/irac_warm/hd189733/r40150016/', '/Users/jkrick/irac_warm/hd189733/r40150528/', '/Users/jkrick/irac_warm/hd189733/r40151552/', '/Users/jkrick/irac_warm/HD209458/r44201728/', '/Users/jkrick/irac_warm/HD209458/r44201216/', '/Users/jkrick/irac_warm/HD209458/r44201472/', '/Users/jkrick/irac_warm/pcrs_planets/HD158460/r42051584/', '/Users/jkrick/irac_warm/pcrs_planets/HD158460/r42506496/']
 
colorarr= ['blue', 'red', 'purple', 'orange', 'gray','blue', 'red', 'purple', 'orange', 'gray']
;for reference 
;keys =['aorname','aorlabel', 'framtime', 'chname', 'fitsname', 'framenumber', 'subimagenum', 'mean_0', 'stddev_0','mean_1', 'stddev_1','mean_2', 'stddev_2','mean_3', 'stddev_3','framedelay']
startaor = 0
stopaor = 4;n_elements(aorname) - 1
 for a = startaor,  stopaor do begin

;want to look at the per amplifier output for just one framedelay
    
    f1 = where(biashash[aorname(a),'framedelay'] ge 1.5 and biashash[aorname(a),'framedelay'] lt 1.6, f1count)
    f2 = where(biashash[aorname(a),'framedelay'] ge 1.6 and biashash[aorname(a),'framedelay'] lt 1.7, f2count)
    f3 = where(biashash[aorname(a),'framedelay'] ge 1.7 and biashash[aorname(a),'framedelay'] lt 1.8, f3count)
    f4 = where(biashash[aorname(a),'framedelay'] ge 1.8 and biashash[aorname(a),'framedelay'] lt 1.9, f4count)
;    f5 = where(biashash[aorname(a),'framedelay'] ge 1.9 and biashash[aorname(a),'framedelay'] lt 2.0, f5count)
;    f6 = where(biashash[aorname(a),'framedelay'] ge 2.0 and biashash[aorname(a),'framedelay'] lt 2.1, f6count)

    print, 'counts, ', f1count/64, f2count/64, f3count/64, f4count/64;, f5count/64, f6count/64


    mean0_f1 = (biashash[aorname(a), 'mean_0'])(f1)
    mean0_f2 = (biashash[aorname(a), 'mean_0'])(f2)
    mean0_f3 = (biashash[aorname(a), 'mean_0'])(f3)
    mean0_f4 = (biashash[aorname(a), 'mean_0'])(f4)
;    mean0_f5 = (biashash[aorname(a), 'mean_0'])(f5)
;    mean0_f6 = (biashash[aorname(a), 'mean_0'])(f6)
    subimage_f1 = (biashash[aorname(a), 'subimagenum'])(f1)
    subimage_f2 = (biashash[aorname(a), 'subimagenum'])(f2)
    subimage_f3 = (biashash[aorname(a), 'subimagenum'])(f3)
    subimage_f4 = (biashash[aorname(a), 'subimagenum'])(f4)
;    subimage_f5 = (biashash[aorname(a), 'subimagenum'])(f5)
;    subimage_f6 = (biashash[aorname(a), 'subimagenum'])(f6)


    meansub = fltarr(64)
    ;mean within each AOR on subimagenumber.
    for si = 0, 63 do begin
       good = where(subimage_f1 eq si)
       meanclip, mean0_f1(good), mc, sc
       meansub(si) = mc
    endfor
    titlename = string(biashash[aorname(a),'aorkey'])+ ' ch' + biashash[aorname(a),'chname']+'  '+string(biashash[aorname(a),'framtime'])
    print, 'titlename', titlename
    ms = plot(subimage_f1, meansub, '1s', xtitle = 'Sub image Number', ytitle = 'Mean level in Frame (DN)', $
             title =titlename, sym_size = 0.3,   sym_filled = 1, xrange = [0,65], yrange = [11, 15])

    meansub = fltarr(64)
    ;mean within each AOR on subimagenumber.
    for si = 0, 63 do begin
       good = where(subimage_f2 eq si)
       meanclip, mean0_f2(good), mc, sc
       meansub(si) = mc
    endfor
   ms = plot(subimage_f2, meansub, '1s', sym_size = 0.3, sym_filled = 1, color = 'blue',/overplot)

    meansub = fltarr(64)
    ;mean within each AOR on subimagenumber.
    for si = 0, 63 do begin
       good = where(subimage_f3 eq si)
       meanclip, mean0_f3(good), mc, sc
       meansub(si) = mc
    endfor
    ms = plot(subimage_f3, meansub, '1s', sym_size = 0.3, sym_filled = 1, color = 'slate grey',/overplot)

    meansub = fltarr(64)
    ;mean within each AOR on subimagenumber.
    for si = 0, 63 do begin
       good = where(subimage_f4 eq si)
       meanclip, mean0_f4(good), mc, sc
       meansub(si) = mc
    endfor
    ms = plot(subimage_f4, meansub, '1s', sym_size = 0.3, sym_filled = 1, color = 'red',/overplot)
;    ms = plot(subimage_f5, mean0_f5, '1s', sym_size = 0.3, sym_filled = 1, color = 'light grey',/overplot)
;    ms = plot(subimage_f6, mean0_f6, '1s', sym_size = 0.3, sym_filled = 1, color = 'light cyan',/overplot)
    t = text(10, 11.2, 'framedly 1.5 - 1.6', color = 'black',/overplot,/data)
        t = text(10, 11.4, 'framedly 1.6 - 1.7', color = 'blue',/overplot,/data)
    t = text(10, 11.6, 'framedly 1.7 - 1.8', color = 'slate grey',/overplot,/data)
    t = text(10, 11.8, 'framedly 1.8 - 1.9', color = 'red',/overplot,/data)

    saven = strcompress('framedelay' + string(biashash[aorname(a),'aorkey'])+ ' ch' + biashash[aorname(a),'chname']+'  '+string(biashash[aorname(a),'framtime']) + '.png',/remove_all)
    ms.save, saven


;--------------------------------------------------------
     ;plot whole time range for each amplifier
    f = where(biashash[aorname(a),'framedelay'] eq 1.85)
    meanarr_0 = (biashash[aorname(a), 'mean_0'])(f)
    subimage = (biashash[aorname(a), 'subimagenum'])(f)

    meansub = fltarr(64)
    ;mean within each AOR on subimagenumber.
    for si = 0, 63 do begin
       good = where(subimage eq si)
       meanclip, meanarr_0(good), mc, sc
       meansub(si) = mc
    endfor

                                ;remove outliers from the y range
     meansort = meansub(sort(meansub))
     ns= .001*n_elements(meansort)
     clipsort = meansort[ns:n_elements(meansort) - ns]
     myrange = [min(clipsort), max(clipsort)]


;    if a eq startaor then  p = plot(subimage, meansub, '1s', xtitle = 'Sub image Number', ytitle = 'Mean level in Frame (DN)', $
 ;              title = ' ch' + biashash[aorname(a),'chname']+'  '+string(biashash[aorname(a),'framtime']), sym_size = 0.3,   sym_filled = 1, xrange = [0,65], yrange = m;yrange)
 ;   if a gt startaor then p = plot(subimage, meansub, '1s', sym_size = 0.3,   sym_filled = 1,color = colorarr(a),/overplot)
;     p1= plot(framnumber, meanarr_1, '1s', sym_size = 0.1,   sym_filled = 1, color = 'gray',/overplot)
;     p2= plot(framnumber, meanarr_2, '1s', sym_size = 0.1,   sym_filled = 1, color = 'dark slate grey',/overplot)
;     p3= plot(framnumber, meanarr_3 ,'1s', sym_size = 0.1,   sym_filled = 1, color = 'light cyan',/overplot)
;     t1 = text(2E4, 170, aorlabel)

;================================================
endfor


end
