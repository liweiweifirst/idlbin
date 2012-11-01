pro plot_hd158460_snap_fit
   colorarr = [  'SILVER'   , 'SKY_BLUE'  , 'SLATE_BLUE' , 'SLATE_GREY' , ' red',  'PLUM' ,  'SPRING_GREEN'  ,  'STEEL_BLUE'   ,  'green', 'TEAL' ,  'blue' ,  'TOMATO'  ,  'TURQUOISE' ,  'VIOLET'  , 'YELLOW'  ,  'YELLOW_GREEN', 'PAPAYA_WHIP'  ,' PEACH_PUFF','   PERU',   ' POWDER_BLUE' ]
 
;!P.MULTI = [0, 1, 2]

  restore, '/Users/jkrick/irac_warm/snapshots/snapshots_corr.sav'
  ;remove those with no pmap coverage
  aorname = ['r44497152','r44497664','r44497920','r44498176','r44498432','r44498688','r44498944','r44499200','r44499456','r44500224','r44500480','r44500736', 'r44500992', 'r44501248', 'r44501504' ]

  ;do some normalization
  for a = 0, n_elements(aorname) - 1 do begin
     print, 'a normalization', aorname(a), snapshots[a].corrflux(1), mean(snapshots[a].corrflux)
     snapshots[a].flux = snapshots[a].flux / snapshots[a].flux(1)
     snapshots[a].fluxerr = snapshots[a].fluxerr / snapshots[a].flux(1)
     snapshots[a].corrflux = snapshots[a].corrflux / snapshots[a].corrflux(1)
     snapshots[a].corrfluxerr = snapshots[a].corrfluxerr / snapshots[a].corrflux(1)
  endfor
  
;first step, put all the snapshot observations togehter as though they were one time sequence
;use the corrected fluxes
  combinedfluxarr = fltarr(n_elements(aorname) * n_elements(snapshots[0].flux))
  combinedfluxerrarr = fltarr(n_elements(aorname) * n_elements(snapshots[0].flux))
  xarr = fltarr(n_elements(aorname) * n_elements(snapshots[0].flux))
  yarr = fltarr(n_elements(aorname) * n_elements(snapshots[0].flux))
  timearr = fltarr(n_elements(aorname) * n_elements(snapshots[0].flux))
print, 'starting', n_elements(xarr)
for a = 0, n_elements(aorname) - 1 do begin
;     if a eq 0 then begin
        combinedfluxarr[a*n_elements(snapshots[0].flux) : ((a + 1)*n_elements(snapshots[0].flux))- 1] = snapshots[a].corrflux
        combinedfluxerrarr[a*n_elements(snapshots[0].flux) : ((a + 1)*n_elements(snapshots[0].flux))- 1] = snapshots[a].corrfluxerr
        xarr[a*n_elements(snapshots[0].flux) : ((a + 1)*n_elements(snapshots[0].flux))- 1] = snapshots[a].xcen
        yarr[a*n_elements(snapshots[0].flux) : ((a + 1)*n_elements(snapshots[0].flux))- 1] = snapshots[a].ycen
        timearr[a*n_elements(snapshots[0].flux) : ((a + 1)*n_elements(snapshots[0].flux))- 1] = snapshots[a].timearr
 ;   endif

;     if a gt 0 then begin
 ;       combinedfluxarr = [combinedfluxarr,snapshots[a].corrflux]
 ;       combinedfluxerrarr = [combinedfluxerrarr,snapshots[a].corrfluxerr]
 ;       xarr = [xarr, snapshots[a].xcen]
 ;       xarr = [yarr, snapshots[a].ycen]
 ;       timearr = [timearr, max(timearr) + 1.11E-4 + snapshots[a].timearr]  ;because first element is 0
;     endif
     print, 'n xcen', n_elements(snapshots[a].xcen), n_elements(xarr)
  endfor
;-------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------
;now add in the fake sin curve
;-------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------

;get rid of outliers in the pointing
  print, 'n xarr', n_elements(xarr)
  good = where(xarr gt 14.95 and xarr lt 15.35 and yarr gt 14.825 and yarr lt 15.2,ngood, complement = bad )
  print, 'bad x', xarr[bad]
;  print, 'bad y', yarr[bad]
  print, 'n good', n_elements(good)
  print, 'n bad', n_elements(bad)
 ; xarr = xarr[good]
 ; yarr = yarr[good]
 ; timearr = timearr[good]
 ; combinedfluxerrarr = combinedfluxerrarr[good]
 ; combinedfluxarr = combinedfluxarr[good]
 ; print, 'n_toimear', n_elements(timearr)

  x = timearr
  y = combinedfluxarr
  yerr = combinedfluxerrarr

;the sin curve
  amplitude =  0.01; 0.0006
  period = 1.0
  phase = 2.4
  y_sin = amplitude*sin(x/period + phase ) 
  noise = randomn(seed, n_elements(x), /Double)
  yerr_sin= (noise- mean(noise))/stddev(noise)*0.0002 + 0.0002
  
  y_sum = y + y_sin
  yerr_sum = sqrt( yerr^2 + yerr_sin^2)
  
