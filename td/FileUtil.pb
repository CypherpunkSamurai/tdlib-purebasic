; File Utils Module
; Author: CypherpunkSamurai

; Usage:
;   IncludeFile "FileUtil.pb" ; FileUtil
;   
;   if FileUtil::TextEncode("< file path >");



DeclareModule FileUtil
  
  Global.s Seperator
  
  ; Exported Functions
  Declare.i Exists(path.s)
  
EndDeclareModule



Module FileUtil
  
  Global.s Seperator = ""
  
  ; Check if the file exists
  Procedure.i Exists(path.s)
    ; Check if file size is -1
    If FileSize(path) = -1
      ProcedureReturn 0
    EndIf
    ; File was found
    ProcedureReturn 1
  EndProcedure
  
  ; Cross Platform Constants
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Seperator = "\"
  CompilerElse 
    Seperator = "/"
  CompilerEndIf
  
EndModule
; IDE Options = PureBasic 6.00 LTS (Windows - x64)
; CursorPosition = 37
; FirstLine = 8
; Folding = -
; EnableXP
; DPIAware
; Compiler = PureBasic 6.00 LTS (Windows - x64)