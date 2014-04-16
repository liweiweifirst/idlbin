function binning_function, a,bin_level, pmapcorr

  common bin_block

  timearr = [planethash[aorname(a),'timearr']]
     fluxarr = [planethash[aorname(a),'flux']]
     fluxerrarr = [planethash[aorname(a),'fluxerr']]
     corrfluxarr = [planethash[aorname(a),'corrflux']]
     corrfluxerrarr = [planethash[aorname(a),'corrfluxerr']]
     xarr = [planethash[aorname(a),'xcen']]
     yarr = [planethash[aorname(a),'ycen']]
     bkgd = [planethash[aorname(a),'bkgd']]
     bmjd = [planethash[aorname(a),'bmjdarr']]
     np = [planethash[aorname(a),'np']]
     npcentroids = [planethash[aorname(a),'npcentroids']]
     phase = [planethash[aorname(a),'phase']]

;     centerpixarr = [ planethash[aorname(a),'centerpixarr5']]
;     print, 'testing xarr', xarr[0:10]
     ;remove outliers, 
;     if pmapcorr eq 1 then begin 
     goodpmap = where(xarr lt mean(xarr) + 2.5*stddev(xarr) and xarr gt mean(xarr) -2.5*stddev(xarr) and xarr lt mean(xarr) +3.0*stddev(yarr) and yarr gt mean(yarr) - 3.0*stddev(yarr) and finite(corrfluxarr) gt 0  ,ngood_pmap, complement=badpmap) ;
 ;    endif else begin
     good = where(xarr lt mean(xarr) + 2.5*stddev(xarr) and xarr gt mean(xarr) -2.5*stddev(xarr) and xarr lt mean(xarr) +3.0*stddev(yarr) and yarr gt mean(yarr) - 3.0*stddev(yarr) ,ngood, complement=bad)
 ;    endelse
     
;     print, 'testing good', good[0:10]

     print, 'bad ',n_elements(bad), n_elements(good)
     print, 'badp ',n_elements(badpmap), n_elements(goodpmap)
     xarr = xarr[good]
     yarr = yarr[good]
     timearr = timearr[good]
     flux = fluxarr[good]
     fluxerr = fluxerrarr[good]
     corrflux = corrfluxarr[good]
     corrfluxerr = corrfluxerrarr[good]
     bmjdarr = bmjd[good]
     bkgdarr = bkgd[good]
     phasearr = phase[good]
     nparr = np[good]
     npcentarr = npcentroids[good]

;     centerpixarr = centerpixarr[good]

;and a second set for those that are in the sweet spot
     xarrp = xarr[goodpmap]
     yarrp = yarr[goodpmap]
     timearrp = timearr[goodpmap]
     fluxp = fluxarr[goodpmap]
     fluxerrp= fluxerrarr[goodpmap]
     corrfluxp = corrfluxarr[goodpmap]
     corrfluxerrp = corrfluxerrarr[goodpmap]
     bmjdarrp = bmjd[goodpmap]
     bkgdarrp = bkgd[goodpmap]
     phasearrp = phase[goodpmap]
     nparrp = np[goodpmap]
     npcentarrp = npcentroids[goodpmap]
    phasearrp = phase[goodpmap]
;     centerpixarrp = centerpixarr[goodpmap]

;     print, 'testing after outlier', n_elements(xarr), flux[0:10], xarr[0:10], corrfluxp[0:10]
; binning
     numberarr = findgen(n_elements(xarr))
     
     h = histogram(numberarr, OMIN=om, binsize = bin_level, reverse_indices = ri)
     print, 'omin', om, 'nh', n_elements(h)

     numberarrp = findgen(n_elements(xarrp))
     hp = histogram(numberarrp, OMIN=omp, binsize = bin_level, reverse_indices = rip)
     print, 'ominp', omp, 'nhp', n_elements(hp), n_elements(xarrp)