;the plots!
  p1 = errorplot(x, y, yerr, '+2',  xtitle = 'Time (hours)', ytitle = 'Flux ', yrange = [0.92, 1.04], xrange = [0,9]) ;, errorbar_capsize = .001)
  p3 = errorplot(x, y_sum,yerr_sum, '+b2',/overplot)

;can I recover the sin curve? Maybe?
;don't need to fit for all the other stuff
; Initial guess	

  start = [amplitude, 1., period,phase]
  ;limit the range of the sin cuve phase
  parinfo = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0.D]}, n_elements(start))
  parinfo[3].limited[0] = 1 
  ; parinfo[3].limited[1] = 1
  parinfo[3].limits[0] = 0.0D
 ; parinfo[3].limits[1] = 2.*!pi

  pa= MPFITFUN('sin_func',x,y_sum, yerr_sum, start,PARINFO =parinfo , PERROR=spa, BESTNORM=achi, DOF=adof, COVAR = COV, status = status, errmsg = errmsg) 
  p4 = plot( x, pa(0)*sin(x/pa(2) + pa(3)) + pa(1),  '6r1.',/overplot)
  
  print, 'status', status
  print, errmsg
  achi = achi / adof
  print, 'reduced chi squared', achi
  print, 'input amplitude, period, phase', amplitude, period*2.*!pi, phase/(2.*!pi)
  print, 'fitted amplitude', pa[0], spa[0]
  print, 'fitted period (hours)', pa[2]*2.*!pi, spa[2]*2.*!pi
  print, 'fitted phase [0,1]', pa[3]/(2.*!pi), spa[3]/(2.*!pi)
  
 ;plot residuals
  sub = y_sum - ( pa(0)*sin(x/pa(2) + pa(3)) + pa(1))
  f2 = plot(timearr, sub+0.95, '6g1.',/overplot)


;fit residuals to know what the errors look like.
  plothist, sub, xhist, yhist,bin=0.0010, /noprint,/noplot
  r0 = barplot(xhist, yhist, fill_color = 'green', xrange = [-0.05, 0.05], xtitle = 'Residuals', ytitle = 'Number')

  noise = fltarr(n_elements(yhist)) + 1.0;  
  by = where(yhist lt 100.)
  noise(by) = 100.
  start = [0.0001, 0.01, 10000.]
  result= MPFITFUN('mygauss',xhist,yhist, noise, start) 
  r1 = plot( xhist, result(2)/sqrt(2.*!Pi) * exp(-0.5*((xhist - result(0))/result(1))^2.),  '3',/overplot)
  
  t_sig = text(0.02, 2000, string(result(1)),'3',/data)

;-------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------
;the plotting
;-------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------

z = pp_multiplot(multi_layout=[n_elements(aorname), 1], global_xtitle='X (pixels)',global_ytitle='Y (pixels)')

  ;have to plot each row one at a time
  for a = 0,  n_elements(aorname) - 1 do begin
     xy=z.plot(snapshots[a].xcen, snapshots[a].ycen, '6r1.',color = 'black', thick = 2, xminor = 0, xtickinterval = 0.5)
     xy.yrange = [14.5, 15.5]
     xy.xrange = [14.5, 15.5]
  endfor
 
 o = pp_multiplot(multi_layout=[n_elements(aorname),1],global_xtitle='Time (hours)',global_ytitle='Flux (Mjy/sr)')

  for a = 0,  n_elements(aorname) - 1 do begin
     st = o.errorplot(snapshots[a].timearr, snapshots[a].flux,snapshots[a].fluxerr,  color = colorarr[a], xminor = 0, xtickinterval = 0.5, multi_index = a) ;
     st.yrange = [0.97,1.02]
      st.xrange = [0,0.6]
    sto = o.errorplot(snapshots[a].timearr, snapshots[a].corrflux- 0.02, snapshots[a].corrfluxerr, multi_index = a)
     sto.yrange = [0.97,1.02]
     sto.xrange = [0,0.6]
   ;  st.xminor = 0
  endfor
 
;  plotname.xrange = [14.5, 15.5]
;  print, 'xranges', m.xranges

;  m.sync_axes, 9
;  print, 'xranges after sync', m.xranges

;another plot
  for a = 0, n_elements(aorname) - 1 do begin
     if a eq 0 then begin
        an = plot(snapshots[a].xcen, snapshots[a].ycen, '6r1.', thick = 2, xrange = [14.5, 15.5], yrange = [14.5, 15.5], xtitle = 'X (pixel)', ytitle = 'Y (pixel)', color = colorarr[a], aspect_ratio = 1)
     endif

     if a gt 0 then begin
        an = plot(snapshots[a].xcen, snapshots[a].ycen, '6r1.', thick = 2, color = colorarr[a],/overplot)
     endif
  endfor

  xsweet = 15.120
  ysweet = 15.085  
  box_x = [xsweet-0.1, xsweet-0.1, xsweet + 0.1, xsweet + 0.1, xsweet -0.1]
  box_y = [ysweet-0.1, ysweet +0.1, ysweet +0.1, ysweet - 0.1,ysweet -0.1]
 ; line4 = polyline(box_x, box_y, thick = 2, color = !color.black,/data)
 
end
