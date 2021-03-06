pro cluster_mips24


common sharevariables, candra, canddec, sep, objectnew, rvir, member, membernoagn, memberagn, clus_z1, clus_24,nfluxlimit,nflux, beta, luminositydistance, wholefield, wholefieldnoagn, wholefieldagn, clus_z1noagn, allzfield


restore, '/Users/jkrick/nutella/idlbin/objectnew.sav'

!P.multi=[0,1,1]
ps_open, filename='/Users/jkrick/nutella/nep/clusters/mips24/junk.ps',/portrait,/square,/color, xsize=5, ysize=5
!P.charthick=3
!P.thick=3
!X.thick=3
!Y.thick=3
redcolor = FSC_COLOR("Red", !D.Table_Size-2)
bluecolor = FSC_COLOR("Blue", !D.Table_Size-3)
blackcolor = FSC_COLOR("Black", !D.Table_Size-4)


;calculate distances in Mpc for reference
z = 1.0    ; maybe one day calculate this more exactly
luminositydistance = lumdist(z)
angulardistance = luminositydistance / ((1+z)^2)    

;what is the conversion between arcminutes and Mpc?
mpcperarcmin = (tan((1./60.)*(!Pi/180.))) * angulardistance 
;-------------------------------------------------------------------------------
;where are the 24 micron sources in the cluster areas
;-------------------------------------------------------------------------------

canddec = [69.045052,  69.06851,  69.087766]
candra = [264.68365, 264.89228, 264.83053]
sep = 0.019

rvir = [.02425,.020,.020]  ;~0.6Mpc
;want rvirial or 2*rvirial
rvir = 2* rvir

;first find a sample of those objects with phot-z's in the
;right range which are within rvir or 2*rvir.
;junk = cluster_mips24_sample()
junk = cluster_sample()

radofsample =0.053 ;radius in degrees of circle with equivalent size of the sample area
 
;-------------------------------------------------------------------------------
;plot cumulative distribution of distance from center for all members
;with mips detections (member), all galaxies in general, and then all cluster
;members regardless of mips detections (clus_z1)
;-------------------------------------------------------------------------------
;measure distance of each member object with mips detection from it's cluster's center.


membernoagndist0 = sphdist(objectnew[membernoagn].ra, objectnew[membernoagn].dec, candra(0), canddec(0), /degrees) 
membernoagndist1 = sphdist(objectnew[membernoagn].ra, objectnew[membernoagn].dec, candra(1), canddec(1), /degrees) 
membernoagndist2 = sphdist(objectnew[membernoagn].ra, objectnew[membernoagn].dec, candra(2), canddec(2), /degrees) 
membernoagndist = fltarr(n_elements(membernoagn))

;in the case of overlaps, keep the smallest distance.
for memnum = 0, n_elements(membernoagn) - 1 do begin
   if membernoagndist0(memnum) lt membernoagndist1(memnum) and membernoagndist0(memnum) lt membernoagndist2(memnum) $
   then membernoagndist(memnum) = membernoagndist0(memnum)
   if membernoagndist1(memnum) lt membernoagndist0(memnum) and membernoagndist1(memnum) lt membernoagndist2(memnum) $
   then membernoagndist(memnum) = membernoagndist1(memnum)
   if membernoagndist2(memnum) lt membernoagndist1(memnum) and membernoagndist2(memnum) lt membernoagndist0(memnum) $
   then membernoagndist(memnum) = membernoagndist2(memnum)
endfor

;second test, in the case of overlaps, ignore cluster 3, but keep
;smallest distance, either cluster 1 or 2
membernoagndist_noclus3 = fltarr(n_elements(membernoagn))
for memnum = 0, n_elements(membernoagn) - 1 do begin
   if membernoagndist0(memnum) lt membernoagndist1(memnum) then membernoagndist_noclus3(memnum) = membernoagndist0(memnum)
   if membernoagndist1(memnum) lt membernoagndist0(memnum) then membernoagndist_noclus3(memnum) = membernoagndist1(memnum)
endfor

;need to sort on distance
membernoagndist = membernoagndist*60.  ;now in arcmin
sortmembernoagndist= membernoagndist(sort(membernoagndist))
N1 = n_elements(sortmembernoagndist)
f1 = (findgen(N1) + 1.)/ N1
plot, sortmembernoagndist, f1, xtitle='Distance from Cluster Center (arcmin)', ytitle='Cumulative Fraction', xrange=[0,3], xstyle=9, yrange=[0,1]
axis, 0, 1.0, xaxis=1, xrange=[0,3*mpcperarcmin], xstyle = 1;, xthick = 3,charthick = 3

;-------------------------------------------------------------------------------
;measure distance of each z=1 object from it's cluster's center.

clus_z1noagndist0 = sphdist(objectnew[clus_z1noagn].ra, objectnew[clus_z1noagn].dec, candra(0), canddec(0), /degrees) 
clus_z1noagndist1 = sphdist(objectnew[clus_z1noagn].ra, objectnew[clus_z1noagn].dec, candra(1), canddec(1), /degrees) 
clus_z1noagndist2 = sphdist(objectnew[clus_z1noagn].ra, objectnew[clus_z1noagn].dec, candra(2), canddec(2), /degrees) 
clus_z1noagndist = fltarr(n_elements(clus_z1noagn))

;in the case of overlaps, keep the smallest distance.
for memnum = 0, n_elements(clus_z1noagn) - 1 do begin
   if clus_z1noagndist0(memnum) lt clus_z1noagndist1(memnum) and clus_z1noagndist0(memnum) lt clus_z1noagndist2(memnum) $
   then clus_z1noagndist(memnum) = clus_z1noagndist0(memnum)
   if clus_z1noagndist1(memnum) lt clus_z1noagndist0(memnum) and clus_z1noagndist1(memnum) lt clus_z1noagndist2(memnum) $
   then clus_z1noagndist(memnum) = clus_z1noagndist1(memnum)
   if clus_z1noagndist2(memnum) lt clus_z1noagndist1(memnum) and clus_z1noagndist2(memnum) lt clus_z1noagndist0(memnum) $
   then clus_z1noagndist(memnum) = clus_z1noagndist2(memnum)
endfor

;second test, in the case of overlaps, ignore cluster 3, but keep
;smallest distance, either cluster 1 or 2
clus_z1noagndist_noclus3 = fltarr(n_elements(clus_z1noagn))
for memnum = 0, n_elements(clus_z1noagn) - 1 do begin
   if clus_z1noagndist0(memnum) lt clus_z1noagndist1(memnum) then clus_z1noagndist_noclus3(memnum) = clus_z1noagndist0(memnum)
   if clus_z1noagndist1(memnum) lt clus_z1noagndist0(memnum) then clus_z1noagndist_noclus3(memnum) = clus_z1noagndist1(memnum)
endfor

;need to sort on distance
clus_z1noagndist = clus_z1noagndist*60.   ;now in Mpc
sortclus_z1noagndist= clus_z1noagndist(sort(clus_z1noagndist))
N1 = n_elements(sortclus_z1noagndist)
f1 = (findgen(N1) + 1.)/ N1
oplot, sortclus_z1noagndist, f1, linestyle = 1

;-------------------------------------------------------------------------------
;look at member w/ 24 that are AGN

memberagndist0 = sphdist(objectnew[memberagn].ra, objectnew[memberagn].dec, candra(0), canddec(0), /degrees) 
memberagndist1 = sphdist(objectnew[memberagn].ra, objectnew[memberagn].dec, candra(1), canddec(1), /degrees) 
memberagndist2 = sphdist(objectnew[memberagn].ra, objectnew[memberagn].dec, candra(2), canddec(2), /degrees) 
memberagndist = fltarr(n_elements(memberagn))

