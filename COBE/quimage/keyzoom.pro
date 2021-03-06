PRO keyzoom
;+
;  KEYZOOM - a UIMAGE-specific routine.  This routine allows a user to
;  zoom in on a section of a selected image from keyboard selected 
;  coordinates.
;#
;  SPR 11415  Oct 25 93  Creation. J. Newmark
;--------------------------------------------------------------------------
  COMMON uimage_data,map6,map7,map8,map9,face6,face7,face8,face9,graph,zoomed
  COMMON uimage_data2,proj_map,proj2_map
  COMMON xwindow,screensize_x,screensize_y,blocksize_x,blocksize_y,$
    block_usage,zoom_index
  COMMON journal,journal_on,luj
  IF((!D.NAME NE 'X') AND (!D.NAME NE 'WIN')) THEN BEGIN
    MESSAGE, 'This routine can only be run on an X-window terminal.', /CONT
    RETURN
  ENDIF
  IF(NOT defined(journal_on)) THEN journal_on = 0
;
;  Have the user select the image which will be zoomed in on.
;  ----------------------------------------------------------
show_menu1:
  menu_title1 = 'Zoom an image'
  name=select_object(/map6,/map7,/map8,/map9,/face6,/face7,$
    /face8,/face9,/proj_map,/proj2_map,/help,/exit,title=menu_title1)
  IF(name EQ 'EXIT') THEN RETURN
  IF(name EQ 'HELP') THEN BEGIN
    uimage_help, menu_title1
    GOTO, show_menu1
  ENDIF
  IF(name EQ 'NO_OBJECTS') THEN BEGIN
    MESSAGE, 'There are no appropriate data objects to choose from.', /CONT
    RETURN
  ENDIF
  IF(name EQ 'EXIT') THEN RETURN
  first_letter=STRMID(name,0,1)
  IF(first_letter EQ 'F') THEN j = EXECUTE('faceno = ' + name + $
               '.faceno') ELSE faceno = -1
  nic = STRPOS(name, '(')
;
;  Handle complexity for different types of data-objects.
;  ------------------------------------------------------
  stype = STRUPCASE(STRMID(name, 0, nic))
  CASE stype OF
            'PROJ_MAP': BEGIN
               re_proj = 1
               j = EXECUTE('win_orig = ' + name + '.win_orig')
               name_orig = get_name(win_orig)
               j = EXECUTE('pos_x = ' + name + '.pos_x')
               j = EXECUTE('pos_y = ' + name + '.pos_y')
               j = EXECUTE('data = ' + name + '.data')
               j = EXECUTE('orient = ' + name + '.orient')
               j = EXECUTE('pcs = ' + name + '.coordinate_system')
               CASE pcs OF
                 'ECLIPTIC'   : p_coord = 'E'
                 'EQUATORIAL' : p_coord = 'Q'
                 'GALACTIC'   : p_coord = 'G'
                 ELSE :
               ENDCASE
               j = EXECUTE('projection = ' + name + '.projection')
               CASE projection OF
                 'AITOFF'            : proj = 'A'
                 'GLOBAL SINUSOIDAL' : proj = 'S'
                 'MOLLWEIDE'         : proj = 'M'
                 ELSE                :
               ENDCASE
               nic = STRPOS(name_orig, '(')
               dtype = STRUPCASE(STRMID(name_orig, 0, nic))
             END
            'PROJ2_MAP': BEGIN
               re_proj = 1
               j = EXECUTE('win_orig = ' + name + '.win_orig')
               name_orig = get_name(win_orig)
               j = EXECUTE('pos_x = ' + name + '.pos_x')
               j = EXECUTE('pos_y = ' + name + '.pos_y')
               j = EXECUTE('data = ' + name + '.data')
               j = EXECUTE('orient = ' + name + '.orient')
               j = EXECUTE('pcs = ' + name + '.coordinate_system')
               CASE pcs OF
                 'ECLIPTIC'   : p_coord = 'E'
                 'EQUATORIAL' : p_coord = 'Q'
                 'GALACTIC'   : p_coord = 'G'
                 ELSE :
               ENDCASE
               j = EXECUTE('projection = ' + name + '.projection')
               CASE projection OF
                 'AITOFF'            : proj = 'A'
                 'GLOBAL SINUSOIDAL' : proj = 'S'
                 'MOLLWEIDE'         : proj = 'M'
                 ELSE                :
               ENDCASE
               nic = STRPOS(name_orig, '(')
               dtype = STRUPCASE(STRMID(name_orig, 0, nic))
             END
             ELSE : BEGIN
               re_proj = 0
               j = EXECUTE('pos_x = ' + name + '.pos_x')
               j = EXECUTE('pos_y = ' + name + '.pos_y')
               j = EXECUTE('orient = ' + name + '.orient')
               j = EXECUTE('data = ' + name + '.data')
               nic = STRPOS(name, '(')
               dtype = STRUPCASE(STRMID(name, 0, nic))
             END
  ENDCASE
