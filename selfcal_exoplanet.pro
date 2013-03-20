pro selfcal_exoplanet, planetname, bin_level, binning=binning, sine=sine
  
;example call: selfcal_exoplanet, 'wasp15', 10*63L, /binning

;run code to read in all the input planet parameters
planetinfo = create_planetinfo()
chname = planetinfo[planetname, 'chname']
ra_ref = planetinfo[planetname, 'ra']
dec_ref = planetinfo[planetname, 'dec']
aorname = planetinfo[planetname, 'aorname']
basedir = planetinfo[planetname, 'basedir']
utmjd_center =  planetinfo[planetname, 'utmjd_center']
transit_duration =  planetinfo[planetname, 'transit_duration']
period =  planetinfo[planetname, 'period']
intended_phase = planetinfo[planetname, 'intended_phase']


;  bin_level = 10.*63L
  startnum = intarr(n_elements(aorname))

;---------------
  dirname = strcompress(basedir + planetname +'/')
  savefilename = strcompress(dirname + planetname +'_phot_ch'+chname+'.sav')
  restore, savefilename
  
;  transit_duration = transit_duration /60./24. ; in days
;  for a = 0, n_elements(aorname) - 1 do  begin
;     (planethash[aorname(a),'bmjdarr']) = (((planethash[aorname(a),'bmjdarr']) -  utmjd_center)/period) + intended_phase
;  endfor
  
;-------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------

for a = 0, 0 do begin;  n_elements(aorname) - 1 do begin


 ;for chopping off some initial part of the light curve

;   print, ' fluxarr first', n_elements(AOR55cnc[a].flux)
  xarr = (planethash[aorname(a),'xcen'])[startnum(a):*]
  yarr = (planethash[aorname(a),'ycen'])[startnum(a):*]
  timearr = (planethash[aorname(a),'timearr'])[startnum(a):*]
  fluxerr = (planethash[aorname(a),'fluxerr'])[startnum(a):*]
  flux = (planethash[aorname(a),'flux'])[startnum(a):*]
  corrflux = (planethash[aorname(a),'corrflux'])[startnum(a):*]
  corrfluxerr = (planethash[aorname(a),'corrfluxerr'])[startnum(a):*]
  bmjd = (planethash[aorname(a),'bmjdarr'])[startnum(a):*]
;  utcs = (planethash[aorname(a),'utcsarr'])[startnum(a):*]

    ;now try to get them all within the same [0,1] phase  
  ;taken from plot_exoplanet.pro
  bmjd_dist = bmjd - utmjd_center ; how many UTC away from the transit center
  phase =( bmjd_dist / period )- fix(bmjd_dist/period)
  pa = where(phase gt 0.5,pacount)
  if intended_phase ne 0.5 then begin
     if pacount gt 0 then phase[pa] = phase[pa] - 1.0
  endif

  print, 'in the beginning', phase[0], phase[n_elements(phase) - 2]


;get rid of outliers
 print, ' fluxarr', n_elements(flux), n_elements(planethash[aorname(a),'flux'])

 print, 'positions', mean(xarr) + 3.0*stddev(xarr),  mean(xarr) -3.0*stddev(xarr),  mean(yarr) +3.0*stddev(yarr), mean(yarr) - 3.0*stddev(yarr)

  good = where(xarr lt mean(xarr) + 3.0*stddev(xarr) and xarr gt mean(xarr) -3.0*stddev(xarr) and yarr lt mean(yarr) +3.0*stddev(yarr) and yarr gt mean(yarr) - 3.0*stddev(yarr),ngood_pmap, complement=bad) 
  print, 'bad position',n_elements(bad), n_elements(good)
 
  xarr = xarr[good]
  yarr = yarr[good]
  timearr = timearr[good]
  fluxerr = fluxerr[good]
  flux = flux[good]
  corrflux =corrflux[good]
  corrfluxerr = corrfluxerr[good]
  bmjd = bmjd[good]
  phase = phase[good]