;in the case of overlaps, keep the smallest distance.
for memnum = 0, n_elements(memberagn) - 1 do begin
   if memberagndist0(memnum) lt memberagndist1(memnum) and memberagndist0(memnum) lt memberagndist2(memnum) $
   then memberagndist(memnum) = memberagndist0(memnum)
   if memberagndist1(memnum) lt memberagndist0(memnum) and memberagndist1(memnum) lt memberagndist2(memnum) $
   then memberagndist(memnum) = memberagndist1(memnum)
   if memberagndist2(memnum) lt memberagndist1(memnum) and memberagndist2(memnum) lt memberagndist0(memnum) $
   then memberagndist(memnum) = memberagndist2(memnum)
endfor


;need to sort on distance
memberagndist = memberagndist*60.   ;now in Mpc
sortmemberagndist= memberagndist(sort(memberagndist))
N1 = n_elements(sortmemberagndist)
f1 = (findgen(N1) + 1.)/ N1
oplot, sortmemberagndist, f1,  linestyle = 5

legend, ['SF members','AGN members', 'all members' ,'field'], linestyle = [0, 5, 1,3]
xyouts, 2.0, 0.1, 'All Cluster '
;-------------------------------------------------------------------------------
;get together some random background regions to look at their spatial distribution
;-------------------------------------------------------------------------------
nrand = 30
seed = 45
randx = randomu(seed, nrand)
randy = randomu(seed, nrand)

randx = randx * 9500. + 6800.
randy = randy * 13300. + 3100.

acshead = headfits('/Users/jkrick/nutella/hst/raw/wholeacs.fits') ;
xyad, acshead, randx, randy, randra, randdec
allranddist = fltarr(nrand*1000)
d = 0
for cand=0, n_elements(randdec) - 1 do begin ;for each random area
   ;don't include stars
   goodrand = where(sphdist(objectnew.ra, objectnew.dec, randra(cand), randdec(cand), /degrees) lt rvir(0) $
                    and objectnew.zphot gt 0.87 and objectnew.zphot lt 1.13  and objectnew.chisq lt 50. $
                    and objectnew.mips24flux gt 17.3 and objectnew.mips24mag lt 90  and nflux gt nfluxlimit );$
 ;                  and objectnew.spt eq 1 or objectnew.spt eq 2 or objectnew.spt eq 3 or objectnew.spt eq 4 or objectnew.spt eq 5$
;   or objectnew.spt eq 8 or objectnew.spt eq 9 or objectnew.spt eq 10 or objectnew.spt eq 11 or objectnew.spt eq 12) 

   for c = 0, n_elements(goodrand) - 1 do begin
      allranddist[d] = sphdist(objectnew[goodrand[c]].ra, objectnew[goodrand[c]].dec, randra(cand), randdec(cand), /degrees) 
      d = d + 1
   endfor


endfor
allranddist = allranddist[0:d-1]*60.

;sort allrand on dist
allranddist = allranddist(sort(allranddist))
N2 = n_elements(allranddist)
f2 = (findgen(N2) + 1.)/ N2
oplot, allranddist, f2, psym = 10, linestyle=3

;determine the ks-test distance and probability for each population
kstwo, allranddist, sortmembernoagndist, ksdist, prob
print, '-------------------------------------------------------------------------------'
print, 'ksdist for membernoagn with 24, prob', ksdist, prob

kstwo, allranddist, sortclus_z1noagndist, ksdistgals, prob
print, 'ksdist for membernoagns, prob', ksdistgals, prob

kstwo, sortmembernoagndist, sortclus_z1noagndist, ksdistgals, prob
print, 'ksdist between membernoagns w/ and w/o 24 , prob', ksdistgals, prob

kstwo, sortmembernoagndist, sortmemberagndist, ksdistgals, prob
print, 'ksdist between membernoagns and memberagn, prob', ksdistgals, prob


;-------------------------------------------------------------------------------
;Is there an overdensity of Mips detections in the cluster compared to
;the background?
;-------------------------------------------------------------------------------
;first, is the spatial density of mips sources over all redshifts higher in the
;clusters than mips sources in the background?
randmips = fltarr(n_elements(randdec))
randmipsz1 = fltarr(n_elements(randdec))

; how many mips detections are within radofsample of randra, randdec?
for rand=0, n_elements(randdec) - 1 do begin ;for each random area
   randmips(rand) = n_elements(where(sphdist(objectnew.ra, objectnew.dec, randra(rand), randdec(rand), /degrees) lt radofsample $
                    and objectnew.mips24flux gt 17.3 and objectnew.mips24mag lt 90  and nflux gt nfluxlimit))


;second, at redshift one, is the spatial density of mips sources in
;the clusters higher than mips sources at redshift one in the background?

   randmipsz1(rand) = n_elements(where(sphdist(objectnew.ra, objectnew.dec, randra(rand), randdec(rand), /degrees) lt radofsample $
                      and objectnew.zphot gt 0.87 and objectnew.zphot lt 1.13  and objectnew.chisq lt 50. $
                      and objectnew.mips24flux gt 17.3 and objectnew.mips24mag lt 90  and nflux gt nfluxlimit))
endfor

print, '-------------------------------------------------------------------------------'
print, 'mean mips sources in background area', mean(randmips), stddev(randmips)
print, 'mean mips sources at z=1 in background area', mean(randmipsz1), stddev(randmipsz1)
print, '-------------------------------------------------------------------------------'

;-------------------------------------------------------------------------------
;try plotting the distributions of just red sources vs. just blue sources, eg Galazzi et al.
;-------------------------------------------------------------------------------
a = where(objectnew[membernoagn].acsmag - objectnew[membernoagn].irac1mag gt 2.3)
redmembernoagn = membernoagn[a]
b = where(objectnew[membernoagn].acsmag - objectnew[membernoagn].irac1mag le 2.3)
bluemembernoagn = membernoagn[b]

a = where(objectnew[clus_z1noagn].acsmag - objectnew[clus_z1noagn].irac1mag gt 2.3)
redclus_z1noagn = clus_z1noagn[a]
b= where(objectnew[clus_z1noagn].acsmag - objectnew[clus_z1noagn].irac1mag le 2.3)
blueclus_z1noagn = clus_z1noagn[b]

redmembernoagndist0 = sphdist(objectnew[redmembernoagn].ra, objectnew[redmembernoagn].dec, candra(0), canddec(0), /degrees) 
redmembernoagndist1 = sphdist(objectnew[redmembernoagn].ra, objectnew[redmembernoagn].dec, candra(1), canddec(1), /degrees) 
redmembernoagndist2 = sphdist(objectnew[redmembernoagn].ra, objectnew[redmembernoagn].dec, candra(2), canddec(2), /degrees) 
redmembernoagndist = fltarr(n_elements(redmembernoagn))

;in the case of overlaps, keep the smallest distance.
for memnum = 0, n_elements(redmembernoagn) - 1 do begin
   if redmembernoagndist0(memnum) lt redmembernoagndist1(memnum) and redmembernoagndist0(memnum) lt redmembernoagndist2(memnum) $
   then redmembernoagndist(memnum) = redmembernoagndist0(memnum)
   if redmembernoagndist1(memnum) lt redmembernoagndist0(memnum) and redmembernoagndist1(memnum) lt redmembernoagndist2(memnum) $
   then redmembernoagndist(memnum) = redmembernoagndist1(memnum)
   if redmembernoagndist2(memnum) lt redmembernoagndist1(memnum) and redmembernoagndist2(memnum) lt redmembernoagndist0(memnum) $
   then redmembernoagndist(memnum) = redmembernoagndist2(memnum)
endfor


;need to sort on distance
redmembernoagndist = redmembernoagndist*60.  ;now in arcmin
sortredmembernoagndist= redmembernoagndist(sort(redmembernoagndist))
N1 = n_elements(sortredmembernoagndist)
f1 = (findgen(N1) + 1.)/ N1
plot, sortredmembernoagndist, f1, xtitle='Distance from Cluster Center (arcmin)', ytitle='Cumulative Fraction', xrange=[0,3], xstyle=9, yrange=[0,1]
oplot, sortredmembernoagndist, f1 , color = redcolor
axis, 0, 1.0, xaxis=1, xrange=[0,3*mpcperarcmin], xstyle = 1;, xthick = 3,charthick = 3