;
;  Store the resolution number in RES, for the call to XY2PIX.
;  -----------------------------------------------------------
  CASE STRUPCASE(dtype) OF
            'MAP6'  : res = 6
            'MAP7'  : res = 7
            'MAP8'  : res = 8
            'MAP9'  : res = 9
            'FACE6' : res = 6
            'FACE7' : res = 7
            'FACE8' : res = 8
            'FACE9' : res = 9
  ENDCASE
  old_bu = block_usage
  j = EXECUTE('window = ' + name + '.window')
  j = EXECUTE('title = ' + name + '.title')
  WSET, window
  ztitle = 'Zoom of "' + title + '"'
  IF(STRLEN(ztitle) GT 40) THEN ztitle = append_number('Zoomed image')
  w_available, zoomwin
  nblocks_x = 5
  nblocks_y = 5
;
;  Create a new instance of a "zoomed" data-object.
;  ------------------------------------------------
  sz = SIZE(zoomed)
  IF(sz(2) NE 8) THEN BEGIN
    zic = 0
    zoomed = {zm_struct, window: 0, title: '', win_orig: 0, start_x: 0, $
              start_y: 0, stop_x: 0, stop_y: 0, specific_zoom: 0, $
              nblocks_x: 0, nblocks_y: 0, scale_min: 0., scale_max: 0., $
              zoomflag: 0, hidden: 0}
  ENDIF ELSE BEGIN
    zic = sz(3)
    zoomed = [zoomed, {zm_struct}]
  ENDELSE
  zoomed(zic).hidden=-1
  zoomed(zic).window = zoomwin
  zoomed(zic).win_orig = window
  zoomed(zic).title = ztitle
  zoomed(zic).nblocks_x = nblocks_x
  zoomed(zic).nblocks_y = nblocks_y
  zname = 'ZOOMED(' + STRTRIM(STRING(zic), 2) + ')'
  nblocks_x_abs = nblocks_x*(2.^zoom_index)
  nblocks_y_abs = nblocks_y*(2.^zoom_index)
  make_window, zoomwin, nblocks_x_abs, nblocks_y_abs, ztitle
  xspace = blocksize_x*nblocks_x_abs
  yspace = blocksize_y*nblocks_y_abs
  zwindowsize_x = xspace-20
  zwindowsize_y = yspace-22-16
  zfact = 4
  WSET, window
  WSHOW, window
;
;  Print out instructions.
;  -----------------------
  PRINT, ' '
  PRINT, 'Please select a point on the image with the following label:'
  PRINT, bold(title)
  PRINT, ' '
;
;  -------------------------------------------------
again:  
keyboard_entry:
;
;  Have the user type in the {lon,lat} coordinates of the desired point.
;  ---------------------------------------------------------------------
      PRINT, 'You will be asked to enter a longitude/latitude coordinate pair'
      PRINT, 'which identifies a location for which a spectrum will be plotted.'
      PRINT, 'Please select the coordinate system you will use.'
      menu = ['Coordinate system:', 'Ecliptic', 'Equatorial', 'Galactic']
      sel = one_line_menu(menu)
      IF(journal_on) THEN PRINTF, luj, '  coordinate system:  ' + menu(sel)
      icoord = STRMID('EQG', sel - 1, 1)
      PRINT, 'Next enter the lon/lat pair in degrees (example: ' + $
        bold('20. -30.') + ').  [<CR> to exit]'
      str = ''
