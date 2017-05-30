Function Query_starid_v2,header, Found = found, ERRMSG = errmsg, $
    Verbose = verbose,  Print = print,Vmag=Vmag,Jmag=Jmag,Hmag=Hmag,Kmag=Kmag,parallax=parallax

  COMMON centroid_block

  ra_rqst = sxpar(header, 'RA_RQST') ;need to use these so that I know when there is a blank channel
  dec_rqst = sxpar(header, 'DEC_RQST')
  naxishere = sxpar(header, 'NAXIS')

  
  ;;some definitions
  ;;ra_rqst and dec_rqst are the center of the array 

  ;;ra_ss *& dec_ss are the sweet spots
  if naxishere eq 2 then begin
     xyad, header, 24., 232., ra_ss, dec_ss
  endif else begin
     ra_ss = ra_rqst
     dec_ss = dec_rqst
  endelse
  


  
  ;;First search NEXSCI
  ;;------------------------------------------------------
  
  base1 = "http://exoplanetarchive.ipac.caltech.edu/cgi-bin/nstedAPI/nph-nstedAPI?table=exoplanets&ra="
  base2 = "&dec="
  base3 = "&radius="
  base4 = "%20minutes&select=pl_hostname,st_pmra, st_pmdec";&order=dist"
  if naxishere eq 2 then dist = 4
  if naxishere eq 3 then dist = 0.4
  QueryURL = strcompress(base1 + string(ra) + base2 + string(dec) + base3 + string(dist) + base4,/remove_all)
  if keyword_set(verbose) then print,queryURL
  
  Result = webget(QueryURL)
  found = 0
  if keyword_set(Verbose) then print, 'Result', Result

  ;;how many objects were found?
  cnt = n_elements(strlen(result.text))

  ;;somehow this isn't working, so don't bother with Nexsci for now
  cnt = 0 
  ;;found at least one object
  if cnt ge 2 then begin
     if cnt gt 2 then print, strcompress('Warning - '+ string(cnt)+ ' matches found for position '  )
        
     row = strarr(cnt-1, 7)
     for i = 1, cnt - 1 do  row[i-1,*]=strsplit(result.text[i],',',/extract,/preserve_null)
     
     dist = row[*,5]
     dist = float(dist)
     mindist = dist.Min(c)
     
     starname = row[c,0]        ;firstline[0]
     ra = row[c,3]              ;firstline[3]
     dec = row[c,4]             ;firstline[4]
     pmra = row[c,1]            ;firstline[1]  ;mas/yr
     pmdec = row[c,2]           ;firstline[2] ;mas/yr
     print, 'pmra and dec', pmra, pmdec
     ;;assume 2013 as the 'middle' of the warm mission to get
     ;;posistions closer
     pmra = pmra*13/1000./60./60. ;arsec
     pmdec = pmdec*13/1000./60./60. ;arcsec
     ra = ra + pmra
     dec = dec + pmdec
     found = 1
     found = frame_check(header, ra, dec, found)
     if found eq 0 then goto, jump0
     ;;didn't find an object 
  endif else begin
     ;;-----------------------------------------------------------------------------------------
     print, 'No objects returned by NExScI. Searching SIMBAD...' ;  The server answered:'+ (result)]
     jump0: print, 'or maybe NExsci not on the frame'
     base1 = "http://simbad.u-strasbg.fr/simbad/sim-coo?Coord="
     base2 = "&Radius="
     base3 = "&Radius.unit=arcmin&output.format=ASCII&coodisp1=d&list.pmsel=on"
     ;;dec needs to have a sign attached
     if dec_ss lt 0 then sdec = string(dec_ss) else sdec = strcompress('+'+string(dec_ss),/remove)
     QueryURL = strcompress(base1 + string(ra_ss) +  sdec + base2 + string(0.4) + base3,/remove)
     if keyword_set(verbose) then print, 'query', QueryURL
     Result = webget(QueryURL)
     Result = Result.text
     if keyword_set(Verbose) then print, Result
     
     ;;how many objects did SIMBAD return?
     idx=where(strpos(Result, 'Number of objects') ne -1, nlines)
     if nlines eq 1 then begin  ;got more than one object
        scnt = strmid(Result[idx], 20)
        ;;but cnt is a string, want it to be an int
        scnt = fix(scnt)
        if keyword_set(Verbose) then print, 'SIMBAD number of matches: ', scnt
        
        if scnt GT 1 then begin 
           print,strcompress('Warning - '+ string(cnt)+ ' SIMBAD matches found for position '  )
        endif 	
        found=1   
        
        ;;now pull the name of the first star in the list
        id2 = where(Result.StartsWith('1|'), nlines)
        firstline = Result[id2[0]]
        junk = splitsimbadstring(firstline, starname=starname, ra=ra, dec=dec, pmra=pmra, pmdec=pmdec)
        
        ;;apply the proper motions
        ;;assume 2013 as the 'middle' of the warm mission to get
        ;;posistions closer
        pmra = pmra*13/1000./60./60. ;arsec
        pmdec = pmdec*13/1000./60./60. ;arcsec
        ra = ra + pmra
        dec = dec + pmdec

        if keyword_set(Verbose) then print, 'Nearest star: ', starname      
        
     ENDIF ELSE BEGIN  ;;SIMBAD found either one star, or didn't find anything, now what??
        
        ;;check for single star
        id1=where(strpos(Result, 'Object') ne -1, nlines)
        if nlines eq 1 then begin
           if keyword_set(Verbose) then print, 'Simbad found something'
           found = 1
           starname = strmid(Result[id1],7,11)
           idcoo = where(Result.StartsWith('Coordinates(ICRS'))
           cooline = Result[idcoo]
           pos = cooline.split(' ')
           ra = pos[1]
           dec = pos[2]
           btest = starname.StartsWith('NVSS')
           if btest gt 0 then GOTO, jumpif
        endif else begin
           jumpif: print, 'either re-running search because found NVSS target or '
           print, ['No objects returned by SIMBAD at the sweet spot.   The server answered:' , $
                   strjoin(result)]

           ;;not at the sweet spot, but maybe at the center of the
           ;;array
           if dec_rqst lt 0 then sdec_rqst = string(dec_rqst) else sdec_rqst = strcompress('+'+string(dec_rqst),/remove)
           narcmin =4
           QueryURL = strcompress(base1 + string(ra_rqst) +  sdec_rqst + base2 + string(narcmin) + base3,/remove)
           print, 'query', QueryURL
           Result = webget(QueryURL)
           Result = Result.text
           idx=where(strpos(Result, 'Number of objects') ne -1, nlines)
                         
           if nlines eq 1 then begin ;got more than one object
              scnt = strmid(Result[idx], 20)
              ;;but cnt is a string, want it to be an int
              scnt = fix(scnt)
              found=1   
        
              ;;now pull the name of the first star in the list
              id2 = where(Result.StartsWith('1|') OR Result.StartsWith('1 |'), nlines)
              firstline = Result[id2]
              junk = splitsimbadstring(firstline, starname=starname, ra=ra, dec=dec, pmra=pmra, pmdec=pmdec)

              ;;apply the proper motions
              ;;assume 2013 as the 'middle' of the warm mission to get
              ;;posistions closer
              pmra = pmra*13/1000./60./60. ;arsec
              pmdec = pmdec*13/1000./60./60. ;arcsec
              ra = ra + pmra
              dec = dec + pmdec
              print, 'ra, dec', ra, dec
           endif
           ;;check for single star
           id1=where(strpos(Result, 'Object') ne -1, nlines)
           if nlines eq 1 then begin
              starname = strmid(Result[id1],7,11)
              idcoo = where(Result.StartsWith('Coordinates(ICRS'))
              cooline = Result[idcoo]
              pos = cooline.split(' ')
              ra = pos[1]
              dec = pos[2]
           endif

           
           ;;figure out how to exit the program if the fov is blank
           ;;(ie. subarray off FOV)
           
           none = where(strpos(Result, 'No astronomical') ne -1, nlines)
           if nlines eq 1 then begin
              found = 0
              starname = 'nostar'
           endif
           
              
              ;;
        endelse
        
     ENDELSE
  endelse
  ;;if keyword_set(Verbose) then print, 'startname before frame_check: ',  found
  found = frame_check(header, ra, dec, found)
  if found eq 0 then starname = 'nostar'
  ;;if keyword_set(Verbose) then print, 'startname after frame_check: ',  starname, found

  
  return, starname
