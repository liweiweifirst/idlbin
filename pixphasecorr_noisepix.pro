;+
; NAME: pixphasecorr_noisepix.pro
;
; PURPOSE:
; This code implements the Knutson et al. 2012 technique of correcting for pixel phase effect
;
; CALLING SEQUENCE:
; pixphasecorr_noisepix, 'hd189733',50, /breatheap
;
; INPUTS:
; planetname= string of the name of the planet corresponding to the correct information in create_planetinfo
; nn = number of nearest neighbors to use.  Knutson et al uses 50, have tried 100 without much difference.

; KEYWORD PARAMETERS:
; breatheap = set this keyword if using variable apertures
; ballard_sigma = set this keyword i=to use the Ballard et al. sigma values instead of those calculated from the nearest neighbors.
;
; OUTPUTS:
; plots the normalized raw fluxes, pmap corrected fluxes, position corrected fluxes and postion + noise pixel corrected fluxes.
; a save file for use in plot_pixphasecorr.pro;
; a few statistics to compare runs with different values
;
; RESTRICTIONS:
; planet photometry must come from a save file from phot_exoplanet.pro (or have that same format)
;
; MODIFICATION HISTORY:
; Dec 2012 JK initial version
;-
pro pixphasecorr_noisepix, planetname, nn, breatheap = breatheap, ballard_sigma = ballard_sigma

  t1 = systime(1)
;get all the necessary saved info/photometry
  planetinfo = create_planetinfo()
  aorname = planetinfo[planetname, 'aorname']
  basedir = planetinfo[planetname, 'basedir']
  chname = planetinfo[planetname, 'chname']
  period = planetinfo[planetname, 'period']
  utmjd_center = planetinfo[planetname, 'utmjd_center']
  exptime = planetinfo[planetname, 'exptime']
  transit_duration = planetinfo[planetname, 'transit_duration']
  dirname = strcompress(basedir + planetname +'/')
  if keyword_set(breatheap) then  savefilename = strcompress(dirname + planetname +'_phot_ch'+chname+'_varap.sav') else savefilename = strcompress(dirname + planetname +'_phot_ch'+chname+'.sav')

  restore, savefilename

  for a = 0, n_elements(aorname) - 1 do begin  ;run through all AORs
     print, 'working on aor', aorname(a)
     np = planethash[aorname(a),'np']  ; np is noise pixel
     xcen = planethash[aorname(a), 'xcen']
     ycen = planethash[aorname(a), 'ycen']
     flux_m = planethash[aorname(a), 'flux']
     fluxerr_m = Planethash[aorname(a), 'fluxerr']
     bmjd = planethash[aorname(a),'bmjdarr']
     phase = planethash[aorname(a),'phase']
     
                                ;make sure we are not trying to correct snapshots with nearest neighbors, 
                                ; won't work because some are in the transits and eclipses which I have excluded.
     if n_elements(np) gt 1000 then begin

        time = (planethash[aorname(a),'timearr'] - (planethash[aorname(a),'timearr'])(0)) ; in seconds;/60./60. ; in hours from beginning of obs.
        print, 'xcen', xcen[0:10]
        print, 'ycent', ycen[0:10]

     ;now try to get them all within the same [0,1] phase     
 ;    bmjd_dist = bmjd - utmjd_center ; how many UTC away from the transit center
 ;    phase =( bmjd_dist / period )- fix(bmjd_dist/period)
 ;    pa = where(phase gt 0.5,pacount)
 ;    if pacount gt 0 then phase[pa] = phase[pa] - 1.0
     
        sqrtnp = sqrt(np)
        
        savefilename = strcompress(dirname + planetname +'_phot_ch'+chname+'.sav')
        restore, savefilename
        corrflux = planethash[aorname(a), 'corrflux'] ;pmap corrected
        corrfluxerr = planethash[aorname(a), 'corrfluxerr']
        
                                ;calculate standard deviations of entire xcen, ycen,and sqrtnp
     ;stdxcen = stddev(xcen)
     ;stdycen = stddev(ycen)
     ;stdsqrtnp = stddev(sqrtnp)
     
   ;change this to a smaller number to test code in less time than a full run
        ni =  n_elements(xcen) 
        print, 'ni, phase', ni, n_elements(phase)
        
        xcen = xcen[0:ni-1]
        ycen = ycen[0:ni-1]
        sqrtnp = sqrtnp[0:ni-1]
        bmjd = bmjd[0:ni-1]
        phase = phase[0:ni-1]
        flux_m =  flux_m[0:ni-1]
        fluxerr_m = fluxerr_m[0:ni-1]
        
                                ;setup arrays for the corrected fluxes
        flux = dblarr(ni)       ; fltarr(n_elements(flux_m))
        fluxerr = dblarr(ni)
        flux_np = dblarr(ni)    ; fltarr(n_elements(flux_m))
        fluxerr_np = dblarr(ni)
        time_0 = time[0:ni - 1]
        phase_0 = phase[0:ni-1]
        warr = dblarr(ni)
        warr_np= dblarr(ni)
        sigmax = dblarr(ni)
        sigmay = dblarr(ni)
        sigma_np = dblarr(ni)
        furthestx = dblarr(ni)
        furthesty= dblarr(ni)
        delta_time = dblarr(ni)
        delta_time_np =  dblarr(ni)
        
        xcen2 = xcen
        ycen2 = ycen
        sqrtnp2 = sqrtnp
        flux_m2 = flux_m
        fluxerr_m2 = fluxerr_m
        time_02  = time_0
        
                                ;mask intervals in time where astrophysical signals exist.
                                ;I know where the transits and eclipses are
        s = mask_signal( phase, period, utmjd_center, transit_duration)
        
                                ;make sure the transit doesn't get included as a nearest neighbor
        good = where(s gt 0, ngood, complement = bad)
        print, 'ngood', ngood, n_elements(bad)
        xcen2(bad) = 1E5
        ycen2(bad) = 1E5
        sqrtnp2(bad) = 1E5
        
                                ;do the nearest neighbors run with triangulation
                                ;http://www.idlcoyote.com/code_tips/slowloops.html
                                ;this returns a sorted list of the nn nearest neighbors
        print, 'xcen2', xcen2[0:10]
        print, 'ycent2', ycen2[0:10]
        
        
        nearest = nearest_neighbors_DT(xcen2,ycen2,chname,DISTANCES=nearest_d,NUMBER=nn)
        nearest_np = nearest_neighbors_np_DT(xcen2,ycen2,sqrtnp2,chname,DISTANCES=nearest_np_d,NUMBER=nn)
        ndimages = dblarr(ngood)
        for j = 0L,   ni - 1 do begin ;for each image (centroid)
