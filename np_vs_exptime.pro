pro np_vs_exptime
;only ch2

;snaps and stares
;wasp14, 2s
;hatp8, 2s

;stares
;hat22 0.4s       indigo
;wasp16; 2s      red
;wasp15; 2s      red
;wasp13; 0.4s   indigo
;hd7924; 0.1s   blueyy
;55cnc; 0.02s    green
;wasp38; 0.4s    indigo
;wasp62;  2s        red
;wasp33; 0.4s    indigo
;hatp17  2s         red
;hatp26  2s         red
;hd189733 0.1   blue
;hd97658  0.1    blue

;just look at ch2 long stares for now (ignore starting 30-min pre-AOR
;want to plot noise pixel vs. exptime
  planetname =['hd97658', 'hd189733', 'hat22', 'wasp16', 'wasp15', 'wasp13', 'hd7924', '55cnc', 'wasp38','wasp62','wasp33','hatp17','hatp26'];  ; took hat22 and wasp7 and some hd189733 out

  colorarr = ['blue', 'blue','indigo','indigo', 'red', 'red', 'red', 'red','indigo', 'indigo','indigo', 'indigo','blue','blue','blue', 'green','indigo', 'indigo','red','indigo', 'indigo','indigo','red','red']
  
  planetinfo = create_planetinfo()
  
  fits_read, '/Users/jkrick/irac_warm/pmap/pmap_fits/pmap_ch1_500x500_0043_120409.fits', pmapdata, pmapheader
  c = contour(pmapdata, /fill, n_levels = 21, rgb_table = 0, xtitle = 'X (pixel)', ytitle = 'Y (pixel)', title = planetname, aspect_ratio = 1, xrange = [0,500], yrange = [0,500])


  meanarr = fltarr(n_elements(colorarr))
  stddevarr = fltarr(n_elements(colorarr))
  exptimearr = fltarr(n_elements(colorarr))

  count = 0
  for p = 0, n_elements(planetname)- 1 do begin
     aorname = planetinfo[planetname(p), 'aorname']
     basedir = planetinfo[planetname(p), 'basedir']
     exptime = planetinfo[planetname(p), 'exptime']
     chname = planetinfo[planetname(p), 'chname']
     dirname = strcompress(basedir + planetname(p) +'/')
     savefilename = strcompress(dirname + planetname(p) +'_phot_ch'+chname+'.sav')
     
     restore, savefilename
     
     for a = 0, n_elements(aorname) - 1 do begin
        nptest = planethash[aorname(a),'np'] 
        print, planetname(p), '  ', aorname(a)
        print,  n_elements(planethash[aorname(a),'np'] ), mean(planethash[aorname(a),'np'],/nan ), stddev(planethash[aorname(a),'np'],/nan )
        e = fltarr(n_elements(planethash[aorname(a),'np'] )) + exptime

        ;get the centers
        xcen500 = 500.* ((planethash[aorname(a),'xcen']) - 14.5)
        ycen500 = 500.* ((planethash[aorname(a),'ycen']) - 14.5)

        ;make the histogram
        ;plothist, planethash[aorname(a),'np'], xhist, yhist, bin = 0.1,/noplot
        meanarr[count] = mean(planethash[aorname(a),'np'] ,/nan)
        stddevarr[count] = stddev(planethash[aorname(a),'np'] ,/nan)
        exptimearr[count] = e(a)

        if p eq 0 and a eq 0 then begin  ; setup plot for the first AOR
           c = plot(xcen500, ycen500, '1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[count],/overplot)

           ;  ps= plot(e, (planethash[aorname(a),'np'] ), '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[p], $
           ;           xtitle = 'Exptime', ytitle = 'Noise Pixel', title = '17 AORs', xrange = [0,2.1], yrange = [2., 10.])
           ;ps = plot(xhist, yhist/ total(yhist), color= colorarr[count], yrange = [0,0.8], xrange = [3.9,6.0], thick = 2, xtitle = 'Noise Pixel', title = '14 AORs')
           
                                ;instead plot the means and standard deviations of the histograms
                                ;  ps = errorplot(e, meany, stddevy, color = colorarr[count],  sym_size = 0.2,   sym_filled = 1, title = '18 AORs', xtitle = 'exptime', ytitle = 'mean np')
        endif else begin
           ;c.window.SetCurrent
           c = plot(xcen500, ycen500, '1s', sym_size = 0.2,   sym_filled = 1, color = colorarr[count],/overplot)

           ;ps.window.SetCurrent
           ;ps = plot(xhist, yhist/ total(yhist), thick = 2, color = colorarr[count],/overplot, /current)
                                ;  ps = plot(e, (planethash[aorname(a),'np'] ), '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[p], /overplot,/current) 
           ;ps = errorplot(e, meany, stddevy, color = colorarr[count],  sym_size = 0.2,   sym_filled = 1, /overplot)
        endelse
        count = count + 1
     endfor  ;for all aors


  endfor ; for all planets


ps = errorplot(exptimearr, meanarr, stddevarr, '1s', sym_color = colorarr,  sym_size = 1,   sym_filled = 1, title = '23 AORs', xtitle = 'exptime', ytitle = 'mean np', xrange =[0,2.5])

print, 'total AORs ', count
  end