;--------
bluemembernoagndist0 = sphdist(objectnew[bluemembernoagn].ra, objectnew[bluemembernoagn].dec, candra(0), canddec(0), /degrees) 
bluemembernoagndist1 = sphdist(objectnew[bluemembernoagn].ra, objectnew[bluemembernoagn].dec, candra(1), canddec(1), /degrees) 
bluemembernoagndist2 = sphdist(objectnew[bluemembernoagn].ra, objectnew[bluemembernoagn].dec, candra(2), canddec(2), /degrees) 
bluemembernoagndist = fltarr(n_elements(bluemembernoagn))

;in the case of overlaps, keep the smallest distance.
for memnum = 0, n_elements(bluemembernoagn) - 1 do begin
   if bluemembernoagndist0(memnum) lt bluemembernoagndist1(memnum) and bluemembernoagndist0(memnum) lt bluemembernoagndist2(memnum) $
   then bluemembernoagndist(memnum) = bluemembernoagndist0(memnum)
   if bluemembernoagndist1(memnum) lt bluemembernoagndist0(memnum) and bluemembernoagndist1(memnum) lt bluemembernoagndist2(memnum) $
   then bluemembernoagndist(memnum) = bluemembernoagndist1(memnum)
   if bluemembernoagndist2(memnum) lt bluemembernoagndist1(memnum) and bluemembernoagndist2(memnum) lt bluemembernoagndist0(memnum) $
   then bluemembernoagndist(memnum) = bluemembernoagndist2(memnum)
endfor


;need to sort on distance
bluemembernoagndist = bluemembernoagndist*60.  ;now in arcmin
sortbluemembernoagndist= bluemembernoagndist(sort(bluemembernoagndist))
N1 = n_elements(sortbluemembernoagndist)
f1 = (findgen(N1) + 1.)/ N1
oplot, sortbluemembernoagndist, f1, color = bluecolor


;---
redclus_z1noagndist0 = sphdist(objectnew[redclus_z1noagn].ra, objectnew[redclus_z1noagn].dec, candra(0), canddec(0), /degrees) 
redclus_z1noagndist1 = sphdist(objectnew[redclus_z1noagn].ra, objectnew[redclus_z1noagn].dec, candra(1), canddec(1), /degrees) 
redclus_z1noagndist2 = sphdist(objectnew[redclus_z1noagn].ra, objectnew[redclus_z1noagn].dec, candra(2), canddec(2), /degrees) 
redclus_z1noagndist = fltarr(n_elements(redclus_z1noagn))

;in the case of overlaps, keep the smallest distance.
for memnum = 0, n_elements(redclus_z1noagn) - 1 do begin
   if redclus_z1noagndist0(memnum) lt redclus_z1noagndist1(memnum) and redclus_z1noagndist0(memnum) lt redclus_z1noagndist2(memnum) $
   then redclus_z1noagndist(memnum) = redclus_z1noagndist0(memnum)
   if redclus_z1noagndist1(memnum) lt redclus_z1noagndist0(memnum) and redclus_z1noagndist1(memnum) lt redclus_z1noagndist2(memnum) $
   then redclus_z1noagndist(memnum) = redclus_z1noagndist1(memnum)
   if redclus_z1noagndist2(memnum) lt redclus_z1noagndist1(memnum) and redclus_z1noagndist2(memnum) lt redclus_z1noagndist0(memnum) $
   then redclus_z1noagndist(memnum) = redclus_z1noagndist2(memnum)
endfor


;need to sort on distance
redclus_z1noagndist = redclus_z1noagndist*60.  ;now in arcmin
sortredclus_z1noagndist= redclus_z1noagndist(sort(redclus_z1noagndist))
N1 = n_elements(sortredclus_z1noagndist)
f1 = (findgen(N1) + 1.)/ N1
oplot, sortredclus_z1noagndist, f1, linestyle = 1, color=redcolor
;---
blueclus_z1noagndist0 = sphdist(objectnew[blueclus_z1noagn].ra, objectnew[blueclus_z1noagn].dec, candra(0), canddec(0), /degrees) 
blueclus_z1noagndist1 = sphdist(objectnew[blueclus_z1noagn].ra, objectnew[blueclus_z1noagn].dec, candra(1), canddec(1), /degrees) 
blueclus_z1noagndist2 = sphdist(objectnew[blueclus_z1noagn].ra, objectnew[blueclus_z1noagn].dec, candra(2), canddec(2), /degrees) 
blueclus_z1noagndist = fltarr(n_elements(blueclus_z1noagn))

;in the case of overlaps, keep the smallest distance.
for memnum = 0, n_elements(blueclus_z1noagn) - 1 do begin
   if blueclus_z1noagndist0(memnum) lt blueclus_z1noagndist1(memnum) and blueclus_z1noagndist0(memnum) lt blueclus_z1noagndist2(memnum) $
   then blueclus_z1noagndist(memnum) = blueclus_z1noagndist0(memnum)
   if blueclus_z1noagndist1(memnum) lt blueclus_z1noagndist0(memnum) and blueclus_z1noagndist1(memnum) lt blueclus_z1noagndist2(memnum) $
   then blueclus_z1noagndist(memnum) = blueclus_z1noagndist1(memnum)
   if blueclus_z1noagndist2(memnum) lt blueclus_z1noagndist1(memnum) and blueclus_z1noagndist2(memnum) lt blueclus_z1noagndist0(memnum) $
   then blueclus_z1noagndist(memnum) = blueclus_z1noagndist2(memnum)
endfor


;need to sort on distance
blueclus_z1noagndist = blueclus_z1noagndist*60.  ;now in arcmin
sortblueclus_z1noagndist= blueclus_z1noagndist(sort(blueclus_z1noagndist))
N1 = n_elements(sortblueclus_z1noagndist)
f1 = (findgen(N1) + 1.)/ N1
oplot, sortblueclus_z1noagndist, f1, linestyle = 1,color=bluecolor

kstwo, redclus_z1noagndist, blueclus_z1noagndist, ksdistgals, prob
print, 'ksdist between red and blue cluster mips sources, prob', ksdistgals, prob

kstwo, redclus_z1noagndist, redmembernoagndist, ksdistgals, prob
print, 'ksdist between red cluster mips sources and red members, prob', ksdistgals, prob

kstwo, blueclus_z1noagndist, bluemembernoagndist, ksdistgals, prob
print, 'ksdist between blue cluster mips sources and red members, prob', ksdistgals, prob

legend, ['MIPS members', 'all members'], linestyle = [0,1]


;-------------------------------------------------------------------------------
;try plotting the distributions of just spirals vs. irregulars (
;possible signs
;of mergers)
;-------------------------------------------------------------------------------
sp = [654,912,972,1176,1528,1792,1823,2160,2162,2236,2612,1006,1036,1075,1119,1258,1500,2149,1523,1796,766,949,1002,1055,1101,1133,1480,1827,2248,2405]
irrmerger=[1473,2155,958,1090,1126,1830,2396,13180,3124,1044,1253,15688,32544,818,1493,1769,1775,13913,32283,82563,45339,1525]
irrdisk=[1244,937,1118,1533,1978,2037,2251,12747,14328,938,1166,14682,31637,1026,1188,1311,2152,2475]
ell = [974,1094,1120,1250,1766,2009,2540]
;test
;irrmerger = [irrmerger, irrdisk]

