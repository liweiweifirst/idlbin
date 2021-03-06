PRO sortdiag2

numogals = 4
;close, /all
spawn, "rm /n/Godiva7/jkrick/galfit/nn/xydiag.log"
spawn, "rm /n/Godiva7/jkrick/galfit/nn/magdiag.log"
spawn, "rm /n/Godiva7/jkrick/galfit/nn/rediag.log"
spawn, "rm /n/Godiva7/jkrick/galfit/nn/axisdiag.log"
spawn, "rm /n/Godiva7/jkrick/galfit/nn/padiag.log"
spawn, "rm /n/Godiva7/jkrick/galfit/nn/bkgddiag.log"
spawn, "rm /n/Godiva7/jkrick/galfit/nn/dsxdiag.log"
spawn, "rm /n/Godiva7/jkrick/galfit/nn/dsydiag.log"
spawn, "rm /n/Godiva7/jkrick/galfit/nn/exp0diag.log"
spawn, "rm /n/Godiva7/jkrick/galfit/nn/exp1diag.log"
spawn, "rm /n/Godiva7/jkrick/galfit/nn/ndiag.log"

deltamag = fltarr(1730)
deltare = fltarr(1730)
deltapa = fltarr(1730)
deltaar= fltarr(1730)
deltaexp0= fltarr(1730)
deltaexp1= fltarr(1730)
deltan = fltarr(1730)
number = 0
;make an array of gal objects
gal= replicate({object, num:0, xcenter:0D, ycenter:0D, mag:0D, re:0D, axisratio:0D, pa:0D, $
     nindex:0D,dsx:0D, dsy:0D, chi2:0D, xcenter2:0D, ycenter2:0D, mag2:0D, re2:0D, axisratio2:0D, $
     pa2:0D, bkgd2:0D, nindex2:0D,dsx2:0D, dsy2:0D},numogals)

;read in the list of what the background expvalues should be
openr, explun, "/n/Godiva7/jkrick/galfit/expback/listresults", /get_lun
background = replicate({imagepar, xpoint:0D, ypoint:0D, P0:0D, P1:0D },78)

xcen = 0
ycen = 0
res0 = 0.
res1 = 0.
i = 0
WHILE (NOT EOF(explun)) DO BEGIN
    READF, explun, xcen, ycen, res0, res1
    background[i] = {imagepar, xcen, ycen, res0, res1}
    i = i +1
ENDWHILE


close, explun
free_lun, explun

openr, mainlun, "/n/Godiva7/jkrick/galfit/nn/listdiag", /get_lun, ERROR = err
IF (err NE 0) then PRINT, "list file did not open"

diagname = " "
WHILE (NOT eof(mainlun)) DO BEGIN
    readf, mainlun, diagname
    print, "working on ", diagname
     ;read which diagnostic this is
    b = strmid(diagname, 39,10) 
    c = strsplit(b, ".", /extract) 
    k = c[0]
    odist = c[1]
    
    openr,  lun, diagname, /get_lun, ERROR = err
    IF (err NE 0) then PRINT, "diagnostics file did not open"
    
    ;figure out how many lines in the file
    numolines = 0
    trash = " "
    WHILE (NOT eof(lun)) DO BEGIN
        readf, lun, trash
        numolines = numolines + 1
    ENDWHILE
    
    close, lun
    free_lun, lun
    
    openr,  lun1, diagname, /get_lun, ERROR = err
    IF (err NE 0) then PRINT, "diagnostics file did not open"
    linefile = " "
    filearr = strarr(numolines)
    i = 0
   ;read in diagnostics file to an array of lines
    WHILE (NOT eof(lun1)) DO BEGIN
        readf, lun1, linefile
        filearr[i] = linefile
        
        i = i + 1
    ENDWHILE
    close, lun1
    free_lun, lun1

    ;put values from diagnostics file into the appropriate galaxies
    ;these are the real values of the galaxy parameters
    s = strsplit( filearr[0] ,/extract)
    gal[0].num = 0
    gal[0].xcenter = s[3]
    gal[0].ycenter = s[4]
    gal[0].mag = s[5]
    s = strsplit( filearr[1] ,/extract)
    gal[0].re = s[0]
    gal[0].axisratio = s[1]
    gal[0].pa = s[2]
    gal[0].nindex = s[3]
    gal[0].dsx = s[4]
    s = strsplit( filearr[2] ,/extract)
    gal[0].dsy = s[0]

    s = strsplit( filearr[3] ,/extract)
    gal[1].num = s[2]
    gal[1].xcenter = s[3]
    gal[1].ycenter = s[4]
    gal[1].mag = s[5]
    s = strsplit( filearr[4] ,/extract)
    gal[1].re = s[0]
    gal[1].axisratio = s[1]
    gal[1].pa = s[2]
    gal[1].nindex = s[3]
    gal[1].dsx = s[3]
    s = strsplit( filearr[5] ,/extract)
    gal[1].dsy = s[0]
    
    s = strsplit( filearr[6] ,/extract)
    gal[2].num = s[2]
    gal[2].xcenter = s[3]
    gal[2].ycenter = s[4]
    gal[2].mag = s[5]
    s = strsplit( filearr[7] ,/extract)
    gal[2].re = s[0]
    gal[2].axisratio = s[1]
    gal[2].pa = s[2]
    gal[2].nindex = s[3]
    gal[2].dsx = s[3]
    s = strsplit( filearr[8] ,/extract)
    gal[2].dsy = s[0]
   
    s = strsplit( filearr[9] ,/extract)
    gal[3].num = s[2]
    gal[3].xcenter = s[3]
    gal[3].ycenter = s[4]
    gal[3].mag = s[5]
    s = strsplit( filearr[10] ,/extract)
    gal[3].re = s[0]
    gal[3].axisratio = s[1]
    gal[3].pa = s[2]
    gal[3].nindex = s[3]
    gal[3].dsx = s[3]
    s = strsplit( filearr[11] ,/extract)
    gal[3].dsy = s[0]

    ;read which expback image was used
    s = strsplit(filearr[12], /extract)

    b = strmid(s[0], 40,15) 
    c = strsplit(b, ".", /extract) 

    xback = c[0]
    yback = c[1]

