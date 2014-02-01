pro np_vs_exptime
;only ch2

;snaps and stares
;wasp14, 2s
;hatp8, 2s

;stares
;hat22 0.4s       indigo
;wasp16; 2s      black
;wasp15; 2s      black
;wasp13; 0.4s   indigo
;hd7924; 0.1s   blue
;55cnc; 0.02s    green
;wasp38; 0.4s    indigo


;just look at ch2 long stares for now (ignore starting 30-min pre-AOR
;want to plot noise pixel vs. exptime

 colorarr = [ 'black', 'black', 'black', 'black','indigo', 'indigo','indigo', 'indigo','blue','blue','blue', 'green','green', 'green','green','indigo', 'indigo']
;

  planetinfo = create_planetinfo()

  planetname =[  'wasp16', 'wasp15', 'wasp13', 'hd7924', '55cnc', 'wasp38']  ; took hat22 out
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
        print, planetname(p), aorname(a)
        print,  n_elements(planethash[aorname(a),'np'] ), mean(planethash[aorname(a),'np'] ), stddev(planethash[aorname(a),'np'] )
        e = fltarr(n_elements(planethash[aorname(a),'np'] )) + exptime

        ;make the histogram
        plothist, planethash[aorname(a),'np'], xhist, yhist, bin = 0.2,/noplot


        if p eq 0 and a eq 0 then begin  ; setup plot for the first AOR

           ;  ps= plot(e, (planethash[aorname(a),'np'] ), '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[p], $
           ;           xtitle = 'Exptime', ytitle = 'Noise Pixel', title = '17 AORs', xrange = [0,2.1], yrange = [2., 10.])
           ps = plot(xhist, yhist/ max(yhist), color= colorarr[count])
        endif else begin
           ps = plot(xhist, yhist/ max(yhist), color = colorarr[count],/overplot, /current)
               ;  ps = plot(e, (planethash[aorname(a),'np'] ), '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[p], /overplot,/current) 
        endelse
        count = count + 1
     endfor  ;for all aors

;     if p eq 5 then begin
;        ;why does 55cnc have such small range in np?
;        for a = 0, n_elements(aorname) - 1 do begin
;           plothist, planethash[aorname(a),'np'], xhist, yhist, bin = 0.2,/noplot
;           ph = plot(xhist, yhist/ median(yhist))
;        endfor
;     endif   ; p eq 5, aka 55cnc


  endfor ; for all planets

print, 'total AORs ', count
  end