;mean together the flux values in each phase bin
     bin_flux = dblarr(n_elements(h))
     bin_fluxerr = bin_flux
     bin_corrflux= bin_flux
     bin_corrfluxerr= bin_flux
     bin_ncorr = bin_flux
     bin_timearr = bin_flux
     bin_bmjdarr = bin_flux
     bin_bkgd = bin_flux
     bin_bkgderr = bin_flux
     bin_xcen = bin_flux
     bin_ycen = bin_flux
     bin_phase = bin_flux
     bin_centerpix = bin_flux
     bin_np = bin_flux
     bin_npcent = bin_flux

     bin_fluxp = dblarr(n_elements(hp))
     bin_fluxerrp = bin_fluxp
     bin_corrfluxp= bin_fluxp
     bin_corrfluxerrp= bin_fluxp
     bin_ncorrp = bin_fluxp
     bin_timearrp = bin_fluxp
     bin_bmjdarrp = bin_fluxp
     bin_bkgdp = bin_fluxp
     bin_bkgderrp = bin_fluxp
     bin_xcenp = bin_fluxp
     bin_ycenp= bin_fluxp
     bin_phasep = bin_fluxp
     bin_centerpixp = bin_fluxp
     bin_nparrp = bin_fluxp
     bin_npcentarrp = bin_fluxp

     c = 0
     for j = 0L, n_elements(h) - 1 do begin

;get rid of the bins with no values and low numbers, meaning low
;overlap
;        print, 'testing ri', ri[j+1], ri[j] + 2
        if (ri[j+1] gt ri[j] + 2)  then begin ;require 3 elements in the bin
        
           meanclip, xarr[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
           bin_xcen[c] = meanx   ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
 
           meanclip, yarr[ri[ri[j]:ri[j+1]-1]], meany, sigmay
           bin_ycen[c] = meany   ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])

           meanclip, bkgdarr[ri[ri[j]:ri[j+1]-1]], meansky, sigmasky
           bin_bkgd[c] = meansky ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])

           meanclip, flux[ri[ri[j]:ri[j+1]-1]], meanflux, sigmaflux
           bin_flux[c] = meanflux ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])

           idataerr = fluxerr[ri[ri[j]:ri[j+1]-1]]
           bin_fluxerr[c] =   sqrt(total(idataerr^2))/ (n_elements(idataerr))
;           meanclip, fluxerr[ri[ri[j]:ri[j+1]-1]], meanfluxerr, sigmafluxerr
;           bin_fluxerr[c] = sigmafluxerr

           meanclip, nparr[ri[ri[j]:ri[j+1]-1]], meannp, sigmanp
           bin_np[c] = meannp ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])

;           meanclip, npcentarr[ri[ri[j]:ri[j+1]-1]], meannpcent, sigmanpcent
           bin_npcent[c] = 27; meannpcent ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])

           junk = where(finite(corrflux[ri[ri[j]:ri[j+1]-1]]) gt 0,ngood)
           bin_ncorr[c] = ngood

           meanclip, timearr[ri[ri[j]:ri[j+1]-1]], meantimearr, sigmatimearr
           bin_timearr[c]=meantimearr
           
          ; meanclip, phasearr[ri[ri[j]:ri[j+1]-1]], meanphasearr, sigmaphasearr
           meanphasearr = mean( phasearr[ri[ri[j]:ri[j+1]-1]],/nan)
           bin_phase[c]= meanphasearr

  
           meanbmjdarr = mean( bmjdarr[ri[ri[j]:ri[j+1]-1]],/nan)
           bin_bmjdarr[c]= meanbmjdarr

         ;can only compute means if there are values in there
;           if pmapcorr eq 1 then begin
;              meanclip, corrflux[ri[ri[j]:ri[j+1]-1]], meancorrflux, sigmacorrflux
;              meancorrflux = mean(corrflux[ri[ri[j]:ri[j+1]-1]],/nan)
;              bin_corrflux[c] = meancorrflux
;           print, 'finished corrfluxx'
;           endif

          ;xxxx this could change
           ;right now it is just the scatter in the bins
