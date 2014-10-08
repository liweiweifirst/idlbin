pro arctarget
close, /all
restore, '/Users/jkrick/idlbin/object.sav'

!P.THICK =3

keeper =[1355,1342,7933]
targets = object[keeper]
header = headfits('/Users/jkrick/hst/raw/wholeacs.fits')

adxy, header, object[keeper].ra, object[keeper].dec, xcenter, ycenter

;first need to make a hyperz input with just those objects.
openw, outlunh, "/Users/jkrick/ZPHOT/hyperz_cat_arc.txt",/get_lun
for num = 0, n_elements(targets) - 1 do begin

   if object[keeper(num)].flamjmag gt 0 and object[keeper(num)].flamjmag ne 99 then begin
      fab = 1594.*10^(object[keeper(num)].flamjmag/(-2.5))
      jmagab = -2.5*alog10(fab) +8.926
   endif else begin
      jmagab = object[keeper(num)].flamjmag
   endelse

   if object[keeper(num)].wircjmag gt 0 and object[keeper(num)].wircjmag ne 99 then begin
      wircjab = 1594.*10^(object[keeper(num)].wircjmag/(-2.5))
      wircjmagab = -2.5*alog10(wircjab) +8.926
   endif else begin
      wircjmagab = object[keeper(num)].wircjmag
   endelse

   if object[keeper(num)].wirchmag gt 0 and object[keeper(num)].wirchmag ne 99 then begin
      wirchab = 1024.*10^(object[keeper(num)].wirchmag/(-2.5))
      wirchmagab = -2.5*alog10(wirchab) +8.926
   endif else begin
      wirchmagab = object[keeper(num)].wirchmag
   endelse

   if object[keeper(num)].wirckmag gt 0 and object[keeper(num)].wirckmag ne 99 then begin
      wirckab = 666.8*10^(object[keeper(num)].wirckmag/(-2.5))
      wirckmagab = -2.5*alog10(wirckab) +8.926
   endif else begin
      wirckmagab = object[keeper(num)].wirckmag
   endelse

   if object[keeper(num)].irac1flux lt 0 then err1 = -1. else err1 = 0.05
   if object[keeper(num)].irac2flux lt 0 then err2 = -1. else err2 =  0.05;8.926 - 2.5*alog10(0.05E-6*object[keeper(num)].irac2)
   if object[keeper(num)].irac3flux lt 0 then err3 = -1. else err3 =  0.05;8.926 - 2.5*alog10(0.05E-6*object[keeper(num)].irac3)
   if object[keeper(num)].irac4flux lt 0 then err4 = -1. else err4 =  0.05;8.926 - 2.5*alog10(0.05E-6*object[keeper(num)].irac4)
   
   if object[keeper(num)].imagerra gt 1000. then object[keeper(num)].imagerra = 1000.
   if object[keeper(num)].gmagerra gt 1000. then object[keeper(num)].gmagerra = 1000.
   if object[keeper(num)].rmagerra gt 1000. then object[keeper(num)].rmagerra = 1000.
   if object[keeper(num)].umagerra gt 1000. then object[keeper(num)].umagerra = 1000.
   

    printf, outlunh, format='(I10,F10.2,F10.2,F10.2,F10.2,F10.2,F10.2,F10.2,F10.2,F10.2,F10.2,F10.2,F10.2,F10.2,F10.2,F10.2,F10.2,F10.2,F10.2,F10.2,F10.2,F10.2,F10.2,F10.2,F10.2,F10.2,F10.2,F10.2,F10.2,F10.2,F10.2,F10.2,F10.2)',$
                 keeper(num), object[keeper(num)].umaga, object[keeper(num)].gmaga, object[keeper(num)].rmaga, $
                 object[keeper(num)].imaga,  object[keeper(num)].acsmag,  jmagab, wircjmagab, $
                 object[keeper(num)].tmassjmag,  wirchmagab, object[keeper(num)].tmasshmag, wirckmagab, $
                 object[keeper(num)].tmasskmag, object[keeper(num)].irac1mag,object[keeper(num)].irac2mag,$
                 object[keeper(num)].irac3mag,object[keeper(num)].irac4mag,   $
                 object[keeper(num)].umagerra, object[keeper(num)].gmagerra, $
                 object[keeper(num)].rmagerra, object[keeper(num)].imagerra, object[keeper(num)].acsmagerr, object[keeper(num)].flamjmagerr, $
                 object[keeper(num)].wircjmagerr,0.02, object[keeper(num)].wirchmagerr, 0.02, object[keeper(num)].wirckmagerr,$
                 0.02,err1,err2,err3,err4
 endfor
close, outlunh
free_lun, outlunh


;---------------------
;run hyperz
;----------------------------------------------------------------------
;plot SED's of keeper objects

!p.multi = [0, 0, 1]

ps_open, file = "/Users/jkrick/ZPHOT/sed.arc.ps", /portrait, xsize = 4, ysize = 4,/color
readcol,'/Users/jkrick/ZPHOT/hyperz_swire_arc.log_phot',idlog, zstep, chiz, probz,sptz,agez,avz,format="A"

readcol,'/Users/jkrick/ZPHOT/hyperz_swire_arc.z_phot',idz, zphota, chia, proba, specta, nagea, agea, $
        ava, ba, zinf99a,zsup99a,zinf90a,zsup90a,zinf68a,zsup68a,zwma,probwma,Mabsa,$
        zphot2a,prob2a,format="A"


