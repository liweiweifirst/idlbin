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
pro pixphasecorr_noisepix, planetname, nn, apradius, chname, breatheap = breatheap, ballard_sigma = ballard_sigma

  t1 = systime(1)
;get all the necessary saved info/photometry
  planetinfo = create_planetinfo()
  if chname eq '2' then aorname= planetinfo[planetname, 'aorname_ch2'] else aorname = planetinfo[planetname, 'aorname_ch1'] 
  basedir = planetinfo[planetname, 'basedir']
;  chname = planetinfo[planetname, 'chname']
;  period = planetinfo[planetname, 'period']
;  utmjd_center = planetinfo[planetname, 'utmjd_center']
  exptime = planetinfo[planetname, 'exptime']
;  transit_duration = planetinfo[planetname, 'transit_duration']
  dirname = strcompress(basedir + planetname +'/')
  if keyword_set(breatheap) then  savefilename = strcompress(dirname + planetname +'_phot_ch'+chname+'_varap.sav') else savefilename = strcompress(dirname + planetname +'_phot_ch'+chname+'_'+string(apradius)+'.sav',/remove_all)

  restore, savefilename
;==========================================
exoplanet_data_file = '/Users/jkrick/idlbin/exoplanets.csv'
exosystem = strmid(planetname, 0, 7) + ' b' ;'HD 209458 b' ;
if planetname eq 'WASP-52b' then teq_p = 1315
if chname eq '2' then lambdaname  = '4.5'
if chname eq '1' then lambdaname  = '3.6'
get_exoplanet_data,EXOSYSTEM=exosystem,MSINI=msini,MSTAR=mstar,RSTAR = rstar, TRANSIT_DEPTH=transit_depth,RP_RSTAR=rp_rstar,$
                   AR_SEMIMAJ=ar_semimaj,$
                   TEQ_P=1315,TEFF_STAR=teff_star,SECONDARY_DEPTH=secondary_depth,SECONDARY_LAMBDA=lambdaname,$
                   INCLINATION=inclination,MJD_TRANSIT=mjd_transit,P_ORBIT=p_orbit,EXODATA=exodata,RA=ra,DEC=dec,VMAG=vmag,$
                   DISTANCE=distance,ECC=ecc,T14=t14,F36=f36,F45=f45,FP_FSTAR0=fp_fstar0,VERBOSE=verbose
ra_ref = ra*15.                 ; comes in hours!
dec_ref = dec
utmjd_center = mjd_transit
period = p_orbit
semimaj = ar_semimaj
dstar = 2.*rstar
m_star = mstar
;t_dur = 13.*dstar*sqrt(semimaj/m_star)
;b = semimaj* cos(inclination*!Pi/180.)
;print, period, rstar, rp_rstar*rstar, b, semimaj, inclination
t_dur =  t14  ; in days
;t_dur = transit_duration( period, rstar, rp_rstar * rstar, b, semimaj)
print,'transit duration in days', t_dur
;==========================================


startaor = 1
stopaor =   n_elements(aorname) - 1



  for a = startaor, stopaor do begin  ;run through all AORs
     print, 'working on aor', aorname(a)
     np = planethash[aorname(a),'npcentroids']  ; np is noise pixel, using value from box_centroider, not noisepix
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
        sqrtnp = sqrt(np)
        
        corrflux = planethash[aorname(a), 'corrflux'] ;pmap corrected
        corrfluxerr = planethash[aorname(a), 'corrfluxerr']
        
;need to put all aor's togehter, otherwise the normalization of
;the weighting process is flattening the light curves.
;and need to do this dynamically which is slow
                                ;could do this faster by keeping track
                                ;of the total number of images in photexoplanet

        if a eq startaor then begin
           xcenarr = xcen 
           ycenarr = ycen
           nparr = np
           sqrtnparr = sqrtnp
           flux_marr = flux_m
           fluxerr_marr = fluxerr_m 
           bmjdarr = bmjd
           phasearr = phase
           corrfluxarr = corrflux
           corrfluxerrarr = corrfluxerr
           timearr = (planethash[aorname(a),'timearr'] - (planethash[aorname(0),'timearr'])(0)) ; XXXXX careful, I used aorname(0)
        endif else begin
           xcenarr = [xcenarr, xcen]
           ycenarr = [ycenarr, ycen]
           nparr = [nparr, np]
           sqrtnparr = [sqrtnparr, sqrtnp]
           flux_marr = [flux_marr, flux_m]
           fluxerr_marr = [fluxerr_marr,fluxerr_m]
           phasearr = [phasearr, phase]
           corrfluxarr = [corrfluxarr, corrflux]
           corrfluxerrarr = [corrfluxerrarr,corrfluxerr]
           timearr = [timearr, (planethash[aorname(a),'timearr'] - (planethash[aorname(0),'timearr'])(0))]
        endelse
     endif   ;not a snapshot

  endfor                        ; for each AOR