;           meanclip, corrfluxerr[ri[ri[j]:ri[j+1]-1]], meancorrfluxerr, sigmacorrfluxerr
;           bin_corrfluxerr[c] = sigmacorrfluxerr


;           meanclip, centerpixarr[ri[ri[j]:ri[j+1]-1]], meancenterpix, sigmacenterpix
;           bin_centerpix[c]= meancenterpix

;            meanclip, phasearr[ri[ri[j]:ri[j+1]-1]], meanphase, sigmaphasearr
;            bin_phase[c]= meanphase

 

;           meanclip, bkgderrarr[ri[ri[j]:ri[j+1]-1]], meanbkgderrarr, sigmabkgderrarr
 ;          bin_bkgderr[c] = meanbkgderrarr


           c = c + 1
        endif
     endfor
     
     bin_xcen = bin_xcen[0:c-1]
     bin_ycen = bin_ycen[0:c-1]
     bin_bkgd = bin_bkgd[0:c-1]
     bin_flux = bin_flux[0:c-1]
     bin_fluxerr = bin_fluxerr[0:c-1]
;     bin_corrflux = bin_corrflux[0:c-1]
     bin_timearr = bin_timearr[0:c-1]
     bin_bmjdarr = bin_bmjdarr[0:c-1]
;     bin_corrfluxerr = bin_corrfluxerr[0:c-1]
     bin_phase = bin_phase[0:c-1]
     bin_ncorr = bin_ncorr[0:c-1]
     bin_np = bin_np[0:c-1]
     bin_npcent = bin_npcent[0:c-1]
;     bin_centerpix = bin_centerpix[0:c-1]
;     print, 'bin_xcen', bin_xcen
;  bin_bkgderr = bin_bkgderr[0:c-1]
     
     ;---------------------------------------------
     ;do it again for the sweet spot points.
     ;xxx should clean this up and make it a function
     cp = 0
     for j = 0L, n_elements(hp) - 1 do begin

;get rid of the bins with no values and low numbers, meaning low overlap
        if (rip[j+1] gt rip[j] + 2)  then begin ;require 3 elements in the bin
;           print, 'binning together', n_elements(numberarr[rip[rip[j]:rip[j+1]-1]])
        ;print, 'binning', numberarr[rip[rip[j]:rip[j+1]-1]]
        
           meanclip, xarrp[rip[rip[j]:rip[j+1]-1]], meanx, sigmax
           bin_xcenp[cp] = meanx   ; mean(fluxarr[rip[rip[j]:rip[j+1]-1]])

           meanclip, yarrp[rip[rip[j]:rip[j+1]-1]], meany, sigmay
           bin_ycenp[cp] = meany   ; mean(fluxarr[rip[rip[j]:rip[j+1]-1]])

;           meanclip, centerpixarrp[ri[ri[j]:ri[j+1]-1]], meancenterpix, sigmacenterpix
;           bin_centerpixp[cp]= meancenterpix

           meanclip, bkgdarrp[rip[rip[j]:rip[j+1]-1]], meansky, sigmasky
           bin_bkgdp[cp] = meansky ; mean(fluxarr[rip[rip[j]:rip[j+1]-1]])

           meanclip, fluxp[rip[rip[j]:rip[j+1]-1]], meanflux, sigmaflux1
           bin_fluxp[cp] = meanflux ; mean(fluxarr[rip[rip[j]:rip[j+1]-1]])

           meanclip, nparrp[rip[rip[j]:rip[j+1]-1]], meannp, sigmanp
           bin_nparrp[cp] = meannp ; mean(fluxarr[rip[rip[j]:rip[j+1]-1]])

