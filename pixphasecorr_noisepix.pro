pro pixphasecorr_noisepix, planetname, breatheap = breatheap
;this code implements the Knutson et al. 2012 technique of correcting for pixel phase effect
;np is noise pixel
t1 = systime(1)
;get all the necessary saved info/photometry
  planetinfo = create_planetinfo()
  aorname = planetinfo[planetname, 'aorname']
  basedir = planetinfo[planetname, 'basedir']
  chname = planetinfo[planetname, 'chname']
  dirname = strcompress(basedir + planetname +'/')
  if keyword_set(breatheap) then  savefilename = strcompress(dirname + planetname +'_phot_ch'+chname+'_varap.sav') else savefilename = strcompress(dirname + planetname +'_phot_ch'+chname+'.sav')

  restore, savefilename

  for a = 0, n_elements(aorname) - 1 do begin  ;run through all AORs
     print, 'working on aor', aorname(a)
     np = planethash[aorname(a),'np'] ;the second AOR has phase 0.4- 0.1, so no transits or eclipses
     xcen = planethash[aorname(a), 'xcen']
     ycen = planethash[aorname(a), 'ycen']
     flux_m = planethash[aorname(a), 'flux']
     time = (planethash[aorname(a),'timearr'] - (planethash[aorname(a),'timearr'])(0)) ; in seconds;/60./60. ; in hours from beginning of obs.
     sqrtnp = sqrt(np)
     
     savefilename = strcompress(dirname + planetname +'_phot_ch'+chname+'.sav')
     restore, savefilename
     corrflux = planethash[aorname(a), 'corrflux'] ;pmap corrected
     
                                ;calculate standard deviations of entire xcen, ycen,and sqrtnp
     stdxcen = stddev(xcen)
     stdycen = stddev(ycen)
     stdsqrtnp = stddev(sqrtnp)
     
     ni =   n_elements(xcen) 
     print, 'ni', ni
     n = 50                     ; number of nearest neighbors to use; tried 100 doesn't make a difference
     
     xcen = xcen[0:ni-1]
     ycen = ycen[0:ni-1]
     sqrtnp = sqrtnp[0:ni-1]
     
                                ;setup an array for the corrected fluxes
     flux = dblarr(ni)          ; fltarr(n_elements(flux_m))
     flux_np = dblarr(ni)       ; fltarr(n_elements(flux_m))
     time_0 = time[0:ni - 1]
     warr = dblarr(ni)
     warr_np= dblarr(ni)
     sigmax = dblarr(ni)
     sigmay = dblarr(ni)
     sigma_np = dblarr(ni)
     furthestx = dblarr(ni)
     furthesty= dblarr(ni)
     delta_time = dblarr(ni)
     delta_time_np =  dblarr(ni)
                                ;do the nearest neighbors run with triangulation
                                ;http://www.idlcoyote.com/code_tips/slowloops.html
                                ;this returns a sorted list of the n nearest neighbors
     nearest = nearest_neighbors_DT(xcen,ycen,DISTANCES=nearest_d,NUMBER=n)
     nearest_np = nearest_neighbors_np_DT(xcen,ycen,sqrtnp,DISTANCES=nearest_np_d,NUMBER=n)
     
     for j = 0,   ni - 1 do begin ;for each image (centroid)
 ;--------------------
  ;find the weighting function without using noise pixel
 ;--------------------
        nearestx = xcen(nearest(*,j))
        nearesty = ycen(nearest(*,j))
        nearestflux = flux_m(nearest(*,j))
        nearesttime = time_0(nearest(*,j))
        
                                ;what is the time distribution like of the points chosen as nearest in position
                                ;track the range in time for each point
        delta_time(j) = abs(time_0[j]- nearesttime(n_elements(nearesttime)-1))