;  utcs = utcs[good]
 print, 'middle flux', n_elements(flux)

  ;print, 'max x, y', max(xarr), min(xarr), max(yarr), min(yarr)

  ;try getting rid of flux outliers.
  ;do some running mean with clipping
 ;also cut the transit
  start = 0
  print, 'nflux', n_elements(flux)
  for ni = 100, n_elements(flux) -1,100 do begin
     meanclip,flux[start:ni], m, s, subs = subs;,/verbose
    ; print, 'good', subs+start
     ;now keep a list of the good ones
     if ni eq 100 then good_ni = subs+start else good_ni = [good_ni, subs+start]
     start = ni + 1
  endfor
  print, 'n good fluxclip', n_elements(good_ni)

  ;see if it worked
  xarr = xarr[good_ni]
  yarr = yarr[good_ni]
  timearr = timearr[good_ni]
  fluxerr = fluxerr[good_ni]
  flux = flux[good_ni]
  corrflux = corrflux[good_ni]
  corrfluxerr = corrfluxerr[good_ni]
  bmjd = bmjd[good_ni]
  phase = phase[good_ni]
;  utcs = utcs[good_ni]
  print, 'nflux', n_elements(flux)


;put time in hours
  timearr = (timearr - timearr(0))/60./60.
  print, 'timearr', min(timearr), max(timearr)

;-------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------
;now work on the data fitting with a polynomial for comparison:
;can I get rid of pixel phase effect?

    x = timearr
    y =flux
    yerr = fluxerr
    xcenarr = xarr
    ycenarr = yarr
    amx = median(xcenarr)         
    amy = median(ycenarr)        
    adx = xcenarr - amx           
    ady = ycenarr - amy    
    ;nfits = n_elements(x) / nframes
    bmjdarr= bmjd
    phasearr = phase
    
;    utcsarr=utcs
    nseg = 1

; Initial guesses	
  if keyword_set(sine) then begin  ;use a fitting function with a sine curve or not
     known_period = period*24.; hours 
     pa0 = [median(y), 1.,1.,1.,1.,1.,0.001,known_period*(2*!Pi),0.9]
     func = 'fpa1_xfunc3'
  endif else begin
     pa0 = [median(y), 1.,1.,1.,1.,1.]
     func = 'fpa1_xfunc2'

  endelse

  parinfo = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0.D]}, n_elements(pa0))
   ;limit the range of the sin cuve phase
  if keyword_set(sine) then begin  ;use a fitting function with a sine curve
     parinfo[7].fixed = 1          
     parinfo[6].limited[0] = 1
     parinfo[6].limits[0] = 0.0
  endif


  afargs = {FLUX:y, DX:adx, DY:ady, T:x, ERR:yerr}
  pa = mpfit('fpa1_xfunc2', pa0, FUNCTARGS=afargs, PERROR=spa, BESTNORM=achi, DOF=adof, COVAR = COV, status = status, errmsg = errmsg, parinfo = parinfo) ;,/quiet)
  print, 'status', status
  print, errmsg
  achi = achi / adof
  print, 'reduced chi squared', achi
  if keyword_set(sine) then begin  ;use a fitting function with a sine curve or not
     model_fit = pa[0] * (1+ pa[1] * adx + pa[2] * ady + pa[3] * adx * ady + pa[4] * adx * adx + pa[5] * ady * ady)+ pa[6]*sin(x/pa[7] + pa[8]) 
  endif else begin
     model_fit = pa[0] * (1+ pa[1] * adx + pa[2] * ady + pa[3] * adx * ady + pa[4] * adx * adx + pa[5] * ady * ady)
  endelse

  ;is there some way to overplot the y vs. time plot with the model?
  ;XXX not working
  model_y = pa[0] * (1+  pa[2] * ady + pa[3] * adx * ady  + pa[5] * ady * ady)

  
  ;plot residuals
  sub = y - model_fit + pa[0]  ; add back in the overall level in Jy

 ; f1 = plot(x,   model  , '6b1.',/overplot)
  ;f2 = plot(x, sub+add, '1sr',/overplot , sym_size = 0.4, sym_filled = 1.)

  print, 'nsub', n_elements(sub)

