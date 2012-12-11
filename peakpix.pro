pro peakpix
  
  ;aorname = ['r40269056', 'r40269312'] ;ch2  ;wasp18
;  aorname = ['r45426688',  'r45428224',  'r45428480',  'r45428736',  'r45428992'] ;ch2 wasp14
; aorname = [ 'r45428992', 'r45428736', 'r45428480', 'r45428224', 'r45426688', 'r45838592', 'r45840128', 'r45841408', 'r45842176', 'r45842944', 'r45844480', 'r45845248', 'r45846016', 'r45846784', 'r45839104', 'r45840896', 'r45841664', 'r45842432', 'r45843200', 'r45844736', 'r45845504', 'r45846272', 'r45847040', 'r45839616', 'r45841152', 'r45841920', 'r45842688', 'r45844224', 'r45844992', 'r45845760', 'r45846528']  ;snapshots and first 5 are ch2 stares
  aorname = ['r41591808'] ;one of the hd189733 AORs.

  for a = 0, n_elements(aorname) - 1 do begin
     print, 'working on ',aorname(a)
     dir = '/Users/jkrick/irac_warm/hd189733/'+ string(aorname(a) ) 
     CD, dir                    ; change directories to the correct AOR directory
     command  =  "find ch1/raw -name '*_dce.fits' > /Users/jkrick/irac_warm/hd189733/rawlist.txt"
     spawn, command
;     command2 =  "find  ch2/bcd -name '*bunc.fits' > /Users/jkrick/irac_warm/wasp18/bunclist.txt"
;     spawn, command2

     readcol,'/Users/jkrick/irac_warm/hd189733/rawlist.txt',fitsname, format = 'A', /silent
     ;readcol,'/Users/jkrick/irac_warm/pcrs_planets/wasp14/bunclist.txt',buncname, format = 'A', /silent
     peakpixarr = fltarr(n_elements(fitsname))
     j = 0

     for i =0.D, 999 do begin ;read each cbcd file, find centroid, keep track
        ;print, 'working on ', fitsname(i)         
        fits_read, fitsname(i), rawdata, rawheader
        
        barrel = fxpar(rawheader, 'A0741D00')
        fowlnum = fxpar(rawheader, 'A0614D00')
        pedsig = fxpar(rawheader, 'A0742D00')
        ichan = fxpar (rawheader, 'CHNLNUM')
              
                                ;use Bill's code to conver to DN
        dewrap2, rawdata, ichan, barrel, fowlnum, pedsig, 0, rawdata
     
                                ;or use Jim's code to convert to DN
;            rawdata = irac_raw2dn(rawdata,ichan,barrel,fowlnum)
        rawdata = reform(rawdata, 32, 32, 64)
        peakpixarr[j] = max(rawdata[13:16,13:16,*])
        j = j + 1
     endfor
  peakpixarr = peakpixarr[0:j-1]
  print, mean(peakpixarr), median(peakpixarr)
;  plothist, peakpixarr, xhist, yhist, bin = 10,/fill, xrange = [1000, 4000],/noplot
;  p = plot(xhist, yhist)
  endfor
  end