;====================================================================================
                                ;calculate standard deviations of entire xcen, ycen,and sqrtnp
     ;stdxcen = stddev(xcen)
     ;stdycen = stddev(ycen)
     ;stdsqrtnp = stddev(sqrtnp)
     
   ;change this to a smaller number to test code in less time than a full run
        ni =  n_elements(xcenarr) 
        print, 'ni, phase', ni, n_elements(phasearr)
                
                                ;setup arrays for the corrected fluxes
        flux = dblarr(ni)       ; fltarr(n_elements(flux_m))
        fluxerr = flux
        flux_np = flux    ; fltarr(n_elements(flux_m))
        fluxerr_np = flux
        time_0 = timearr[0:ni - 1]
        phase_0 = phasearr[0:ni-1]
        warr = flux
        warr_np= flux
        sigmax = flux
        sigmay = flux
        sigma_np = flux
        furthestx = flux
        furthesty= flux
        delta_time = flux
        delta_time_np =  flux
        ndimages = flux

        xcen2 = xcenarr
        ycen2 = ycenarr
        sqrtnp2 = sqrtnparr
        flux_m2 = flux_marr
        fluxerr_m2 = fluxerr_marr
        time_02  = time_0
        
                                ;mask intervals in time where astrophysical signals exist.
                                ;I know where the transits and eclipses are
        ;mess around with reducing transit period
;        t_dur = t_dur / 2.
        s = mask_signal( phasearr, period, utmjd_center, t_dur)
 ;test without masking signal
 ;       s = xcen2
                                ;make sure the transit doesn't get included as a nearest neighbor
        good = where(s gt 0, ngood, complement = bad)
        print, 'ngood', ngood, n_elements(bad)
        xcen2(bad) = 1E5
        ycen2(bad) = 1E5
        sqrtnp2(bad) = 1E5
        
                                ;do the nearest neighbors run with triangulation
                                ;http://www.idlcoyote.com/code_tips/slowloops.html
                                ;this returns a sorted list of the nn nearest neighbors
        
        nearest = nearest_neighbors_DT(xcen2,ycen2,chname,DISTANCES=nearest_d,NUMBER=nn)
        nearest_np = nearest_neighbors_np_DT(xcen2,ycen2,sqrtnp2,chname,DISTANCES=nearest_np_d,NUMBER=nn)

        for j = 0L,   ni - 1 do begin ;for each image (centroid)
          ;--------------------
          ;find the weighting function without using noise pixel
           ;--------------------
           
           if s[j] gt 0 then begin ;out of transit
              ;not inside a transit, so do the normal nearest neighbor search for weights.
              nearestx = xcen2(nearest(*,j))
              nearesty = ycen2(nearest(*,j))
              nearestflux = flux_m2(nearest(*,j))
              nearestfluxerr = fluxerr_m2(nearest(*,j))
              nearesttime = time_02(nearest(*,j))
              
               ;what is the time distribution like of the points chosen as nearest in position
               ;track the range in time for each point
              delta_time(j) = abs(time_0[j]- nearesttime(n_elements(nearesttime)-1))
;                                       
                                ;make sure that the nearest neighbor is not the point itself
                                ;if it is, then get rid of that one and just use the nearest n-1
                                ;this should never really happen because I find the nearest 
                                ;neighbor by finding the distance from the target to all other points.  
                                ;So there is never the case of finding the distance to itself.
              ;the few cases it finds probably are duplicate positions.
              if  xcen2(j) eq nearestx(0) and ycen2(j) eq nearesty(0) then begin
;                 print, 'got a nearest neighbor as the target', j
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
              goodx[0] = xcenarr[j]
              goody[0] = ycenarr[j]
              goodflux[0] = flux_marr[j]
              goodx[1:*] = xcenarr(good)
              goody[1:*] = ycenarr(good)
              goodflux[1:*] = flux_marr(good)
              
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
              goodxnp[0] = xcenarr[j]
              goodynp[0] = ycenarr[j]
              goodfluxnp[0] = flux_marr[j]
              goodsqrtnp[0] = sqrtnparr[j]
              goodxnp[1:*] = xcenarr(good)
              goodynp[1:*] = ycenarr(good)
              goodfluxnp[1:*] = flux_marr(good)
              goodsqrtnp[1:*] = sqrtnparr(good)
              
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
           
           w = weight(stdxcen, stdycen, nearestx, nearesty,  xcenarr(j), ycenarr(j), nearestflux)
           warr[j] = w
                                ; print, 'testing', flux_m(j), w,  flux_m(j) / w
           flux(j) = flux_m2(j) / w
           fluxerr(j) = fluxerr_m2(j) / w
           
;---------------------
           
           stdxcennp = stddev(nearestxnp)
           stdycennp = stddev(nearestynp)
           stdsqrtnp = stddev(nearestsqrtnp)
           sigma_np[j] = stdsqrtnp
           
           w_np = weight_np(stdxcennp, stdycennp, stdsqrtnp, nearestxnp, nearestynp, nearestsqrtnp, xcenarr(j), ycenarr(j), sqrtnparr(j), nearestfluxnp)
           warr_np[j] = w_np
           flux_np(j) = flux_marr(j) / w_np
           fluxerr_np(j) = fluxerr_marr(j) / w_np
                                ;--------------------
           
        endfor

        