;    print, "using image", s
;    print, "background centered at", xback, "   ",yback

    ;for the rest of the lines in the diagnostics file, 
    ;read the paramters from the galfit fits into the correct galaxies
    FOR j = 13, numolines - 1, 1 DO BEGIN
        s = strsplit(filearr[j], /extract)
        t= N_elements(s)
        IF (t GT 1) THEN BEGIN
            IF (s[0] NE "NOT") AND (s[0] NE "because") THEN BEGIN
                IF (round(float(s[0])) EQ round(gal[0].xcenter)) AND (round(float(s[1])) EQ round(gal[0].ycenter))$
                  THEN BEGIN
                    IF (t EQ 5) THEN BEGIN
                        gal[0].xcenter2 = s[0]
                        gal[0].ycenter2 = s[1]
                        gal[0].chi2= s[2]
                        gal[0].mag2 = s[3]
                        gal[0].re2 = s[4]
                        j = j+1
                        s = strsplit(filearr[j], /extract)
                        
                        gal[0].axisratio2 = s[0]
                        gal[0].pa2 = s[1]
                        gal[0].bkgd2 = s[2]
                        gal[0].dsx2= s[2]
                        gal[0].dsy2 = s[3]
                    ENDIF
                    IF (t EQ 9) THEN BEGIN
                        gal[0].xcenter2 = s[0]
                        gal[0].ycenter2 = s[1]
                        gal[0].chi2= s[2]
                        gal[0].mag2 = s[3]
                        gal[0].re2 = s[4]
                        gal[0].nindex2 = s[5]
                        gal[0].axisratio2 = s[6]
                        gal[0].pa2 = s[7]
                        gal[0].bkgd2 = s[8]
                        j = j+1
                        s = strsplit(filearr[j], /extract)
                        gal[0].dsx2 = s[0]
                        gal[0].dsy2 = s[1]
                    enDIF
                    IF (t EQ 10) THEN BEGIN
                        gal[0].xcenter2 = s[0]
                        gal[0].ycenter2 = s[1]
                        gal[0].chi2= s[2]
                        gal[0].mag2 = s[3]
                        gal[0].re2 = s[4]
                        gal[0].nindex2 = s[5]
                        gal[0].axisratio2 = s[6]
                        gal[0].pa2 = s[7]
                        gal[0].bkgd2 = s[8]
                        gal[0].dsx2 = s[9]
                        j = j+1
                        s = strsplit(filearr[j], /extract)
                        gal[0].dsy2= s[0]
                    enDIF
                    
                    IF (gal[0].re2 GT 100) THEN gal[0].xcenter2 = 0.
                    IF (gal[0].axisratio2 LT 0.09) THEN gal[0].xcenter2 = 0.
                    IF (t EQ 9) THEN s = strsplit(filearr[j-1], /extract)
                    IF (t EQ 10) THEN s = strsplit(filearr[j-1], /extract)
                    
                ENDIF
                
                IF (round(float(s[0])) EQ round(gal[1].xcenter)) AND (round(float(s[1])) EQ round(gal[1].ycenter))$
                  THEN  BEGIN
                    IF (t EQ 5) THEN BEGIN
                         gal[1].xcenter2 = s[0]
                         gal[1].ycenter2 = s[1]
                         gal[1].chi2= s[2]
                         gal[1].mag2 = s[3]
                         gal[1].re2 = s[4]
                         j = j+1
                         s = strsplit(filearr[j], /extract)
                        
                         gal[1].axisratio2 = s[0]
                         gal[1].pa2 = s[1]
                         gal[1].bkgd2 = s[2]
                         gal[1].dsx2 = s[2]
                         gal[1].dsy2 = s[3]
                     ENDIF
                       IF (t EQ 9) THEN BEGIN
                        gal[1].xcenter2 = s[0]
                        gal[1].ycenter2 = s[1]
                        gal[1].chi2= s[2]
                        gal[1].mag2 = s[3]
                        gal[1].re2 = s[4]
                        gal[1].nindex2 = s[5]
                        gal[1].axisratio2 = s[6]
                        gal[1].pa2 = s[7]
                        gal[1].bkgd2 = s[8]
                          j = j+1
                        s = strsplit(filearr[j], /extract)
                        gal[1].dsx2= s[0]
                        gal[1].dsy2 = s[1]
                    enDIF
                    IF (t EQ 10) THEN BEGIN
                        gal[1].xcenter2 = s[0]
                        gal[1].ycenter2 = s[1]
                        gal[1].chi2= s[2]
                        gal[1].mag2 = s[3]
                        gal[1].re2 = s[4]
                        gal[1].nindex2 = s[5]
                        gal[1].axisratio2 = s[6]
                        gal[1].pa2 = s[7]
                        gal[1].bkgd2 = s[8]
                        gal[1].dsx2 = s[9]
                        j = j+1
                        s = strsplit(filearr[j], /extract)
                         gal[1].dsy2= s[0]
                    enDIF
                    