END 


function frame_check, header, ra, dec, found
  ;;check that the star is on the frame:
  ;;print, 'found starting frame check', found
  adxy, header, ra, dec, maybex, maybey
  naxishere = sxpar(header, 'NAXIS')
  if naxishere eq 2 then begin
     xmax = 256-11 & ymax = 256-11
  endif else begin
     xmax = 32-11 & ymax = 32-11
  endelse
  ;;print, 'framecheck maybex, maybey, naxishere', maybex, maybey, naxishere, xmax, ymax
  ;;print, 'starname middle frame check', found

  if (maybex lt 10) or (maybex gt xmax) or (maybey lt 10) or(maybey gt ymax) then begin
     found = 0
     starname = 'nostar'
     print, 'star not on the frame => nostar'
  endif
    ;;print, 'starname ending frame check', found

  return, found
end


                                ; Get V mag if present
;;      vi = where(strpos(Result, '%M.V ') ne -1,vcnt)
;;      if vcnt GE 1 then reads,strmid(Result[vi],4),vmag

      ; Get J mag if present
;;      ji = where(strpos(Result, '%M.J ') ne -1,jcnt)
;;      if jcnt GE 1 then reads,strmid(Result[ji],4),jmag

      ; Get H mag if present
;;      hi = where(strpos(Result, '%M.H ') ne -1,hcnt)
;;      if hcnt GE 1 then reads,strmid(Result[hi],4),hmag

      ; Get K mag if present
