PRO plothistminmax, arr, xhist,yhist, BIN=bin,  MIN=min, MAX=max, $
              NOPLOT=NoPlot, OVERPLOT=Overplot, $
              PSYM = psym, Peak=Peak, Fill=Fill, FCOLOR=Fcolor, FLINE=FLINE, $
              FSPACING=Fspacing, FPATTERN=Fpattern, $
              FORIENTATION=Forientation, $
              ANONYMOUS_ = dummy_, norm = norm, $
              aspect=aspect, $
              reverse_indices=reverse_indices, $
              _EXTRA = _extra
;+
; NAME:
;      PLOTHIST
; PURPOSE:
;      Plot the histogram of an array with the corresponding abcissa.
;
; CALLING SEQUENCE:
;      plothist, arr, xhist, yhist, [, BIN=, /FILL, /NOPLOT, /OVERPLOT, PEAK=,
;                norm=, aspect=, reverse_indices=, 
;                ...plotting keywords]
; INPUTS:
;      arr - The array to plot the histogram of.   It can include negative
;            values, but non-integral values will be truncated.              
;
; OPTIONAL OUTPUTS:
;      xhist - X vector used in making the plot  
;              ( = lindgen( N_elements(h)) * bin + min(arr) + bin/2)
;      yhist - Y vector used in making the plot  (= histogram(arr/bin))
;
; OPTIONAL INPUT KEYWORDS:
;      BIN -  The size of each bin of the histogram,  scalar (not necessarily
;             integral).  If not present (or zero), the bin size is set to 1.
;      MIN - The minimum value in arr to consider
;      MAX - The maximum value in arr to consider. Can save much memory in sparse
;            arrays.
;      /NOPLOT - If set, will not plot the result.  Useful if intention is to
;             only get the xhist and yhist outputs.
;      /OVERPLOT - If set, will overplot the data on the current plot.  User
;            must take care that only keywords valid for OPLOT are used.
;      PEAK - if non-zero, then the entire histogram is normalized to have
;             a maximum value equal to the value in PEAK.  If PEAK is
;             negative, the histogram is inverted.
;      /FILL - if set, will plot a filled (rather than line) histogram.
;
; The following keywords take effect only if the FILL keyword is set:
;      FCOLOR - color to use for filling the histogram
;      /FLINE - if set, will use lines rather than solid color for fill (see
;              the LINE_FILL keyword in the POLYFILL routine)
;      FORIENTATION - angle of lines for fill (see the ORIENTATION keyword
;              in the POLYFILL routine)
;      FPATTERN - the pattern to use for the fill (see the PATTERN keyword
;              in the POLYFILL routine)
;      FSPACING - the spacing of the lines to use in the fill (see the SPACING
;              keyword in the POLYFILL routine)
;
; Any input keyword that can be supplied to the PLOT procedure (e.g. XRANGE,
;    LINESTYLE) can also be supplied to PLOTHIST.
;
; EXAMPLE:
;       Create a vector of random 1000 values derived from a Gaussian of mean 0,
;       and sigma of 1.    Plot the histogram of these values with a bin
;       size of 0.1
;
;       IDL> a = randomn(seed,1000)
;       IDL> plothist,a, bin = 0.1
;
; MODIFICATION HISTORY:
;        Written     W. Landsman            January, 1991
;        Add inherited keywords W. Landsman        March, 1994
;        Use ROUND instead of NINT  W. Landsman   August, 1995
;        Add NoPlot and Overplot keywords.   J.Wm.Parker  July, 1997
;        Add Peak keyword.   J.Wm.Parker  Jan, 1998
;        Add FILL,FCOLOR,FLINE,FPATTERN,FSPACING keywords. J.Wm.Parker Jan, 1998
;        Converted to IDL V5.0   W. Landsman 21-Jan-1998
;        Allowed min/max to be sent. Erin Scott Sheldon UofMich Jun-07-2001
;        Added /norm keyword Erin Scott Sheldon UChicago 17-Oct-2002
;        Now uses bin centers rather than the leading edge of the bin.
;                    Erin Scott Sheldon UChicago 25-Nov-2003
;-
;                       Check parameters.
  On_error,2

  if N_params() LT 1 then begin   
      print, 'Syntax - plothist, arr, [xhist,yhist, ' + $
        'BIN=, PEAK=, /NOPLOT,/OVERPLOT, /FILL, FCOLOR=, FLINE=, ' + $
        'FORIENTATION=, FPATTERN=, FSPACING=, '+$
        'norm=, aspect=, reverse_indices=,   ...plot_keywords]'
      return
  endif

  if N_elements( arr ) LT 2 then message, $
    'ERROR - Input array must contain at least 2 elements'
  arrmin = min( arr, MAX = arrmax)
  if ( arrmin EQ arrmax ) then message, $
    'ERROR - Input array must contain distinct values'

  if not keyword_set(BIN) then bin = 1. else bin = float(abs(bin))
  IF n_elements(max) EQ 0 THEN max=max(arr)
  IF n_elements(min) EQ 0 THEN min=min(arr)