;        if j gt 110500 then print, 'centers', xcen(j), ycen(j), xcen2(j), ycen2(j)
                                ;--------------------
                                ;find the weighting function without using noise pixel
                                ;--------------------
           
           if s[j] gt 0 then begin ;out of transit
                                ;not inside a transit, so do the normal nearest neighbor search for weights.
                                ; thisx = xcen2(j)
                                ; thisy = ycen2(j)
              nearestx = xcen2(nearest(*,j))
              nearesty = ycen2(nearest(*,j))
              nearestflux = flux_m2(nearest(*,j))
              nearestfluxerr = fluxerr_m2(nearest(*,j))
              nearesttime = time_02(nearest(*,j))
              
                                ;what is the time distribution like of the points chosen as nearest in position
                                ;track the range in time for each point
              delta_time(j) = abs(time_0[j]- nearesttime(n_elements(nearesttime)-1))
;                                         if j gt 500 and j lt 520 then print, 'time' , time_0[j], nearesttime
              
                                ;make sure that the nearest neighbor is not the point itself
                                ;if it is, then get rid of that one and just use the nearest n-1
              if  xcen2(j) eq nearestx(0) and ycen2(j) eq nearesty(0) then begin
                 nearestx = nearestx[1:*]
                 nearesty = nearesty[1:*]
                 nearestflux = nearestflux[1:*]
                 nearestfluxerr = nearestfluxerr[1:*]
              endif
              
              furthestx[j] = abs(xcen2(j) - nearestx(n_elements(nearestx)-1))
              furthesty[j] = abs(ycen2(j) - nearesty(n_elements(nearesty)-1))
              
              
                                ;some debugging
                                ;what is the average distance to the nearest neighbor
                                ; will eventually want to plot that as a funciton of phase or time
              ndarr = fltarr(n_elements(nearestx))
              for nd = 0, n_elements(nearestx) - 1 do begin
                                ;             print, 'testing inside', xcen2(j), nearestx(nd), ycen2(j), nearesty(nd)
                 ndarr(nd) = sqrt((xcen2(j) - nearestx(nd))^2 + (ycen2(j) - nearesty(nd))^2)
              endfor