;                gal[1].xcenter2 = s[0]
;                gal[1].ycenter2 = s[1]
;                gal[1].chi2= s[2]
;                gal[1].mag2 = s[3]
;                gal[1].re2 = s[4]
;                gal[1].axisratio2 = s[5]
;                gal[1].pa2 = s[6]
                    
                    
                    IF (gal[1].re2 GT 100) THEN gal[1].xcenter2 = 0.
                    IF (gal[1].axisratio2 LT 0.09) THEN gal[1].xcenter2 = 0.
                    IF (t EQ 9) THEN s = strsplit(filearr[j-1], /extract)
                    IF (t EQ 10) THEN s = strsplit(filearr[j-1], /extract)
                                         
                ENDIF
                
                IF (round(float(s[0])) EQ round(gal[2].xcenter)) AND (round(float(s[1])) EQ round(gal[2].ycenter))$
                  THEN BEGIN
                    IF (t EQ 5) THEN BEGIN
                         gal[2].xcenter2 = s[0]
                         gal[2].ycenter2 = s[1]
                         gal[2].chi2= s[2]
                         gal[2].mag2 = s[3]
                         gal[2].re2 = s[4]
                         j = j+1
                         s = strsplit(filearr[j], /extract)
                        
                         gal[2].axisratio2 = s[0]
                         gal[2].pa2 = s[1]
                         gal[2].bkgd2 = s[2]
                         gal[2].dsx2 = s[2]
                         gal[2].dsy2 = s[3]
                     ENDIF
                    IF (t EQ 9) THEN BEGIN
                        gal[2].xcenter2 = s[0]
                        gal[2].ycenter2 = s[1]
                        gal[2].chi2= s[2]
                        gal[2].mag2 = s[3]
                        gal[2].re2 = s[4]
                        gal[2].nindex2 = s[5]
                        gal[2].axisratio2 = s[6]
                        gal[2].pa2 = s[7]
                        gal[2].bkgd2 = s[8]
                         j = j+1
                        s = strsplit(filearr[j], /extract)
                        gal[2].dsx2 = s[0]
                        gal[2].dsy2 = s[1]
                    enDIF
                    IF (t EQ 10) THEN BEGIN
                        gal[2].xcenter2 = s[0]
                        gal[2].ycenter2 = s[1]
                        gal[2].chi2= s[2]
                        gal[2].mag2 = s[3]
                        gal[2].re2 = s[4]
                        gal[2].nindex2 = s[5]
                        gal[2].axisratio2 = s[6]
                        gal[2].pa2 = s[7]
                        gal[2].bkgd2 = s[8]
                        gal[2].dsx2 = s[9]
                        j = j+1
                        s = strsplit(filearr[j], /extract)
                        gal[2].dsy2= s[0]
                    enDIF
                    IF (gal[2].re2 GT 100) THEN gal[2].xcenter2 = 0.
                    IF (gal[2].axisratio2 LT 0.09) THEN gal[2].xcenter2 = 0.
                    IF (t EQ 9) THEN s = strsplit(filearr[j-1], /extract)
                    IF (t EQ 10) THEN s = strsplit(filearr[j-1], /extract)
                                                                                
                ENDIF
                
                IF (round(float(s[0])) EQ round(gal[3].xcenter)) AND (round(float(s[1])) EQ round(gal[3].ycenter))$
                  THEN BEGIN
                    IF (t EQ 5) THEN BEGIN
 ;                        print, "inside gal[3] if t eq 5"
                         gal[3].xcenter2 = s[0]
                         gal[3].ycenter2 = s[1]
                         gal[3].chi2= s[2]
                         gal[3].mag2 = s[3]
                         gal[3].re2 = s[4]
                         j = j+1
                         s = strsplit(filearr[j], /extract)
                        
                         gal[3].axisratio2 = s[0]
                         gal[3].pa2 = s[1]
                         gal[3].bkgd2 = s[2]
                         gal[3].dsx2= s[2]
                         gal[3].dsy2 = s[3]
                     ENDIF
                    IF (t EQ 9) THEN BEGIN
                        gal[3].xcenter2 = s[0]
                        gal[3].ycenter2 = s[1]
                        gal[3].chi2= s[2]
                        gal[3].mag2 = s[3]
                        gal[3].re2 = s[4]
                        gal[3].nindex2 = s[5]
                        gal[3].axisratio2 = s[6]
                        gal[3].pa2 = s[7]
                        gal[3].bkgd2 = s[8]
                        j = j+1
                        s = strsplit(filearr[j], /extract)
                        gal[3].dsx2 = s[0]
                        gal[3].dsy2 = s[1]
                    ENDIF
                    
                    IF (t EQ 10) THEN BEGIN
                        gal[3].xcenter2 = s[0]
                        gal[3].ycenter2 = s[1]
                        gal[3].chi2= s[2]
                        gal[3].mag2 = s[3]
                        gal[3].re2 = s[4]
                        gal[3].nindex2 = s[5]
                        gal[3].axisratio2 = s[6]
                        gal[3].pa2 = s[7]
                        gal[3].bkgd2 = s[8]
                        gal[3].dsx2 = s[9]
                        j = j+1
                       s = strsplit(filearr[j], /extract)
                        gal[3].dsy2= s[0]
                    ENDIF
                    
                    IF (gal[3].re2 GT 100) THEN gal[3].xcenter2 = 0.
                    IF (gal[3].axisratio2 LT 0.09) THEN gal[3].xcenter2 = 0.
                    IF (t EQ 9) THEN s = strsplit(filearr[j-1], /extract)
                    IF (t EQ 10) THEN s = strsplit(filearr[j-1], /extract)
                    
                ENDIF
                
            ENDIF
            
        ENDIF
        
    ENDFOR

     ;find correlations among the position angles
     ;this is not perfect, need to have it know that 1 is within 10% of 179
    FOR f = 0,numogals - 1,1 DO BEGIN
        IF (gal[f].pa LT 0. ) THEN gal[f].pa = gal[f].pa + 180. ;really shouldn't have gotten here
        IF (gal[f].pa2 LT 0.) AND (gal[f].pa2 GT (-180.)) THEN gal[f].pa2 = gal[f].pa2 + 180.
        IF (gal[f].pa2 LT 0.) AND (gal[f].pa2 LT (-180.)) THEN gal[f].pa2 = gal[f].pa2 + 360.
        IF (gal[f].pa2 GT 180.) THEN gal[f].pa2 = gal[f].pa2 - 180.
    ENDFOR
     
    FOR m = 0, numogals - 1, 1 DO BEGIN
  
         ;make a magnitude cutoff
         IF (gal[m].mag GT 23.) THEN BEGIN
             gal[m].xcenter2 = 0.
             gal[m].ycenter2 = 0.
             gal[m].mag2 = 0.
             gal[m].re2 = 0.
             gal[m].axisratio2 = 0.
             gal[m].pa2 = 0.
         ENDIF
         
;make a cutoff in re
;    IF (gal[m].re GT 15) THEN BEGIN
;        gal[m].xcenter2 = 0.
;        gal[m].ycenter2 = 0.
;        gal[m].mag2 = 0.
;        gal[m].re2 = 0.
;        gal[m].axisratio2 = 0.
;        gal[m].pa2 = 0.
;    ENDIF
        
     ENDFOR

     fracpercent = numogals
                                ;if I don't include a galaxy, need to
                                ;know that then there are less total to include in the fractions
    FOR z = 0, numogals - 1, 1 DO BEGIN
        IF (gal[z].xcenter2 EQ 0.) THEN BEGIN
            fracpercent = fracpercent - 1.
        ENDIF
        
    ENDFOR

    exp010percent= 0.
    exp020percent= 0.
    exp110percent= 0.
    exp120percent = 0.
    
    
    IF (fracpercent NE 0.) THEN  BEGIN
        fracpercent = 1. / fracpercent
    ENDIF
 

    sname = strcompress("/n/Godiva7/jkrick/galfit/nn/nogals" + string(k)  + "." + $
                            string(odist) , /remove_all)
 
    expresult = funcprof( sname, xback, yback)

        ;did I recover the icl in the background?


    FOR i = 0,77,1 DO BEGIN
        IF (fix(background[i].xpoint) EQ fix(xback+1)) AND (fix(background[i].ypoint) EQ fix(yback+1)) THEN BEGIN
            exp0orig = background[i].P0
            exp1orig = background[i].P1
