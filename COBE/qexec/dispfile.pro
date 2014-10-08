  PRO DispFile, Filename
;+
;   Description
;   -----------
;   DispFile displays the document file specified in the input variable
;   FileName using the WEX system routine Action.
;
;   Calling Sequence:
;
;      DispFile, Filename
;
;   where,
;
;      Filename - is an input string variable containing the document's
;                 file name.
;
;#
;   Called by
;   ---------
;   Action
;
;   Routines Called
;   ---------------
;   TScroll
;
;   History
;   -------
;   Created by C. Groden,  Universities Space Research Association,  Jan 1993
;
;.Title
;   Procedure DispFile
;-
;
  ON_ERROR, 2    ; Return to called on error
;
@wexcntrl.inc
;
  GET_LUN, unit
  OPENR, unit, Filename
  Line = ' '
  READF, unit, Line
  Text = Line
;
  WHILE (NOT EOF(unit)) DO BEGIN
	READF, unit, Line 
	Text = [ Text, Line ]
  ENDWHILE
;
; Display text using TSCROLL
;
  TSCROLL, Text, Title = Filename, Quit = TQuit
  IF (TQuit) then CollapseWEX = 'Quit'
  Return
  End
;DISCLAIMER:
;
;This software was written at the Cosmology Data Analysis Center in
;support of the Cosmic Background Explorer (COBE) Project under NASA
;contract number NAS5-30750.
;
;This software may be used, copied, modified or redistributed so long
;as it is not sold and this disclaimer is distributed along with the
;software.  If you modify the software please indicate your
;modifications in a prominent place in the source code.  
;
;All routines are provided "as is" without any express or implied
;warranties whatsoever.  All routines are distributed without guarantee
;of support.  If errors are found in this code it is requested that you
;contact us by sending email to the address below to report the errors
;but we make no claims regarding timely fixes.  This software has been 
;used for analysis of COBE data but has not been validated and has not 
;been used to create validated data sets of any type.
;
;Please send bug reports to CGIS@ZWICKY.GSFC.NASA.GOV.


