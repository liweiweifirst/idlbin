pro plot_calstar_stability

restore, '/Users/jkrick/irac_warm/calstars/allch1phot.sav'
;potential calstar names
names = ['HD4182_', '1812095', 'KF08T3_', 'KF06T2_', 'KF06T1_', 'KF09T1_', 'NPM1p60', 'NPM1p67', 'NPM1p68', 'HD16545']
colors = ['black', 'grey', 'red', 'blue', 'chocolate', 'cyan', 'orange', 'maroon', 'medium purple', 'yellow']

namecolors = starnamearr
for n = 0, n_elements(names) - 1 do begin
   a = where(starnamearr eq names(n))
   namecolors[a] = colors[n]
endfor

p1 = errorplot((timearr - min(timearr))/60./60./ 24., fluxarr, fluxerrarr, '1s', sym_size = 0.2,   sym_filled = 1, color = namecolors,$
                     xtitle = 'Time(days)', ytitle = 'Flux', title = 'Calstar')


end
