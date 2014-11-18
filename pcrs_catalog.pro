pro pcrs_catalog

readcol, '~/external/irac_warm/pcrs_catalog/pcrsguidestarcatalog.txt', star_id, junk, junk, Validity, Q, posEr, pErWk,  vMag, rightAscensn,  declination, prpMtnRA, prpMtnDc,  parllx, magEr,  raErr, declEr, mKER, mKED, plxEr, dOjbE, bkgEr, bstEr, P, M, X

a = where(Q eq 0)
b = where(Q eq 1)
plothist, posEr(b)/ 18.25 * 24., xhist, yhist,  bin=1.0, /noprint,/noplot
ph = barplot(xhist, yhist,  xtitle = 'PCRS Catalog Position Error at 2015.25 (mas)', ytitle = 'Number', fill_color = 'sky blue' , title = titlename, name = 'grade B')

plothist, posEr(a)/ 18.25 * 24., xhist, yhist,  bin=1.0, /noprint,/noplot
ph1 = barplot(xhist, yhist, overplot = ph, fill_color = 'red', name = 'grade A')

L = legend(target = [ph, ph1], position = [140,3000], /data, /auto_text_color)

;-----------

hip = where(M eq 0)
tyc = where(M gt 0)

plothist, posEr(tyc)/ 18.25 * 24., xhist, yhist,  bin=1.0, /noprint,/noplot
ph2 = barplot(xhist, yhist,  xtitle = 'PCRS Catalog Position Error at 2015.25 (mas)', ytitle = 'Number', fill_color = 'sky blue' , title = titlename, name = 'Tycho')

plothist, posEr(hip)/ 18.25 * 24., xhist, yhist,  bin=1.0, /noprint,/noplot
ph3 = barplot(xhist, yhist, overplot = ph2, fill_color = 'red', name = 'Hipparcos')

L = legend(target = [ph2, ph3], position = [140,3000], /data, /auto_text_color)
end
