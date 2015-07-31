pro print_corrflux

restore, '~/external/irac_warm/epic201367065d/epic201367065d_phot_ch2_2.25000_150226.sav'
openw, outlun, '/Users/jkrick/external/irac_warm/epic201367065d/epic201367065d_corrphot_r53522944.txt',/GET_LUN
aorname = 'r53522432';'r53522944';'r53521920','r53521664'
time = (planethash[aorname,'bmjdarr']) 
     corrflux =planethash[aorname,'corrflux_d']
     corrfluxerr =planethash[aorname,'corrfluxerr']

for i = 0, n_elements(time) - 1 do begin
   printf, outlun, time(i), corrflux(i)/ median(corrflux), ' ', corrfluxerr(i)/ median(corrflux), format = '(D, F10.7 ,A,  F10.8)'
endfor
close, outlun
free_lun, outlun

end