;           print, 'testing', ndarr[5:6], mean(ndarr,/nan)
              ndimages(j) = mean(ndarr, /nan)
                                ;          print, 'mean dist', j, mean(ndarr,/NAN)
              
                                ;          if j gt 100400 then begin
                                ;             print, 'out transit'
                                ;             for c = 0, nn - 1 do print, nearestx(c), nearesty(c)
                                ;          endif
              
              
;--------------------
                                ;find the weighting function using noise pixel
                                ;--------------------
              
              nearestxnp = xcen2(nearest_np(*,j))
              nearestynp = ycen2(nearest_np(*,j))
              nearestsqrtnp = sqrtnp2(nearest_np(*,j))
              nearestfluxnp = flux_m2(nearest_np(*,j))
              nearesttimenp = time_02(nearest_np(*,j))
              
              delta_time_np(j) = abs(time_02[j]- nearesttimenp(n_elements(nearesttimenp)-1))
              
                                ;make sure that the nearest neighbor is not the point itself
              if  xcen2(j) eq nearestxnp(0) and ycen2(j) eq nearestynp(0) then begin
                 nearestxnp = nearestxnp[1:*]
                 nearestynp = nearestynp[1:*]
                 nearestsqrtnp  = nearestsqrtnp[1:*]
                 nearestfluxnp = nearestfluxnp[1:*]
              endif
              
              
              
              
           endif else begin     ;s[j] eq 0 ; in transit
                                ;print, 'j', j
              goodx = fltarr(ngood + 1)
              goody = fltarr(ngood + 1)
              goodflux = fltarr(ngood + 1)
              goodx[0] = xcen[j]
              goody[0] = ycen[j]
              goodflux[0] = flux_m[j]
              goodx[1:*] = xcen(good)
              goody[1:*] = ycen(good)
              goodflux[1:*] = flux_m(good)
              
                                ; try the brute force way
              dist = distance(goodx, goody, 0, chname)
              sd = sort(dist)
              sortdist = dist(sd)
              sortxcen = goodx(sd)
              sortycen = goody(sd)
              sortflux_m = goodflux(sd)
              nearestx = sortxcen[1:nn] ;zeroth element will be the same position as the target image
              nearesty = sortycen[1:nn]
              nearestflux = sortflux_m[1:nn]
              
                                ;===========
                                ;with weightnp
                                ;------------
              goodxnp = fltarr(ngood + 1)
              goodynp = fltarr(ngood + 1)
              goodfluxnp = fltarr(ngood + 1)
              goodsqrtnp = fltarr(ngood+1)
              goodxnp[0] = xcen[j]
              goodynp[0] = ycen[j]
              goodfluxnp[0] = flux_m[j]
              goodsqrtnp[0] = sqrtnp[j]
              goodxnp[1:*] = xcen(good)
              goodynp[1:*] = ycen(good)
              goodfluxnp[1:*] = flux_m(good)
              goodsqrtnp[1:*] = sqrtnp(good)
              
                                ; try the brute force way
              dist = distance_np(goodx, goody, goodsqrtnp,0, chname)
              sd = sort(dist)
              sortdist = dist(sd)
              sortxcen = goodx(sd)
              sortycen = goody(sd)
              sortflux_m = goodflux(sd)
              sortsqrtnp = goodsqrtnp(sd)
              
              nearestxnp = sortxcen[1:nn] ;zeroth element will be the same position as the target image
              nearestynp = sortycen[1:nn]
              nearestfluxnp = sortflux_m[1:nn]
              nearestsqrtnp = sortsqrtnp[1:nn]
              
           endelse              ;end in transit
           
                                ;calculate sigmas on the nearest neighbors.
           stdxcen = stddev(nearestx)
           stdycen = stddev(nearesty)
           sigmax[j] = stdxcen
           sigmay[j] = stdycen
           
                                ;fix sigmas to ballard values
           if keyword_set(ballard_sigma) then begin
                                ;values from Ballard et al. 2010 PASP
              stdxcen = 0.017
              stdycen = 0.0043
           endif
           
           w = weight(stdxcen, stdycen, nearestx, nearesty,  xcen(j), ycen(j), nearestflux)
           warr[j] = w
                                ; print, 'testing', flux_m(j), w,  flux_m(j) / w
           flux(j) = flux_m2(j) / w
           fluxerr(j) = fluxerr_m2(j) / w
           