;then put it all back together again
  if nseg eq 1 then begin
     full_xarr = xcenarr
     full_yarr = ycenarr
     full_flux = y
     full_fluxerr = yerr
     full_bmjd = bmjdarr
     full_phase = phasearr
;     full_utcs = utcsarr
     full_model = model_fit
     full_model_y = model_y
     full_sub = sub
     full_time = x
  endif else begin
     full_xarr = [full_xarr, xcenarr]
     full_yarr = [full_yarr, ycenarr]
     full_flux = [full_flux,y]
     full_fluxerr = [full_fluxerr, yerr]
     full_bmjd = [full_bmjd,bmjdarr]
     full_phase = [full_phase, phasearr]
;     full_utcs = [full_utcs, utcsarr]
     full_model = [full_model,model_fit]
     full_model_y = [full_model_y, model_y]
     full_sub = [full_sub,sub]
     full_time = [full_time, x]

  endelse
  print, 'nfull', n_elements(full_xarr)
;endfor  ;for nseg

  f = strcompress(dirname + 'selfcal_bmjd_' + string(a) + '.sav',/remove_all)
  save, full_bmjd, filename = f
  f = strcompress(dirname + 'selfcal_sub_' + string(a) + '.sav',/remove_all)
  save, full_sub, filename = f
  f = strcompress(dirname + 'selfcal_fluxerr_' + string(a) + '.sav',/remove_all)
  save, full_fluxerr, filename = f

;-------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------

 ; nframes = bin_level
 ; nfits = long(n_elements(flux)) / nframes
  ;help, nfits

 ;binning after fitting
  if keyword_set(binning) then begin
     
     nfits = n_elements(full_xarr) / bin_level
     print, 'nfits',  nfits

     numberarr = findgen(n_elements(full_xarr))

     h = histogram(numberarr, OMIN=om, binsize = bin_level, reverse_indices = ri)
     print, 'omin', om, 'nh', n_elements(h)

     bin_flux = dblarr(n_elements(h))
     bin_fluxerr = dblarr(n_elements(h))
     bin_corrflux= dblarr(n_elements(h))
     bin_corrfluxerr= dblarr(n_elements(h))
     bin_timearr = dblarr(n_elements(h))
     bin_bmjdarr = dblarr(n_elements(h))
     bin_phasearr = dblarr(n_elements(h))
     bin_bkgd = dblarr(n_elements(h))
     bin_bkgderr = dblarr(n_elements(h))
     bin_xcen = dblarr(n_elements(h))
     bin_ycen = dblarr(n_elements(h))
;     bin_utcs = dblarr(n_elements(h))
     bin_sub = dblarr(n_elements(h))
     bin_model = dblarr(n_elements(h))
     bin_model_y = dblarr(n_elements(h))

     c = 0
     for j = 0L, n_elements(h) - 1 do begin

;get rid of the bins with no values and low numbers, meaning low overlap
        if (ri[j+1] gt ri[j])  then begin