;           meanclip, npcentarrp[rip[rip[j]:rip[j+1]-1]], meannpcent, sigmanpcent
           bin_npcentarrp[cp] = 27;meannpcent ; mean(fluxarr[rip[rip[j]:rip[j+1]-1]])

           junk = where(finite(corrfluxp[rip[rip[j]:rip[j+1]-1]]) gt 0,ngood)
           bin_ncorrp[cp] = ngood
           ;can only compute means if there are values in there
           if pmapcorr eq 1 then begin
              meanclip, corrfluxp[rip[rip[j]:rip[j+1]-1]], meancorrflux, sigmacorrflux
;              meancorrflux = mean(corrflux[rip[rip[j]:rip[j+1]-1]],/nan)
              bin_corrfluxp[cp] = meancorrflux
           endif

           meanclip, timearrp[rip[rip[j]:rip[j+1]-1]], meantimearr, sigmatimearr
           bin_timearrp[cp]=meantimearr
           
;           meanclip, phasearrp[rip[rip[j]:rip[j+1]-1]], meanphasearr, sigmabmjdarr
           meanphasearr = mean(phasearrp[rip[rip[j]:rip[j+1]-1]],/nan)
           bin_phasep[cp]= meanphasearr

           meanbmjdarr = mean( bmjdarrp[rip[rip[j]:rip[j+1]-1]],/nan)
           bin_bmjdarrp[cp]= meanbmjdarr

           ;xxxx this could change
           ;ripght now it is just the scatter in the bins
           icorrdataerr = corrfluxerrp[rip[rip[j]:rip[j+1]-1]]
           bin_corrfluxerrp[cp] =   sqrt(total(icorrdataerr^2))/ (n_elements(icorrdataerr))
           idataerr = fluxerrp[rip[rip[j]:rip[j+1]-1]]
           bin_fluxerrp[cp] =   sqrt(total(idataerr^2))/ (n_elements(idataerr))

;           meanclip, corrfluxerrp[rip[rip[j]:rip[j+1]-1]], meancorrfluxerr, sigmacorrfluxerr
;           bin_corrfluxerrp[cp] = sigmacorrfluxerr
;           meanclip, fluxerrp[rip[rip[j]:rip[j+1]-1]], meanfluxerr, sigmafluxerr
;           bin_fluxerrp[cp] = sigmafluxerr

;           meanclip, bkgderrarr[rip[rip[j]:rip[j+1]-1]], meanbkgderrarr, sigmabkgderrarr
 ;          bin_bkgderr[cp] = meanbkgderrarr

           cp = cp + 1
        ;print, 'testing', j, phasearr[ri[ri[j]:ri[j+1]-1]]
        endif
     endfor
     
     bin_xcenp = bin_xcenp[0:cp-1]
     bin_ycenp = bin_ycenp[0:cp-1]
     bin_bkgdp = bin_bkgdp[0:cp-1]
     bin_fluxp = bin_fluxp[0:cp-1]
     bin_fluxerrp = bin_fluxerrp[0:cp-1]
     bin_corrfluxp = bin_corrfluxp[0:cp-1]
     bin_timearrp = bin_timearrp[0:cp-1]
     bin_bmjdarrp = bin_bmjdarrp[0:cp-1]
     bin_corrfluxerrp = bin_corrfluxerrp[0:cp-1]
     bin_phasep = bin_phasep[0:cp-1]
     bin_ncorrp = bin_ncorrp[0:cp-1]
     bin_nparrp = bin_nparrp[0:cp-1]
     bin_npcentarrp = bin_npcentarrp[0:cp-1]
;     bin_centerpixp = bin_centerpixp[0:cp-1]
;  bin_bkgderrp = bin_bkgderrp[0:cp-1]



;print, 'end binning, xcen, corrfluxp, flux, fluxp', bin_xcen[0:10], bin_corrfluxp[0:10], bin_flux[0:10], bin_fluxp[0:10]

return, 0

end
