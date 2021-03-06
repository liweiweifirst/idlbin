pro cluster

restore, '/Users/jkrick/idlbin/objectnew.sav'
!p.multi = [0, 1,2]
!P.charthick = 1
redcolor = FSC_COLOR("Red", !D.Table_Size-2)
bluecolor = FSC_COLOR("Blue", !D.Table_Size-3)
greencolor = FSC_COLOR("Green", !D.Table_Size-4)
yellowcolor = FSC_COLOR("Yellow", !D.Table_Size-5)
cyancolor = FSC_COLOR("cyan", !D.Table_Size-6)
orangecolor = FSC_COLOR("orange", !D.Table_Size-7)
purplecolor = FSC_COLOR("purple", !D.Table_Size-8)

sep =0.017 ;(55")  0.0062; (720kpc)

memberarr = fltarr(50000)
totcount = 0.D
ck=0
a24 = fltarr(500)
;setup variable for the colors of all clusters
iall = fltarr(210000)
iracall = fltarr(210000)
mips24all = fltarr(210000)
  j = 0l
iallz = fltarr(210000)
iracallz = fltarr(210000)
m2 = 0l 
;I know that the photometry is bad for these objects and they end up with wrong,very red colors, so don't even let them into the sample
;this happens because they are not detections in irac, but are near a bright source, so they will get flux in the aperture as
;determined by the acs photometry.
badnum=[21735,21820,21854,22133,22169,22707,22761,23225]
objectnew[badnum].irac1mag = -99.0

m=-0.12
ball = 5.1
rcswidth = 0.5

;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
;look at all objects within sep
;-----------------------------------------------------------------------
;candidate clusters
canddec = [69.04481,  69.06851,  69.087766];,  68.98017,  69.019103 ]
candra = [264.68160, 264.89228, 264.83053];, , 264.66337, 265.27136 ]


openw, outlun23, '/Users/jkrick/nep/clusters/rcslt24.0.reg', /get_lun
printf, outlun23, 'fk5'
printf, outlun23, 'global color=red font="helvetica 10 normal" select=1 highlite=1 edit=1 move=1 delete=1 include=1 fixed=0 source'

for cand=0,1 do begin
;for cand=0, n_elements(canddec) - 1 do begin
   print, 'working on cluster', candra(cand), canddec(cand)
   
   ;objects within sep of  the center and detected in irac1
   good = where(sphdist(objectnew.ra, objectnew.dec, candra(cand), canddec(cand), /degrees) lt sep and objectnew.irac1mag gt 0 and objectnew.irac1mag lt 90 and objectnew.acsmag gt 0 and objectnew.acsmag lt 90); and objectnew.nearestdist gt 0.00055) ;and objectnew.nearestdist*60*60/0.6 gt 4.0 
   print, 'n_elements(good), cluster', n_elements(good)
   ;put the starting members in an array of all clusters
     for k = 0l, n_elements(good) - 1 do begin
        iall[j] = objectnew[good[k]].acsmag
        iracall[j] =objectnew[good[k]].irac1mag
        mips24all[j] = objectnew[good[k]].mips24flux
        j = j + 1
     endfor

     goodz = where(sphdist(objectnew.ra, objectnew.dec, candra(cand), canddec(cand), /degrees) lt sep and objectnew.irac1mag gt 0 and objectnew.irac1mag lt 90  and objectnew.zphot gt 0.8 and objectnew.zphot lt 1.1 and objectnew.prob gt 20) 
     for l = 0l, n_elements(goodz) - 1 do begin
        iallz[m2] = objectnew[goodz[l]].acsmag
        iracallz[m2] =objectnew[good[l]].irac1mag
        m2 =m2 + 1
     endfor

;-------------------------------------------------------------------
; individual redshift distributions
;---------------------------------------------------------------------

   plothist, objectnew[good].zphot, xhist, yhist, bin = 0.05, xrange=[0,1.5], /xstyle, thick = 3, xthick = 3, ythick = 3, $
             charthick = 3, xtitle='Redshift', ystyle =1, ytitle='Number'
;title=strcompress(string(candra(cand)) + string(canddec(cand)))  yrange=[0,10],

