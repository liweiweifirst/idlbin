;Viewing contents of file '../idllib/idl_5.2/lib/interpol.pro'
; $Id: interpol.pro,v 1.9.4.1 1999/01/16 16:41:53 scottm Exp $
;
; Copyright (c) 1982-1999, Research Systems, Inc.  All rights reserved.
;	Unauthorized reproduction prohibited.

FUNCTION INTERPOL, V, X, U
;+
; NAME:
;	INTERPOL
;
; PURPOSE:
;	Linearly interpolate vectors with a regular or irregular grid.
;
; CATEGORY:
;	E1 - Interpolation
;
; CALLING SEQUENCE:
;	Result = INTERPOL(V, N) 	;For regular grids.
;
;	Result = INTERPOL(V, X, U)	;For irregular grids.
;
; INPUTS:
;	V:	The input vector can be any type except string.
;
;	For regular grids:
;	N:	The number of points in the result when both input and
;		output grids are regular.  
;
;	Irregular grids:
;	X:	The absicissae values for V.  This vector must have same # of
;		elements as V.  The values MUST be monotonically ascending 
;		or descending.
;
;	U:	The absicissae values for the result.  The result will have 
;		the same number of elements as U.  U does not need to be 
;		monotonic.
;	
; OPTIONAL INPUT PARAMETERS:
;	None.
;
; OUTPUTS:
;	INTERPOL returns a floating-point vector of N points determined
;	by linearly interpolating the input vector.
;
;	If the input vector is double or complex, the result is double 
;	or complex.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	Result(i) = V(x) + (x - FIX(x)) * (V(x+1) - V(x))
;
;	where 	x = i*(m-1)/(N-1) for regular grids.
;		m = # of elements in V, i=0 to N-1.
;
;	For irregular grids, x = U(i).
;		m = number of points of input vector.
;
; MODIFICATION HISTORY:
;	Written, DMS, October, 1982.
;	Modified, Rob at NCAR, February, 1991.  Made larger arrays possible 
;		and correct by using long indexes into the array instead of
;		integers.
;	Modified, DMS, August, 1998.  Now use binary intervals which
;	speed things up considerably when U is random.
;-
;
on_error,2                      ;Return to caller if an error occurs
m = N_elements(v)               ;# of input pnts

if N_params(0) eq 2 then begin	;Regular?  Simply use INTERPOLATE function
    r = findgen(x)*(m-1)/(x-1>1) ;Grid points in V
    rl = long(r)		;Cvt to integer
    s = size(v)
    if s[s[0]+1] eq 1 then dif = v[1:*]-fix(v)  $ ;V[i+1]-v[i], signed for bytes
    else dif = v[1:*]-v    ;Other types are already signed
    return, V[rl] + (r-rl)*dif[rl] ;interpolate
endif
;
if n_elements(x) ne m then $ 
  stop,'INTERPOL - V and X must have same # of elements'
n = n_elements(u)               ;# of output points
m1 = m-1                        ;last subs in v and x
r= fltarr(n)+V[0]               ;floating, dbl or cmplx result

low = 0L                        ;Lower & upper subscript bounds
high = m1

if x[1] ge x[0] then begin      ;X in ascending order??
    for i=0L,n-1 do begin       ;Each u
        z = u[i]
; Ensure that (z=u[i]) is less than x[high].
        if z gt x[high] then begin
            if z ge x[m1] then begin mid=m1-1 & goto, skip
            endif
            del = 1L            ;Adjust upper bound upwards
            while z gt x[high+del < m1] do del = del+ del 
            high = high + del < m1
        endif
; Ensure that (z=u[i]) is greater than or equal to x[low].
        if z lt x[low] then begin
            if z le x[0] then begin mid=0L & goto, skip
            endif
            while z lt x[low] do low = low / 2 ;Adjust lower downwards.
        endif
; Here we know that (u[i] = z), and z GE x[low], and z LT x[high].
        while  high-low gt 1L do begin ;Binary subdivision loop
            mid = (low + high)/2L
            if z ge x[mid] then low = mid $
            else high = mid
        endwhile
;        if z lt x[low] or z ge x[low+1] then stop, 'screw-up'
        mid = low
skip:   r[i] = v[mid] + (z-x[mid]) * (v[mid+1]-v[mid])/(x[mid+1]-x[mid])
    endfor 
    
endif else begin                ;Descending order, same logic, only reversed

    for i=0L, n-1 do begin      ;Each u
        z = u[i]
        if z lt x[high] then begin
            if z le x[m1] then begin mid=m1-1 & goto, skip1
            endif
            del = 1L
            while z lt x[high+del < m1] do del = 2L* del 
            high = high + del < m1
;            while z lt x[high] do high = (high + m)/2
        endif
        if z gt x[low] then begin
            if z ge x[0] then begin mid=0L & goto, skip1
            endif
            while z gt x[low] do low = low / 2
        endif
; Here we know that (u[i] = z), and z LE x[low], and z GT x[high].
        while  high-low gt 1L do begin ;Binary subdivision loop
            mid = (low + high)/2L
            if z le x[mid] then low = mid $
            else high = mid
        endwhile
        mid = low
;        if z gt x[low] or z le x[low+1] then stop, 'screw-up'
skip1:  r[i] = v[mid] + (z-x[mid]) * (v[mid+1]-v[mid])/(x[mid+1]-x[mid])
    endfor
endelse

return, r
end
