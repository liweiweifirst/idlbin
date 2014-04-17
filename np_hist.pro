pro np_hist
  planetname = 'WASP-52b'
  chname = '2'
  apradius = 2.25
  planetinfo = create_planetinfo()
  if chname eq '2' then aorname= planetinfo[planetname, 'aorname_ch2'] else aorname = planetinfo[planetname, 'aorname_ch1'] 
  basedir = planetinfo[planetname, 'basedir']
  period =  planetinfo[planetname, 'period']
  
  dirname = strcompress(basedir + planetname +'/')
  savefilename = strcompress(dirname + planetname +'_phot_ch'+chname+'_'+string(apradius)+'.sav',/remove_all)
  print, 'restoring ', savefilename
  restore, savefilename
  print, 'aorname', aorname(0)
  
  colorarr = ['blue', 'red','black','green','grey','purple']

  for a = 0, n_elements(aorname) -1 do begin
     if a eq 0 then begin
        meannp = mean(planethash[aorname(a),'np'],/nan)
        meannpcent = mean(planethash[aorname(a),'npcentroids'],/nan)
        delta = meannp - meannpcent
     endif

     np = planethash[aorname(a),'np'] - delta
     plothist, np, xhist, yhist, /noplot, bin = 0.05
     if a eq 0 then p = plot (xhist, yhist, color = colorarr(a), xtitle = 'Noise pixel', $
                              ytitle = 'Number', title = planetname, xrange = [3.5, 5.5], thick = 3)
     if a gt 0 then p = plot (xhist, yhist, color = colorarr(a),thick = 3, /overplot)
     
     plothist, planethash[aorname(a),'npcentroids'], xhist, yhist, /noplot, bin = 0.05
     p = plot (xhist, yhist, color = colorarr(a),/overplot, linestyle = 2, thick = 3)
  endfor
;----------------------------------------------------

;just work on one AOR
  a = 1
  dir = dirname+ string(aorname(a) ) 
  CD, dir                       ; change directories to the correct AOR directory
  command  = strcompress( 'find ch'+chname+"/bcd -name 'SPITZER*_bcd.fits' > "+dirname+'bcdlist.txt')
  spawn, command
  readcol,strcompress(dirname +'bcdlist.txt'),fitsname, format = 'A', /silent
  
  for i = 0, n_elements(fitsname) - 1 do begin
           fits_read, fitsname(i), im, h
           frametime = sxpar(header, 'FRAMTIME')
           ch = sxpar(header, 'CHNLNUM')
           ronoise = sxpar(header, 'RONOISE')
           gain = sxpar(header, 'GAIN')
           fluxconv = sxpar(header, 'FLUXCONV')
           exptime = sxpar(header, 'EXPTIME')
           naxis = sxpar(header, 'NAXIS')

           ;run noisepix with various permutations on aperture size
           ;or anything else
           ;to see what the effect on the overall levels are.

  endfor
  
end