spdist0 = sphdist(objectnew[sp].ra, objectnew[sp].dec, candra(0), canddec(0), /degrees) 
spdist1 = sphdist(objectnew[sp].ra, objectnew[sp].dec, candra(1), canddec(1), /degrees) 
spdist2 = sphdist(objectnew[sp].ra, objectnew[sp].dec, candra(2), canddec(2), /degrees) 
spdist = fltarr(n_elements(sp))

;in the case of overlaps, keep the smallest distance.
for memnum = 0, n_elements(sp) - 1 do begin
   if spdist0(memnum) lt spdist1(memnum) and spdist0(memnum) lt spdist2(memnum) $
   then spdist(memnum) = spdist0(memnum)
   if spdist1(memnum) lt spdist0(memnum) and spdist1(memnum) lt spdist2(memnum) $
   then spdist(memnum) = spdist1(memnum)
   if spdist2(memnum) lt spdist1(memnum) and spdist2(memnum) lt spdist0(memnum) $
   then spdist(memnum) = spdist2(memnum)
endfor


;need to sort on distance
spdist = spdist*60.  ;now in arcmin
sortspdist= spdist(sort(spdist))
N1 = n_elements(sortspdist)
f1 = (findgen(N1) + 1.)/ N1
plot, sortspdist, f1, xtitle='Distance from Cluster Center (arcmin)', ytitle='Cumulative Fraction', xrange=[0,3], xstyle=9, yrange=[0,1]
axis, 0, 1.0, xaxis=1, xrange=[0,3*mpcperarcmin], xstyle = 1;, xthick = 3,charthick = 3

;---
irrmergerdist0 = sphdist(objectnew[irrmerger].ra, objectnew[irrmerger].dec, candra(0), canddec(0), /degrees) 
irrmergerdist1 = sphdist(objectnew[irrmerger].ra, objectnew[irrmerger].dec, candra(1), canddec(1), /degrees) 
irrmergerdist2 = sphdist(objectnew[irrmerger].ra, objectnew[irrmerger].dec, candra(2), canddec(2), /degrees) 
irrmergerdist = fltarr(n_elements(irrmerger))

;in the case of overlaps, keep the smallest distance.
for memnum = 0, n_elements(irrmerger) - 1 do begin
   if irrmergerdist0(memnum) lt irrmergerdist1(memnum) and irrmergerdist0(memnum) lt irrmergerdist2(memnum) $
   then irrmergerdist(memnum) = irrmergerdist0(memnum)
   if irrmergerdist1(memnum) lt irrmergerdist0(memnum) and irrmergerdist1(memnum) lt irrmergerdist2(memnum) $
   then irrmergerdist(memnum) = irrmergerdist1(memnum)
   if irrmergerdist2(memnum) lt irrmergerdist1(memnum) and irrmergerdist2(memnum) lt irrmergerdist0(memnum) $
   then irrmergerdist(memnum) = irrmergerdist2(memnum)
endfor


;need to sort on distance
irrmergerdist = irrmergerdist*60.  ;now in arcmin
sortirrmergerdist= irrmergerdist(sort(irrmergerdist))
N1 = n_elements(sortirrmergerdist)
f1 = (findgen(N1) + 1.)/ N1
oplot, sortirrmergerdist, f1,linestyle=1

;---
irrdiskdist0 = sphdist(objectnew[irrdisk].ra, objectnew[irrdisk].dec, candra(0), canddec(0), /degrees) 
irrdiskdist1 = sphdist(objectnew[irrdisk].ra, objectnew[irrdisk].dec, candra(1), canddec(1), /degrees) 
irrdiskdist2 = sphdist(objectnew[irrdisk].ra, objectnew[irrdisk].dec, candra(2), canddec(2), /degrees) 
irrdiskdist = fltarr(n_elements(irrdisk))

;in the case of overlaps, keep the smallest distance.
for memnum = 0, n_elements(irrdisk) - 1 do begin
   if irrdiskdist0(memnum) lt irrdiskdist1(memnum) and irrdiskdist0(memnum) lt irrdiskdist2(memnum) $
   then irrdiskdist(memnum) = irrdiskdist0(memnum)
   if irrdiskdist1(memnum) lt irrdiskdist0(memnum) and irrdiskdist1(memnum) lt irrdiskdist2(memnum) $
   then irrdiskdist(memnum) = irrdiskdist1(memnum)
   if irrdiskdist2(memnum) lt irrdiskdist1(memnum) and irrdiskdist2(memnum) lt irrdiskdist0(memnum) $
   then irrdiskdist(memnum) = irrdiskdist2(memnum)
endfor


;need to sort on distance
irrdiskdist = irrdiskdist*60.  ;now in arcmin
sortirrdiskdist= irrdiskdist(sort(irrdiskdist))
N1 = n_elements(sortirrdiskdist)
f1 = (findgen(N1) + 1.)/ N1
;oplot, sortirrdiskdist, f1,linestyle=1

;---
elldist0 = sphdist(objectnew[ell].ra, objectnew[ell].dec, candra(0), canddec(0), /degrees) 
elldist1 = sphdist(objectnew[ell].ra, objectnew[ell].dec, candra(1), canddec(1), /degrees) 
elldist2 = sphdist(objectnew[ell].ra, objectnew[ell].dec, candra(2), canddec(2), /degrees) 
elldist = fltarr(n_elements(ell))

;in the case of overlaps, keep the smallest distance.
for memnum = 0, n_elements(ell) - 1 do begin
   if elldist0(memnum) lt elldist1(memnum) and elldist0(memnum) lt elldist2(memnum) $
   then elldist(memnum) = elldist0(memnum)
   if elldist1(memnum) lt elldist0(memnum) and elldist1(memnum) lt elldist2(memnum) $
   then elldist(memnum) = elldist1(memnum)
   if elldist2(memnum) lt elldist1(memnum) and elldist2(memnum) lt elldist0(memnum) $
   then elldist(memnum) = elldist2(memnum)
endfor


;need to sort on distance
elldist = elldist*60.  ;now in arcmin
sortelldist= elldist(sort(elldist))
N1 = n_elements(sortelldist)
f1 = (findgen(N1) + 1.)/ N1
oplot, sortelldist, f1,linestyle=2

kstwo, spdist, irrmergerdist, ksdistgals, prob
print, 'ksdist between spirals and irr/mergers, prob', ksdistgals, prob
legend, ['spiral', 'merger','elliptical'], linestyle = [0,1,2]

;;-------------------------------------------------------------------------------
;what is the luminosity of those sources
;-------------------------------------------------------------------------------


;use ranga's code to match SED's to the 24micron flux given the photz
;of the galaxy.
get_lir, objectnew[membernoagn].zphot, objectnew[membernoagn].mips24flux, objectnew[membernoagn].mips24fluxerr, lir, lirerr
;print, 'total, mean lir, mean lirerr', total(lir), mean(lir) , mean(lirerr)
plothist, lir, bin = 5E9, /xlog, xtitle = 'Lir in solar luminosities', ytitle = 'Number', xrange=[1E9, 5E12], xstyle=9, yrange=[0,6]
oplot, findgen(25) - findgen(25) + 1E11, findgen(25), linestyle = 3
oplot, findgen(25) - findgen(25) + 1E12, findgen(25), linestyle = 3


;test plotting this in a different way
lir_test = alog10(lir)
plothist, lir_test, bin = 0.1,  xtitle = 'Lir in log(solar luminosities)', ytitle = 'Number', xstyle=9, xrange=[10, 12.2]
oplot, findgen(25) - findgen(25) + 11, findgen(25), linestyle = 3
oplot, findgen(25) - findgen(25) + 12, findgen(25), linestyle = 3
oplot, findgen(25) - findgen(25) + 10.2, findgen(25), linestyle = 1

;how many LIRGs, and ULIRGs?
lirg = where(lir ge 1E11 and lir lt 1E12)
sublirg = where(lir lt 1E11)
ulirg = where(lir ge 1E12)