;                print, xback, yback, exp0orig, exp1orig
        ENDIF
    ENDFOR
    
 
    exp0diff = abs(exp0orig - expresult[0])
    exp1diff = abs(exp1orig - expresult[1])
    
    IF (round(100*exp0diff/ exp0orig) LE 10) THEN exp010percent = 1. ;exp010percent + fracpercent
    IF (round(100*exp0diff/ exp0orig) LE 20) THEN exp020percent = 1. ;exp020percent + fracpercent
    IF (round(100*exp1diff/ exp1orig) LE 10) THEN exp110percent = 1. ;exp110percent + fracpercent
    IF (round(100*exp1diff/ exp1orig) LE 20) THEN exp120percent = 1. ;exp120percent + fracpercent
    


     ;distance between galaxies
    dist = abs(gal[0].xcenter - gal[2].xcenter)
    
    x10percent = 0.
    mag10percent = 0.
    re10percent = 0.
    axis10percent = 0.
    pa10percent = 0.
    bkgd10percent = 0.
    dsx10percent = 0.
    dsy10percent = 0.
    x20percent = 0.
    mag20percent = 0.
    re20percent = 0.
    axis20percent = 0.
    pa20percent = 0.
    bkgd20percent = 0.
    dsx20percent = 0.
    dsy20percent = 0.
    n10percent = 0.
    n20percent = 0.
    
    ;for each galaxy, if it hasn't been removed from the list,
    ;find the percentage of galaxies that
    ;recovered the correct parameters
    ;to 10 and 20 percent 
    FOR k = 0, numogals - 1, 1 DO BEGIN
 
        IF ( gal[k].xcenter2 NE 0.) THEN BEGIN
;
            xcenterdiff = abs(gal[k].xcenter - gal[k].xcenter2)
            ycenterdiff = abs(gal[k].ycenter - gal[k].ycenter2)
            magdiff = abs(gal[k].mag - gal[k].mag2) 
            rediff = abs(gal[k].re - gal[k].re2) 
            axisratiodiff = abs(gal[k].axisratio - gal[k].axisratio2) 
            padiff = abs(gal[k].pa - gal[k].pa2) 
            bkgddiff = abs(2 - gal[k].bkgd2)   ;will need to change this if I change bkgd values
            dsxdiff = abs(gal[k].dsx - gal[k].dsx2)
            dsydiff = abs(gal[k].dsy - gal[k].dsy2)
            ndiff  = abs(gal[k].nindex - gal[k].nindex2)

           deltamag[number] = gal[k].mag - gal[k].mag2
            deltare[number] = gal[k].re- gal[k].re2
            deltapa[number] = gal[k].pa - gal[k].pa2
            deltaar[number] = gal[k].axisratio - gal[k].axisratio2
            deltan[number] = gal[k].nindex - gal[k].nindex2
            number = number + 1
 

             IF ((xcenterdiff + ycenterdiff) / 2 LE 0.5) THEN x10percent = x10percent + fracpercent
             IF ( magdiff LE 0.1) THEN mag10percent = mag10percent + fracpercent
             IF (padiff LE 10) THEN  pa10percent = pa10percent + fracpercent
             IF (gal[k].re LT 4) THEN BEGIN
                 IF (rediff LE 1) THEN re10percent = re10percent + fracpercent
             ENDIF ELSE BEGIN
                 IF (round(100* rediff/ gal[k].re) LE 10) THEN re10percent = re10percent + fracpercent
             ENDELSE
             IF (axisratiodiff LE 0.1) THEN axis10percent = axis10percent + fracpercent
             IF (round(100*bkgddiff / 2.0) LE 2) THEN bkgd10percent = bkgd10percent + fracpercent
             IF (round(100*dsxdiff/ gal[k].dsx) LE 10) THEN dsx10percent = dsx10percent + fracpercent
             IF (round(100*dsydiff / gal[k].dsy) LE 10) THEN dsy10percent =dsy10percent + fracpercent
;             IF(ndiff LE 0.1) THEN n10percent =n10percent + fracpercent


             IF ((xcenterdiff + ycenterdiff) / 2 LE 1) THEN x20percent = x20percent + fracpercent
             IF ( magdiff LE 0.2) THEN mag20percent = mag20percent + fracpercent
             IF (padiff LE 20) THEN  pa20percent = pa20percent + fracpercent
             IF (gal[k].re LT 4) THEN BEGIN
                 IF (rediff LE 2) THEN re20percent = re20percent + fracpercent
             ENDIF ELSE BEGIN
                 IF (round(100* rediff/ gal[k].re) LE 20) THEN re20percent = re20percent + fracpercent
             ENDELSE
             IF (axisratiodiff LE 0.2) THEN axis20percent = axis20percent + fracpercent
             IF (round(100*bkgddiff / 4.0) LE 4) THEN bkgd20percent = bkgd20percent + fracpercent
             IF (round(100*dsxdiff/ gal[k].dsx) LE 20) THEN dsx20percent = dsx20percent + fracpercent
             IF (round(100*dsydiff / gal[k].dsy) LE 20) THEN dsy20percent =dsy20percent + fracpercent
;            IF(ndiff LE 0.2) THEN n20percent =n20percent + fracpercent


        ENDIF


    ENDFOR
;put them into files
    openw, outlun, "/n/Godiva7/jkrick/galfit/nn/xydiag.log", /GET_LUN, /append
    printf, outlun, dist, x10percent, x20percent
    close, outlun
    free_lun, outlun
    
    openw, outlun, "/n/Godiva7/jkrick/galfit/nn/magdiag.log", /GET_LUN, /append
    printf, outlun, dist, mag10percent, mag20percent
    close, outlun
    free_lun, outlun
    
    openw, outlun, "/n/Godiva7/jkrick/galfit/nn/rediag.log", /GET_LUN, /append
    printf, outlun, dist, re10percent,re20percent
    close, outlun
    free_lun, outlun
    
    openw, outlun, "/n/Godiva7/jkrick/galfit/nn/axisdiag.log", /GET_LUN, /append
    printf, outlun, dist, axis10percent,axis20percent
    close, outlun
    free_lun, outlun
    
    openw, outlun, "/n/Godiva7/jkrick/galfit/nn/padiag.log", /GET_LUN, /append
    printf, outlun, dist, pa10percent,pa20percent
    close, outlun
    free_lun, outlun

    openw, outlun, "/n/Godiva7/jkrick/galfit/nn/bkgddiag.log", /GET_LUN, /append
    printf, outlun, dist, bkgd10percent,bkgd20percent
    close, outlun
    free_lun, outlun

    openw, outlun, "/n/Godiva7/jkrick/galfit/nn/dsxdiag.log", /GET_LUN, /append
    printf, outlun, dist, dsx10percent,dsx20percent
    close, outlun
    free_lun, outlun

    openw, outlun, "/n/Godiva7/jkrick/galfit/nn/dsydiag.log", /GET_LUN, /append
    printf, outlun, dist, dsy10percent,dsy20percent
    close, outlun
    free_lun, outlun

    openw, outlun, "/n/Godiva7/jkrick/galfit/nn/exp0diag.log", /GET_LUN, /append
    printf, outlun, dist, exp010percent,exp020percent
    close, outlun
    free_lun, outlun

    openw, outlun2, "/n/Godiva7/jkrick/galfit/nn/exp1diag.log", /GET_LUN, /append, ERROR = err
    IF (err NE 0) then PRINT, "exp1 file did not open"
    printf, outlun2, dist, exp110percent,exp120percent
    close, outlun2
    free_lun, outlun2

