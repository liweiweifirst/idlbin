pro plot_pld_database, aorname, binscale, starts, position_plot = position_plot, csv_out = csv_out
  ;;aorname should be a string
  ;;suggest binscale = 64 to start with
  ;;start with starts = 0, unlesss you know which save file it resides in
  savenames = [ '/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/centroids_save/track_centroids_pixval_01.sav','/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/centroids_save/track_centroids_pixval_02.sav','/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/centroids_save/track_centroids_pixval_03.sav','/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/centroids_save/track_centroids_pixval_04.sav','/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/centroids_save/track_centroids_pixval_05.sav','/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/centroids_save/track_centroids_pixval_06.sav','/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/centroids_save/track_centroids_pixval_07.sav','/Users/jkrick/Library/Mobile Documents/com~apple~CloudDocs/centroids_save/track_centroids_pixval_08.sav']
  ;;set up for plotting
  extra={xthick: 2, ythick:2, margin: 0.2, sym_size: 0.2,   sym_filled: 1, xstyle:1}

  
 
  stops = n_elements(savenames) - 1
     for s = starts, stops do begin
        print, 'restoring ', savenames(s)
        restore, savenames(s)
        aorlist = planethash.keys()
        print, 'n aorlist', n_elements(aorlist)
        n = where(aorlist eq aorname, aorcount)
        n = n[0]                 ;where returns an array!
        if aorcount gt 0 then begin ; found the AOR          
           print, 'found the AOR', aorlist(n), n_elements(planethash[aorlist(n)].xcen)
           help, planethash[aorlist(n)].bmjdarr
           bmjd = planethash[aorlist(n)].bmjdarr
           corrected_flux = planethash[aorlist(n)].pld_flux
           flux = planethash[aorlist(n)].flux
           flux_unc = planethash[aorlist(n)].fluxerr
           corr_unc = planethash[aorlist(n)].pld_unc
           xcen = planethash[aorlist(n)].xcen
           ycen = planethash[aorlist(n)].ycen
           nparr =  planethash[aorlist(n)].npcentroids
           
           ;; binning
           numberarr = findgen(n_elements(bmjd))
           h = histogram(numberarr, OMIN=om, binsize = binscale, reverse_indices = ri)
           
           bin_pldflux=dblarr(n_elements(h))
           bin_bmjd = bin_pldflux
           bin_corrunc = bin_pldflux
           bin_xcen = bin_pldflux
           bin_ycen = bin_pldflux
           bin_flux = bin_pldflux
           bin_np = bin_pldflux
           
           c = 0
           for j = 0L, n_elements(h) - 1 do begin
              
              ;;get rid of the bins with no values and low numbers, meaning
              ;;low overlap
              if (ri[j+1] gt ri[j] + 2)  then begin ;require 3 elements in the bin
                 
                 meanclip, corrected_flux[ri[ri[j]:ri[j+1]-1]], meancorrflux, sigmacorrflux
                 bin_pldflux[c] = meancorrflux
                 
                 meanclip, flux[ri[ri[j]:ri[j+1]-1]], meanflux, sigmaflux
                 bin_flux[c] = meanflux
                 
                 idataerr = corr_unc[ri[ri[j]:ri[j+1]-1]]
                 bin_corrunc[c] =   sqrt(total(idataerr^2))/ (n_elements(idataerr))
                 
                 meanbmjdarr = mean( bmjd[ri[ri[j]:ri[j+1]-1]],/nan)
                 bin_bmjd[c]= meanbmjdarr
                 
                 meanxcen = mean( xcen[ri[ri[j]:ri[j+1]-1]],/nan)
                 bin_xcen[c]= meanxcen
                 
                 meanycen = mean( ycen[ri[ri[j]:ri[j+1]-1]],/nan)
                 bin_ycen[c]= meanycen
                 
                 meannp = mean( nparr[ri[ri[j]:ri[j+1]-1]],/nan)
                 bin_np[c]= meannp
                 
                 c = c + 1
              endif
           endfor
           bin_pldflux = bin_pldflux[0:c-1]
           bin_corrunc = bin_corrunc[0:c-1]
           bin_bmjd = bin_bmjd[0:c-1]
           bin_xcen = bin_xcen[0:c-1]
           bin_ycen = bin_ycen[0:c-1]
           bin_flux = bin_flux[0:c-1]
           bin_np = bin_np[0:c-1]
           
           normfactor = median(bin_pldflux)
           plot_norm = median(bin_flux)
           
           
           ;;set up some plots to be saved and not displayed
           plotx = (bin_bmjd - bin_bmjd[0]) * 24.
           pp = plot(plotx, bin_xcen, '1s',  title = aorname, $
                     ytitle = 'X position', position =[0.2, 0.75, 0.9, 0.91], ytickinterval = 0.1, $
                     xshowtext = 0, ytickformat = '(F10.2)', dimensions = [600, 900], _extra = extra, yminor = 0)
           
           
           pp= plot(plotx, bin_ycen, '1s',  $
                    ytitle = 'Y position',  position = [0.2, 0.59, 0.9, 0.75],/current,  ytickinterval = 0.1,$
                    xshowtext = 0,ytickformat = '(F10.2)', _extra = extra, yminor = 0)
           
           pp= plot(plotx, bin_np, '1s', $
                    ytitle = 'Noise Pixel',  position = [0.2, 0.42, 0.9, 0.58] , /current, $
                    xshowtext = 0,ytickformat = '(F10.1)', _extra = extra, ytickinterval = 1.0, yminor = 0, yrange = [3.5, 8.0],$
                    buffer = 1) ;,$ title = planetname,, ymajor = 4;xrange = setxrange) position =  [0.2, 0.50, 0.9, 0.63]
           
           pp = plot(plotx, bin_flux/plot_norm, '1s',  ytitle = 'Raw Flux',xshowtext = 0,$
                     position =[0.2, 0.25, 0.9, 0.41], /current, _extra = extra, $ ;ytickinterval = 0.002, $
                     yminor = 0,  yrange = [0.995,1.005])
           
           
           pp = plot(plotx, bin_pldflux/normfactor, '1s',$
                     ytitle = "PLD Flux", xtitle = 'Time in hours',/current,_extra = extra, $
                     position = [0.2, 0.08, 0.9, 0.24], yrange = [0.997, 1.002] ) ;, ytickinterval = 0.002 )
           
           ;;pp = errorplot(plotx, bin_pldflux/normfactor, bin_corrunc/normfactor,'1s',$
           ;;               ytitle = "PLD Flux", xtitle = 'Time in hours',/current,_extra = extra, $
           ;;               position = [0.2, 0.08, 0.9, 0.24],buffer = 1 ) ;, ytickinterval = 0.002 )
           
           plotname = strcompress('/Users/jkrick/external/irac_warm/trending/plots/multi_' + string(aorname) + '.png',/remove_all)
           print, plotname
           pp.save,plotname
 

           ;;this plot overlays the positions on the pmap contours
           if keyword_set(position_plot) then begin
              print, 'inside position plot'
              chname = '1'
              if chname eq '2' then fits_read, '/Users/jkrick/irac_warm/pmap/pmap_fits/pmap_100x100_ch2_r2p25_s3_7_0p1s_x4_150723.fits', $
                                               pmapdata, pmapheader
              if chname eq '1' then fits_read, '/Users/jkrick/irac_warm/pmap/pmap_fits/pmap_500x500_ch1_r2p25_s3_7_sd_0p4s_sdark_150722.fits',$
                                               pmapdata, pmapheader
              c = contour(pmapdata, /fill, n_levels = 15, rgb_table = 0, xtitle = 'X (pixel)', ytitle = 'Y (pixel)', $
                          aspect_ratio = 1, xrange = [0,500], yrange = [0,500], axis_style = 0) ;21
              
              xss = 14.5
              yss = 14.5
              ;; print, 'mean position', mean(planethash[aorname(a),'xcen']), mean(planethash[aorname(a),'ycen'])
              xcen500 = 500.* (xcen - xss)
              ycen500 = 500.* (ycen - yss)

              an = plot(xcen500, ycen500, '1s', sym_size = 0.3,   sym_filled = 1, color = red, overplot = c)
           endif


           if keyword_set(csv_out) then begin
              print, 'printing a csv output file'
              
              all_arr = [ [bmjd] , [flux] , [flux_unc] , [corrected_flux],[corr_unc] ]
              help, all_arr

              trans_arr = transpose(all_arr)
              help, trans_arr
              header = ['bmjd','raw_flux','raw_flux_unc','pld_flux','pld_flux_unc']

              
              ;;use write_csv
              csvname = strcompress('/Users/jkrick/external/irac_warm/trending/plots/data_' + string(aorname) + '.csv',/remove_all)
              write_csv, csvname,  trans_arr, header = header

           endif
           
          GOTO, jump1

           
        endif
     endfor
     jump1: print, 'done searching' ;don't need to keep searching if we already found the AOR
  
end