print, 'LIRGS #, %', n_elements(lirg), float(n_elements(where(lir ge 1E11 and lir lt 1E12))) / float(n_elements(membernoagn))
print, 'ULIRGS #, %', n_elements(where(lir ge 1E12 )), float(n_elements(where(lir ge 1E12 ))) / float(n_elements(membernoagn))


;plot cumulative distribution of LIRGS vs sub-LIRGS.
lirg = [lirg,ulirg]
lirgdist0 = sphdist(objectnew[membernoagn[lirg]].ra, objectnew[membernoagn[lirg]].dec, candra(0), canddec(0), /degrees) 
lirgdist1 = sphdist(objectnew[membernoagn[lirg]].ra, objectnew[membernoagn[lirg]].dec, candra(1), canddec(1), /degrees) 
lirgdist2 = sphdist(objectnew[membernoagn[lirg]].ra, objectnew[membernoagn[lirg]].dec, candra(2), canddec(2), /degrees) 
lirgdist = fltarr(n_elements(lirg))

;in the case of overlaps, keep the smallest distance.
for memnum = 0, n_elements(lirg) - 1 do begin
   if lirgdist0(memnum) lt lirgdist1(memnum) and lirgdist0(memnum) lt lirgdist2(memnum) $
   then lirgdist(memnum) = lirgdist0(memnum)
   if lirgdist1(memnum) lt lirgdist0(memnum) and lirgdist1(memnum) lt lirgdist2(memnum) $
   then lirgdist(memnum) = lirgdist1(memnum)
   if lirgdist2(memnum) lt lirgdist1(memnum) and lirgdist2(memnum) lt lirgdist0(memnum) $
   then lirgdist(memnum) = lirgdist2(memnum)
endfor

;need to sort on distance
lirgdist = lirgdist*60.  ;now in arcmin
sortlirgdist= lirgdist(sort(lirgdist))
N1 = n_elements(sortlirgdist)
f1 = (findgen(N1) + 1.)/ N1
plot, sortlirgdist, f1, xtitle='Distance from Cluster Center (arcmin)', ytitle='Cumulative Fraction', xrange=[0,3], xstyle=9, yrange=[0,1]
axis, 0, 1.0, xaxis=1, xrange=[0,3*mpcperarcmin], xstyle = 1;, xthick = 3,charthick = 3
;---------
sublirgdist0 = sphdist(objectnew[membernoagn[sublirg]].ra, objectnew[membernoagn[sublirg]].dec, candra(0), canddec(0), /degrees) 
sublirgdist1 = sphdist(objectnew[membernoagn[sublirg]].ra, objectnew[membernoagn[sublirg]].dec, candra(1), canddec(1), /degrees) 
sublirgdist2 = sphdist(objectnew[membernoagn[sublirg]].ra, objectnew[membernoagn[sublirg]].dec, candra(2), canddec(2), /degrees) 
sublirgdist = fltarr(n_elements(sublirg))

;in the case of overlaps, keep the smallest distance.
for memnum = 0, n_elements(sublirg) - 1 do begin
   if sublirgdist0(memnum) lt sublirgdist1(memnum) and sublirgdist0(memnum) lt sublirgdist2(memnum) $
   then sublirgdist(memnum) = sublirgdist0(memnum)
   if sublirgdist1(memnum) lt sublirgdist0(memnum) and sublirgdist1(memnum) lt sublirgdist2(memnum) $
   then sublirgdist(memnum) = sublirgdist1(memnum)
   if sublirgdist2(memnum) lt sublirgdist1(memnum) and sublirgdist2(memnum) lt sublirgdist0(memnum) $
   then sublirgdist(memnum) = sublirgdist2(memnum)
endfor

;need to sort on distance
sublirgdist = sublirgdist*60.  ;now in arcmin
sortsublirgdist= sublirgdist(sort(sublirgdist))
N1 = n_elements(sortsublirgdist)
f1 = (findgen(N1) + 1.)/ N1
oplot, sortsublirgdist, f1, linestyle =1

legend, ['LIRG', 'sub-LIRGs'], linestyle = [0,1]

kstwo, lirgdist, sublirgdist, ksdist, prob
print, '-------------------------------------------------------------------------------'
print, 'ksdist for lirgist & sublirgdist', ksdist, prob

;----------------
;
;now convert lir into sfr.
lirtosfr=1.71E-10
sfr = lir * 1.71E-10
print, 'total, mean sfr, min(sfr)', total(sfr), mean(sfr), min(sfr)
axis, 10,10,  xaxis=1, xrange=[1E10*lirtosfr,1.6E12*lirtosfr], xstyle = 1, /xlog

;plothist, sfr, xtitle = 'SFR in solar masses/ year', ytitle = 'Number'

;----------------
;compare with all mips sources at z=1 across the field
get_lir, objectnew[wholefieldnoagn].zphot, objectnew[wholefieldnoagn].mips24flux, objectnew[wholefieldnoagn].mips24fluxerr, lir_field, lirerr_field
;normalize to the total number of the member sample
a = float(n_elements(membernoagn))
b =  float(n_elements(wholefieldnoagn))
normfactor = a / b

plothist,  lir_field , xhist_field, yhist_field, bin = 5E9, /xlog, /noprint, /noplot;, xtitle = 'Lir in solar luminosities', ytitle = 'Number', xrange=[1E9, 5E12], xstyle=9
;oplot, xhist_field, yhist_field, psym = 10, linestyle = 1
plot, xhist_field , yhist_field*normfactor,  xtitle = 'Lir in solar luminosities', ytitle = 'Number', xrange=[1E9, 5E12], xstyle=9, psym = 10,/xlog
oplot, findgen(25) - findgen(25) + 1E11, findgen(25), linestyle = 3
oplot, findgen(25) - findgen(25) + 1E12, findgen(25), linestyle = 3
axis, 1E9,8,  xaxis=1, xrange=[1E9*lirtosfr,5E12*lirtosfr], xstyle = 1

;----------------
;test to see if these two are drawn from the same distribution

kstwo, lir, lir_field, lir_dist, lir_prob
print, 'KS test on Lir', lir_dist,lir_prob


;-------------------------
;which are the ulirgs?
ulirg = where(lir ge 1E12)
;print, 'ulirg', member[ulirg], memberdist[ulirg]*mpcperarcmin, objectnew[member[ulirg]].ra, objectnew[member[ulirg]].dec



;-------------------------------------------------------------------------------
;what is the morphology of those sources
;-------------------------------------------------------------------------------

;start with just what type of galaxy was the best fit in hyperz 

;spectral type key
sptkey = strarr(15)
;sptkey=["  "," Arp220 " ," Ell13  " ," Ell2  " ," M82  " ," Mrk231" ," QSO1 " ," QSO2 " ," S0   " ," Sa  " ," Sb  " ," Sc  " ," Sd  " ," Sey1.8", " Sey2  " ," Torus" ]     
sptkey=[" Arp220 " ," Ell13  " ," Ell2  " ," M82  " ," Mrk231" ," QSO1 " ," QSO2 " ," S0   " ," Sa  " ," Sb  " ," Sc  " ," Sd  " ," Sey1.8", " Sey2  "  ]     

nothing = replicate(' ', 17)
plothist, objectnew[member].spt, xhist, yhist, /noprint, /noplot; xrange=[0,16], xstyle = 1, xtickname = nothing
plothist, objectnew[wholefield].spt, xhist_field, yhist_field, /noprint, /noplot; xrange=[0,16], xstyle = 1, xtickname = nothing
plothist, objectnew[allzfield].spt, xhist_allzfield, yhist_allzfield, /noprint, /noplot

a = float(n_elements(member))
b =  float(n_elements(wholefield))
normfactor = a / b
yhist_field = yhist_field*normfactor

c = float(n_elements(allzfield))
normfactor = a / c
yhist_allzfield = yhist_allzfield*normfactor

;want to sort on the most popular kind of object
;sptkey = sptkey[sort(yhist)]
;yhist = yhist[sort(yhist)]