;    openw, outlun, "/n/Godiva7/jkrick/galfit/nn/ndiag.log", /GET_LUN, /append
;printf, outlun, dist, n10percent,n20percent
;    close, outlun
;    free_lun, outlun

ENDWHILE


close, mainlun
free_lun, mainlun

;i know this is not efficient, but read back in from files to plot

device, true=24
device, decomposed=0
colors = GetColor(/load, Start=1)

mydevice = !D.NAME
!p.multi= [0, 0, 2]
SET_PLOT, 'ps'

device, filename = '/n/Godiva7/jkrick/galfit/nn/frac.ps', /portrait, $
  BITS=8, scale_factor=0.9 , /color
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



numolines = 730

dist = fltarr(numolines)
xy10point = fltarr(numolines)
mag10point = fltarr(numolines)
re10point = fltarr(numolines)
axis10point = fltarr(numolines)
pa10point = fltarr(numolines)
bkgd10point = fltarr(numolines)
dsx10point = fltarr(numolines)
dsy10point = fltarr(numolines)
xy20point = fltarr(numolines)
mag20point = fltarr(numolines)
re20point = fltarr(numolines)
axis20point = fltarr(numolines)
pa20point = fltarr(numolines)
bkgd20point = fltarr(numolines)
dsx20point = fltarr(numolines)
dsy20point = fltarr(numolines)

exp010point = fltarr(numolines)
exp020point = fltarr(numolines)
exp110point = fltarr(numolines)
exp120point = fltarr(numolines)
n10point = fltarr(numolines)
n20point = fltarr(numolines)

i  = 0
openr, whatever, "/n/Godiva7/jkrick/galfit/nn/xydiag.log", /GET_LUN
WHILE (NOT eof(whatever)) DO BEGIN
    readf, whatever, distin, xypointin, second
    dist[i] = distin
    xy10point[i] = xypointin
    xy20point[i] = second
    i = i + 1
ENDWHILE
close, whatever
free_lun, whatever
   
i  = 0
openr, whatever, "/n/Godiva7/jkrick/galfit/nn/magdiag.log", /GET_LUN
WHILE (NOT eof(whatever)) DO BEGIN
    readf, whatever, distin, magpointin, second
    mag10point[i] = magpointin
    mag20point[i] = second
    i = i + 1
ENDWHILE
close, whatever
free_lun, whatever
 
i  = 0
openr, whatever, "/n/Godiva7/jkrick/galfit/nn/rediag.log", /GET_LUN
WHILE (NOT eof(whatever)) DO BEGIN
    readf, whatever, distin, repointin, second
    re10point[i] = repointin
    re20point[i] = second
    i = i + 1
ENDWHILE
 close, whatever
free_lun, whatever

i  = 0
openr, whatever, "/n/Godiva7/jkrick/galfit/nn/axisdiag.log", /GET_LUN
WHILE (NOT eof(whatever)) DO BEGIN
    readf, whatever, distin, axispointin, second
    axis10point[i] = axispointin
    axis20point[i] = second
    i = i + 1
ENDWHILE
close, whatever
free_lun, whatever
 
i  = 0
openr, whatever, "/n/Godiva7/jkrick/galfit/nn/padiag.log", /GET_LUN
WHILE (NOT eof(whatever)) DO BEGIN
    readf, whatever, distin, papointin, second
    pa10point[i] = papointin
    pa20point[i] = second
    i = i + 1
ENDWHILE
close, whatever
free_lun, whatever

i  = 0
openr, whatever, "/n/Godiva7/jkrick/galfit/nn/bkgddiag.log", /GET_LUN
WHILE (NOT eof(whatever)) DO BEGIN
    readf, whatever, distin, bkgdpointin, second
    bkgd10point[i] = bkgdpointin
    bkgd20point[i] = second
    i = i + 1
ENDWHILE
close, whatever
free_lun, whatever

i  = 0
openr, whatever, "/n/Godiva7/jkrick/galfit/nn/dsxdiag.log", /GET_LUN
WHILE (NOT eof(whatever)) DO BEGIN
    readf, whatever, distin, dsxpointin, second
    dsx10point[i] = dsxpointin
    dsx20point[i] = second
    i = i + 1
ENDWHILE
close, whatever
free_lun, whatever

i  = 0
openr, whatever, "/n/Godiva7/jkrick/galfit/nn/dsydiag.log", /GET_LUN
WHILE (NOT eof(whatever)) DO BEGIN
    readf, whatever, distin, dsypointin, second
    dsy10point[i] = dsypointin
    dsy20point[i] = second
    i = i + 1
ENDWHILE
close, whatever
free_lun, whatever

;i  = 0
;openr, whatever5, "/n/Godiva7/jkrick/galfit/nn/ndiag.log", /GET_LUN
;WHILE (NOT eof(whatever5)) DO BEGIN
;    readf, whatever, junk1,junk2,junk3
;    n10point[i] = junk2
;    n20point[i] = junk3
;    i = i + 1
;ENDWHILE
;close, whatever5
;free_lun, whatever5

i =0
openr, whatever, "/n/Godiva7/jkrick/galfit/nn/exp0diag.log", /GET_LUN
WHILE (NOT eof(whatever)) DO BEGIN
    readf, whatever, distin, dsypointin, second
    exp010point[i] = dsypointin
    exp020point[i] = second
    i = i + 1
