; Imports need to be in module
IncludeFile "TextEnDe.pb" ; TextEncodeDecoder
UseModule TextEnDe
IncludeFile "FileUtil.pb"
UseModule FileUtil


; DLL Load Const
DeclareModule td
  
  Global.i lib
  
  Declare.i CreateClientID();
  Declare.i Send(client_id.i, request.s);
  Declare.s Receive(timeout.i)          ;
  Declare.s Execute(request.s)          ;
  
EndDeclareModule

Module td
  
  ; Library name
  #TDJSON_lib = "tdjson";
  
  ; Library 
  Global lib_path.s = #TDJSON_lib
  Global lib_postfix.s = ""
  
  ; Cross Platform Lib
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    lib_postfix = ".dll"
  CompilerEndIf
  
  
  ; Loads the DLL
  ; A global lib instance
  ; (not using Protected instance as
  ; it can be used only For Procedure
  Global.i lib
  
  Procedure Init()
    ; Check if postfix present
    If lib_postfix
      lib_path = lib_path + lib_postfix
    EndIf
    ; Check if the lib exists and load
    ; Else Load Normal Lib
    If FileUtil::Exists(lib_path)
      lib = OpenLibrary(#PB_Any, lib_path);
      If lib
        Debug "[td] init..."
        Debug "[td] IMPORTANT: Dont close the library, the function addresses will NULL"
      Else
        DebuggerError("[td] Unable to load dll: " + lib_path)
      EndIf
    Else
      DebuggerError("[td] File not found: " + lib_path)
    EndIf
  EndProcedure
  
  
  ; Wrappers for the function Calls
  Procedure.i CreateClientID()
    ProcedureReturn CallFunction(lib, "td_create_client_id");
  EndProcedure
  
  Procedure.i Send(client_id.i, request.s)
    request_send.s = TextEnDe::TextEncode(request);
    ProcedureReturn CallFunction(lib, "td_send", client_id, @request_send.s);
  EndProcedure
  
  Procedure.s Receive(timeout.i)
    rc = CallFunction(lib, "td_receive", timeout);
    If rc
      r.s = TextEnDe::TextDecodePeek(rc)             ;
      ProcedureReturn r.s                            ;
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
  
  Procedure.s Execute(request.s)
    rc.s = TextEnDe::TextEncode(request);
    r.s = TextEnDe::TextDecodePeek(CallFunction(lib, "td_execute", @rc.s));
    ProcedureReturn r.s                                                   ;
  EndProcedure
  
  
  ; Load the DLL when module is load
  Init()
  
EndModule


; IDE Options = PureBasic 6.00 LTS (Windows - x64)
; CursorPosition = 86
; FirstLine = 60
; Folding = --
; EnableXP
; DPIAware
; Compiler = PureBasic 6.00 LTS (Windows - x64)