;what is the actual phot-z predicted redshift of the cluster?
;   print, 'xhist', xhist[15:27]
;   print, 'yhist', yhist[15:27]
   start = [1.0, 0.3, 50.0]
   err = fltarr(n_elements(xhist)) +1.0 
   result1= MPFITFUN('gauss',xhist[15:27],yhist[15:27], err, start,/quiet)   
   print, 'gaussian fit', result1

   oplot, xhist, result1(2)/sqrt(2.*!Pi) * exp(-0.5*((xhist - result1(0))/result1(1))^2.), linestyle = 2

   ;add the average distribution
;;   oplot, xhist, yhist, linestyle = 1,thick=3
;   oplot, xhist, yhist + 3*sqrt(yhist), linestyle = 2,thick=3
;   plothist, randz/nrand, xhist2, yhist2, bin = 0.05, /overplot


;-------------------------------------------------------------------
;cmd fitting section
;---------------------------------------------------------------------
;;   plot, objectnew[good].irac1mag, objectnew[good].acsmag - objectnew[good].irac1mag,psym = 2, yrange=[0,8], xtitle = 'acs', ytitle = 'acs - ch1', xrange=[15,25], thick = 3, xthick = 3, ythick = 3, charthick = 3, xstyle=1

;sort them in rmag space to only fit to the better data
   sortindex= sort(objectnew[good].irac1mag)
   irac1sort= objectnew[good].irac1mag[sortindex]
   rsort = objectnew[good].rmag[sortindex]
   acssort = objectnew[good].acsmag[sortindex]
   zsort = objectnew[good].zmagbest[sortindex]
   
   a = where(acssort - irac1sort gt 2.0 and acssort - irac1sort lt 4.0 )
;a = where(irac1sort lt 22)
;biweight fit (robust for non-gaussian distributions)
;coeff = ROBUST_LINEFIT( objectnew.rmag, objectnew.vr, yfit, sig, coeff_sig)
   if n_elements(a) gt 1 then begin
      coeff1 = ROBUST_LINEFIT(irac1sort(a),acssort(a) - irac1sort(a), yfit1, sig1, coeff_sig1)
      coeff2 = ROBUST_LINEFIT(irac1sort,rsort - irac1sort, yfit2, sig2, coeff_sig2)
      coeff3 = ROBUST_LINEFIT(irac1sort,zsort - irac1sort, yfit3, sig3, coeff_sig3)
      
;      print, "sig1, sig2", sig1,sig2,sig3
      err = dindgen(n_elements(good)) - dindgen(n_elements(good)) + 1
      start = [-0.02,2.0]
      startr = [-0.02, 4.0]
      sortindex= sort(objectnew[good].irac1mag)
      irac1sort= objectnew[good].irac1mag[sortindex]
      rsort = objectnew[good].rmag[sortindex]
      acssort = objectnew[good].acsmag[sortindex]
      zsort = objectnew[good].zmagbest[sortindex]
      yfit1sort = yfit1[sortindex]
      yfit2sort = yfit2[sortindex]
      yfit3sort = yfit3[sortindex]
      
   endif
   
   
;instead just pick a rcs by eye and with bc03 idea of where the color should be given the redshift
;want to fix the slope at -0.09 de lucia etal.
;can come back and fix this later
   xvals = findgen(22) +13
   m = -0.12
   b = fltarr(5)
   b = [4.9,4.5,4.5,4.5,5.2]
   
;;   oplot, xvals,  m*xvals + b(cand), thick = 3 , color = orangecolor
;;   oplot, xvals, m*xvals + b(cand) + rcswidth, thick = 3 , color = orangecolor
;;   oplot, xvals,  m*xvals + b(cand) - rcswidth, thick = 3 , color = orangecolor
;;   oplot, xvals,  m*xvals + ball, thick = 3 , color = orangecolor
;;   oplot, xvals, m*xvals + ball + rcswidth, thick = 3 , color = orangecolor
;;   oplot, xvals,  m*xvals + ball - rcswidth, thick = 3 , color = orangecolor