ENDWHILE
close, whatever
free_lun, whatever

i  = 0
openr, whatever, "/n/Godiva7/jkrick/galfit/nn/exp1diag.log", /GET_LUN
WHILE (NOT eof(whatever)) DO BEGIN
    readf, whatever, distin, dsypointin, second
    exp110point[i] = dsypointin
    exp120point[i] = second
    i = i + 1
ENDWHILE
close, whatever
free_lun, whatever


;shorten the arrays to only be as long as they need to be
dist = dist[0:i -1]
xy10point = xy10point[0:i-1]
mag10point = mag10point[0:i-1]
re10point = re10point[0:i-1]
axis10point = axis10point[0:i-1]
pa10point = pa10point[0:i-1]
bkgd10point = bkgd10point[0:i-1]
dsx10point = dsx10point[0:i-1]
dsy10point = dsy10point[0:i-1]
xy20point = xy20point[0:i-1]
mag20point = mag20point[0:i-1]
re20point = re20point[0:i-1]
axis20point = axis20point[0:i-1]
pa20point = pa20point[0:i-1]
bkgd20point = bkgd20point[0:i-1]
dsx20point = dsx20point[0:i-1]
dsy20point = dsy20point[0:i-1]

exp010point = exp010point[0:i-1]
exp020point = exp020point[0:i-1]
exp110point = exp110point[0:i-1]
exp120point = exp120point[0:i-1]

;n10point = n10point[0:i-1]
;n20point = n20point[0:i-1]

;sort them,
sortindex= sort(dist)
sorteddist = dist[sortindex]
sortedxy10point = xy10point[sortindex]
sortedmag10point = mag10point[sortindex]
sortedre10point = re10point[sortindex]
sortedaxis10point = axis10point[sortindex]
sortedpa10point = pa10point[sortindex]
sortedbkgd10point = bkgd10point[sortindex]
sorteddsx10point = dsx10point[sortindex]
sorteddsy10point = dsy10point[sortindex]
sortedxy20point = xy20point[sortindex]
sortedmag20point = mag20point[sortindex]
sortedre20point = re20point[sortindex]
sortedaxis20point = axis20point[sortindex]
sortedpa20point = pa20point[sortindex]
sortedbkgd20point = bkgd20point[sortindex]
sorteddsx20point = dsx20point[sortindex]
sorteddsy20point = dsy20point[sortindex]

sortedexp010point = exp010point[sortindex]
sortedexp020point = exp020point[sortindex]
sortedexp110point = exp110point[sortindex]
sortedexp120point = exp120point[sortindex]
;sortedn10point = n10point[sortindex]
;sortedn20point = n20point[sortindex]

f = 0
d = 0
newdist = fltarr(i - 1)
newxy10point = fltarr(i - 1)
newmag10point = fltarr(i - 1)
newre10point = fltarr(i - 1)
newaxis10point = fltarr(i - 1)
newpa10point = fltarr(i - 1)
newbkgd10point = fltarr(i - 1)
newdsx10point = fltarr(i - 1)
newdsy10point = fltarr(i - 1)
newxy20point = fltarr(i - 1)
newmag20point = fltarr(i - 1)
newre20point = fltarr(i - 1)
newaxis20point = fltarr(i - 1)
newpa20point = fltarr(i - 1)
newbkgd20point = fltarr(i - 1)
newdsx20point = fltarr(i - 1)
newdsy20point = fltarr(i - 1)

newexp010point = fltarr(i - 1)
newexp020point = fltarr(i - 1)
newexp110point = fltarr(i - 1)
newexp120point = fltarr(i - 1)

newn10point = fltarr(i-1)
newn20point = fltarr(i-1)
;average all the values at the same distance
FOR c = 1, i - 1,  1 DO BEGIN

    IF  (sorteddist(c) EQ sorteddist(c - 1))  THEN BEGIN 
        newdist(d)  = sorteddist(c)
        newxy10point(d) = newxy10point(d) + sortedxy10point(c)
        newmag10point(d) = newmag10point(d) + sortedmag10point(c)
        newre10point(d) = newre10point(d) + sortedre10point(c)
        newaxis10point(d) = newaxis10point(d) + sortedaxis10point(c)
        newpa10point(d) = newpa10point(d) + sortedpa10point(c)
        newbkgd10point(d) = newbkgd10point(d) + sortedbkgd10point(c)
        newdsx10point(d) = newdsx10point(d) + sorteddsx10point(c)
        newdsy10point(d) = newdsy10point(d) + sorteddsy10point(c)
        newxy20point(d) = newxy20point(d) + sortedxy20point(c)
        newmag20point(d) = newmag20point(d) + sortedmag20point(c)
        newre20point(d) = newre20point(d) + sortedre20point(c)
        newaxis20point(d) = newaxis20point(d) + sortedaxis20point(c)
        newpa20point(d) = newpa20point(d) + sortedpa20point(c)
        newbkgd20point(d) = newbkgd20point(d) + sortedbkgd20point(c)
        newdsx20point(d) = newdsx20point(d) + sorteddsx20point(c)
        newdsy20point(d) = newdsy20point(d) + sorteddsy20point(c)

        newexp010point(d) = newexp010point(d) + sortedexp010point(c)
        newexp020point(d) = newexp020point(d) + sortedexp020point(c)
        newexp110point(d) = newexp110point(d) + sortedexp110point(c)
        newexp120point(d) = newexp120point(d) + sortedexp120point(c)
;      newn10point(d) = newn10point(d) + sortedn10point(c)
;        newn20point(d) = newn20point(d) + sortedn20point(c)

        f = f + 1
    ENDIF ELSE BEGIN
        newxy10point(d) = newxy10point(d) / f
        newmag10point(d) = newmag10point(d) / f
        newre10point(d) = newre10point(d) / f
        newaxis10point(d) = newaxis10point(d) / f
        newpa10point(d) = newpa10point(d) / f
        newbkgd10point(d) = newbkgd10point(d) / f
        newdsx10point(d) = newdsx10point(d) / f
        newdsy10point(d) = newdsy10point(d) / f
       newxy20point(d) = newxy20point(d) / f
        newmag20point(d) = newmag20point(d) / f
        newre20point(d) = newre20point(d) / f
        newaxis20point(d) = newaxis20point(d) / f
        newpa20point(d) = newpa20point(d) / f
        newbkgd20point(d) = newbkgd20point(d) / f
        newdsx20point(d) = newdsx20point(d) / f
        newdsy20point(d) = newdsy20point(d) / f

        newexp010point(d) = newexp010point(d) / f
        newexp020point(d) = newexp020point(d) / f
        newexp110point(d) = newexp110point(d) / f
        newexp120point(d) = newexp120point(d) / f
