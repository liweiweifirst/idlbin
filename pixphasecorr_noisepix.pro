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
  time = (planethash[aorname(2),'timearr'] - (planethash[aorname(2),'timearr'])(0))/60./60.  ; in hours from beginning of obs.
  np2 = np^2
  
  ;setup an array for the corrected fluxes
  flux = fltarr(n_elements(flux_m))
  for j = 0,  n_elements(xcen) - 1 do begin ;for each image (centroid)
     dist = distance_np(xcen, ycen, np, j)
;     print, 'xcen', xcen(j)
         ;now sort arrays by dist from closest to furthest
     sd = sort(dist)
     sortdist = dist(sd)
     sortxcen = xcen(sd)
     sortycen = ycen(sd)
     sortnp = np(sd)
     sortnp2 = sortnp^2

     ;take the n "nearest" centroids
     n = 50
     nearestx = sortxcen[1:n]  ;zeroth element will be the same position as the target image
     nearesty = sortycen[1:n]
     nearestnp = sortnp[1:n]
     nearestnp2 = sortnp2[1:n]

;     print, 'nearestx', nearestx

     ;find the weighting function
     xcenj = xcen(j)
     ycenj = ycen(j)
     np2j = np2(j)
     w = weight(nearestx, nearesty, nearestnp2, xcenj, ycenj, np2j)
;     print, 'w', w

     ;correct the data by the weights
     flux(j) = flux_m(j) / w
;     print, 'j, fluxes', j, flux_m(j), flux(j)
  endfor

  bad = where(finite(flux) lt 1, badcount)
  print, 'nan? ', badcount

  plothist, flux, xhist, yhist, bin = 0.01,/nan,/noplot
  pt = plot(xhist, yhist)

;plot the results
;  p1 = plot(time, flux_m, '1s', sym_size = 0.1,   sym_filled = 1,color = 'black', xtitle = 'Time (hrs)', ytitle = 'Flux', title = planetname)
;  p1 = plot(time, flux, '1s', sym_size = 0.1,   sym_filled = 1,color = 'red', /overplot)

  
end


function distance_np, xcen, ycen, np, j
  ;calculate the "distance" from the working centroid to all other centroids.
  b = 0.8                       ; for 3.6micron channel taken from paper
  dist = (xcen - xcen(j))^2 + ((ycen -ycen(j))/b)^2 + (sqrt(np) - sqrt(np(j)))^2

  return, dist

end

function weight, nearestx, nearesty, nearestnp2,  xcenj, ycenj, np2j

  ;measure sigmas of each distribution
  ;XXX is this supposed to be sigma over n, or over all elements of position arrays?
  ;sorta has to be over n, otherwise it wouldn't be a function of j
  sigmax = stddev(nearestx)
  sigmay = stddev(nearesty)
  sigmanp2 = stddev(nearestnp2)

  ;gaussian weighting function
  gaussx = exp( -((nearestx - xcenj)^2)/(2*sigmax^2) )
  gaussy = exp(-((nearesty  - ycenj)^2)/(2*sigmay^2) )
  gaussnp = exp(-((nearestnp2  - np2j)^2)/(2*sigmanp2^2) )

  ;now sum
  w = total(gaussx*gaussy*gaussnp)

  return, w

end
