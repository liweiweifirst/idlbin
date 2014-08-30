function track_box, im, x_center, y_center
  pixvals = fltarr(25,63)
  for ip = 0, n_elements(x_center) - 1 do begin
     c = 0
     for xp = round(x_center) - 2, round(x_center) + 2 do begin
        for yp = round(y_center) - 2, round(y_center) + 2 do begin
           print, 'x,y', xp, yp,im[xp, yp]
           pixvals[c] = im[xp, yp]
        endfor
     endfor

  endfor

return, pixvals
end
