;+
; NAME:
;       UNDEFINE
;
; PURPOSE:
;       The purpose of this program is to delete or undefine
;       an IDL program variable from within an IDL program or
;       at the IDL command line. It is a more powerful DELVAR.
;
; AUTHOR:
;       FANNING SOFTWARE CONSULTING
;       David Fanning, Ph.D.
;       1642 Sheely Drive
;       Fort Collins, CO 80526 USA
;       Phone: 970-221-0438
;       E-mail: davidf@dfanning.com
;       Coyote's Guide to IDL Programming: http://www.dfanning.com
;
; CATEGORY:
;       Utilities.
;
; CALLING SEQUENCE:
;       UNDEFINE, variable
;
; REQUIRED INPUTS:
;       variable: The variable to be deleted. Up to 10 variables may be specified as arguments.
;
; SIDE EFFECTS:
;       The variable no longer exists.
;
; EXAMPLE:
;       To delete the variable "info", type:
;
;        IDL> Undefine, info
;
; MODIFICATION HISTORY:
;       Written by David W. Fanning, 8 June 97, from an original program
;       given to me by Andrew Cool, DSTO, Adelaide, Australia.
;       Simplified program so you can pass it an undefined variable. :-) 17 May 2000. DWF
;       Simplified it even more by removing the unnecessary SIZE function. 28 June 2002. DWF.
;       Added capability to delete up to 10 variables at suggestion of Craig Markwardt. 10 Jan 2008. DWF.
;       If the variable is a pointer or object reference the pointer is freed or the object is destroyed
;          before the varaiable is undefined. 8 June 2009. DWF.
;-
;******************************************************************************************;
;  Copyright (c) 2008 - 2009, by Fanning Software Consulting, Inc.                         ;
;  All rights reserved.                                                                    ;
;                                                                                          ;
;  Redistribution and use in source and binary forms, with or without                      ;
;  modification, are permitted provided that the following conditions are met:             ;
;                                                                                          ;
;      * Redistributions of source code must retain the above copyright                    ;
;        notice, this list of conditions and the following disclaimer.                     ;
;      * Redistributions in binary form must reproduce the above copyright                 ;
;        notice, this list of conditions and the following disclaimer in the               ;
;        documentation and/or other materials provided with the distribution.              ;
;      * Neither the name of Fanning Software Consulting, Inc. nor the names of its        ;
;        contributors may be used to endorse or promote products derived from this         ;
;        software without specific prior written permission.                               ;
;                                                                                          ;
;  THIS SOFTWARE IS PROVIDED BY FANNING SOFTWARE CONSULTING, INC. ''AS IS'' AND ANY        ;
;  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES    ;
;  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT     ;
;  SHALL FANNING SOFTWARE CONSULTING, INC. BE LIABLE FOR ANY DIRECT, INDIRECT,             ;
;  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED    ;
;  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;         ;
;  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND             ;
;  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT              ;
;  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS           ;
;  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                            ;
;******************************************************************************************;
PRO UNDEFINE, var0, var1, var2, var3, var4, var5, var6, var7, var8, var9
   
   IF N_Elements(var0) NE 0 THEN BEGIN
        dataType = Size(var0, /TNAME)
        IF dataType EQ 'POINTER' THEN Ptr_Free, var0
        IF dataType EQ 'OBJREF' THEN Obj_Destroy, var0
        var0 = 0
        dummy = Temporary(var0)
   ENDIF

   IF N_Elements(var1) NE 0 THEN BEGIN
        dataType = Size(var1, /TNAME)
        IF dataType EQ 'POINTER' THEN Ptr_Free, var1
        IF dataType EQ 'OBJREF' THEN Obj_Destroy, var1
        var1 = 0
        dummy = Temporary(var1)
   ENDIF

   IF N_Elements(var2) NE 0 THEN BEGIN
        dataType = Size(var2, /TNAME)
        IF dataType EQ 'POINTER' THEN Ptr_Free, var2
        IF dataType EQ 'OBJREF' THEN Obj_Destroy, var2
        var2 = 0
        dummy = Temporary(var2)
   ENDIF

   IF N_Elements(var3) NE 0 THEN BEGIN
        dataType = Size(var3, /TNAME)
        IF dataType EQ 'POINTER' THEN Ptr_Free, var3
        IF dataType EQ 'OBJREF' THEN Obj_Destroy, var3
        var3 = 0
        dummy = Temporary(var3)
   ENDIF

   IF N_Elements(var4) NE 0 THEN BEGIN
        dataType = Size(var4, /TNAME)
        IF dataType EQ 'POINTER' THEN Ptr_Free, var4
        IF dataType EQ 'OBJREF' THEN Obj_Destroy, var4
        var4 = 0
        dummy = Temporary(var4)
   ENDIF

   IF N_Elements(var5) NE 0 THEN BEGIN
        dataType = Size(var5, /TNAME)
        IF dataType EQ 'POINTER' THEN Ptr_Free, var5
        IF dataType EQ 'OBJREF' THEN Obj_Destroy, var5
        var5 = 0
        dummy = Temporary(var5)
   ENDIF

   IF N_Elements(var6) NE 0 THEN BEGIN
        dataType = Size(var6, /TNAME)
        IF dataType EQ 'POINTER' THEN Ptr_Free, var6
        IF dataType EQ 'OBJREF' THEN Obj_Destroy, var6
        var6 = 0
        dummy = Temporary(var6)
   ENDIF

   IF N_Elements(var7) NE 0 THEN BEGIN
        dataType = Size(var7, /TNAME)
        IF dataType EQ 'POINTER' THEN Ptr_Free, var7
        IF dataType EQ 'OBJREF' THEN Obj_Destroy, var7
        var7 = 0
        dummy = Temporary(var7)
   ENDIF

   IF N_Elements(var8) NE 0 THEN BEGIN
        dataType = Size(var8, /TNAME)
        IF dataType EQ 'POINTER' THEN Ptr_Free, var8
        IF dataType EQ 'OBJREF' THEN Obj_Destroy, var8
        var8 = 0
        dummy = Temporary(var8)
   ENDIF

   IF N_Elements(var9) NE 0 THEN BEGIN
        dataType = Size(var9, /TNAME)
        IF dataType EQ 'POINTER' THEN Ptr_Free, var9
        IF dataType EQ 'OBJREF' THEN Obj_Destroy, var9
        var9 = 0
        dummy = Temporary(var9)
   ENDIF


END