;;      ki = where(strpos(Result, '%M.K ') ne -1,kcnt)
;;      if kcnt GE 1 then reads,strmid(Result[ki],4),kmag

      ; Get parallax if present
;;      plxi = where(strpos(Result, '%X ') ne -1,plxcnt)
;;      if plxcnt GE 1 then reads,strmid(Result[plxi],2),parallax
  
;;        starname = strmid(Result[id2[0]],13,25)
;;        ;;and remove some blank spaces
;;        starname = strtrim(starname)
;;        ;;need to keep the found ra and dec
;;        pos = strmid(Result[id2[0]],43,20)
;;        pos = strtrim(pos)
;;        minus = pos.Contains('-')
;;        if minus gt 0 then begin
;;           negdec = pos.Split('\-')
;;           ra = float(negdec[0])
;;           dec = float(negdec[1])
;;           dec = dec*(-1)
;;        endif else begin
;;           posdec = pos.Split('\+')
;;           ra = float(posdec[0])
;;           dec = float(posdec[1])
;;        endelse

;;              starname = strmid(Result[id2[0]],13,25)
;;              ;;and remove some blank spaces
;;              starname = strtrim(starname)
;;                     ;;need to keep the found ra and dec
;;              pos = strmid(Result[id2[0]],43,20)
;;              pos = strtrim(pos)
;;              print, 'pos', pos
;;              minus = pos.Contains('-')
;;              if minus gt 0 then begin
;;                 negdec = pos.Split('\-')
;;                 ra = float(negdec[0])
;;                 dec = float(negdec[1])
;;                 dec = dec*(-1)
;;              endif else begin
;;                 posdec = pos.Split('\+')
;;                 ra = float(posdec[0])
;;                 dec = float(posdec[1])
;;              endelse
