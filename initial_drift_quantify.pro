pro initial_drift_quantify
  aorname = [ 'r50678528',  'r50665984',  'r51824640',  'r51816192',  'r51836416',  'r51843584',  'r51819776',  'r51833088',  'r51832320',  'r51820544',  'r51844096',  'r51832576',  'r51837184',  'r51828480',  'r51840000',  'r51823360', 'r51840256',  'r51841536',  'r51842816',  'r51823872',  'r51831040',  'r51840512',  'r51834880',  'r51835136',  'r51820800',  'r51835904',  'r51827968',  'r51816704',  'r51834368',  'r51829504', 'r51816448',  'r51826176',  'r51822848',  'r51832064',  'r51838976',  'r51815936',   'r51835648',  'r51828224',  'r51831552',  'r51829248',  'r52364288', 'r52364544',  'r52364800',  'r52365312',  'r50651392',  'r50653440',  'r50653184',  'r50652928',  'r50654976',  'r50652672',  'r50655232',  'r50652416',  'r50678016',  'r50676480',   'r49711360',  'r51831296',  'r51818496',  'r51827200',  'r51842304',  'r51818752',  'r51830016',  'r51817728',  'r51816960',  'r47037184',  'r47029248',  'r51842560',  'r51839488',  'r51817216',  'r51821568', 'r51837440',  'r51830528',  'r47030784',  'r47053824',  'r51837952',  'r51826688',  'r51830784',  'r51843328',  'r51836672',  'r51833600',  'r51833344',  'r51838464',  'r51825152',  'r51825920',  'r51832832',  'r51838720', 'r51837696',  'r51823104',  'r51883264',  'r51884032',  'r51822080',  'r51834112',  'r51834624',  'r51826432',  'r51841024',  'r51842048',  'r51819520',  'r51824384',  'r51821056',  'r51836160',  'r51827456',  'r51843072',  'r53522688',  'r53522432',  'r53522176',  'r53521920',  'r53521152',  'r53521664',  'r53523200',  'r53522944',  'r54315776',  'r54315520',  'r50651136',  'r50656000',  'r50651648', 'r50655744',  'r50649856',  'r50656768',  'r50650624',  'r50656256',  'r50650112',  'r50653696',  'r50655488',  'r50651904']


