pro test_phase 
  planetname = 'wasp16'

  planetinfo = create_planetinfo()
  chname = planetinfo[planetname, 'chname']
  ra_ref = planetinfo[planetname, 'ra']
  dec_ref = planetinfo[planetname, 'dec']
  aorname = planetinfo[planetname, 'aorname']
  basedir = planetinfo[planetname, 'basedir']
  utmjd_center =  planetinfo[planetname, 'utmjd_center']
  print, 'utmjd_center ', utmjd_center, format = '(A, F0)'
  transit_duration =  planetinfo[planetname, 'transit_duration']
  period =  planetinfo[planetname, 'period']
  intended_phase = planetinfo[planetname, 'intended_phase']
  stareaor = planetinfo[planetname, 'stareaor']
  plot_norm= planetinfo[planetname, 'plot_norm']
  plot_corrnorm = planetinfo[planetname, 'plot_corrnorm']
  
  dirname = strcompress(basedir + planetname +'/')
  savefilename = strcompress(dirname + planetname +'_phot_ch'+chname+'.sav')
  restore, savefilename
  


;first look at the raw data
  for a = 0,   n_elements(aorname) - 1 do begin
     dir = dirname+ string(aorname(a) ) 
     CD, dir                    ; change directories to the correct AOR directory
     command  = strcompress( 'find ch'+chname+"/bcd -name '*_bcd.fits' > "+dirname+'bcdlist.txt')
     spawn, command
     readcol,strcompress(dirname +'bcdlist.txt'),fitsname, format = 'A', /silent

     bmjd_obsarr = fltarr(n_elements(fitsname))

     for i =0.D,  12 do begin ;read each cbcd file, find centroid, keep track
        ;print, 'working on ', fitsname(i)         
        header = headfits(fitsname(i)) ;
        bmjd_obsarr[i] = sxpar(header, 'BMJD_OBS')
 
     endfor

     print, 'bmjd_obsarr', bmjd_obsarr[0], '  ', bmjd_obsarr[10], format = '(A,F0,A, F0)'
  endfor

;-------------------------------------------------------
;work out the phase
;-------------------------------------------------------
  print, ';;;;;;;;;;;;;;;;;;;'
  transit_duration = transit_duration /60./24.  ; in days
  test_med = fltarr(n_elements(aorname))

  for a = 0, n_elements(aorname) - 1 do  begin
     ;now try to get them all within the same [0,1] phase     
     bmjd = (planethash[aorname(a),'bmjdarr'])
     print, 'bmjd ', bmjd(0), format = '(A,F0)'
     bmjd_dist = bmjd - utmjd_center ; how many UTC away from the transit center
     print, 'bmjd- utmjd  ', bmjd_dist(0), format = '(A,F0)'
     phase =( bmjd_dist / period )- fix(bmjd_dist/period)

     ;ok, but now I want -0.5 to 0.5, not 0 to 1
     ;need to be careful here because subtracting half a phase will put things off, need something else
     print, ' before phase ',  phase(0), format = '(A,F0)'    
     if intended_phase lt 0.5 then begin  ;primary transit
        pa = where(phase gt 0.5,pacount)
        if pacount gt 0 then phase[pa] = phase[pa] - 1.0
     endif else begin  ;secondary eclipse
        print, 'secondary eclipse intended'
        phase = phase + 0.5
     endelse

    print, ' after phase',  phase(0), format = '(A,F0)'
 endfor

end
