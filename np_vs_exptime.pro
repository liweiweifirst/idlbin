pro np_vs_exptime
;only ch2

;snaps and stares
;wasp14, 2s
;hatp8, 2s

;stares
;hat22 0.4s
;wasp16; 2s
;wasp15; 2s
;wasp13; 0.4s
;hd7924; 0.1s
;55cnc; 0.02s
;wasp38; 0.4s


;just look at ch2 long stares for now (ignore starting 30-min pre-AOR
;want to plot noise pixel vs. exptime

 colorarr = ['blue', 'red', 'medium_purple', 'dark_orange', 'green',  'aquamarine','black' ]
;

  planetinfo = create_planetinfo()

  planetname =[ 'hat22', 'wasp16', 'wasp15', 'wasp13', 'hd7924', '55cnc', 'wasp38']

  for p = 0, n_elements(planetname)- 1 do begin
     aorname = planetinfo[planetname(p), 'aorname']
     basedir = planetinfo[planetname(p), 'basedir']
     exptime = planetinfo[planetname(p), 'exptime']
     chname = planetinfo[planetname(p), 'chname']
     dirname = strcompress(basedir + planetname(p) +'/')
     savefilename = strcompress(dirname + planetname(p) +'_phot_ch'+chname+'.sav')
     restore, savefilename
     
     for a = 0, n_elements(aorname) - 1 do begin
        
        e = fltarr(n_elements(planethash[aorname(a),'np'] )) + exptime
        if p eq 0 and a eq 0 then begin  ; setup plot for the first AOR
           ps= plot(e, (planethash[aorname(a),'np'] ), '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[p], $
                    xtitle = 'Exptime', ytitle = 'Noise Pixel', title = '7 datasets',$
                    xrange = [0,2.1], yrange = [2., 10.])
        endif else begin
           ps = plot(e, (planethash[aorname(a),'np'] ), '1s', sym_size = 0.2,   sym_filled = 1,  color = colorarr[p], /overplot,/current) 
        endelse
     endfor  ;for all aors

  endfor ; for all planets

  end