read_lonlat:
      READ, 'lon lat:  ', str
      str = STRTRIM(str, 2)
      IF(str EQ '') THEN RETURN
      ic = STRPOS(str, ' ')
      IF(ic EQ -1) THEN ic = STRPOS(str, ',')
      IF(ic EQ -1) THEN BEGIN
        PRINT, 'Invalid delimiter (should be " " or ",").  Please enter again.'
        GOTO, read_lonlat
      ENDIF
      str1 = STRMID(str, 0, ic)
      str2 = STRMID(str, ic + 1, STRLEN(str))
      IF(validnum(str1) + validnum(str2) NE 2) THEN BEGIN
        PRINT, 'Invalid numerical value(s).  Please enter again.'
        GOTO, read_lonlat
      ENDIF
      lon = FLOAT(str1)
      lat = FLOAT(str2)
      IF((lat LT -90.) OR (lat GT 90.)) THEN BEGIN
        PRINT, 'Latitude must be between -90 and 90.  Please enter again.'
        GOTO, read_lonlat
      ENDIF
      IF(journal_on) THEN PRINTF, luj, '  lon, lat = ' + str
;
;  Convert {lon,lat} to array indices.
;  -----------------------------------
      ocoord = 'R' + STRING(res, '(i1)')
      pix = coorconv([[lon], [lat]], infmt = 'L', outfmt = 'P', $
        inco = icoord, outco = ocoord)
      IF(strmid(dtype,0,4) EQ 'FACE') THEN BEGIN
        onface = FIX(pix(0) / (4. ^ (res - 1)))
        IF(onface NE faceno) THEN BEGIN
          PRINT, 'Selected point does not lie on the appropriate face.' + $
            '  Please enter again.'
          GOTO, read_lonlat
        ENDIF
        pix2xy, pix, ix, iy, res = res, /face
      ENDIF ELSE BEGIN
        pix2xy, pix, ix, iy, res = res
      ENDELSE
      IF (re_proj EQ 1) THEN BEGIN
        inco = orient + STRING(res, '(i1)')
        uvec=coorconv(pix,infmt='P',outfmt='U',inco=inco,outco=p_coord)
        projpix=uv2proj(uvec,proj,SIZE(data))
        ix=projpix(0)
        iy=projpix(1)
      ENDIF
;
;
;
  zx = !D.X_VSIZE/2
  zy = !D.Y_VSIZE/2
  TVCRS, zx, zy, /DEV
  did_zoom = 0
show_menu2:
          menu_title2 = 'Zoom options'
          menu = [menu_title2, 'Set Zoom Factor', 'Resize Zoom Window', ' ', $
            'HELP', 'Continue']
          zoom_sel = umenu(menu, init = 1, title = 0)
          CASE zoom_sel OF
            1 : BEGIN
;
;  Put up a menu that allows the user to change the zoom factor.
;  -------------------------------------------------------------
                  initz = FIX(zfact)
show_menu3:
                  menu_title3 = 'Zoom factor'
                  menu = [menu_title3, STRTRIM(INDGEN(14) + 1, 2), ' ', $
                    'HELP', 'Exit this menu']
                  sel = umenu(menu, init = initz, title = 0)
                  CASE sel OF
                    15: GOTO, show_menu3
                    16: BEGIN
                          uimage_help, menu_title3
                          GOTO, show_menu3
                        END
                    17:
                    ELSE: zfact = sel
                  ENDCASE
                END
            2 : BEGIN
;
;  Allow the user to change the size of the zoom-window.
;  -----------------------------------------------------
                  resize_graph, zname
                  j = EXECUTE('nblocks_x = ' + zname + '.nblocks_x')
                  j = EXECUTE('nblocks_y = ' + zname + '.nblocks_y')
                  xspace = blocksize_x * nblocks_x * (2.^zoom_index)
                  yspace = blocksize_y * nblocks_y * (2.^zoom_index)
                  zwindowsize_x = xspace - 20
                  zwindowsize_y = yspace - 22 - 16
                END
            3:  GOTO, show_menu2
            4 : BEGIN
                  uimage_help, menu_title2
                  GOTO, show_menu2
                END
	    5 : 
	  ENDCASE
          WSET, window
          WSHOW, window
          TVCRS, zx, zy, /DEV   ;restore cursor
