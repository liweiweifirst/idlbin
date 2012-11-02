;+
; NAME:
;       SLICE_ND
;
; PURPOSE:
;
;       Slice an arbitrarily sized array along an arbitrary dimension.
;
; CALLING SEQUENCE:
;
;       slice=slice_nd(array,slice_dimension,slice_plane)
;
; INPUTS:
;
;       array: An array of at least 2 dimensions from which to extract
;          a slice.
;
;       dimension: The (zero offset) dimension to fix when taking the
;       slice (0= take columns, 1= row, 2=cube planes, etc.).
;
;       slice_plane: The plane to take (0 .. size of slice dimension - 1).
;
; OUTPUTS:
;
;       slice: A slice extracted from ARRAY.
;
; EXAMPLE:
;       
;       a=randomu(sd,5,4,3,2)
;       slice=slice_nd(a,2,2)
;
; MODIFICATION HISTORY:
;
;       Sat Apr 12 13:37:16 2008, J.D. Smith
;
;		Written.
;
;-
;##############################################################################
;
; LICENSE
;
;  Copyright (C) 2008 J.D. Smith
;
;  This file is free software; you can redistribute it and/or modify
;  it under the terms of the GNU General Public License as published
;  by the Free Software Foundation; either version 2, or (at your
;  option) any later version.
;
;  This file is distributed in the hope that it will be useful, but
;  WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;  General Public License for more details.
;
;  You should have received a copy of the GNU General Public License
;  along with this file; see the file COPYING.  If not, write to the
;  Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;  Boston, MA 02110-1301, USA.
;
;##############################################################################

function slice_nd, array, dim, slice
  s=size(array,/DIMENSIONS)
  ns=n_elements(s)
  take=dim eq 0?1:product(s[0:dim-1],/PRESERVE_TYPE)
  skip=take*s[dim]
  t=[take,dim eq ns-1?1:product(s[dim+1:ns-1],/PRESERVE_TYPE)]
  s[dim]=1
  ind=reform(slice*take + $
             rebin(lindgen(t[0]),t,/SAMPLE)+ $
             skip*rebin(lindgen(1,t[1]),t,/SAMPLE),s)
  return,array[ind]
end