;---------------------------------------------------------------------
;determine which objects are 'members' of the RCS
;---------------------------------------------------------------------

 

   singlecount = 0
   singlememberarr = fltarr(n_elements(good))
   brightcountclus = 0
   dimcountclus = 0
   for count = 0.D, n_elements(good) - 1 do begin
      limithigh = (m*objectnew[good[count]].irac1mag) + ball +rcswidth; 2*sig1;0.5 
      limitlow = (m*objectnew[good[count]].irac1mag) + ball - rcswidth;2*sig1;0.5 
;      limithigh = (m*objectnew[good[count]].irac1mag) + b(cand) +rcswidth; 2*sig1;0.5 
;      limitlow = (m*objectnew[good[count]].irac1mag) + b(cand) - rcswidth;2*sig1;0.5 
      if (objectnew[good[count]].acsmag - objectnew[good[count]].irac1mag LT limithigh )AND ( objectnew[good[count]].acsmag - objectnew[good[count]].irac1mag GT limitlow) then begin
       ; add this member galaxy to a larger array of all member galaxies
         memberarr(totcount) = good[count]
         totcount = totcount + 1
         ;also want to know members of this cluster only
         singlememberarr(singlecount) =good[count]
         singlecount = singlecount  + 1
 ;       printf, outlunclus, 'circle( ', objectnew[good[count]].ra, objectnew[good[count]].dec, ' 3")'

     endif

;      if (objectnew[good[count]].acsmag - objectnew[good[count]].irac1mag LT limithigh ) $
;         AND ( objectnew[good[count]].acsmag - objectnew[good[count]].irac1mag GT limitlow) $
;         and objectnew[good[count]].irac1mag lt 24.6 and objectnew[good[count]].irac1mag gt 22.6 then begin
;         dimcountclus = dimcountclus + 1
         
;      endif

;      if (objectnew[good[count]].acsmag - objectnew[good[count]].irac1mag LT limithigh )AND ( objectnew[good[count]].acsmag - objectnew[good[count]].irac1mag GT limitlow) and objectnew[good[count]].irac1mag lt 22.6 and objectnew[good[count]].irac1mag gt 20.6 then brightcountclus = brightcountclus + 1


;remove the set of statements, reinstate those above

      if (objectnew[good[count]].acsmag - objectnew[good[count]].irac1mag LT limithigh )AND ( objectnew[good[count]].acsmag - objectnew[good[count]].irac1mag GT limitlow) and objectnew[good[count]].irac1mag lt 22.6 and objectnew[good[count]].rmag lt 24.0 then begin
         brightcountclus = brightcountclus + 1

         printf, outlun23, 'circle( ', objectnew[good[count]].ra, objectnew[good[count]].dec, ' 3")', objectnew[good[count]].rmag, objectnew[good[count]].irac1mag

      endif

      if (objectnew[good[count]].acsmag - objectnew[good[count]].irac1mag LT limithigh )AND ( objectnew[good[count]].acsmag - objectnew[good[count]].irac1mag GT limitlow) and objectnew[good[count]].irac1mag lt 22.6 and objectnew[good[count]].rmag lt 24.0 then dimcountclus = dimcountclus + 1

   endfor
   print, 'cluster', singlecount, brightcountclus, dimcountclus, totcount


;---------------------------------------------------------------------
;histograms of member galaxies
;---------------------------------------------------------------------
   singlememberarr = singlememberarr[0:singlecount - 1]
   print, 'number in rcs in cluster;  brighter than 22.1', n_elements(singlememberarr),  n_elements(singlememberarr(where (objectnew[singlememberarr].irac1mag lt 21.4)))

;;   plothist, objectnew[singlememberarr].irac1mag,  thick = 3, xthick = 3, ythick = 3, charthick = 3, $
;;             xtitle='irac1 mag', xrange=[15,25], xstyle = 9;, yrange=[0,12]
;;   axis, 0,12, xaxis=1,xrange=[-24.1,-16.1], xstyle=1, xthick=3, charthick=3

;   plothyperz, singlememberarr, '/Users/jkrick/nep/clusters/member.ps'

endfor 

close, outlun23
free_lun, outlun23



end