; Compute the histogram and abcissa.

; y = round( ( arr / bin))
; yhist = histogram( y )

  ;; Allow min/max to be sent. This can save memory
  yhist = histogram(arr, bin=bin, min=min, max=max, $
                    reverse_indices=reverse_indices)
  N_hist = N_elements( yhist )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Should use the middle of the bin, not the lower end!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; xhist = lindgen( N_hist ) * bin + min
  xhist = lindgen( N_hist ) * bin + min + bin/2.0

;;;
;   If renormalizing the peak, do so.
;
  if keyword_set(Peak) then yhist = yhist * (Peak / float(max(yhist)))

;IF n_elements(norm) NE 0 THEN BEGIN
;    toty = total(yhist*bin)
;    yhist = yhist/toty
;ENDIF 

  IF keyword_set(norm) THEN BEGIN
      toty = total(yhist*bin)
      yhist = yhist/toty

      IF norm[0] NE 1 THEN yhist=yhist*norm
  ENDIF 

;;;
;   If not doing a plot, exit here.
;
  if keyword_set(NoPlot) then return

  if not keyword_set(PSYM) then psym = 10 ;Default histogram plotting

  if keyword_set(Overplot) then begin
      oplot, [xhist[0] - bin, xhist, xhist[n_hist-1]+ bin] , [0,yhist,0],  $ 
        PSYM = psym, _EXTRA = _extra 
  endif else begin
      if not keyword_set(XRANGE) then xrange = [ xhist[0] ,xhist[N_hist-1] ]

      IF n_elements(aspect) NE 0 THEN BEGIN 
           aplot, aspect, $
            [xhist[0] - bin, xhist, xhist[n_hist-1]+ bin] , [0,yhist,0],  $ 
            PSYM = psym, _EXTRA = _extra
      ENDIF ELSE BEGIN 
          plot, $
            [xhist[0] - bin, xhist, xhist[n_hist-1]+ bin] , [0,yhist,0],  $ 
            PSYM = psym, _EXTRA = _extra
      ENDELSE 
  endelse

;;;
;   If doing a fill of the histogram, then go for it.
;
  if keyword_set(Fill) then begin
      Xfill = transpose([[Xhist-bin/2.0],[Xhist+bin/2.0]])
      Xfill = reform(Xfill, n_elements(Xfill))
      Xfill = [Xfill[0], Xfill, Xfill[n_elements(Xfill)-1]]
      Yfill = transpose([[Yhist],[Yhist]])
      Yfill = reform(Yfill, n_elements(Yfill))
      Yfill = [0, Yfill, 0]

      if keyword_set(Fcolor) then Fc = Fcolor else Fc = !P.Color
      if keyword_set(Fline) then begin
          if keyword_set(Fspacing) then Fs = Fspacing else Fs = 0
          if keyword_set(Forientation) then Fo = Forientation else Fo = 0
          polyfill, Xfill,Yfill, color=Fc, /line_fill, spacing=Fs, orient=Fo
      endif else begin
          if keyword_set(Fpattern) then begin
              polyfill, Xfill,Yfill, color=Fc, pattern=Fpattern
          endif else begin
              polyfill, Xfill,Yfill, color=Fc
          endelse
      endelse

;;;
;   Because the POLYFILL can erase/overwrite parts of the originally plotted
; histogram, we need to replot it here.
;
      oplot, [xhist[0] - bin, xhist, xhist[n_hist-1]+ bin] , [0,yhist,0],  $ 
        PSYM = psym, _EXTRA = _extra
  endif


  return
end
