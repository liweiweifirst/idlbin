function nearest_neighbors_DT,x,y,DISTANCES=nearest_d,NUMBER=k
  if n_elements(k) eq 0 then k=6
  
  ;; Compute Delaunay triangulation
  triangulate,x,y,CONNECTIVITY=c
  n=n_elements(x) 
  nearest=lonarr(k,n,/NOZERO)
  nearest_d=fltarr(k,n,/NOZERO)

  for point=0L,n-1 do begin 
     p=c[c[point]:c[point+1]-1] ;start with this point's DT neighbors
     d=(x[p]-x[point])^2+(y[p]-y[point])^2
     for i=1,k do begin 
        s=sort(d)               ; A wasteful priority queue, but anyway
        p=p[s] & d=d[s]
        nearest[i-1,point]=p[0] ; Happy Day: the closest candidate is a NN
        nearest_d[i-1,point]=d[0]
        if i eq k then continue
        
        ;; Add all its neighbors not yet seen
        new=c[c[p[0]]:c[p[0]+1]-1]
        nnew=n_elements(new) 
        already_got=[p,nearest[0:i-1,point],point]
        ngot=n_elements(already_got) 
        wh=where(long(total(rebin(already_got,ngot,nnew,/SAMPLE) ne $
                            rebin(transpose(new),ngot,nnew,/SAMPLE),1)) $
                 eq ngot, cnt)
        if cnt gt 0 then begin 
           new=new[wh]
           p=[p[1:*],new]
           d=[d[1:*],(x[new]-x[point])^2+(y[new]-y[point])^2]
        endif else begin 
           p=p[1:*]
           d=d[1:*]
        endelse 
     endfor
  endfor 
  if arg_present(nearest_d) then nearest_d=sqrt(nearest_d)
 return, nearest
end 
