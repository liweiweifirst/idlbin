pro snap_darkcorr, chname
;this code backs the dark correction out of the snapshot observations,
;and then puts back the same dark for all snaps.

;assumes subarray - aka naxis = 3
  
; XXXneed to deal with each frame ; only for hreverse - which is really maybe a header problem, try just 'reverse' and forget about the header since I am re-reversing it later

 ;XXX need to deal with outfilename
  basedir = '/Users/jkrick/irac_warm/pcrs_planets/wasp-14b/'
  caldir = basedir + 'calibration/'
  fluxconv = .1469              ;MJY/sr / DN/s
  fits_read, strcompress(caldir + 'irac_b2_sa_superskyflat_100426.fits',/remove_all), flatdata, flatheader
  fits_read,  strcompress(caldir + 'SPITZER_I2_45966336_0000_1_C9501418_sdark.fits',/remove_all), dark45966336,header45966336
  fits_read,  strcompress(caldir + 'SPITZER_I2_45860608_0000_1_C9491430_sdark.fits',/remove_all), dark45860608,header45860608
  fits_read,  strcompress(caldir + 'SPITZER_I2_45863936_0000_1_C9497379_sdark.fits',/remove_all), dark45863936,header45863936
  fits_read,  strcompress(caldir + 'SPITZER_I2_48987392_0000_1_C9735186_sdark.fits',/remove_all), dark48987392,header48987392
  fits_read,  strcompress(caldir + 'SPITZER_I2_48998144_0000_1_C9737980_sdark.fits',/remove_all), dark48998144,header48998144
  fits_read,  strcompress(caldir + 'SPITZER_I2_49015808_0000_1_C9756026_sdark.fits',/remove_all), dark49015808,header49015808
;choose one dark for them all
  thedark = dark45966336
  theheader = header45966336
                                ;all the snaps
  aorname_ch2 = [ 'r45838592', 'r45840128', 'r45841408', 'r45842176', 'r45842944', 'r45844480', 'r45845248', 'r45846016', 'r45846784', 'r45839104', 'r45840896', 'r45841664', 'r45842432', 'r45843200', 'r45844736', 'r45845504', 'r45846272', 'r45847040', 'r45839616', 'r45841152', 'r45841920','r45843968','r45843712','r45843456','r45840640','r45840384','r45839872','r45839360','r45838848','r45838336','r48688384','r48688128','r48687872','r48687616','r48683776','r48683264', 'r48682752','r48682240','r48681472','r48681216','r48680704'] ; ch2
  
  for a = 0, n_elements(aorname) - 1 do begin
     print, 'working on ',aorname(a)
     dir = basedir + string(aorname(a) ) 
     CD, dir                    ; change directories to the correct AOR directory
     command  = strcompress( 'find ch'+chname+"/bcd -name '*_bcd.fits' > "+dirname+'bcdlist.txt')
     spawn, command
     readcol,strcompress(dir +'bcdlist.txt'),fitsname, format = 'A', /silent
     print,'n_elements(fitsname)', n_elements(fitsname)
     
     for i = 0, n_elements(fitsname) - 1 do begin ; for each image
        
                                ;read in the data
        fits_read, fitsname(i), data, header

                                ;back out the flux conversion
        data = data / fluxconv
        
                                ; flip the image
        hreverse, data, header, 2,/silent
        
                                ;remove the flat
        data = data * flatdata
        
                                ;remove the dark that was already used in the image
        darkname = sxpar(header, 'SKDKRKEY')
        case darkname of 
           '45966336': dark = dark45966336
           '45860608': dark =dark45860608
           '45863936': dark =dark45863936
           '48987392': dark = dark48987392
           '48998144': dark = dark48998144
           '49015808': dark = dark49015808
        endcase
        data = data + dark
        
                                ;--------------------------
        
                                ;put the same dark back into every frame
        data = data - thedark
        
                                ;divde back out the flat
        data = data / flatdata
        
                                ;flip the image
        hreverse, data, header, 2,/silent
        
                                ;put the fluxconv back in
        data = data * fluxconv
        
                                ;write out the new fits file
        fits_write, outfilename, data, header
        
     endfor                     ; for each image
  endfor                        ; for each AOR
end
