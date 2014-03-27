PRO pmap_correct_interpolate_single,x,y,f,ch,np,func,f_interp,f_interp_unc,NNEAREST=nnearest, USE_NP = use_np
  COMMON pmap_data,x_pmap,y_pmap,f_pmap,np_pmap,func_pmap,scale,sigscale
   ;print, 'testing use_np', use_np
  ;;; Find the nearest neighbors in the pmap dataset
   IF N_ELEMENTS(nnearest) EQ 0 THEN nnearest = 50
   np1d = SQRT(np)
   np_pmap_1d = SQRT(np_pmap)
   
   ;;; (Squared) Distance of pmap dataset points to current point
   b = FIX(ch) EQ 1 ? 0.8 : 1.0
;   d2 = (x_pmap-x)^2 + ((y_pmap-y)/b)^2 + keyword_set(use_np)*(np_pmap_1d-np1d)^2  ; only add the np to distance if called

;; Compute Delaunay triangulation
 ;add the point of interest as the first point in the pmap x's and y's
   xtrian = [x,x_pmap]
   ytrian = [y,y_pmap]
   nptrian = [np, np_pmap_1d]
   ftrian = [f, f_pmap]
   functrian = [func, func_pmap]
   nearest = nearest_neighbors_np_DT(xtrian,ytrian,nptrian,ch,DISTANCES=d,NUMBER=nnearest)

   ;;; Compute the spread in the pmap data for the nearest neighbor points 
   sig_x = STDDEV(xtrian[nearest],/NAN,/DOUBLE)
   sig_y = STDDEV(ytrian[nearest],/NAN,/DOUBLE)
   sig_np_1d = STDDEV(nptrian[nearest],/NAN,/DOUBLE)
   
   ;;; Compute the weighted occupation vector at point (X,Y,NP) (for the nearest neighbor points)
   occ_vec = ( EXP(-(x-xtrian[nearest])^2/(2*sig_x^2)) + $
               EXP(-(y-ytrian[nearest])^2/(2*sig_y^2)) + $
                   keyword_set(use_np)*EXP(-(np1d-nptrian[nearest])^2/(2*sig_np_1d^2)) $
                  ) 
   kernel = occ_vec / functrian[nearest]^2
   ;;; Compute the weighted average (interpolated) pmap flux at point (X,Y,NP)  
   f_interp = TOTAL(ftrian[nearest] * kernel,/NAN,/DOUBLE) / TOTAL(kernel,/NAN,/DOUBLE)
   f_interp_unc = TOTAL(occ_vec * kernel,/NAN,/DOUBLE) / TOTAL(kernel,/NAN,/DOUBLE)^2
               
   RETURN
END

FUNCTION pmap_correct_jk,x,y,f,ch,np,occdata,FUNC=func,CORR_UNC=corr_unc,FULL=full,DATAFILE=datafile,NNEAREST=nnearest,Verbose=verbose, Use_np = use_np, THRESHOLD_OCC = threshold_occ

;;; Common block for pmap data set:
   COMMON pmap_data,x_pmap,y_pmap,f_pmap,np_pmap,func_pmap,scale,sigscale


   IF KEYWORD_SET(FULL) EQ 1 THEN BEGIN
      xfov = 8.
      yfov = 216.
   ENDIF ELSE BEGIN
      xfov = 0.
      yfov = 0.
   ENDELSE
   
   IF N_ELEMENTS(datafile) EQ 0 THEN BEGIN
      savfiles = FILE_SEARCH('pmap_data_ch'+STRTRIM(STRING(ch),2)+'*.sav',count=nfiles)
      use_file = savfiles[nfiles-1]   ;;; Choose the latest file
      IF keyword_set(VERBOSE) THEN print,'Using pmap data file '+use_file 
   ENDIF ELSE use_file = datafile
   RESTORE,use_file
   
   ndata = N_ELEMENTS(f)
   
   IF N_ELEMENTS(func) EQ 0 THEN func = REPLICATE(1.0,ndata)
   IF N_ELEMENTS(x) NE ndata OR N_ELEMENTS(y) NE ndata OR N_ELEMENTS(np) NE ndata OR N_ELEMENTS(func) NE ndata THEN BEGIN
      result = DIALOG_MESSAGE('X,Y,F,FUNC,NP must all have the same number of elements.  Exiting.',/ERROR,/CENTER)
      RETURN,-1
   ENDIF
   
   IF N_ELEMENTS(ch) NE ndata THEN channel = REPLICATE(ch[0],ndata) ELSE channel = ch
      
   f_corr = DBLARR(ndata)
   corr_unc = f_corr
   f_pmap_interp = f_corr
   f_pmap_interp_unc = f_corr
   
;;; Loop through the input data
   IF keyword_set(verbose) THEN Print,'Correcting '+STRN(ndata)+' data points'
   FOR i = 0,ndata-1 DO BEGIN
      IF KEYWORD_SET(verbose) THEN Iterwait,i,10,100,Text='Completed '
      pmap_correct_interpolate_single,x[i]-xfov,y[i]-yfov,f[i],channel[i],np[i],func[i],fi,fiu,NNEAREST=nnearest, USE_NP = use_np
      f_pmap_interp[i] = fi
      f_pmap_interp_unc[i]  = fiu
      
;now check to see if we are in a region of the pmap with sufficient data
      IF KEYWORD_SET(THRESHOLD_OCC) THEN BEGIN
         IF occdata[x[i]-xfov, y[i]-yfov] EQ !VALUES.F_NAN THEN f_pmap_interp[i] = !VALUES.F_NAN
      endif

   ENDFOR
   
;;; Correct the measured fluxes by dividing by the normalized
;;; interpolated pmap flux
   f_corr = f * scale /f_pmap_interp
   corr_unc = f_corr * SQRT( (f_pmap_interp_unc/f_pmap_interp)^2 + (func/f)^2 ) 
   



   RETURN,f_corr
END
