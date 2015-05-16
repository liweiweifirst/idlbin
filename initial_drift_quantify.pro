pro initial_drift_quantify
  aorname = [ 'r50678528',  'r50665984',  'r51824640',  'r51816192',  'r51836416',  'r51833088', 'r51843584',  'r51819776',   'r51832320',  'r51820544',  'r51844096',  'r51832576',  'r51837184',  'r51828480',  'r51840000',  'r51823360', 'r51840256',  'r51841536',  'r51842816',  'r51823872',  'r51831040',  'r51840512',  'r51834880',  'r51835136',  'r51820800',  'r51835904',  'r51827968',  'r51816704',  'r51834368',  'r51829504', 'r51816448',  'r51826176',  'r51822848',  'r51832064',  'r51838976',  'r51815936',   'r51835648',  'r51828224',  'r51831552',  'r51829248',  'r52364288', 'r52364544',  'r52364800',  'r52365312',  'r50651392',  'r50653440',   'r50678016',  'r50676480',   'r50653184',  'r50652928',   'r51831296',  'r51818496', 'r50654976',  'r50652672', 'r51827200',  'r51842304',  'r50655232',  'r50652416', 'r51818752',  'r51830016',  'r51817728',  'r51816960',  'r47037184',  'r47029248',    'r51839488',  'r51817216',  'r51821568', 'r51837440',  'r51830528',  'r47030784',  'r47053824',  'r51837952',  'r51826688',  'r51830784',   'r51836672',  'r51833600',  'r51833344',  'r51838464',  'r51825152',  'r51825920',  'r51832832',  'r51838720', 'r51837696',  'r51823104',       'r51834624',  'r51826432',   'r51819520',  'r51824384', 'r53521152',  'r53521664',  'r51843072', 'r51821056', 'r53522176',  'r53521920',  'r51836160',  'r51827456',    'r53522688',  'r53522432',    'r54315776',  'r54315520','r50651904',  'r50650112',  'r53523200',  'r53522944',   'r50653696',  'r50655488' ] ;'r51822080',  'r51834112','r49711360','r51842560',  'r50653184',  'r50652928',  'r50654976',  'r50652672',  'r50655232',  'r50652416','r51843328',  'r51883264','r51884032', 'r51841024', 'r51842048', 'r50651136',  'r50656000','r50651648', 'r50655744',    'r50649856',  'r50656768',  'r50650624',  'r50656256', 


colorarr = ['blue', 'red','green','black','purple', 'deep_pink', 'magenta', 'medium_purple', 'orchid', 'thistle', 'pink', 'orange_red', 'rosy_brown',  'chocolate', 'saddle_brown', 'maroon', 'dark_orange', 'pale_goldenrod','red',  'aquamarine', 'teal', 'steel_blue', 'dodger_blue', 'dark_blue', 'indigo','dark_slate_blue', 'blue_violet', 'purple',  'dark_slate_grey', 'khaki', 'tomato', 'lavender','gold', 'green_yellow', 'lime', 'green', 'olive_drab', 'pale_green', 'spring_green','blue', 'red','deep_pink', 'magenta', 'medium_purple','light_sea_green', 'teal', 'cadet_blue', 'aquamarine', 'dark_turquoise', 'aqua','blue', 'red','green','black','purple', 'deep_pink', 'magenta', 'medium_purple', 'orchid', 'thistle', 'pink', 'orange_red', 'rosy_brown',  'chocolate', 'saddle_brown', 'maroon', 'dark_orange', 'pale_goldenrod','red',  'aquamarine', 'teal', 'steel_blue', 'khaki', 'tomato','gold', 'green_yellow', 'lime', 'green', 'olive_drab', 'pale_green', 'spring_green','blue', 'red','deep_pink', 'magenta', 'medium_purple','light_sea_green', 'teal', 'cadet_blue', 'aquamarine', 'dark_turquoise', 'aqua' ,'blue', 'red','black','green','black','purple', 'deep_pink', 'magenta', 'medium_purple', 'orchid', 'thistle', 'pink', 'orange_red', 'rosy_brown',  'chocolate', 'saddle_brown', 'maroon', 'dark_orange', 'pale_goldenrod','red',  'aquamarine', 'teal', 'steel_blue', 'dodger_blue', 'dark_blue', 'indigo','dark_slate_blue', 'blue_violet', 'purple','dim_grey', 'slate_grey', 'dark_slate_grey', 'khaki', 'tomato', 'lavender','gold', 'green_yellow', 'lime', 'green', 'olive_drab', 'pale_green', 'spring_green','blue', 'red','deep_pink', 'magenta', 'medium_purple','light_sea_green', 'teal', 'cadet_blue', 'aquamarine', 'dark_turquoise', 'aqua','blue', 'red','black','green','grey','purple', 'deep_pink', 'magenta', 'medium_purple', 'orchid', 'thistle', 'pink', 'orange_red', 'rosy_brown',  'chocolate', 'saddle_brown', 'maroon', 'dark_orange', 'pale_goldenrod','red',  'aquamarine', 'teal', 'steel_blue', 'khaki', 'tomato','gold', 'green_yellow', 'lime', 'green', 'olive_drab', 'pale_green', 'spring_green','blue', 'red','deep_pink', 'magenta', 'medium_purple','light_sea_green', 'teal', 'cadet_blue', 'aquamarine', 'dark_turquoise', 'aqua','blue', 'red','black','green','grey','purple', 'deep_pink', 'magenta', 'medium_purple', 'orchid', 'thistle', 'pink', 'orange_red', 'rosy_brown',  'chocolate', 'saddle_brown', 'maroon', 'dark_orange', 'pale_goldenrod','red',  'aquamarine', 'teal', 'steel_blue', 'dodger_blue', 'dark_blue', 'indigo']
;
  ;;read in the saved centroids from all AORs
  restore, '/Users/jkrick/external/initial_drift/centroids.sav'
  extra={ sym_size: 0.1, sym_filled: 1, xrange: [0,6], yrange: [14.5, 20.0]};[20.0, 26.5]}

  spreadfactor = 0.1
  startaor = 0; 54 ;67 ;44
  stopaor = 53; 104; 113; 89; 66
  for a = startaor, stopaor do begin;  n_elements(aorname) - 1 do begin
     print, 'working on ', aorname(a), ' ', a
     xarr = planethash[aorname(a), 'xcen']
     yarr = planethash[aorname(a), 'ycen']
     timearr = planethash[aorname(a), 'timearr'] 
     bmjdarr = planethash[aorname(a), 'bmjdarr'] 