;        newn10point(d) = newn10point(d) / f
;        newn20point(d) = newn20point(d) / f


        d = d + 1
        f = 0
    ENDELSE

ENDFOR

;again shorten the arrays to only be as long as they need to be
newdist = newdist[0:d-1]
newxy10point = newxy10point[0:d-1]
newmag10point = newmag10point[0:d-1]
newre10point = newre10point[0:d-1]
newaxis10point = newaxis10point[0:d-1]
newpa10point = newpa10point[0:d-1]
newbkgd10point = newbkgd10point[0:d-1]
newdsx10point = newdsx10point[0:d-1]
newdsy10point = newdsy10point[0:d-1]
newxy20point = newxy20point[0:d-1]
newmag20point = newmag20point[0:d-1]
newre20point = newre20point[0:d-1]
newaxis20point = newaxis20point[0:d-1]
newpa20point = newpa20point[0:d-1]
newbkgd20point = newbkgd20point[0:d-1]
newdsx20point = newdsx20point[0:d-1]
newdsy20point = newdsy20point[0:d-1]

newexp010point = newexp010point[0:d-1]
newexp020point = newexp020point[0:d-1]
newexp110point = newexp110point[0:d-1]
newexp120point = newexp120point[0:d-1]
;newn10point = newn10point[0:d-1]
;newn20point = newn20point[0:d-1]

plot, newdist, newxy10point,thick = 3, charthick = 3,$
       YRANGE = [0,1.1] ,psym = -5, xtickinterval = 10,$
        ytitle = 'fraction of gals correct ', title = 'Sersic galaxies fit with deV profile';, $
;  xtitle = 'distance between galaxies (pixels)'

oplot, newdist, newmag10point, thick = 3, psym = -6,color = colors.red
oplot, newdist, newre10point, thick = 3, psym = -4, color = colors.green
oplot, newdist, newaxis10point, thick = 3, psym = -2, color = colors.magenta
oplot, newdist, newpa10point, thick = 3, psym = -1, color = colors.blue
;oplot, newdist, newbkgd10point, thick = 3, psym = -1, color = colors.cyan
;oplot, newdist, newdsx10point, thick = 3, psym = -2, color = colors.orange
;oplot, newdist, newdsy10point, thick = 3, psym = -4, color = colors.cyan
oplot, newdist, newexp010point, thick = 3, psym = -1, color = colors.salmon
oplot, newdist, newexp110point, thick = 3, psym = -1, color = colors.peru
;oplot, newdist, newn10point, thick = 3, psym = -1, color = colors.greenyellow

xyouts, 30, 0.55, "xycenters", charsize = 0.7,color = colors.black
xyouts, 30, 0.45, "magnitude (18 - 23)", charsize = 0.7,color = colors.red
xyouts, 30, 0.25, "re (0.1 - 18.1)", charsize = 0.7,color = colors.green
xyouts, 30, 0.35, "axisratio(0.1 - 1)", charsize = 0.7,color = colors.magenta
xyouts, 30, 0.15, "position angle", charsize = 0.7,color = colors.blue
;xyouts, 30, 0.05, "background", charsize = 0.7,color = colors.cyan


xline = findgen(100)
yline = fltarr(100)
yline(*) = 0.7
oplot, xline,yline, color = colors.black


plot, newdist, newxy20point,thick = 3, charthick = 3,$
       YRANGE = [0,1.1] ,psym = -5, xtickinterval = 10,$
        ytitle = 'fraction of gals correct ',   xtitle = 'distance between galaxies (pixels)', $
        subtitle = '4 galaxies per simulation, 20 simulations at each separation distance'
;title = 'Galaxy Simulation Fun', $


oplot, newdist, newmag20point, thick = 3, psym = -6,color = colors.red
oplot, newdist, newre20point, thick = 3, psym = -4, color = colors.green
oplot, newdist, newaxis20point, thick = 3, psym = -2, color = colors.magenta
oplot, newdist, newpa20point, thick = 3, psym = -1, color = colors.blue
;oplot, newdist, newbkgd20point, thick = 3, psym = -1, color = colors.cyan
;oplot, newdist, newdsx20point, thick = 3, psym = -2, color = colors.orange
;oplot, newdist, newdsy20point, thick = 3, psym = -4, color = colors.cyan
oplot, xline,yline, color = colors.black
oplot, newdist, newexp020point, thick = 3, psym = -1, color = colors.salmon
oplot, newdist, newexp120point, thick = 3, psym = -1, color = colors.peru
;oplot, newdist, newn20point, thick = 3, psym = -1, color = colors.greenyellow

;xyouts, 60, 0.4, "dsky/dx", charsize = 0.7,color = colors.orange
;xyouts, 60, 0.3, "dsky/dy", charsize = 0.7,color = colors.cyan
xyouts, 30, 0.4, "exp0", charsize = 0.7,color = colors.salmon
xyouts, 30, 0.3, "exp1", charsize = 0.7,color = colors.peru
;xyouts, 30, 0.2, "n", charsize = 0.7, color = colors.greenyellow

close, lun1
device, /close
set_plot, mydevice
;-------------------------------------------------------------------------------------------

deltamag = deltamag[0:number -1]
deltare = deltare[0:number-1]
deltapa =deltapa[0:number-1]
deltaar= deltaar[0:number-1]
deltan = deltan[0:number-1]

!p.multi= [0, 0, 1]
SET_PLOT, 'ps'
device, filename = '/n/Godiva7/jkrick/galfit/nn/maghist.ps', /portrait, $
  BITS=8, scale_factor=0.9 , /color
plothist, deltamag, xhist, yhist, bin = 0.05, xrange = [-0.5,0.5], xtitle= "delta magnitude", ytitle= "N", thick = 3, title = "Magnitude histogram",  fcolor = blue, charthick = 3

start = [-0.01,0.05,10.]
err = xhist - xhist + 1.         ;make a simple error array, all even errors
result1 = MPFITFUN('gauss',xhist, yhist, err, start);, weights=weight);,PARINFO=pi);, weights=weight)
xaxis = findgen(1000) / 1000.
xaxis2 = -xaxis
oplot, xaxis, result1(2)/sqrt(2.*!Pi) * exp(-0.5*((xaxis- result1(0))/result1(1))^2.), color = colors.red, thick = 5
oplot, xaxis2, result1(2)/sqrt(2.*!Pi) * exp(-0.5*((xaxis2- result1(0))/result1(1))^2.), color = colors.red, thick = 5

