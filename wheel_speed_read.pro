pro wheel_speed_read
  t1 = systime(1)

  close, /all
  ;read in the data
  ;read_csv doesn't work on this file (maybe too large, maybe formatting)
  filename = '/Users/jkrick/irac_warm/irac_wheel_speeds/ctab_data.17534.ecsv';test.ecsv'
  openr, 1, filename

  n=0L
  line=' '
  nmax=99999999
  rw1=dblarr(nmax)
  rw2=rw1
  rw3=rw1
  rw4=rw1
  time=dblarr(nmax)
  
  dn=0.d0
  eu=0.d0
  t=0.d0

  while not eof(1) do begin
     readf, 1, line
     if(strmid(line,8,1) eq 'T') then begin
        reads, strmid(line,25,3), pid, format='(i3)'
        ibad=strpos(line,'?')
        if(ibad lt 8) then begin
           fpos=strpos(line,',F')
           qs=strmid(line,29,fpos-29)
           
           
           reads, qs, dn, eu, t
           
           time(n)=t
           
           case pid of
            
              718: rw1(n)=eu
              719: rw2(n)=eu
              720: rw3(n)=eu
              721: begin
                 
                 rw4(n)=eu
                 n=n+1
              end
              
           endcase
           
        endif
     endif
  endwhile
  
  close, 1
  
  print, 'n: ', n
  
  time=time[0:n-1]
  rw1=rw1[0:n-1]
  rw2=rw2[0:n-1]
  rw3=rw3[0:n-1]
  rw4=rw4[0:n-1]
  save, time, rw1, rw2, rw3, rw4, filename = '/Users/jkrick/irac_warm/irac_wheel_speeds/speeds.sav'

; FIELD2 = P-0718, 719, 720, 721
;FIELD4 = speeds
;FIELD5 = sclk
 
;------------------------------------------------------------------------
  planetname = 'hatp2'
  chname = '2'
  apradius = 2.25
  planetinfo = create_planetinfo()
  if chname eq '2' then aorname= planetinfo[planetname, 'aorname_ch2'] else aorname = planetinfo[planetname, 'aorname_ch1'] 
  basedir = planetinfo[planetname, 'basedir']
  
  dirname = strcompress(basedir + planetname +'/');+'/hybrid_pmap_nn/')
  savefilename = strcompress(dirname + planetname +'_phot_ch'+chname+'_'+string(apradius)+'.sav',/remove_all)
  print, 'restoring ', savefilename
  restore, savefilename
  print, 'aorname', aorname(0)

  for a = 0, n_elements(aorname) - 1 do begin
     sclk_0 = planethash[aorname(a),'sclktime_0'] ; in seconds
     bmjdarr = planethash[aorname(a), 'bmjdarr']
                                ;turn bmjd into sclk
     elapsed_days= bmjdarr(n_elements(bmjdarr)-1) - bmjdarr(0)
     elapsed_secs = elapsed_days*24.*60.*60.
     sclk = dindgen(n_elements(bmjdarr))*elapsed_secs / n_elements(bmjdarr)
     sclk = sclk + sclk_0
     sclk_end = sclk(n_elements(sclk) -1 )
     
                                ;set up the plot, but wait to actually plot until after the wheel speeds
 ;    psx = plot(sclk, planethash[aorname(a),'xcen'], '1s', sym_size = 0.2,   sym_filled = 1,  color = 'blue', yrange = [14.5, 15.5],$
;                xtitle = 'Sclk_time', ytitle = 'Xcen', title = planetname, axis_style = 1, margin = [0.15, 0.15, 0.2, 0.15],/nodata)
    
     
                                ;find the corresponding sclk in the wheel speed table
     sc = where(time gt sclk_0 and time lt sclk_end , sclkcount)
     print, sclkcount, time(sc(0)),time(sc(sclkcount - 1))
          
     pw = plot(time(sc), rw1(sc), margin = [0.15, 0.15, 0.2, 0.15], color = 'silver', xtitle = 'Sclk_time', $
               ytitle = 'Wheel Speeds', title = planetname, axis_style = 1)
     pw = plot(time(sc), rw2(sc), /current, axis_style = 0, margin = [0.15, 0.15, 0.2, 0.15], color = 'silver')
     pw = plot(time(sc), rw3(sc), /current, axis_style = 0, margin = [0.15, 0.15, 0.2, 0.15], color = 'silver')
     pw = plot(time(sc), rw4(sc), /current, axis_style = 0, margin = [0.15, 0.15, 0.2, 0.15], color = 'silver')

     psx = plot(sclk, planethash[aorname(a),'xcen'], '1s',  axis_style = 0,sym_size = 0.2,   sym_filled = 1,  color = 'blue', /current, /overplot)
     psx= plot(sclk, planethash[aorname(a),'ycen'], '1s', axis_style = 0, sym_size = 0.2,   sym_filled = 1,  color = 'green', /current, /overplot)
   

     a_psx = axis('y', target = psx, axis_range = [14.5,15.5], LOCATION = [max(psx.xrange),0,0], textpos = 1, title = 'X & Y Centroids')
     
  endfor
  
  print, 'time check', systime(1) - t1

end