;
;  now display the zoomed-in section of the image in the zoom-window.
;  --------------------------------------------------------------------
          j = EXECUTE('pos_x = ' + name + '.pos_x')
          j = EXECUTE('pos_y = ' + name + '.pos_y')
          x = FIX(ix(0))*2.^zoom_index + pos_x
          y = FIX(iy(0))*2.^zoom_index + pos_y
          IF(N_ELEMENTS(x0) EQ 1) THEN box_erase
          zx = x                                ;save zoom center.
          zy = y
          x0 = (x-zwindowsize_x / (zfact*2)) > 0         ;left edge from center
          y0 = (y-zwindowsize_y / (zfact*2)) > 0         ;bottom
          nx = (zwindowsize_x / zfact) < (!D.X_VSIZE - x0) ;size of new image
          ny = (zwindowsize_y / zfact) < (!D.Y_VSIZE - y0)
          area = TVRD(x0, y0, nx, ny)              ;read image
          box_draw, x0, y0, x0 + nx - 1, y0 + ny - 1
          xss = nx * zfact                      ;make integer rebin factors
          yss = ny * zfact
          j = EXECUTE('scale_min = ' + name + '.scale_min')
          j = EXECUTE('scale_max = ' + name + '.scale_max')
          datastart_x = FIX((x0-pos_x) / (2.^zoom_index))
          datastart_y = FIX((y0-pos_y) / (2.^zoom_index))
          zoomed(zic).start_x = datastart_x
          zoomed(zic).start_y = datastart_y
          zoomed(zic).stop_x = datastart_x + FIX(nx / (2.^zoom_index))
          zoomed(zic).stop_y = datastart_y + FIX(ny / (2.^zoom_index))
          zoomed(zic).specific_zoom = zfact
          zoomed(zic).scale_min = scale_min
          zoomed(zic).scale_max = scale_max
;
; display the pixel coordinates          
          print,'center pixel =',pix
;
          show_zoomed, zname
          area = 0
          WSET, window
          did_zoom = 1
  menu = ['Change/New Zoom?', 'Yes', 'No']
  change_sel = umenu(menu, init = 2, title = 0)
  IF (change_sel EQ 1) THEN GOTO, again
exit:
  IF(N_ELEMENTS(x0) EQ 1) THEN box_erase
;
;  If no zooming was actually done, then remove all traces of the instance
;  of the zoomed type object which had been set up.
;  -----------------------------------------------------------------------
  IF(did_zoom EQ 0) THEN BEGIN
    IF(zic NE 0) THEN zoomed = zoomed(0:(zic-1)) ELSE zoomed = 0
    block_usage = old_bu
    WDELETE, zoomwin
  ENDIF ELSE BEGIN
;
;  If journaling is enabled, then send some info to the journal file.
;  ------------------------------------------------------------------
    IF(journal_on) THEN BEGIN
      PRINTF, luj, menu_title1
      PRINTF, luj, '  operand:  ' + title
      PRINTF, luj, '  the zooming parameters were:'
      PRINTF, luj, '    start_x = ', STRTRIM(datastart_x, 2)
      PRINTF, luj, '    start_y = ', STRTRIM(datastart_y, 2)
      PRINTF, luj, '    stop_x  = ', $
        STRTRIM(datastart_x + FIX(nx / (2.^zoom_index)), 2)
      PRINTF, luj, '    stop_y  = ', $
        STRTRIM(datastart_y + FIX(ny / (2.^zoom_index)), 2)
      PRINTF, luj, '    center pixel = ', STRTRIM(pix, 2)
      PRINTF, luj, '    specific_zoom = ', STRTRIM(zfact, 2)
      PRINTF, luj, '  output:   ' + ztitle
      PRINTF, luj, '----------------------------------------' + $
                   '--------------------------------------'
    ENDIF
  ENDELSE
  GOTO, show_menu1
END
;DISCLAIMER:
;
;This software was written at the Cosmology Data Analysis Center in
;support of the Cosmic Background Explorer (COBE) Project under NASA
;contract number NAS5-30750.
;
;This software may be used, copied, modified or redistributed so long
;as it is not sold and this disclaimer is distributed along with the
;software.  If you modify the software please indicate your
;modifications in a prominent place in the source code.  
;
;All routines are provided "as is" without any express or implied
;warranties whatsoever.  All routines are distributed without guarantee
;of support.  If errors are found in this code it is requested that you
;contact us by sending email to the address below to report the errors
;but we make no claims regarding timely fixes.  This software has been 
;used for analysis of COBE data but has not been validated and has not 
;been used to create validated data sets of any type.
;
;Please send bug reports to CGIS@ZWICKY.GSFC.NASA.GOV.