val = string(result1(0)) + " " + string(result1(1)) + " " +string(result1(2))
xyouts, 0.1, 200, val, charsize = 0.7,color = colors.red
device, /close
set_plot, mydevice
;-----------------------------------------------------------------------------------------

!p.multi= [0, 0, 1]
SET_PLOT, 'ps'
device, filename = '/n/Godiva7/jkrick/galfit/nn/rehist.ps', /portrait, $
  BITS=8, scale_factor=0.9 , /color
plothist, deltare, xhist, yhist, bin = 0.05,xrange = [-2., 2.], xtitle= "delta re", ytitle= "N", thick = 3, title = "re histogram",  fcolor = blue, charthick = 3

start = [-0.01,0.5,100.]
err =xhist - xhist  + 1.         ;make a simple error array, all even errors
result1 = MPFITFUN('gauss',xhist, yhist, err, start);, weights=weight);,PARINFO=pi);, weights=weight)
xaxis = findgen(1000) / 1000.
xaxis2 = -xaxis
oplot, xaxis, result1(2)/sqrt(2.*!Pi) * exp(-0.5*((xaxis- result1(0))/result1(1))^2.), color = colors.red, thick = 5
oplot, xaxis2, result1(2)/sqrt(2.*!Pi) * exp(-0.5*((xaxis2- result1(0))/result1(1))^2.), color = colors.red, thick = 5
val = string(result1(0)) + " " + string(result1(1)) + " " +string(result1(2))
xyouts, 0.2, 150, val, charsize = 0.7,color = colors.red

device, /close
set_plot, mydevice
;-----------------------------------------------------------------------------------------

!p.multi= [0, 0, 1]
SET_PLOT, 'ps'
device, filename = '/n/Godiva7/jkrick/galfit/nn/arhist.ps', /portrait, $
  BITS=8, scale_factor=0.9 , /color
plothist, deltaar, xhist, yhist, bin = 0.05, xrange = [-0.5, 0.5],xtitle= "delta axis ratio", ytitle= "N", thick = 3, title = "Axis Ratio histogram", fcolor = blue, charthick = 3


start = [-0.01,0.5,100.]
err = xhist - xhist + 1.     ;make a simple error array, all even errors
result1 = MPFITFUN('gauss',xhist, yhist, err, start);, weights=weight);,PARINFO=pi);, weights=weight)
xaxis = findgen(1000) / 1000.
xaxis2 = -xaxis
oplot, xaxis, result1(2)/sqrt(2.*!Pi) * exp(-0.5*((xaxis- result1(0))/result1(1))^2.), color = colors.red, thick = 5
oplot, xaxis2, result1(2)/sqrt(2.*!Pi) * exp(-0.5*((xaxis2- result1(0))/result1(1))^2.), color = colors.red, thick = 5
val = string(result1(0)) + " " + string(result1(1)) + " " +string(result1(2))
xyouts, 0.1, 400, val, charsize = 0.7,color = colors.red
device, /close
set_plot, mydevice
;-----------------------------------------------------------------------------------------

!p.multi= [0, 0, 1]
SET_PLOT, 'ps'
device, filename = '/n/Godiva7/jkrick/galfit/nn/nhist.ps', /portrait, $
  BITS=8, scale_factor=0.9 , /color
plothist, deltan, xhist, yhist, bin = 0.05, xrange = [-2, 2],xtitle= "delta n (sersic index)", ytitle= "N", thick = 3, title = "n  histogram", fcolor = blue, charthick = 3


start = [-0.01,0.5,100.]
err = xhist - xhist + 1.     ;make a simple error array, all even errors
result1 = MPFITFUN('gauss',xhist, yhist, err, start);, weights=weight);,PARINFO=pi);, weights=weight)
xaxis = findgen(1000) / 1000.
xaxis2 = -xaxis
oplot, xaxis, result1(2)/sqrt(2.*!Pi) * exp(-0.5*((xaxis- result1(0))/result1(1))^2.), color = colors.red, thick = 5
oplot, xaxis2, result1(2)/sqrt(2.*!Pi) * exp(-0.5*((xaxis2- result1(0))/result1(1))^2.), color = colors.red, thick = 5
val = string(result1(0)) + " " + string(result1(1)) + " " +string(result1(2))
xyouts, 0.1, 60, val, charsize = 0.7,color = colors.red
device, /close
set_plot, mydevice



close, /all
undefine, gal
undefine, background

END
 ;           xcenterdiff = round(100.* abs(gal[k].xcenter - gal[k].xcenter2) / gal[k].xcenter)
;            ycenterdiff = round(100.*abs(gal[k].ycenter - gal[k].ycenter2) / gal[k].ycenter)
;            magdiff = round(100.*abs(gal[k].mag - gal[k].mag2) / gal[k].mag)
;            rediff = round(100.*abs(gal[k].re - gal[k].re2) / gal[k].re)
;            axisratiodiff = round(100.*abs(gal[k].axisratio - gal[k].axisratio2) / gal[k].axisratio)
;            IF ( gal[k].pa EQ 0.) THEN BEGIN
;                padiff = round(100.*abs(gal[k].pa - gal[k].pa2) / gal[k].pa2)
;            ENDIF ELSE BEGIN
;                padiff = round(100.*abs(gal[k].pa - gal[k].pa2) / gal[k].pa)
;            ENDELSE;;;;

;            IF ((xcenterdiff + ycenterdiff) / 2 LE 10) THEN x10percent = x10percent + fracpercent
;            IF (magdiff LE 10) THEN mag10percent = mag10percent + fracpercent
;            IF (rediff LE 10) THEN re10percent = re10percent + fracpercent
;            IF (axisratiodiff LE 10) THEN axis10percent = axis10percent + fracpercent
;            IF (abs(gal[k].pa - gal[k].pa2) LT 18.) THEN pa10percent = pa10percent + fracpercent;;

;            IF ((xcenterdiff + ycenterdiff) / 2 LE 20) THEN x20percent = x20percent + fracpercent
;            IF (magdiff LE 20) THEN mag20percent = mag20percent + fracpercent
;            IF (rediff LE 20) THEN re20percent = re20percent + fracpercent
;            IF (axisratiodiff LE 20) THEN axis20percent = axis20percent + fracpercent
;            IF (padiff LE 20) THEN pa20percent = pa20percent +
;            fracpercent