colorarr = ['blue', 'red','green','black','purple', 'deep_pink', 'magenta', 'medium_purple', 'orchid', 'thistle', 'pink', 'orange_red', 'rosy_brown',  'chocolate', 'saddle_brown', 'maroon', 'dark_orange', 'pale_goldenrod','red',  'aquamarine', 'teal', 'steel_blue', 'dodger_blue', 'dark_blue', 'indigo','dark_slate_blue', 'blue_violet', 'purple',  'dark_slate_grey', 'khaki', 'tomato', 'lavender','gold', 'green_yellow', 'lime', 'green', 'olive_drab', 'pale_green', 'spring_green','blue', 'red','deep_pink', 'magenta', 'medium_purple','light_sea_green', 'teal', 'cadet_blue', 'aquamarine', 'dark_turquoise', 'aqua','blue', 'red','green','black','purple', 'deep_pink', 'magenta', 'medium_purple', 'orchid', 'thistle', 'pink', 'orange_red', 'rosy_brown',  'chocolate', 'saddle_brown', 'maroon', 'dark_orange', 'pale_goldenrod','red',  'aquamarine', 'teal', 'steel_blue', 'khaki', 'tomato','gold', 'green_yellow', 'lime', 'green', 'olive_drab', 'pale_green', 'spring_green','blue', 'red','deep_pink', 'magenta', 'medium_purple','light_sea_green', 'teal', 'cadet_blue', 'aquamarine', 'dark_turquoise', 'aqua' ,'blue', 'red','black','green','black','purple', 'deep_pink', 'magenta', 'medium_purple', 'orchid', 'thistle', 'pink', 'orange_red', 'rosy_brown',  'chocolate', 'saddle_brown', 'maroon', 'dark_orange', 'pale_goldenrod','red',  'aquamarine', 'teal', 'steel_blue', 'dodger_blue', 'dark_blue', 'indigo','dark_slate_blue', 'blue_violet', 'purple','dim_grey', 'slate_grey', 'dark_slate_grey', 'khaki', 'tomato', 'lavender','gold', 'green_yellow', 'lime', 'green', 'olive_drab', 'pale_green', 'spring_green','blue', 'red','deep_pink', 'magenta', 'medium_purple','light_sea_green', 'teal', 'cadet_blue', 'aquamarine', 'dark_turquoise', 'aqua','blue', 'red','black','green','grey','purple', 'deep_pink', 'magenta', 'medium_purple', 'orchid', 'thistle', 'pink', 'orange_red', 'rosy_brown',  'chocolate', 'saddle_brown', 'maroon', 'dark_orange', 'pale_goldenrod','red',  'aquamarine', 'teal', 'steel_blue', 'khaki', 'tomato','gold', 'green_yellow', 'lime', 'green', 'olive_drab', 'pale_green', 'spring_green','blue', 'red','deep_pink', 'magenta', 'medium_purple','light_sea_green', 'teal', 'cadet_blue', 'aquamarine', 'dark_turquoise', 'aqua','blue', 'red','black','green','grey','purple', 'deep_pink', 'magenta', 'medium_purple', 'orchid', 'thistle', 'pink', 'orange_red', 'rosy_brown',  'chocolate', 'saddle_brown', 'maroon', 'dark_orange', 'pale_goldenrod','red',  'aquamarine', 'teal', 'steel_blue', 'dodger_blue', 'dark_blue', 'indigo']
;
  ;;read in the saved centroids from all AORs
  restore, '/Users/jkrick/external/initial_drift/centroids.sav'
  extra={ sym_size: 0.1, sym_filled: 1, xrange: [0,2E4], yrange: [14.5, 15.6]}

  for a = 0, 10 do begin; n_elements(aorname) - 1 do begin
     print, 'working on ', aorname(a), ' ', a
     xarr = planethash[aorname(a), 'xcen']
     yarr = planethash[aorname(a), 'ycen']
     timearr = planethash[aorname(a), 'timearr'] 
     bmjdarr = planethash[aorname(a), 'bmjdarr'] 
 
     ;;figure out how they are linked
     ;;plot them all together at first.

     if a eq 0 then begin  ; plot the first one regardless
        timearr = timearr - timearr(0)
        yarr = yarr;/ yarr(0)
        xarr = xarr;/ xarr(0)
        px = plot(timearr, xarr, '1s', xtitle = 'Sclk', ytitle = 'X position', _extra = extra, color = colorarr[a])
        py = plot(timearr, yarr, '1s', xtitle = 'Sclk', ytitle = 'Y position', _extra = extra, color = colorarr[a])
     endif else begin
        if planethash[aorname(a), 'ra'] eq planethash[aorname(a-1), 'ra'] then begin
           print, 'same ra as previous AOR', colorarr(a - 1)
           ;;plot them with the same color
           t0 = planethash[aorname(a-1), 'timearr'] 
           x0 = planethash[aorname(a-1), 'xcen'] 
           y0 = planethash[aorname(a-1), 'ycen'] 
           timearr = timearr - t0(0)
           yarr = yarr;/y0(0)
           xarr = xarr;/ x0(0)

           px = plot(timearr, xarr, '1s',  _extra = extra, color = colorarr[a-1],overplot = px)
           py = plot(timearr, yarr, '1s',  _extra = extra, color = colorarr[a-1],overplot = py)
        endif else begin
           ;;plot them with a different color
           timearr = timearr - timearr(0)
           yarr = yarr;/ yarr(0)
           xarr = xarr;/ xarr(0)

           px = plot(timearr, xarr, '1s', _extra = extra, color = colorarr[a],overplot = px)
           y = plot(timearr, yarr, '1s', _extra = extra, color = colorarr[a],overplot = py)
        endelse
     endelse
     ;;why the time gaps.... the bcds are all there
    ; if a eq 8 then print, 'timearr', timearr
     if a eq 9 then print, 'bmjd', bmjdarr 
     

  endfor  ; for each AOR


end