;readlargecol, '/Users/jkrick/ZPHOT/hyperz_swire_jason.obs_sed',idz, u,g,r,i,j,wj,tj,wh,th,wk,tk,one,two,three, four,$
;         uerr, gerr, rerr, ierr, jerr, wjerr,tjerr,wherr,therr,wkerr,tkerr,oneerr, twoerr, threeerr, fourerr,format="A",/debug
readlargecol, '/Users/jkrick/ZPHOT/hyperz_swire_arc.obs_sed',idz, u,g,r,i,acs,j,wj,tj,wh,th,wk,tk,one,two,three, four,$
         uerr, gerr, rerr, ierr,acserr, jerr, wjerr,tjerr,wherr,therr,wkerr,tkerr,oneerr, twoerr, threeerr, fourerr,format="A",/debug

print, n_elements(zphota), n_elements(u)

;spectral type key
sptkey=[" Arp220 " ," Ell13  " ," Ell2  " ," I19254 " ," M82  " ," Mrk231" ," QSO1 " ," QSO2 " ," S0   " ," Sa  " ," Sb  " ," Sc  " ," Sd  " ," Sey2  " ," Torus" ]     
;---------------------------------------------------------------------


fits_read, '/Users/jkrick/hst/raw/wholeacs.fits', acsdata, acshead

size = 10



;x = [3540.,4660.,6255.,7680.,36000.,45000.,58000.,80000.]    ;wavelengths of our photometry in angs.
;x = [.3540,.4660,.6255,.7680,.8140,1.196, 1.25,1.24,1.635,1.65,2.15,2.16,3.6000,4.5000,5.8,8.,24.]    ;wavelengths of our photometry in microns
x = [.3540,.4660,.6255,.7680,.8330,1.196, 1.25,1.24,1.635,1.65,2.15,2.16,3.6000,4.5000,5.8,8.]    ;wavelengths of our photometry in microns
;x = [.3540,.4660,.6255,.7680,1.196, 1.25,1.24,1.635,1.65,2.15,2.16,3.6000,4.5000,5.8,8.]    ;wavelengths of our photometry in microns
y = x
yerr = x

interest =indgen(n_elements(idz)) 
for n = 0,n_elements(idz) - 1 do begin

;output the acs image of the object
   print, "working on n ", n

  
 print,    xcenter(n) - size/0.05, xcenter(n)+ size/0.05  ,ycenter(n) -size/0.05, ycenter(n)+size/0.05
      plotimage, xrange=[xcenter(n) - size/0.05, xcenter(n)+ size/0.05],$
                 yrange=[ycenter(n) -size/0.05, ycenter(n)+size/0.05], $
                 bytscl(acsdata, min = -0.01, max = 0.1),$
                 /preserve_aspect, /noaxes, ncolors=60
      xyouts, xcenter(n)- 0.6*size/0.05, ycenter(n)-1.2*size/0.05, strcompress(string(keeper(n))+ 'ACS' + string(object[keeper(n)].acsmag)),charthick = 3
      

   print, "plotted"


;plot the fitted SED along with photometry of an individual galaxy

  y = [u(interest(n)),g(interest(n)),r(interest(n)),i(interest(n)),acs(interest(n)), j(interest(n)),wj(interest(n)),tj(interest(n)),wh(interest(n)),th(interest(n)),wk(interest(n)),tk(interest(n)),one(interest(n)),two(interest(n)),three(interest(n)), four(interest(n))] ;photometry
  yerr = [uerr(interest(n)),gerr(interest(n)),rerr(interest(n)),ierr(interest(n)),acserr(interest(n)),jerr(interest(n)),wjerr(interest(n)),tjerr(interest(n)), wherr(interest(n)),therr(interest(n)),wkerr(interest(n)), tkerr(interest(n)),oneerr(interest(n)),twoerr(interest(n)),threeerr(interest(n)), fourerr(interest(n))]
;   y = [u(n),g(n),r(n),i(n), j(n),wj(n),tj(n),wh(n),th(n),wk(n),tk(n),one(n),two(n),three(n), four(n)] ;photometry
;   yerr = [uerr(n),gerr(n),rerr(n),ierr(n),jerr(n),wjerr(n),tjerr(n), wherr(n),therr(n),wkerr(n), tkerr(n),oneerr(n),twoerr(n),threeerr(n), fourerr(n)]

   plot,alog10(x), alog10(y), psym = 5, thick = 3, charthick = 3, xthick = 3, ythick = 3, $
        xtitle = "log(microns)", ytitle = "log(flux(microjansky))", title=strcompress("object " + string(idz(n)) +string(zphota(n)) + string(proba(n)) + string(sptkey(specta(n)-1)))

   errplot, alog10(x), alog10(y - yerr), alog10(y + yerr)
;
   readcol,strcompress('/Users/jkrick/ZPHOT/' + string(idz(n)) + '.spe', /remove_all),x2, y2,format="A",/silent
   oplot, alog10((x2/1E4)), alog10(y2), thick = 3
   


;plot the probability distribution as well
plot, zstep[n*120:n*120+120], probz[n*120:n*120+120], thick =3

endfor


;-----------------------------------------------------------------------


;-----------------------------------------------------------------------


ps_close, /noprint, /noid

help, /memory




END



