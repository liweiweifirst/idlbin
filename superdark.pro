pro superdark
                                ;changing to read in individual dark
                                ;files to make one superdark for the
                                ;warm mission 
  expname = ['s0p1s', 's2s']
  chname = '2'

  for e = 0, 0 do begin         ; n_elements(expname) -1 do begin
;for now exptime can be 's0p1s' or 's2s'
     case expname(e) OF
        's0p1s': exptime_d = 0.1
        's2s': exptime_d = 2.0
     endcase
     
     
     
     dirname = '/Volumes/external/irac_warm/darks/superdarks/'
     expdir = dirname + expname(e)
     cd, expdir
     ntotdarks = 0
     if e eq 0 then aorname = ['r38712320','r38811136','r38814720','r38927872','r38931456','r39105792','r39109376','r39123456','r39127040','r39144192','r39147776','r39206144','r39209728','r39220480','r39224064','r39340288','r39343872','r39354112','r39357696','r39427328','r39430912','r39452672','r39456256','r39535360','r39538944','r39552768','r39556352','r40258048','r40261632','r40277760','r40281344','r40322048','r40325632','r41019392','r41022976','r41083648','r41087232','r41178624','r41180928','r41232384','r41235968','r41254144','r41257728','r41406464','r41410048','r41433856','r41437440','r41605120','r41608704','r41622784','r41626368','r41680128','r41683712','r41861632','r41865216','r41888000','r41891584','r41994752','r41998336','r42012672','r42016256','r42040320','r42043904','r42083584','r42087168','r42157312','r42159616','r42554368','r42559232','r42600704','r42604288','r42772480','r42776064','r43953920','r43957504','r43993600','r44152576','r44156160','r44235008','r44238592','r44375552','r44379136','r44396288','r44399872','r44421888','r44425472','r44484608','r44488192','r44617728','r44621312','r44920064','r45048320','r45052160','r45178368','r45181952','r45211904','r45215488','r45249792','r45253376','r45281024','r45284864','r45375744','r45379328','r45418496','r45422080','r45522944','r45526528','r45561600','r45565440','r45648896','r45652480','r45670912','r45682944','r45696256','r45699840','r45730816','r45734400','r45751552','r45755136','r45772032','r45775360','r45804800','r45808128','r45826816','r45830144','r45860096','r45863424','r45965824','r45969152','r46013696','r46017024','r46081024','r46084352','r46098432','r46102016','r46499584','r46503168','r46925568','r46929152','r47076352','r47079936','r47584256','r47587840','r47607552','r47611392','r48400896','r48404480','r48426240','r48429824','r48490240','r48493824','r48566272','r48569856','r48582400','r48593152','r48608512','r48619520','r48625920','r48637184','r48648448','r48659200','r48752384','r48763136','r48801280','r48812032','r48828160','r48839680','r48854528','r48866560','r48871680','r48882432','r48903680','r48920832','r48939776','r48953600','r48986880','r48997632','r49004544','r49015296','r49021696','r49036032','r49052928','r49063680','r49078528','r49089280','r49100544','r49111552','r49122304','r49133056','r49231616','r49241088','r49871360','r49882112','r50096384','r50107136','r50691584','r50702336','r50762752','r50773504','r50805504','r50816256','r50823680','r50834432','r50847232','r50857984','r50885888','r50896640','r50907136','r50918144','r50957824','r50976256','r50999808','r51010560','r51021312','r51032064','r51046912','r51057408','r51074048','r51084800','r51186944','r51197696','r51441408'] ;'r41930496','r41934080','r44660224',

;ugh 4 dimensions
     bigim = fltarr(32, 32, 128, n_elements(aorname)*18)  ; XXXmaking this number up for now
     count = 0
     testpix = fltarr( n_elements(aorname)*18)


     for a = 0, n_elements(aorname) - 1 do begin
;        print, 'working on ', aorname(a)
        cd, expdir
       ;make a superskyflat for each subframe
        skyflatname = strcompress( aorname(a) + '/ch'+ chname + '/cal/*superskyflat*.fits',/remove_all)