;           print, 'binning together', n_elements(numberarr[ri[ri[j]:ri[j+1]-1]])
        ;print, 'binning', numberarr[ri[ri[j]:ri[j+1]-1]]
        
           meanclip, full_xarr[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
           bin_xcen[c] = meanx   ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
;           print, 'finished x'

           meanclip, full_yarr[ri[ri[j]:ri[j+1]-1]], meany, sigmay
           bin_ycen[c] = meany   ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
;           print, 'finished y'

;           meanclip, full_bkgd[ri[ri[j]:ri[j+1]-1]], meansky, sigmasky
;           bin_bkgd[c] = meansky ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
;           print, 'finished bkgd'

           meanclip, full_flux[ri[ri[j]:ri[j+1]-1]], meanflux, sigmaflux
           bin_flux[c] = meanflux ; mean(fluxarr[ri[ri[j]:ri[j+1]-1]])
;           print, 'finished flux'

;           meanclip, corrflux[ri[ri[j]:ri[j+1]-1]], meancorrflux, sigmacorrflux
;           bin_corrflux[c] = meancorrflux
;           print, 'finished corrfluxx'

           meanclip, full_time[ri[ri[j]:ri[j+1]-1]], meantimearr, sigmatimearr
           bin_timearr[c]=meantimearr
;           print, 'finished time'

           meanclip, full_bmjd[ri[ri[j]:ri[j+1]-1]], meanbmjdarr, sigmabmjdarr
           bin_bmjdarr[c]= meanbmjdarr
;           print, 'finished first bmjd'

           meanclip, full_phase[ri[ri[j]:ri[j+1]-1]], meanphasearr, sigmaphasearr
           bin_phasearr[c]= meanphasearr


           ;xxxx fix this to divide out N
;           meanclip, corrfluxerr[ri[ri[j]:ri[j+1]-1]], meancorrfluxerr, sigmacorrfluxerr
;           bin_corrfluxerr[c] = meancorrfluxerr
;           meanclip, full_fluxerr[ri[ri[j]:ri[j+1]-1]], meanfluxerr, sigmafluxerr
;           bin_fluxerr[c] = meanfluxerr

           idataerr = full_fluxerr[ri[ri[j]:ri[j+1]-1]]
           bin_fluxerr[c] =   sqrt(total(idataerr^2))/ (n_elements(idataerr))


;           meanclip, bkgderrarr[ri[ri[j]:ri[j+1]-1]], meanbkgderrarr, sigmabkgderrarr
 ;          bin_bkgderr[c] = meanbkgderrarr
;           print, 'finished last meanclips'

;           meanclip, full_utcs[ri[ri[j]:ri[j+1]-1]], meanutcs, sigmautcs
;           bin_utcs[c] = meanutcs

           meanclip, full_sub[ri[ri[j]:ri[j+1]-1]], meansub, sigmasub
           bin_sub[c] = meansub

           meanclip, full_model[ri[ri[j]:ri[j+1]-1]], meanmodel, sigmamodel
           bin_model[c] = meanmodel

           meanclip, full_model_y[ri[ri[j]:ri[j+1]-1]], meanmodely, sigmamodely
           bin_model_y[c] = meanmodely

           c = c + 1
        ;print, 'testing', j, phasearr[ri[ri[j]:ri[j+1]-1]]
        endif
     endfor
  bin_xcen = bin_xcen[0:c-1]
  bin_ycen = bin_ycen[0:c-1]
 ; bin_bkgd = bin_bkgd[0:c-1]
  bin_flux = bin_flux[0:c-1]
  bin_fluxerr = bin_fluxerr[0:c-1]
;  bin_corrflux = bin_corrflux[0:c-1]
  bin_timearr = bin_timearr[0:c-1]
  bin_bmjdarr = bin_bmjdarr[0:c-1]
  bin_phasearr = bin_phasearr[0:c-1]
;  bin_corrfluxerr = bin_corrfluxerr[0:c-1]
;  bin_bkgderr = bin_bkgderr[0:c-1]
;  bin_utcs = bin_utcs[0:c-1]
  bin_sub = bin_sub[0:c-1]
  bin_model = bin_model[0:c-1]
  bin_model_y = bin_model_y[0:c-1]

  print, 'nbin', n_elements(bin_timearr)
;-------------------------------------------------------------------------------------
 ;plot the binned stuff

;set time = 0 in the middle of the transit
  tt = 0  ;XXX
 ; bin_time = bin_time -tt

;set time in orbital phase from 0 at transit to 1 at next transit
;  phase_time = bin_time / (period*24.)

  ;y vs. time
;     st = plot(bin_time, bin_ycen,'1o',xtitle = 'Time from transit (hours)',ytitle = 'Y pix',   color = 'black', sym_filled = 1, sym_size = 0.4, yrange = yyrange, title = titlename) ;, axis_style = 1) 
;tjunk = plot(bin_time,bin_ycen,/current, xrange = st.xrange, yrange = yyrange, nodata = 1)
;topx = axis('X', location = [0, 14.8],  target = tjunk, title = 'Time from transit (hours)')
;     st2 = plot(bin_time, bin_model_y+14.5,'1sb',/overplot, sym_size = 0.2, sym_filled = 1.)
     print, 'bin_model_y', mean(bin_model_y)
  ;-----------------
  ;x vs time
  ;   st1 = plot(bin_time, bin_xcen,'1o', xtitle = 'Time from transit (hours)',ytitle = 'X pix',  color = 'black', sym_filled = 1, sym_size = 0.4) ;
  ;-----------------
  ;x vs y
 ;    st2 = plot(bin_time, bin_ycen,'1o', ytitle = 'Y pix',xtitle = 'Time',  color = 'black', sym_filled = 1, sym_size = 0.4) ;
   ;-----------------


 