;---------------------
           
           stdxcennp = stddev(nearestxnp)
           stdycennp = stddev(nearestynp)
           stdsqrtnp = stddev(nearestsqrtnp)
           sigma_np[j] = stdsqrtnp
           
           w_np = weight_np(stdxcennp, stdycennp, stdsqrtnp, nearestxnp, nearestynp, nearestsqrtnp, xcen(j), ycen(j), sqrtnp(j), nearestfluxnp)
           warr_np[j] = w_np
           flux_np(j) = flux_m(j) / w_np
           fluxerr_np(j) = fluxerr_m(j) / w_np
                                ;--------------------
           
        endfor
        
;  bad = where(finite(flux) lt 1, badcount)
;  print, 'nan? ', badcount
        
        
;plot the results
        p1 = plot(time[0:ni-1]/60./60., flux_m[0:ni-1]/ median(flux_m[0:ni-1]), '1s', sym_size = 0.1,   sym_filled = 1,color = 'black', xtitle = 'Time (hrs)', ytitle = 'Flux', title = planetname, name = 'raw flux', yrange =[0.93, 1.15])
        p4 =  plot(time[0:ni-1]/60./60., (corrflux[0:ni-1] /median( corrflux[0:ni-1])) + 0.05, '1s', sym_size = 0.1,   sym_filled = 1,color = 'grey',/overplot, name = 'pmap corr')
        p2 = plot(time_0/60./60., flux/median(flux) -0.05, '1s', sym_size = 0.1,   sym_filled = 1,color = 'red', /overplot, name = 'position corr')
        p3 = plot(time_0/60./60., flux_np /median(flux_np)+ 0.1, '1s', sym_size = 0.1,   sym_filled = 1,color = 'blue', /overplot, name = 'position + np')
        
        
        p1 = plot(phase_0, flux_m[0:ni-1]/ median(flux_m[0:ni-1]), '1s', sym_size = 0.1,   sym_filled = 1,color = 'black', xtitle = 'Time (hrs)', ytitle = 'Flux', title = planetname, name = 'raw flux', yrange =[0.93, 1.15])
        p4 =  plot(phase_0, (corrflux[0:ni-1] /median( corrflux[0:ni-1])) + 0.05, '1s', sym_size = 0.1,   sym_filled = 1,color = 'grey',/overplot, name = 'pmap corr')
        p2 = plot(phase_0, flux/median(flux) -0.05, '1s', sym_size = 0.1,   sym_filled = 1,color = 'red', /overplot, name = 'position corr')
        p3 = plot(phase_0, flux_np /median(flux_np)+ 0.1, '1s', sym_size = 0.1,   sym_filled = 1,color = 'blue', /overplot, name = 'position + np')
        
        xtest = findgen(n_elements(ndimages))
        ptest = plot(xtest, ndimages, yrange = [0, 0.1], xtitle = 'Some indication of time with eclipse removed', ytitle = 'average distance to nearest neighbors')
        ptest.save, dirname+'nn_dist.png'
                                ; l = legend(target = [p1, p4, p2,p3], position = [1.5, 1.18], /data, /auto_text_color)
        