;  bad = where(finite(flux) lt 1, badcount)
;  print, 'nan? ', badcount
        save, /all, filename =strcompress(dirname + 'pixphasecorr_ch'+chname+'_'+string(apradius)+'.sav',/remove_all)


        print, 'about to plot blue ', median(flux_np), n_elements(flux_marr), n_elements(corrfluxarr), n_elements(flux), n_elements(flux_np)
;plot the results
;        p1 = plot(time[0:ni-1]/60./60., flux_marr[0:ni-1]/ median(flux_marr[0:ni-1]), '1s', sym_size = 0.1,   sym_filled = 1,color = 'black', xtitle = 'Time (hrs)', ytitle = 'Flux', title = planetname, name = 'raw flux', yrange =[0.93, 1.15])
;        p4 =  plot(time[0:ni-1]/60./60., (corrfluxarr[0:ni-1] /median( corrfluxarr[0:ni-1])) + 0.05, '1s', sym_size = 0.1,   sym_filled = 1,color = 'grey',/overplot, name = 'pmap corr')
;        p2 = plot(time_0/60./60., flux/median(flux) -0.05, '1s', sym_size = 0.1,   sym_filled = 1,color = 'red', /overplot, name = 'position corr')
;        p3 = plot(time_0/60./60., flux_np /median(flux_np)+ 0.1, '1s', sym_size = 0.1,   sym_filled = 1,color = 'blue', /overplot, name = 'position + np')
        
        
        p1 = plot(phase_0, flux_marr[0:ni-1]/ median(flux_marr[0:ni-1]), '1s', sym_size = 0.1,   sym_filled = 1,color = 'black', xtitle = 'Phase', ytitle = 'Flux', title = planetname, name = 'raw flux', yrange =[0.93, 1.15])
        p4 =  plot(phase_0, (corrfluxarr[0:ni-1] /median( corrfluxarr[0:ni-1])) + 0.05, '1s', sym_size = 0.1,   sym_filled = 1,color = 'grey',/overplot, name = 'pmap corr')
        p2 = plot(phase_0, flux/median(flux) -0.05, '1s', sym_size = 0.1,   sym_filled = 1,color = 'red', /overplot, name = 'position corr')
        p3 = plot(phase_0, flux_np /median(flux_np)+ 0.1, '1s', sym_size = 0.1,   sym_filled = 1,color = 'blue', /overplot, name = 'position + np')
        
        xtest = findgen(n_elements(ndimages))
        ptest = plot(xtest, ndimages, yrange = [0, 0.1], xtitle = 'Some indication of time with eclipse removed', ytitle = 'average distance to nearest neighbors')
        ptest.save, dirname+'nn_dist.png'
                                ; l = legend(target = [p1, p4, p2,p3], position = [1.5, 1.18], /data, /auto_text_color)
        
;    print, 'mean and stddev of sigmax', mean(sigmax), stddev(sigmax)
;     print, 'mean and stddev of sigmay', mean(sigmay), stddev(sigmay)
;     print, 'mean and stddev of sigmanp', mean(sigma_np), stddev(sigma_np)
     print, 'mean and stddev of furthestx', mean(furthestx), stddev(furthestx)
     print, 'mean and stddev of furthesty', mean(furthesty), stddev(furthesty)
;     print, 'mean and stddev of deltatime', mean(delta_time), stddev(delta_time)
;     print, '------'
;     if ni gt 12000 then print, 'stddev of raw, pmap, position, position+np corr', stddev(flux_m[12000:ni-1],/nan),stddev(corrflux[12000:ni-1],/nan), stddev(flux[12000:*],/nan), stddev(flux_np[12000:*],/nan)
        



;  endif

     
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
     

;  endfor
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

function mask_signal, phase, period, utmjd_center, t_dur
                                 ;turn transit duration into phase
  transit_dur = t_dur       ; now in days  / 60/24. 
  transit_phase = transit_dur / period          ; what fraction of the phase is this in transit (or eclipse)
  print, 'test transit phase', transit_phase
  
  bad_t = where(phase ge 0.D - transit_phase/2. and phase le 0.D + transit_phase/2.,n_bad_t)
  bad_e1 = where(phase ge 0.5 - transit_phase/2., n_bad_e1)
  bad_e2 = where(phase le -0.5 + transit_phase/2., n_bad_e2)
  
  print, 'testing fraction of bad phases', float(n_bad_t + n_bad_e1 +n_bad_e2 )/  float(n_elements(phase))
;  if n_bad_t gt 0 then print, 'testing masked transit phases', phase(bad_t)
;  if n_bad_e1 gt 0 then print, 'testing e1 phases', phase(bad_e1)
;  if n_bad_e2 gt 0 then print, 'testing e2 phases', phase(bad_e2)

  s = dblarr(n_elements(phase)) + 1.D
  s(bad_t) = 0.
  s(bad_e1) = 0.
  s(bad_e2) = 0.
  return, s
end