;     x = bin_bmjdarr           ;/ max(timearr)        ; fix to 1 phase
;     x = bin_timearr
     x = bin_phasearr
;     y = bin_flux             ;/ fluxarr[1]          ;normalize
;     p1 = plot(x, y,  '1o',  xtitle = 'Orbital Phase', ytitle = ' Flux',  sym_size = 0.2, sym_filled = 1.,title = titlename, xrange = [0.32,0.62])
;     f1 = plot(x,bin_model,  '1ob',/overplot , sym_size = 0.2, sym_filled = 1.) ;-0.0027
;     f2 = plot(x, bin_sub, '1or',/overplot , sym_size = 0.2, sym_filled = 1.)

     y = (bin_sub )/mean(bin_sub)
     yerr = bin_fluxerr/ mean(bin_sub)
     print, 'n x, y, yerr', n_elements(x), n_elements(y), n_elements(yerr)
     print, 'y', y[0:10]
     print, 'x', x[0:10]
     o = errorplot(x, y,yerr,'1o',sym_size = 0.7, sym_filled = 1, xtitle = 'Orbital Phase', ytitle = 'Normalized corrected binned flux', title = planetname)
     
  endif                         ;binning
  selfcal_timearr = full_time
  selfcal_flux = full_flux
  
  save, /all, filename=strcompress(dirname + 'selfcal.sav')
;  save, selfcal_timearr, filename='/Users/jkrick/irac_warm/pcrs_planets/55cnc/selfcal_timearr.sav'
;  save, selfcal_flux, filename='/Users/jkrick/irac_warm/pcrs_planets/55cnc/selfcal_flux.sav'
;  save, bin_time, filename='/Users/jkrick/irac_warm/pcrs_planets/55cnc/bin_time.sav'
;  save, bin_sub, filename='/Users/jkrick/irac_warm/pcrs_planets/55cnc/bin_sub.sav'
endfor

end


function fpa1_xfunc2, p, FLUX=flux, DX=dx, DY=dy, T=t, ERR=err
; p is parameters, f0, a1..a5
; t is time
    n = n_elements(dx)
    model = dblarr(n) + p[0]

    scale = p[1] * dx + p[2] * dy + p[3] * dx * dy + p[4] * dx * dx + $
            p[5] * dy * dy 
    dt = t - min(t)
    if (n_elements(p) ge 7) then scale2 = 1.0 + p[6] * dt else scale2 = 1.0
    if (n_elements(p) eq 8) then scale2 = scale2 + p[7] * dt * dt
    
    model = model * (1. + scale) * scale2
    model = (flux - model) / err

return, model
end

function fpa1_xfunc3, p, FLUX=flux, DX=dx, DY=dy, T=t, ERR=err
; p is parameters, f0, a1..a5
; t is time
    n = n_elements(dx)
    model = dblarr(n) + p[0]

    scale = p[1] * dx + p[2] * dy + p[3] * dx * dy + p[4] * dx * dx + $
            p[5] * dy * dy 
    dt = t - min(t)
    
    model = model * (1. + scale) 
    
    ;now add in the sin curve 
    model = model + p[6]*sin(t/p[7] + p[8]) 
 

   model = (flux - model) / err

return, model
end