;try sorting on type of objects.
index = [1,2,7,8,9,10,11,3,0,4,5,6,12,13]
sptkey = sptkey(index)
yhist = yhist(index)
yhist_field = yhist_field(index)
yhist_allzfield = yhist_allzfield(index)

plot, xhist, yhist, xrange=[0,17], xstyle = 1, xtickname = nothing, psym = 2, ytitle="Number", yrange=[0,25]
oplot, xhist_field, yhist_field, psym = 4;, linestyle = 2
oplot, xhist_allzfield, yhist_allzfield, psym = 6;, linestyle = 4

xlabel = findgen(16) 
ylabel = findgen(16) - findgen(16) -0.1
;sptkey=[" Torus", sptkey]
sptkey =[" ", sptkey, " Torus"]

xyouts, xlabel, ylabel, sptkey, orientation=310

;make a vertical line at the end of the histogram
;psym = 10 does not fully get the histogram thing correct
x = [1,1]
y  = [9,0]
oplot, x, y
x = [1,2]
y  = [9,9]
oplot, x, y
x=[15,15]
y = [13,0]
oplot, x, y
x=[14,15]
y = [13,13]
oplot, x, y

x = [15,15]
y = [19.9,0]
oplot, x, y, linestyle = 2
x = [14,15]
y = [19.9,19.9]
oplot, x, y, linestyle = 2
x = [1,2]
y = [5.4,5.4]
oplot, x, y, linestyle = 2
x = [1,1]
y = [5.4,0]
oplot, x, y, linestyle = 2

;-------------------------------------------------------------------------------
;make thumbnail image of the morphology by eye stuff
;-------------------------------------------------------------------------------

;interest = [1196, 1250, 1036, 1026, 2536]
;acsthumbnails, interest, '/Users/jkrick/nep/clusters/mips24/morphthumb.ps'

;-------------------------------------------------------------------------------
;make irac color color plot to see where all of these objects are.
;-------------------------------------------------------------------------------
vsym, /polygon, /fill

plot, alog10(objectnew[clus_z1].irac3flux / objectnew[clus_z1].irac1flux), alog10(objectnew[clus_z1].irac4flux / objectnew[clus_z1].irac2flux), $
      psym = 8, xrange = [-1.5, 1.], yrange=[-1.0, 1.0],/xst,/yst, xtitle='log(S5.8/S3.6)', ytitle = 'log(S8.0/S4.5)', symsize=0.5 

oplot, [-0.2,1.3], [-0.2,-0.2]
oplot, [-0.2,-0.2], [-0.2,0.3]
oplot, [-0.2,1.3], [0.3,1.5]

oplot,alog10(objectnew[member].irac3flux / objectnew[member].irac1flux), alog10(objectnew[member].irac4flux / objectnew[member].irac2flux), $
      psym = 8,symsize=0.5, color=redcolor

; now pick out the ones that hyperz thinks are AGN
agn = where(objectnew[member].spt eq 6 or objectnew[member].spt eq 7 or objectnew[member].spt eq 13$
or objectnew[member].spt eq 14 or objectnew[member].spt eq 15)


oplot,  alog10(objectnew[member[agn]].irac3flux / objectnew[member[agn]].irac1flux), $
        alog10(objectnew[member[agn]].irac4flux / objectnew[member[agn]].irac2flux),  psym = 8,symsize=0.5, color=bluecolor
print, '-------------'
print, 'number of agn within member based on hyperz', n_elements(AGN)

;legend, ['all redshift 1', 'all redshift 1 with 24', 'all redshift 1 with 24 with AGN hyperz fit'], psym = [8,8,8], colors=[blackcolor, redcolor, bluecolor]

;------------------------------------------------------------------------------
;compare our measurements to Bai et al. 2007
junk = mass_norm_sfr()

;------------------------------------------------------------------------------
;what are the UV derived SFR's for the member galaxies with
;mips detections?

;junk = uv_sfr()
;------------------------------------------------------------------------------
;what is the AGN fraction for these clusters based on definition of
;eastman2007?

junk = find_agnfraction()

;-----------------------------------------------------------------------------
;put the member galaxies with 24 detections on the CMD's from paper I

;same plot as paper 1
;arg ; unfortunately need to use the old catalog to make the plots match...
;restore, '/Users/jkrick/idlbin/object.old.sav'
;not any more, new sample with nflux > 5 has fixed this problem.

iall = fltarr(210000)
iracall = fltarr(210000)
avall = fltarr(210000)
j = 0
sep_paper1 =0.017
for cand=0, n_elements(canddec) - 1 do begin
   good = where(sphdist(objectnew.ra, objectnew.dec, candra(cand), canddec(cand), /degrees) lt rvir(cand) and nflux gt nfluxlimit $
               and objectnew.zphot gt 0.87 and objectnew.zphot lt 1.13  and objectnew.chisq lt 50.);objectnew.irac1mag gt 0 and objectnew.irac1mag lt 90 and objectnew.acsmag gt 0 and objectnew.acsmag lt 90 );objectnew.nearestdist gt 0.00055) ;and objectnew.nearestdist*60*60/0.6 gt 4.0 ) ;

   for k = 0l, n_elements(good) - 1 do begin
      iall[j] = objectnew[good[k]].acsmag
      iracall[j] =objectnew[good[k]].irac1mag
      avall[j] = objectnew[good[k]].av
      j = j + 1
   endfor
endfor
iall = iall[0:j-1]
iracall = iracall[0:j-1]

;print,'n_elem,ents(iall)', n_elements(iall)


dm = 44.1
dm = dm - 0.75  ;for filter bandpass shrinking
dm = dm - 0.7  ;evolution correction
kcorr = 0.
m = -0.12
ball = 5.2
rcswidth = 0.5

;im_hessplot, iracall, iall -iracall, yrange=[0,6], xtitle = '[3.6] (AB)', ytitle = 'ACS F814W - [3.6]', xrange=[18,25],/notsquare, nbin2d=15, position = [0.1 ,0.1 , 0.9,0.9], charsize=1, charthick=3, xthick=3, ythick=3, thick=3,xstyle=9, ystyle = 1
;axis, 0,6, xaxis=1,xrange=[18-dm+kcorr,25-dm+kcorr], xstyle=1, xthick=3, charthick=3

;oplot, findgen(100),  m*findgen(100) + ball, thick = 3 ;, color = orangecolor
;oplot, findgen(100), m*findgen(100) + ball + rcswidth, thick = 3 ;, color = orangecolor
;oplot, findgen(100),  m*findgen(100) +ball - rcswidth, thick = 3 ;, color = orangecolor
;oplot, [25.1, 22], [2.9,6.0], linestyle = 2, thick=3

;now overplot member galaxies
;switch back to new catalog
;restore, '/Users/jkrick/idlbin/objectnew.sav'

;oplot, objectnew[member].irac1mag, objectnew[member].acsmag - objectnew[member].irac1mag, psym = 2

;now indicate which ones are AGN based on their SED fits
;oplot, objectnew[member[agn]].irac1mag, objectnew[member[agn]].acsmag - objectnew[member[agn]].irac1mag, psym = 6


;redmember = where(objectnew[member[notagn]].acsmag - objectnew[member[notagn]].irac1mag gt 2.5)
;plothyperz, member[notagn[redmember]], '/Users/jkrick/nep/clusters/mips24/redmips24.ps'

;maybe instead or inaddition should plot color distribution.
;otherwise it is noticeable that there are galaxies in the member
;sample in places where there are none in the CMD.  damn.  also a few
;junky things up by the detection limit.


plothist, iall-iracall, xtitle =  'ACS F814W - [3.6]', xrange=[1,5], xstyle = 1 $
          , ytitle = 'Number', bin = 0.2, yrange=[0,100]

x = [2.3,2.3]
y = [0,100]
oplot, x, y, linestyle = 1

