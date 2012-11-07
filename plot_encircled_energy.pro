pro plot_encircled_energy, planetname
; this program plots the encircled energy as a function of aperture size for a staring mode data set
; the purpose of this code is to look for changes in the slope of that curve as a function of time


  print, systime()

  planetinfo = create_planetinfo()
  chname = planetinfo[planetname, 'chname']
  ra_ref = planetinfo[planetname, 'ra']
  dec_ref = planetinfo[planetname, 'dec']
  aorname = planetinfo[planetname, 'aorname']
  basedir = planetinfo[planetname, 'basedir']
  dirname = strcompress(basedir + planetname +'/')


  restore, strcompress(dirname + planetname +'_ee_ch'+chname+'.sav')
  ap =  findgen(45) / 5 + 1.   ;this will make a smoother curve


;test output 
  print, 'bin_flux', bin_flux(0,*)


;Plot the binned curve of growths
  min = 500
  for p = min, 800 do begin
     if p eq min then begin
        a = plot(ap, bin_flux(p,*), '1r', xtitle = 'Aperture size', ytitle = 'Encircled Energy') 
     endif
     if p gt 594 and p lt 670 then begin
        a = plot(ap, bin_flux(p,*), '1b',/overplot)
     endif else begin
        a = plot(ap, bin_flux(p,*), '1r', /overplot)
     endelse
     
  endfor


  
  print, systime()

end
