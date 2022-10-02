; Text Encoding Decoding Library
; Author: CypherpunkSamurai

; Usage:
;   IncludeFile "TextEnDe.pb" ; TextEncodeDecoder
;   
;   text.s = TextEnDe::TextEncode("text to encode");

DeclareModule TextEnDe
  
  ; Exposed DLL Functions
  Declare.s TextEncode(text.s)
  
  Declare.s TextDecode(text.s)
  Declare.s TextDecodePeek(pointer)
  
EndDeclareModule



Module TextEnDe
  
  
  ; Text Encode Decode Functions
  
  Procedure.s TextEncode(text.s)
    ; Encode Readable code to bytes
    ; Convert UTF8 to Unicode
    *_utf8 = UTF8(text);
    ProcedureReturn PeekS(*_utf8, -1, #PB_Unicode);
  EndProcedure
  
  
  
  Procedure.s TextDecode(text.s)
    ; Encode bytes to readable code
    ; Convert Unicode to UTF-8
    ProcedureReturn PeekS(@text, -1, #PB_UTF8);
  EndProcedure
  
  Procedure.s TextDecodePeek(pointer)
    ; Encode bytes to code
    ProcedureReturn PeekS(pointer, -1, #PB_UTF8)
  EndProcedure
  
  
  
EndModule
; IDE Options = PureBasic 6.00 LTS (Windows - x64)
; CursorPosition = 42
; FirstLine = 10
; Folding = -
; EnableXP
; DPIAware
; Compiler = PureBasic 6.00 LTS (Windows - x64)