plothist, objectnew[membernoagn].acsmag - objectnew[membernoagn].irac1mag, bin=0.2, /overplot, linestyle=2

print, 'n red before', n_elements(where(objectnew[membernoagn].acsmag - objectnew[membernoagn].irac1mag gt 2.3))

;try correcting for extinction 
Rv = 4.05
lambda = .41
k41 = 2.659*(-2.156 + (1.509/lambda) + (-.198/(lambda^2)) + (.011/(lambda^3)) ) + Rv
lambda = 1.8
k18 = 2.659*(-1.857 + (1.040/lambda) ) + Rv

;for members with 24
A41 = objectnew[membernoagn].av * k41/Rv
A18 = objectnew[membernoagn].av * k18/Rv

A41z1 = objectnew[clus_z1noagn].av * k41/Rv
A18z1 = objectnew[clus_z1noagn].av * k18/Rv

acsintrinsic = objectnew[membernoagn].acsmag - A41
irac1intrinsic = objectnew[membernoagn].irac1mag - A18

acsclusz1intrinsic = objectnew[clus_z1noagn].acsmag - A41
irac1clusz1intrinsic = objectnew[clus_z1noagn].irac1mag - A18

print, 'membernoagn, av, acsintrinsic, irac1intrinsic, acs-irac intrinsic, acs-irac nonintrinsic'
for colorn = 0, n_elements(membernoagn) -1 do begin
   print,format = '(I10, F10.2, F10.2, F10.2, F10.2, F10.2)', membernoagn[colorn], objectnew[membernoagn[colorn]].av, acsintrinsic[colorn], irac1intrinsic[colorn], acsintrinsic[colorn] - irac1intrinsic[colorn], objectnew[membernoagn[colorn]].acsmag - objectnew[membernoagn[colorn]].irac1mag
endfor

;print, 'Av.41', min(A41), max(A41)
;print, 'AV1,88', min(A18), max(A18)

;for all members
A41 = avall * k41/Rv
A18 = avall*k18/Rv

iallintrinsic = iall - A41
iracallintrinsic = iracall - A18

plothist, iallintrinsic - iracallintrinsic,  xtitle =  'ACS F814W - [3.6] corrected', xrange=[1,5], xstyle = 1 $
          , ytitle = 'Number', bin = 0.2
plothist, acsintrinsic - irac1intrinsic, bin=0.2, /overplot, linestyle=2

oplot, x, y, linestyle = 1

print, 'n red after', n_elements(where(acsintrinsic - irac1intrinsic gt 2.3))

;print, 'Av.41', min(A41), max(A41)
;print, 'AV1,88', min(A18), max(A18)

;how many of the mips sources are on the red sequence, roughly
;red = where(objectnew[member].acsmag - objectnew[member].irac1mag gt 2.5 )
;print, 'number on red sequence', n_elements(red)
;print, 'number of nonagn red', n_elements(redmember) 

;what does the cmd of all mips sources at photz=1 look like?

;plot, objectnew[wholefield].irac1mag, objectnew[wholefield].acsmag - objectnew[wholefield].irac1mag, psym = 2, yrange=[0,6], xtitle = '[3.6] (AB)', ytitle = 'ACS F814W - [3.6]', xrange=[18,25], xstyle = 1

;oplot, findgen(100),  m*findgen(100) + ball, thick = 3 ;, color = orangecolor
;oplot, findgen(100), m*findgen(100) + ball + rcswidth, thick = 3 ;, color = orangecolor
;oplot, findgen(100),  m*findgen(100) +ball - rcswidth, thick = 3 ;, color = orangecolor
;oplot, [25.1, 22], [2.9,6.0], linestyle = 2, thick=3


;------------------------------------------------------------------------------

a = where(acsintrinsic -irac1intrinsic gt 2.3)
redmembernoagn = membernoagn[a]
b = where(acsintrinsic - irac1intrinsic le 2.3)
bluemembernoagn = membernoagn[b]

a = where(acsclusz1intrinsic -irac1clusz1intrinsic gt 2.3)
redmembernoagn = membernoagn[a]
b = where(acsclusz1intrinsic - irac1clusz1intrinsic le 2.3)
bluemembernoagn = membernoagn[b]

redmembernoagndist0 = sphdist(objectnew[redmembernoagn].ra, objectnew[redmembernoagn].dec, candra(0), canddec(0), /degrees) 
redmembernoagndist1 = sphdist(objectnew[redmembernoagn].ra, objectnew[redmembernoagn].dec, candra(1), canddec(1), /degrees) 
redmembernoagndist2 = sphdist(objectnew[redmembernoagn].ra, objectnew[redmembernoagn].dec, candra(2), canddec(2), /degrees) 
redmembernoagndist = fltarr(n_elements(redmembernoagn))

;in the case of overlaps, keep the smallest distance.
for memnum = 0, n_elements(redmembernoagn) - 1 do begin
   if redmembernoagndist0(memnum) lt redmembernoagndist1(memnum) and redmembernoagndist0(memnum) lt redmembernoagndist2(memnum) $
   then redmembernoagndist(memnum) = redmembernoagndist0(memnum)
   if redmembernoagndist1(memnum) lt redmembernoagndist0(memnum) and redmembernoagndist1(memnum) lt redmembernoagndist2(memnum) $
   then redmembernoagndist(memnum) = redmembernoagndist1(memnum)
   if redmembernoagndist2(memnum) lt redmembernoagndist1(memnum) and redmembernoagndist2(memnum) lt redmembernoagndist0(memnum) $
   then redmembernoagndist(memnum) = redmembernoagndist2(memnum)
endfor

print, 'red', n_elements(redmembernoagndist)

;need to sort on distance
redmembernoagndist = redmembernoagndist*60.  ;now in arcmin
sortredmembernoagndist= redmembernoagndist(sort(redmembernoagndist))
N1 = n_elements(sortredmembernoagndist)
f1 = (findgen(N1) + 1.)/ N1
plot, sortredmembernoagndist, f1, xtitle='Distance from Cluster Center (arcmin)', ytitle='Cumulative Fraction', xrange=[0,3], xstyle=9, yrange=[0,1]
oplot, sortredmembernoagndist, f1, color=redcolor
axis, 0, 1.0, xaxis=1, xrange=[0,3*mpcperarcmin], xstyle = 1;, xthick = 3,charthick = 3

;--------
bluemembernoagndist0 = sphdist(objectnew[bluemembernoagn].ra, objectnew[bluemembernoagn].dec, candra(0), canddec(0), /degrees) 
bluemembernoagndist1 = sphdist(objectnew[bluemembernoagn].ra, objectnew[bluemembernoagn].dec, candra(1), canddec(1), /degrees) 
bluemembernoagndist2 = sphdist(objectnew[bluemembernoagn].ra, objectnew[bluemembernoagn].dec, candra(2), canddec(2), /degrees) 
bluemembernoagndist = fltarr(n_elements(bluemembernoagn))

;in the case of overlaps, keep the smallest distance.
for memnum = 0, n_elements(bluemembernoagn) - 1 do begin
   if bluemembernoagndist0(memnum) lt bluemembernoagndist1(memnum) and bluemembernoagndist0(memnum) lt bluemembernoagndist2(memnum) $
   then bluemembernoagndist(memnum) = bluemembernoagndist0(memnum)
   if bluemembernoagndist1(memnum) lt bluemembernoagndist0(memnum) and bluemembernoagndist1(memnum) lt bluemembernoagndist2(memnum) $
   then bluemembernoagndist(memnum) = bluemembernoagndist1(memnum)
   if bluemembernoagndist2(memnum) lt bluemembernoagndist1(memnum) and bluemembernoagndist2(memnum) lt bluemembernoagndist0(memnum) $
   then bluemembernoagndist(memnum) = bluemembernoagndist2(memnum)
endfor

print, 'red', n_elements(bluemembernoagndist)