;        print, 'skyflatname', skyflatname
        fits_read, skyflatname, flatdata, flatheader
                                ;need to make this [32,32,64]
        flat64 = fltarr(32,32,64)
        flatsingle = flatdata[*,*,0]
        for f = 0, 63 do flat64[*,*,f] = flatsingle


        cd, strcompress(aorname(a) + '/ch'+chname + '/bcd',/remove_all)
        command1 = 'ls *bcd.fits > bcdlist.txt'
        spawn, command1
        readcol,'bcdlist.txt',fitsname, format = 'A', /silent
        ntotdarks = ntotdarks + n_elements(fitsname)
        
 
;-----------------------
        for i = 0,  n_elements(fitsname) - 1 do begin

                                ;make sure I really pulled the correct
                                ;darks
           header = headfits(fitsname(i)) ;
           ch = sxpar(header, 'CHNLNUM')
           framtime = sxpar(header, 'FRAMTIME')
           naxis = sxpar(header, 'NAXIS')
 ;          print, 'ch, naxis, exptime', ch, chname, naxis, framtime, exptime_d
           if chname eq ch and naxis eq 3 and framtime eq exptime_d then begin
              fits_read, fitsname(i), data, header
        
                                ;back out the flux conversion
              fluxconv = sxpar(header, 'FLUXCONV')
              exptime = sxpar(header, 'EXPTIME')
              data = data / fluxconv ; now in DN/s
              data = data* exptime   ; now in DN
                                ; flip the image
              data = reverse(data, 2)
        
                                ;remove the flat
              data = data * flat64
        
              darkname = sxpar(header, 'SKDKRKEY')
              darkepid = sxpar(header, 'SDRKEPID')
              framedelay = sxpar(header, 'FRAMEDLY')
              aorkey = sxpar(header, 'AORKEY')

                                ;remove the dark that was already used in the image
              fits_read, strcompress('../cal/SPITZER_I'+chname+'_'+string(darkname)+ '_0000_*_C'+string(darkepid)+'_sdark.fits',/remove_all), darkdata, darkheader
              data = data + darkdata

              ;and put it together with the others tomake the superdark
              bigim(0, 0, 0, count) = data
              testpix[count] = data[11,11]
              count = count + 1
           endif   ; if the correct darks

           endfor  ; for each fitsname
        endfor  ; for each AOR
     print, 'final count', count, n_elements(aorname) * 18, ntotdarks
     bigim= bigim[*,*,*,0:count-1]
     
     
;now make a median
     superdark = median(bigim, dimension = 4)
     fits_write, dirname+ 'superdark_'+expname(e)+'.fits', superdark, header ; just use the last header
     
     ;print, 'testpix', n_elements(testpix), testpix
     plothist, testpix, xhist, yhist, /noprint,/noplot
     ph = barplot(xhist, yhist,  xtitle = 'Single pixel value', ytitle = 'Number', fill_color = 'sky blue')
     ph = plot(intarr(300) + median(testpix), indgen(300), linestyle = 4, thick = 2, overplot = ph)

;and what would a meanclip look like.
     meanclip, testpix, meanout, sigmaout
     ph = plot(intarr(300) + meanout, indgen(300), linestyle = 1, thick = 2, overplot = ph)


;a plot of the difference between a mean and a median for all
;pixels
     superdark_mean = mean(bigim, dimension = 4,/double, /nan)

     delta = superdark - superdark_mean
     plothist, delta, xhist, yhist, bin = 0.05, /noprint, /noplot
     phd = barplot(xhist, yhist,  xtitle = 'Median - Mean', ytitle = 'Number', fill_color = 'orange', xrange = [-0.5, 0.5])

;------------------------------------------------
    
  endfor                        ; for each expname

end
  


;;and next somehow compare to the individual darks.
;;;darks are still in DN, so are quantized. => histograms won't help
;     fluxarr = fltarr(64*count)
;     c = 0
;     for i = 0, n_elements(bigim[0,0,0,*]) - 1 do begin
;                                ;divide superdark by individual darks
;;   divim = superdark / bigim[*,*,*,i]
;;   fits_write, strcompress(dirname+ 'divdark_'+expname(e)+'_'+ string(i) + '.fits',/remove_all), divim, header ; won't be the correct header
;        
;                                ;try getting rid of the flat and the zodi level
;        subim =    bigim[*,*,*,i] - superdark
;        subim = subim / flat64
; ;       subim = subim - mean(subim,/nan) ; get rid of the zodi (or any constant level in the image)
;        subim = subim*fluxconv
;        fits_write, strcompress(dirname+ 'subdark_'+expname(e)+'_'+ string(i) + '.fits',/remove_all), subim, header ; won't be the correct header
;        
;                                ;do aperture photometry at the center 
;        for j = 0, 63 do begin
;           aper, subim[*,*,j], 15.5, 15.5, flux, fluxerr, sky, skyerr, 1., 3., [3, 6],/nan, /exact,/flux,/silent
;           fluxarr(c) = flux
;           c = c + 1
;        endfor
;        
;     endfor
     
