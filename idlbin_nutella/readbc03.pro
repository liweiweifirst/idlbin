pro readbc03
close, /all


model = fltarr(9,1086,504)

readcol,'/Users/jkrick/nutella/bin/bc03/filelist_3',filename,format="A",/silent
filename = strcompress(filename + ",0.3,0.5,0.7,1,3,5,8,12")

for i = 0, n_elements(filename) -1 do begin
   readcol, filename(i), lambda, age0, age1, age2,age3,age4,age5,age6,age7,age8,format="A",/silent

   model[0,*,i] = age0
   model[1,*,i] = age1
   model[2,*,i] = age2
   model[3,*,i] = age3
   model[4,*,i] = age4
   model[5,*,i] = age5
   model[6,*,i] = age6
   model[7,*,i] = age7
   model[8,*,i] = age8

endfor


save, model, filename='/Users/jkrick/nutella/bin/bc03/bc03_2.sav'
save, lambda, filename = '/Users/jkrick/nutella/bin/bc03/lambda_2.sav'

end
