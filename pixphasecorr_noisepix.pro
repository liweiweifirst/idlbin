pro pixphasecorr_noisepix, planetname
;this code implements the Knutson et al. 2012 technique of correcting for pixel phase effect
;np is noise pixel

;get all the necessary saved info/photometry
  planetinfo = create_planetinfo()
  aorname = planetinfo[planetname, 'aorname']
  basedir = planetinfo[planetname, 'basedir']
  chname = planetinfo[planetname, 'chname']
  dirname = strcompress(basedir + planetname +'/')
  savefilename = strcompress(dirname + planetname +'_phot_ch'+chname+'.sav')
  restore, savefilename
  np = planethash[aorname(2),'np']   ;the second AOR has phase 0.4- 0.1, so no transits or eclipses
  xcen = planethash[aorname(2), 'xcen']
  ycen = planethash[aorname(2), 'ycen']
  flux_m = planethash[aorname(2), 'flux']
  corrflux = planethash[aorname(2), 'corrflux']  ;pmap corrected
  time = (planethash[aorname(2),'timearr'] - (planethash[aorname(2),'timearr'])(0))/60./60.  ; in hours from beginning of obs.
  sqrtnp = sqrt(np)

  ;calculate standard deviations of entire xcen, ycen,and sqrtnp
  stdxcen = stddev(xcen)
  stdycen = stddev(ycen)
  stdsqrtnp = stddev(sqrtnp)

    ;setup an array for the corrected fluxes
  ni =  n_elements(xcen)
  flux = dblarr(ni); fltarr(n_elements(flux_m))
  flux_np = dblarr(ni); fltarr(n_elements(flux_m))
  time_0 = time[0:ni - 1]
;  warr = dblarr(ni)
;  warr_np= dblarr(ni)
  n = 50                        ; tried 100 doesn't make a difference

  for j = 0,   ni - 1 do begin ;for each image (centroid)
     ;normal distance in x and y
     ;----------------------------
     dist = distance(xcen, ycen, np, j)
     ;print, 'dist', dist
;     print, 'xcen', xcen(j)
         ;now sort arrays by dist from closest to furthest
     sd = sort(dist)

     sortdist = dist(sd)
     ;print, 'sd', sortdist[0:10]
     sortxcen = xcen(sd)
     sortycen = ycen(sd)

     ;take the n "nearest" centroids
     nearestx = sortxcen[1:n]  ;zeroth element will be the same position as the target image
     nearesty = sortycen[1:n]


     ;distance in x y and np
     ;----------------------------
     dist_np = distance_np(xcen, ycen,np, j)
     sd_np = sort(dist_np)

     sortdist_np = dist_np(sd_np)
     ;print, 'sd', sortdist[0:10]
     sortxcen_np = xcen(sd_np)
     sortycen_np = ycen(sd_np)
     sortsqrtnp_np = sqrtnp(sd_np)

     ;take the n "nearest" centroids
     nearestx_np = sortxcen_np[1:n]  ;zeroth element will be the same position as the target image
     nearesty_np = sortycen_np[1:n]
     nearestsqrtnp_np = sortsqrtnp_np[1:n]
;----------------------------

     ;print, 'nearestx', xcen(j), nearestx
     ;print, 'nearesty', ycen(j), nearesty

     ;find the weighting function
     xcenj = xcen(j)
     ycenj = ycen(j)
     sqrtnpj = sqrtnp(j)
     w = weight(stdxcen, stdycen, nearestx, nearesty,  xcenj, ycenj)

     w_np = weight_np(stdxcen, stdycen, stdsqrtnp, nearestx_np, nearesty_np, nearestsqrtnp_np, xcenj, ycenj, sqrtnpj)
;     print, 'w', w, w_np
;     warr[j] = w
;     warr_np[j] = w_np
     
     ;correct the data by the weights
     flux(j) = flux_m(j) / w
     flux_np(j) = flux_m(j) / w_np
;     print, 'j, fluxes', j, flux_m(j), flux(j), flux_np(j)

     
  endfor

;  bad = where(finite(flux) lt 1, badcount)
;  print, 'nan? ', badcount

 
;plot the results
  p1 = plot(time[0:ni-1], flux_m[0:ni-1]/ median(flux_m[0:ni-1]), '1s', sym_size = 0.1,   sym_filled = 1,color = 'black', xtitle = 'Time (hrs)', ytitle = 'Flux', title = planetname, name = 'raw flux', yrange =[0.93, 1.18])
  p4 =  plot(time[0:ni-1], (corrflux[0:ni-1] /median( corrflux[0:ni-1])) + 0.05, '1s', sym_size = 0.1,   sym_filled = 1,color = 'grey',/overplot, name = 'pmap corr')
  p2 = plot(time_0, flux/median(flux) -0.05, '1s', sym_size = 0.1,   sym_filled = 1,color = 'red', /overplot, name = 'position corr')
  p3 = plot(time_0, flux_np /median(flux_np)+ 0.1, '1s', sym_size = 0.1,   sym_filled = 1,color = 'blue', /overplot, name = 'position + np')

  l = legend(target = [p1, p4, p2,p3], position = [1.5, 1.18], /data, /auto_text_color)

 ; print, 'flux', flux
  save, /all, filename =strcompress(dirname + planetname +'_pixphasecorr_ch'+chname+'_varap.sav')

;  plothist, warr, xhist, yhist, bin = 0.5, /noplot
;  plothist, warr_np, xhistnp, yhistnp,bin = 0.5, /noplot
;  wp = plot(xhist, yhist, color = 'red')
;  wp = plot(xhistnp, yhistnp, color = 'blue', /overplot)

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


function weight_np, stdxcen, stdycen, stdsqrtnp,nearestx, nearesty, nearestsqrtnp,  xcenj, ycenj, sqrtnpj

  ;measure sigmas of each distribution
  ;XXX is this supposed to be sigma over n, or over all elements of position arrays?
  ;sorta has to be over n, otherwise it wouldn't be a function of j
  ;sigmax = stdxcen;stddev(nearestx)
  ;sigmay = stdycen              ; stddev(nearesty)
 ; sigmanp2 = stddev(nearestnp2)
  
  ;gaussian weighting function
  gaussx = exp( -((nearestx - xcenj)^2)/(2*stdxcen^2) )
  gaussy = exp(-((nearesty  - ycenj)^2)/(2*stdycen^2) )
  gaussnp = exp(-((nearestsqrtnp  - sqrtnpj)^2)/(2*stdsqrtnp^2) )
;  gaussx = exp( -((nearestx - xcenj)^2)/(2*sigmax^2) )
;  gaussy = exp(-((nearesty  - ycenj)^2)/(2*sigmay^2) )
;  gaussnp = exp(-((nearestnp2  - np2j)^2)/(2*sigmanp2^2) )

  ;now sum
  w = total(gaussx*gaussy*gaussnp)

  return, w

end

function weight, stdxcen, stdycen, nearestx, nearesty, xcenj, ycenj

  ;measure sigmas of each distribution
  ;XXX is this supposed to be sigma over n, or over all elements of position arrays?
  ;sorta has to be over n, otherwise it wouldn't be a function of j
  sigmax = stdxcen; stddev(nearestx)
  sigmay = stdycen; stddev(nearesty)
 
  ;gaussian weighting function
  gaussx = exp( -((nearestx - xcenj)^2)/(2*sigmax^2) )
  gaussy = exp(-((nearesty  - ycenj)^2)/(2*sigmay^2) )
  
  ;now sum
  w = total(gaussx*gaussy)

  return, w

end