;;make a histogram of the empty fluxes
;     plothist, fluxarr, xhist, yhist, /autobin,/noplot;

;     start = [0.0, 2.5, 1000]
;     error = fltarr(n_elements(xhist)) + 0.1          ; uniform errors
;     result= MPFITFUN('mygauss',xhist,yhist, error, start) ;ICL
;;     h = plot(xhist, result(2)/sqrt(2.*!Pi) * exp(-0.5*((xhist - result(0))/result(1))^2.), thick = 2, color = 'green', /overplot)
;
;     ;normalize
;     yhist = yhist / float(n_elements(yhist));

;     if e eq 0 then h = plot(xhist, yhist, xtitle = 'Empty Aperture Flux(MJy/sr)', ytitle = 'Number', title = 'Test Super Darks', color = 'blue',; thick = 2, xrange = [-10, 10], name = '0.1s')
;     if e ne 0 then h2 = plot(xhist, yhist, color = 'green',thick = 2,/overplot, name = '2s')

;   l = legend(target = [h, h2], position = [9, 3.6], /data, /auto_text_color)


;aorname = [r38712320,r38811136,r38814720,r38927872,r38931456,r39105792,r39109376,r39123456,r39127040,r39144192,r39147776,r39206144,r39209728,r39220480,r39224064,r39340288,r39343872,r39354112,r39357696,r39427328,r39430912,r39452672,r39456256,r39535360,r39538944,r39552768,r39556352,r40258048,r40261632,r40277760,r40281344,r40322048,r40325632,r41019392,r41022976,r41083648,r41087232,r41178624,r41180928,r41232384,r41235968,r41254144,r41257728,r41406464,r41410048,r41433856,r41437440,r41605120,r41608704,r41622784,r41626368,r41680128,r41683712,r41861632,r41865216,r41888000,r41891584,r41930496,r41934080,r41994752,r41998336,r42012672,r42016256,r42040320,r42043904,r42083584,r42087168,r42157312,r42159616,r42554368,r42559232,r42600704,r42604288,r42772480,r42776064,r43953920,r43957504,r43993600,r44152576,r44156160,r44235008,r44238592,r44375552,r44379136,r44396288,r44399872,r44421888,r44425472,r44484608,r44488192,r44617728,r44621312,r44660224,r44920064,r45048320,r45052160,r45178368,r45181952,r45211904,r45215488,r45249792,r45253376,r45281024,r45284864,r45375744,r45379328,r45418496,r45422080,r45522944,r45526528,r45561600,r45565440,r45648896,r45652480,r45670912,r45682944,r45696256,r45699840,r45730816,r45734400,r45751552,r45755136,r45772032,r45775360,r45804800,r45808128,r45826816,r45830144,r45860096,r45863424,r45965824,r45969152,r46013696,r46017024,r46081024,r46084352,r46098432,r46102016,r46499584,r46503168,r46925568,r46929152,r47076352,r47079936,r47584256,r47587840,r47607552,r47611392,r48400896,r48404480,r48426240,r48429824,r48490240,r48493824,r48566272,r48569856,r48582400,r48593152,r48608512,r48619520,r48625920,r48637184,r48648448,r48659200,r48752384,r48763136,r48801280,r48812032,r48828160,r48839680,r48854528,r48866560,r48871680,r48882432,r48903680,r48920832,r48939776,r48953600,r48986880,r48997632,r49004544,r49015296,r49021696,r49036032,r49052928,r49063680,r49078528,r49089280,r49100544,r49111552,r49122304,r49133056,r49231616,r49241088,r49871360,r49882112,r50096384,r50107136,r50691584,r50702336,r50762752,r50773504,r50805504,r50816256,r50823680,r50834432,r50847232,r50857984,r50885888,r50896640,r50907136,r50918144,r50957824,r50976256,r50999808,r51010560,r51021312,r51032064,r51046912,r51057408,r51074048,r51084800,r51186944,r51197696,r51441408]