;     if j gt 500 and j lt 520 then print, 'time' , time_0[j], nearesttime
                                ;make sure that the nearest neighbor is not the point itself
                                ;if it is, then get rid of that one and just use the nearest n-1
        if  xcen(j) eq nearestx(0) and ycen(j) eq nearesty(0) then begin
           nearestx = nearestx[1:*]
           nearesty = nearesty[1:*]
           nearestflux = nearestflux[1:*]
        endif
        
        furthestx[j] = abs(xcen(j) - nearestx(n_elements(nearestx)-1))
        furthesty[j] = abs(ycen(j) - nearesty(n_elements(nearesty)-1))
        
                                ;calculate sigmas on the nearest neighbors.
        stdxcen = stddev(nearestx)
        stdycen = stddev(nearesty)
        sigmax[j] = stdxcen
        sigmay[j] = stdycen
        
                                ;fix sigmas to ballard values
;    stdxcen = 0.017
;    stdycen = 0.0043
        
        w = weight(stdxcen, stdycen, nearestx, nearesty,  xcen(j), ycen(j), nearestflux)
        warr[j] = w
                                ; print, 'testing', flux_m(j), w,  flux_m(j) / w
        flux(j) = flux_m(j) / w
        
;--------------------
 ;find the weighting function using noise pixel
 ;--------------------
        
        nearestx = xcen(nearest_np(*,j))
        nearesty = ycen(nearest_np(*,j))
        nearestsqrtnp = sqrtnp(nearest_np(*,j))
        nearestflux = flux_m(nearest_np(*,j))
        nearesttime = time_0(nearest_np(*,j))
        
        delta_time_np(j) = abs(time_0[j]- nearesttime(n_elements(nearesttime)-1))
        
                                ;make sure that the nearest neighbor is not the point itself
        if  xcen(j) eq nearestx(0) and ycen(j) eq nearesty(0) then begin
           nearestx = nearestx[1:*]
           nearesty = nearesty[1:*]
           nearestsqrtnp  = nearestsqrtnp[1:*]
           nearestflux = nearestflux[1:*]
        endif
        
        stdxcen = stddev(nearestx)
        stdycen = stddev(nearesty)
        stdsqrtnp = stddev(nearestsqrtnp)
        sigma_np[j] = stdsqrtnp
        
                                ;fix sigmas to ballard values
                                ;    stdxcen = 0.017
;     stdycen = 0.0043
        
        
        w_np = weight_np(stdxcen, stdycen, stdsqrtnp, nearestx, nearesty, nearestsqrtnp, xcen(j), ycen(j), sqrtnp(j), nearestflux)
        warr_np[j] = w_np
        flux_np(j) = flux_m(j) / w_np
        
  ;--------------------
        
     endfor
     
;  bad = where(finite(flux) lt 1, badcount)
;  print, 'nan? ', badcount
     
     
;plot the results
     p1 = plot(time[0:ni-1]/60./60., flux_m[0:ni-1]/ median(flux_m[0:ni-1]), '1s', sym_size = 0.1,   sym_filled = 1,color = 'black', xtitle = 'Time (hrs)', ytitle = 'Flux', title = planetname, name = 'raw flux', yrange =[0.93, 1.15])
     p4 =  plot(time[0:ni-1]/60./60., (corrflux[0:ni-1] /median( corrflux[0:ni-1])) + 0.05, '1s', sym_size = 0.1,   sym_filled = 1,color = 'grey',/overplot, name = 'pmap corr')
     p2 = plot(time_0/60./60., flux/median(flux) -0.05, '1s', sym_size = 0.1,   sym_filled = 1,color = 'red', /overplot, name = 'position corr')
     p3 = plot(time_0/60./60., flux_np /median(flux_np)+ 0.1, '1s', sym_size = 0.1,   sym_filled = 1,color = 'blue', /overplot, name = 'position + np')
     
                                ; l = legend(target = [p1, p4, p2,p3], position = [1.5, 1.18], /data, /auto_text_color)
     
    print, 'mean and stddev of sigmax', mean(sigmax), stddev(sigmax)
     print, 'mean and stddev of sigmay', mean(sigmay), stddev(sigmay)
     print, 'mean and stddev of sigmanp', mean(sigma_np), stddev(sigma_np)
     print, 'mean and stddev of furthestx', mean(furthestx), stddev(furthestx)
     print, 'mean and stddev of furthesty', mean(furthesty), stddev(furthesty)
     print, 'mean and stddev of deltatime', mean(delta_time), stddev(delta_time)
     print, '------'
     if ni gt 12000 then print, 'stddev of raw, pmap, position, position+np corr', stddev(flux_m[12000:ni-1],/nan),stddev(corrflux[12000:ni-1],/nan), stddev(flux[12000:*],/nan), stddev(flux_np[12000:*],/nan)


     save, /all, filename =strcompress(dirname + planetname +'_pixphasecorr_ch'+chname+'_'+aorname(a)+'.sav')


  
     
