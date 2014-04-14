pro snap_darkcorr, chname
;this code backs the dark correction out of the snapshot observations,
;and then puts back the same dark for all snaps.

;assumes subarray - aka naxis = 3
  

  basedir = '/Users/jkrick/irac_warm/pcrs_planets/HD158460/'
  caldir = basedir + 'calibration/'
  fluxconv = .1469              ;MJY/sr / DN/s
  fits_read, '/Users/jkrick/irac_warm/pcrs_planets/HD158460/r45184768/ch2/cal/irac_b2_sa_superskyflat_100426.fits', flatdata, flatheader
  ;need to make this [32,32,64]
  flat64 = fltarr(32,32,64)
  flatsingle = flatdata[*,*,0]
  for f = 0, 63 do flat64[*,*,f] = flatsingle

  ra_ref = 261.42213
  dec_ref = 60.048479

;  fits_read,  strcompress(caldir + 'SPITZER_I2_45966336_0000_1_C9501418_sdark.fits',/remove_all), dark45966336,header45966336
;  fits_read,  strcompress(caldir + 'SPITZER_I2_45860608_0000_1_C9491430_sdark.fits',/remove_all), dark45860608,header45860608
;  fits_read,  strcompress(caldir + 'SPITZER_I2_45863936_0000_1_C9497379_sdark.fits',/remove_all), dark45863936,header45863936
;  fits_read,  strcompress(caldir + 'SPITZER_I2_48987392_0000_1_C9735186_sdark.fits',/remove_all), dark48987392,header48987392
;  fits_read,  strcompress(caldir + 'SPITZER_I2_48998144_0000_1_C9737980_sdark.fits',/remove_all), dark48998144,header48998144
;  fits_read,  strcompress(caldir + 'SPITZER_I2_49015808_0000_1_C9756026_sdark.fits',/remove_all), dark49015808,header49015808

;choose one dark for them all
;  thedark = dark45966336
;  theheader = header45966336
 
;choose the superdark
 fits_read, '/Users/jkrick/irac_warm/darks/superdarks/superdark_s2s.fits', thedark, theheader

               ;HD158460              
   aorname = [ 'r45184256','r45184512','r45184768','r45185024','r45185280','r45185536','r45185792','r45186048','r45186304','r45186560','r45186816','r45187072','r45187328','r45187584','r45187840','r45188096','r45188352','r45188608'] 
  prefluxarr = fltarr(n_elements(aorname) * 500* 64)
  superfluxarr = fltarr(n_elements(aorname) * 500* 64)
  c = 0L

  for a = 0,   n_elements(aorname) - 1 do begin
     print, 'working on ',aorname(a)
     dir = basedir + string(aorname(a) ) 
     CD, dir                    ; change directories to the correct AOR directory
     command  = strcompress( 'find ch'+chname+"/bcd -name 'SPITZER*_bcd.fits' > "+dir+'bcdlist.txt')
     spawn, command
     command2 =  strcompress('find ch'+chname+"/bcd -name 'SPITZER*_bunc.fits' > "+dir+'bunclist.txt')
     spawn, command2
   
     readcol,strcompress(dir +'bcdlist.txt'),fitsname, format = 'A', /silent
     readcol,strcompress(dir +'bunclist.txt'),buncname, format = 'A', /silent
     print,'n_elements(fitsname)', n_elements(fitsname)
     
     for i = 0,  n_elements(fitsname) - 1 do begin ; for each image

                                ;read in the data
        fits_read, fitsname(i), data, header
        fits_read, buncname(i), unc, uncheader

        ; do some baseline aperture photometry
        get_centroids_for_calstar_jk,data, header, unc, ra_ref, dec_ref,  t, dt, hjd, xft, x3, y3, $
                                     x5, y5, x7, y7, xg, yg, xh, yh, f, b, x3s, y3s, x5s, y5s, $
                                     x7s, y7s, fs, bs, xp3, yp3, xp5, yp5, xp7, yp7, xp3s, yp3s, $
                                     xp5s, yp5s, xp7s, yp7s, fp, fps, np, flag, ns, sf, $
                                     xfwhm, yfwhm, /WARM
        prefluxarr(c) = f[*,1]      
        
                                ;back out the flux conversion
        data = data / fluxconv
        
                                ; flip the image
        data = reverse(data, 2)
        
                                ;remove the flat
        data = data * flat64
        
                                ;remove the dark that was already used in the image
        command  = strcompress( 'find ch'+chname+"/cal -name '*_sdark.fits' > "+dir+'dark.txt')
        spawn, command
        readcol,strcompress(dir +'dark.txt'),darkname, format = 'A', /silent
        fits_read, darkname, dark, darkheader
        
        ;darkname = sxpar(header, 'SKDKRKEY')
        ;case darkname of 
        ;   '45966336': dark = dark45966336
        ;   '45860608': dark =dark45860608
        ;   '45863936': dark =dark45863936
        ;   '48987392': dark = dark48987392
        ;   '48998144': dark = dark48998144
        ;   '49015808': dark = dark49015808
       ; endcase
        data = data + dark
       
                                ;--------------------------
        
                                ;put the same dark back into every frame
        data = data - thedark
        
                                ;divde back out the flat
        data = data / flat64
        
                                ;flip the image
        data = reverse(data, 2)
        
                                ;put the fluxconv back in
        data = data * fluxconv
        
                                ;write out the new fits file
        outfilename =strmid(fitsname(i),0, 8) + 'sdcorr' + strmid(fitsname(i), 8)
        fits_write, outfilename, data, header
        

        ;do some aperture photometry after changing the dark
        get_centroids_for_calstar_jk,data, header, unc, ra_ref, dec_ref,  t, dt, hjd, xft, x3, y3, $
                                     x5, y5, x7, y7, xg, yg, xh, yh, f, b, x3s, y3s, x5s, y5s, $
                                     x7s, y7s, fs, bs, xp3, yp3, xp5, yp5, xp7, yp7, xp3s, yp3s, $
                                     xp5s, yp5s, xp7s, yp7s, fp, fps, np, flag, ns, sf, $
                                     xfwhm, yfwhm, /WARM
        superfluxarr(c) = f[*,1]      
        c = c + 63

     endfor                     ; for each image
  endfor                        ; for each AOR

  prefluxarr = prefluxarr[0:c-63]
  superfluxarr = superfluxarr[0:c-63]
  plothist, prefluxarr, prexhist, preyhist, /noplot, bin = 0.0001
  h = plot(prexhist, preyhist, thick = 2, xtitle = 'Aperture flux', ytitle = 'Number', title = 'WASP-14b', $
           color = 'Navy', name = 'campaign dark', xrange = [0.057, 0.0595])
  
  plothist, superfluxarr, superxhist, superyhist, /noplot, bin = 0.0001
  h2 =  plot(superxhist, superyhist, thick = 2, /overplot, color = 'red', name = 'superdark')

  l = legend(target = [h, h2], position = [0.0595, 1000], /data, /auto_text_color)

end