;    print, 'mean and stddev of sigmax', mean(sigmax), stddev(sigmax)
;     print, 'mean and stddev of sigmay', mean(sigmay), stddev(sigmay)
;     print, 'mean and stddev of sigmanp', mean(sigma_np), stddev(sigma_np)
;     print, 'mean and stddev of furthestx', mean(furthestx), stddev(furthestx)
;     print, 'mean and stddev of furthesty', mean(furthesty), stddev(furthesty)
;     print, 'mean and stddev of deltatime', mean(delta_time), stddev(delta_time)
;     print, '------'
;     if ni gt 12000 then print, 'stddev of raw, pmap, position, position+np corr', stddev(flux_m[12000:ni-1],/nan),stddev(corrflux[12000:ni-1],/nan), stddev(flux[12000:*],/nan), stddev(flux_np[12000:*],/nan)
        

     save, /all, filename =strcompress(dirname + 'pixphasecorr_ch'+chname+'_'+aorname(a)+'.sav')


  endif

     
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
  
   ;gaussian weighting function including noise pixel
  gaussx = exp( -((nearestx - xcenj)^2)/(2*stdxcen^2) )
  gaussy = exp(-((nearesty  - ycenj)^2)/(2*stdycen^2) )
  gaussnp = exp(-((nearestsqrtnp  - sqrtnpj)^2)/(2*stdsqrtnp^2) )

  ;now sum
  w = total((gaussx*gaussy*gaussnp*nearestflux)/total(gaussx*gaussy*gaussnp))

  return, w

end


function distance_np, xcen, ycen, sqrtnp, j, chname
  ;calculate the "distance" from the working centroid to all other centroids.
  if chname eq 1 then  b = 0.8 else b = 1.0 ; from knutson et al. 2012
                       ; for 3.6micron channel taken from paper
  dist = (xcen - xcen(j))^2 + ((ycen -ycen(j))/b)^2 + (sqrtnp - sqrtnp(j))^2

  return, dist

end

function distance, xcen, ycen,  j, chname
                                ;calculate the "distance" from the working centroid to all other centroids.
 
  if chname eq 1 then  b = 0.8 else b = 1.0 ; from knutson et al. 2012
                      ; for 3.6micron channel taken from paper
  dist = (xcen - xcen(j))^2 + ((ycen -ycen(j))/b)^2 

  return, dist

end

function mask_signal, phase, period, utmjd_center, transit_duration
       ;turn bmjd into phase
;   bmjd_dist = bmjd - utmjd_center ; how many UTC away from the transit center
;  phase =( bmjd_dist / period )- fix(bmjd_dist/period)

                                ;ok, but now I want -0.5 to 0.5, not 0 to 1
                                ;need to be careful here because subtracting half a phase will put things off, need something else
;  pa = where(phase gt 0.5,pacount)
;  if pacount gt 0 then phase[pa] = phase[pa] - 1.0
  ;plothist, phase, xhist, yhist, bin = 0.02,/noplot
  ;tt = plot(xhist, yhist, xtitle = 'phase')
                                ;turn transit duration into phase
  transit_duration = transit_duration / 60/24.       ; now in days
  transit_phase = transit_duration / period          ; what fraction of the phase is this in transit (or eclipse)
  print, 'test transit phase', transit_phase
  
  bad_t = where(phase ge 0.D - transit_phase/2. and phase le 0.D + transit_phase/2.,n_bad_t)
  bad_e1 = where(phase ge 0.5 - transit_phase/2., n_bad_e1)
  bad_e2 = where(phase le -0.5 + transit_phase/2., n_bad_e2)
  
  print, 'testing fraction of bad phases', float(n_bad_t + n_bad_e1 +n_bad_e2 )/  float(n_elements(phase))
  
  s = dblarr(n_elements(phase)) + 1.D
  s(bad_t) = 0.
  s(bad_e1) = 0.
  s(bad_e2) = 0.
  return, s
end
