pro plot_nonlin, planetname, chname
  colorarr = ['black', 'red', 'blue', 'cyan', 'Maroon', 'magenta', 'gray', 'navy']

  for pl = 0,  n_elements(planetname) - 1 do begin
     print, 'working on planet', planetname(pl)
  ;read in the relevant photometry
     planetinfo = create_planetinfo()
     if chname eq '2'  then aorname= planetinfo[planetname(pl), 'aorname_ch2'] else aorname = planetinfo[planetname(pl), 'aorname_ch1'] 
     basedir = planetinfo[planetname(pl), 'basedir']
     dirname = strcompress(basedir + planetname(pl) +'/')
     savename = strcompress(dirname + planetname(pl) +'_phot_ch'+chname+'_varap.sav')
     restore, savename
     
                                ;put all the relevant information from the aors together
     for a = 0, n_elements(aorname) -1 do begin
        if a eq 0 then begin
           xcen= planethash[aorname(a),'xcen']
           ycen= planethash[aorname(a),'ycen']
           flux = planethash[aorname(a),'flux']
           peakpixDN = planethash[aorname(a),'peakpixDN']
        endif else begin
           xcen= [xcen, planethash[aorname(a),'xcen']]
           ycen= [ycen, planethash[aorname(a),'ycen']]
           flux= [flux, planethash[aorname(a),'flux']]
           peakpixDN = [peakpixDN, planethash[aorname(a),'peakpixDN']]
        endelse
        
     endfor
     
                                ;what is the peakpix in DN
     plothist, peakpixDN, xhist, yhist, /noplot,/nan
                                ; ppp = plot(xhist, yhist)
     
                                ;calculate distance from sweet spot
     xsweet = 15.12
     ysweet = 15.00
     xdist = (xcen - xsweet)
     ydist = (ycen- ysweet)
     dsweet = sqrt(xdist^2 + ydist^2)
     
                                ;bin as a function of dsweet (maybe in bins of 0.015 pixels)
     ;need to sort on dsweet first
     ds = sort(dsweet)
     dsweet = dsweet(ds)
     flux = flux(ds)
     
  ;plot one of the flux/dsweets just to see what that looks like
  ; does it have the shape I expect it to?
    if pl eq 0 then  p2 = plot(dsweet, flux, '1s', sym_size = 0.1, color = colorarr(pl), xrange = [0, 0.5], $
               xtitle = 'Distance from Sweet Spot (Pix)', ytitle = 'Flux', yrange = [0.05, 0.07])


 ;    numberarr = findgen(n_elements(dsweet))
;     bin_number = 30
     bin_level = 0.015
 ;    h = histogram(numberarr, OMIN=om, nbins  = bin_number, reverse_indices = ri)
     h = histogram(dsweet, OMIN=om, binsize  = bin_level, reverse_indices = ri, max = 0.5)
     print, 'n_elements(h)', n_elements(h)
     bin_flux = dblarr(n_elements(h))
     bin_dsweet = bin_flux
     bin_peakpix = bin_flux
     c = 0
     for j = 0L, n_elements(h) - 1 do begin
;        print, 'testing ri', ri[j+1], ri[j] + 2
                                ;get rid of the bins with no values and low numbers, meaning low overlap
        if (ri[j+1] gt ri[j] + 2)  then begin ;require 3 elements in the bin
;           print, 'dsweet', dsweet[ri[ri[j]:ri[j+1]-1]]
           meanclip_jk, dsweet[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
           bin_dsweet[c] = meanx    
           
           meanclip_jk, flux[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
           bin_flux[c] = meanx    

           meanclip_jk, peakpixDN[ri[ri[j]:ri[j+1]-1]], meanx, sigmax
           bin_peakpix[c] = meanx    

           c = c +1
        endif
     endfor
     print, 'c', c
     bin_flux = bin_flux[0:c-1]
     bin_dsweet = bin_dsweet[0:c-1]
     bin_peakpix = bin_peakpix[0:c-1]
     print , 'peakpix DN', bin_peakpix(0)
                                ;plot
                                ;will want to normalize by F(0.35)
     normdist = 0.0
;     d = where(dsweet gt normdist - 0.01 and dsweet lt normdist +0.05, dcount)
;     normflux = mean(flux(d), /nan)
;     print, dcount, normflux, median(flux)
 
     normflux = bin_flux(20)
     print, 'normflux', normflux
     p = plot(bin_dsweet, bin_flux/normflux, '1s', sym_size = 1,   sym_filled = 1,xtitle = 'Distance from Sweet Spot (Pix)', ytitle = 'F/ F(0.3)',$
              xrange = [0, 0.5], yrange = [0.96, 1.01], color = colorarr(pl), overplot = p)
     pt = text(0.1, 0.98 + pl*0.002, planetname(pl) + string(bin_peakpix(0)), /current, /data, color = colorarr(pl))
     a = where(finite(flux) lt 1, nancount)
     print, 'nancount', nancount, n_elements(flux)
  endfor                        ; for each planet pl


end