;  plothist, warr, xhist, yhist, bin = 0.5, /noplot
;  plothist, warr_np, xhistnp, yhistnp,bin = 0.5, /noplot
;  wp = plot(xhist, yhist, color = 'red')
;  wp = plot(xhistnp, yhistnp, color = 'blue', /overplot)
     
    
;  plothist, sigmax, xhist, yhist, bin = 0.0001,/noplot
;  px = plot(xhist, yhist, xtitle = 'sigma', color = 'brown', xrange = [0, 0.003], name = 'sigma x')
;  plothist, sigmay, xhist, yhist, bin = 0.0001,/noplot
;  py = plot(xhist, yhist,color = 'green', /overplot, name = 'sigma y')
;  l2 = legend(target = [px, py], position = [0.0028, 3E4], /data, /auto_text_color)
     
;  plothist, delta_time/0.1, xhist, yhist, bin = 50, /noplot
;  ps = plot(xhist, yhist, xtitle = 'delta time (number of 0.1s frames)',/xlog, color = 'red')
;  plothist, delta_time_np/0.1, xhist, yhist, bin = 50, /noplot
;  ps = plot(xhist, yhist, /overplot, color = 'blue')
     

  endfor
     print,'total time in minutes', (systime(1)-t1)/60.

end


function weight, stdxcen, stdycen, nearestx, nearesty, xcenj, ycenj, nearestflux

  ;gaussian weighting function
 ;print, 'test', xcenj, nearestx(0), ycenj, nearesty(0)
  gaussx = exp( -((nearestx - xcenj)^2)/(2*stdxcen^2) )
  gaussy = exp(-((nearesty  - ycenj)^2)/(2*stdycen^2) )
  
 ; print, 'total gaussx gaussy', total(gaussx*gaussy), total(gaussx*gaussy*fluxj)
  ;now sum
  w = (total(gaussx*gaussy*nearestflux) )/ (total(gaussx*gaussy))
  return, w
  
end

function weight_np, stdxcen, stdycen, stdsqrtnp,nearestx, nearesty, nearestsqrtnp,  xcenj, ycenj, sqrtnpj, nearestflux
  
   ;gaussian weighting function
  gaussx = exp( -((nearestx - xcenj)^2)/(2*stdxcen^2) )
  gaussy = exp(-((nearesty  - ycenj)^2)/(2*stdycen^2) )
  gaussnp = exp(-((nearestsqrtnp  - sqrtnpj)^2)/(2*stdsqrtnp^2) )

  ;now sum
  w = total((gaussx*gaussy*gaussnp*nearestflux)/total(gaussx*gaussy*gaussnp))

  return, w

end


function distance_np, xcen, ycen, np, j
  ;calculate the "distance" from the working centroid to all other centroids.
  b = 0.8                       ; for 3.6micron channel taken from paper
  dist = (xcen - xcen(j))^2 + ((ycen -ycen(j))/b)^2 + (sqrt(np) - sqrt(np(j)))^2

  return, dist

end

function distance, xcen, ycen, np, j
                                ;calculate the "distance" from the working centroid to all other centroids.
 
  b = 0.8                       ; for 3.6micron channel taken from paper
  dist = (xcen - xcen(j))^2 + ((ycen -ycen(j))/b)^2 

  return, dist

end