;     print, 'before', xarr[0:10]
     ;;figure out how they are linked
     ;;plot them all together at first.

     if a eq startaor then begin  ; plot the first one regardless
        p_timearr = (timearr - timearr(0)) / 60./60.
;        print, 'startaor', xarr[100:110]

        ;;try gaussian smoothing
        xarr_gauss = GAUSS_SMOOTH(xarr,5,/nan) + a*spreadfactor
        yarr_gauss = GAUSS_SMOOTH(yarr,5,/nan)+ a*spreadfactor
        
;        print, 'xarr_gauss', xarr_gauss[100:110]

        px = plot(p_timearr, xarr_gauss, '1s', xtitle = 'Time (Hrs)', ytitle = 'X position', _extra = extra, color = colorarr[a])
        py = plot(p_timearr, yarr_gauss, '1s', xtitle = 'Time (Hrs)', ytitle = 'Y position', _extra = extra, color = colorarr[a])

     endif else begin
        print, colorarr(a), ' ',colorarr(a-1), planethash[aorname(a), 'ra'], planethash[aorname(a-1), 'ra'], format = '( A, A, A, F, F)'
        if abs(planethash[aorname(a), 'ra'] - planethash[aorname(a-1), 'ra']) lt 0.01 then begin
           print, 'same ra as previous AOR', colorarr(a - 1)
           ;;plot them with the same color
           t0 = planethash[aorname(a-1), 'timearr'] 
           x0 = planethash[aorname(a-1), 'xcen'] 
           y0 = planethash[aorname(a-1), 'ycen'] 
           p_timearr = [p_timearr, (timearr - t0(0)) / 60./60.]
           ;;try gaussian smoothing
           xarr_gauss = [xarr_gauss, GAUSS_SMOOTH(xarr,5,/nan) + (a - 1)*spreadfactor]
           yarr_gauss = [yarr_gauss, GAUSS_SMOOTH(yarr,5,/nan) + (a - 1)*spreadfactor]


           px = plot(p_timearr, xarr_gauss , '1s',  _extra = extra, color = colorarr[a-1],overplot = px)
           py = plot(p_timearr, yarr_gauss , '1s',  _extra = extra, color = colorarr[a-1],overplot = py)
        endif else begin
           ;;plot them with a different color
           p_timearr = (timearr - timearr(0)) / 60./60.

           ;;try gaussian smoothing
           xarr_gauss = GAUSS_SMOOTH(xarr,5,/nan) + a*spreadfactor
           yarr_gauss = GAUSS_SMOOTH(yarr,5,/nan) + a*spreadfactor
;           print, 'xarr_gauss new AOR', xarr_gauss[100:110]
;
           px = plot(p_timearr, xarr_gauss, '1s', _extra = extra, color = colorarr[a],overplot = px)
           py = plot(p_timearr, yarr_gauss, '1s', _extra = extra, color = colorarr[a],overplot = py)
        endelse
     endelse
     

  endfor  ; for each AOR


; an interesting set to plot on its own:
;  aorname = [ 'r50651392',  'r50653440',  'r50653184',  'r50652928',  'r50654976',  'r50652672',  'r50655232',  'r50652416']
;  for a = 0, n_elements(aorname) - 1 do begin
;     xarr = planethash[aorname(a), 'xcen']
;     yarr = planethash[aorname(a), 'ycen']
;     timearr = planethash[aorname(a), 'timearr'] 
;     help, timearr
;     help, xarr
;     help, yarr
;     p1 = plot(timearr, xarr, '1s',sym_size = 0.1,sym_filled = 1, overplot = p1)
;     p2 = plot(timearr, yarr, '1s', _extra, overplot = p2)
;  endfor


end