;need to sort on distance
bluemembernoagndist = bluemembernoagndist*60.  ;now in arcmin
sortbluemembernoagndist= bluemembernoagndist(sort(bluemembernoagndist))
N1 = n_elements(sortbluemembernoagndist)
f1 = (findgen(N1) + 1.)/ N1
oplot, sortbluemembernoagndist, f1, color=bluecolor
;--------

redclus_z1noagndist0 = sphdist(objectnew[redclus_z1noagn].ra, objectnew[redclus_z1noagn].dec, candra(0), canddec(0), /degrees) 
redclus_z1noagndist1 = sphdist(objectnew[redclus_z1noagn].ra, objectnew[redclus_z1noagn].dec, candra(1), canddec(1), /degrees) 
redclus_z1noagndist2 = sphdist(objectnew[redclus_z1noagn].ra, objectnew[redclus_z1noagn].dec, candra(2), canddec(2), /degrees) 
redclus_z1noagndist = fltarr(n_elements(redclus_z1noagn))

;in the case of overlaps, keep the smallest distance.
for memnum = 0, n_elements(redclus_z1noagn) - 1 do begin
   if redclus_z1noagndist0(memnum) lt redclus_z1noagndist1(memnum) and redclus_z1noagndist0(memnum) lt redclus_z1noagndist2(memnum) $
   then redclus_z1noagndist(memnum) = redclus_z1noagndist0(memnum)
   if redclus_z1noagndist1(memnum) lt redclus_z1noagndist0(memnum) and redclus_z1noagndist1(memnum) lt redclus_z1noagndist2(memnum) $
   then redclus_z1noagndist(memnum) = redclus_z1noagndist1(memnum)
   if redclus_z1noagndist2(memnum) lt redclus_z1noagndist1(memnum) and redclus_z1noagndist2(memnum) lt redclus_z1noagndist0(memnum) $
   then redclus_z1noagndist(memnum) = redclus_z1noagndist2(memnum)
endfor


;need to sort on distance
redclus_z1noagndist = redclus_z1noagndist*60.  ;now in arcmin
sortredclus_z1noagndist= redclus_z1noagndist(sort(redclus_z1noagndist))
N1 = n_elements(sortredclus_z1noagndist)
f1 = (findgen(N1) + 1.)/ N1
oplot, sortredclus_z1noagndist, f1, linestyle = 1,color=redcolor
;---
blueclus_z1noagndist0 = sphdist(objectnew[blueclus_z1noagn].ra, objectnew[blueclus_z1noagn].dec, candra(0), canddec(0), /degrees) 
blueclus_z1noagndist1 = sphdist(objectnew[blueclus_z1noagn].ra, objectnew[blueclus_z1noagn].dec, candra(1), canddec(1), /degrees) 
blueclus_z1noagndist2 = sphdist(objectnew[blueclus_z1noagn].ra, objectnew[blueclus_z1noagn].dec, candra(2), canddec(2), /degrees) 
blueclus_z1noagndist = fltarr(n_elements(blueclus_z1noagn))

;in the case of overlaps, keep the smallest distance.
for memnum = 0, n_elements(blueclus_z1noagn) - 1 do begin
   if blueclus_z1noagndist0(memnum) lt blueclus_z1noagndist1(memnum) and blueclus_z1noagndist0(memnum) lt blueclus_z1noagndist2(memnum) $
   then blueclus_z1noagndist(memnum) = blueclus_z1noagndist0(memnum)
   if blueclus_z1noagndist1(memnum) lt blueclus_z1noagndist0(memnum) and blueclus_z1noagndist1(memnum) lt blueclus_z1noagndist2(memnum) $
   then blueclus_z1noagndist(memnum) = blueclus_z1noagndist1(memnum)
   if blueclus_z1noagndist2(memnum) lt blueclus_z1noagndist1(memnum) and blueclus_z1noagndist2(memnum) lt blueclus_z1noagndist0(memnum) $
   then blueclus_z1noagndist(memnum) = blueclus_z1noagndist2(memnum)
endfor


;need to sort on distance
blueclus_z1noagndist = blueclus_z1noagndist*60.  ;now in arcmin
sortblueclus_z1noagndist= blueclus_z1noagndist(sort(blueclus_z1noagndist))
N1 = n_elements(sortblueclus_z1noagndist)
f1 = (findgen(N1) + 1.)/ N1
oplot, sortblueclus_z1noagndist, f1, linestyle = 1,color=bluecolor

legend, ['MIPS members', 'all members'], linestyle = [0,1]

kstwo, sortbluemembernoagndist, sortredmembernoagndist, ksdist, prob
print, 'after extinction, ks test ble to red MIPS members', ksdist, prob
;-------------------------------------------------------------------------------------------------




ps_close, /noprint,/noid


end


;-------------------------------------------------------------------------------------------------


;plothist, objectnewnew[good].rmag, xrange=[10,30]

;plothyperz, good, strcompress( '/Users/jkrick/nep/clusters/mips24/mips24_'+string(i)+'.ps')


;openw, outlun, strcompress('/Users/jkrick/nep/clusters/mips24/cluster'+string(i)+'.reg'), /get_lun
;printf, outlun, 'fk5'
;for rc=0, n_elements(good) -1 do  printf, outlun, 'circle( ', objectnewnew[good[rc]].ra, objectnewnew[good[rc]].dec, ' 3")'
;close, outlun
;free_lun, outlun


;openw, outlun2, strcompress('/Users/jkrick/nep/clusters/mips24/cluster'+string(i)+'.txt'), /get_lun
;printf, outlun, 'number, ra, dec, zphot, rmag, acsmag, irac1mag, mips24flux, acsmatchdist, comment'
;for rc=0, n_elements(good) -1 do  printf, outlun2,  format='(I10,F10.5,F10.5,F10.2,F10.2,F10.2,F10.2,F10.2)', good[rc], objectnewnew[good[rc]].ra, objectnewnew[good[rc]].dec, objectnewnew[good[rc]].zphot, objectnewnew[good[rc]].rmag,objectnewnew[good[rc]].acsmag, objectnewnew[good[rc]].irac1mag,objectnewnew[good[rc]].mips24flux
;close, outlun2
;free_lun, outlun2


;-------------------------------------------------------------------------------------------------
;now bin distances
;5 bins, < .0038, .0038 < .0076, .0076<.0114, .0114 < .0152,
;.0152<.019

;x = [.0019,.0057,.0095,.0133,.0171]
;x = x * 60.
;y = [n_elements(where(sortdistallcluster lt .0038* 60.)),n_elements(where(sortdistallcluster ge .0038* 60. and sortdistallcluster lt .0076* 60.)),n_elements(where(sortdistallcluster ge .0076* 60. and sortdistallcluster lt .0114* 60.)),n_elements(where(sortdistallcluster ge .0114* 60. and sortdistallcluster lt .0152* 60.)),n_elements(where(sortdistallcluster ge .152* 60. and sortdistallcluster lt .019* 60.))]

;y2 = [n_elements(where(allranddist lt .0038* 60.)),n_elements(where(allranddist ge .0038* 60. and allranddist lt .0076* 60.)),n_elements(where(allranddist ge .0076* 60. and allranddist lt .0114* 60.)),n_elements(where(allranddist ge .0114* 60. and allranddist lt .0152* 60.)),n_elements(where(allranddist ge .152* 60. and allranddist lt .019* 60.))]

;plot, x, y, psym = 2;, psym = 10
;oplot, x, y2, psym = 1; linestyle = 1;,psym=10

;plothist, sortdistallcluster, bin=0.019*60./10., xtitle='distance from cluster center in arcminutes', ytitle='N', xrange=[0,0.02*60.], xstyle=1
;plothist, allranddist, bin=0.019*60./10., /overplot, linestyle=1
;print, n_elements(dist24), n_elements(allranddist) ,'nelements dist, rand'

