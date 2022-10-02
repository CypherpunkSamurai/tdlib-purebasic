; Import from .td/
IncludePath "td"
IncludeFile "td.pb"
UseModule td

; Globals
Global.s r.s, w.s ; For reading and writing json
#LOG = "[test] "
#API_ID = 
#API_HASH = ""
#NAME = "KanjiTek"
#ID = test

Procedure.i JSON_HasKey(response.s, string.s)
  j = ParseJSON(#PB_Any, response)
  If GetJSONMember(JSONValue(j), string)
    ProcedureReturn 1
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

Procedure.s JSON_ReadString(response.s, string.s)
  j = ParseJSON(#PB_Any, response)
  If Not j
    DebuggerError("Invalid JSON")
  EndIf
  ; Check if the string is present
  type = GetJSONMember(JSONValue(j), string)
  If Not type
    DebuggerError("The JSON Key is not present")
  Else
    ProcedureReturn GetJSONString(type)
  EndIf
EndProcedure

Procedure.s ReadAuthState(response.s)
  j = ParseJSON(#PB_Any, response)
  If Not j
    DebuggerError("Invalid JSON")
  EndIf
  ; Check if the string is present
  auth = GetJSONMember(JSONValue(j), "authorization_state")
  If Not auth 
    DebuggerError("The JSON Key is not present")
  Else
    ProcedureReturn GetJSONString(GetJSONMember(auth, "@type"))
  EndIf
EndProcedure



; Message Updates Parser


Procedure.i ReadMessageChatID(response.s)
  j = ParseJSON(#PB_Any, response)
  If Not j
    DebuggerError("Invalid JSON")
  EndIf
  ; Check if the string is present
  auth = GetJSONMember(JSONValue(j), "message")
  If Not auth 
    DebuggerError("The JSON Key is not present")
  Else
    ProcedureReturn GetJSONInteger(GetJSONMember(auth, "chat_id"))
  EndIf
EndProcedure


Procedure.s ReadMessageText(response.s)
  j = ParseJSON(#PB_Any, response)
  If Not j
    DebuggerError("Invalid JSON")
  EndIf
  ; Check if the string is present
  m = GetJSONMember(JSONValue(j), "message")
  If Not m
    DebuggerError("The JSON Key is not present")
  Else
    text = GetJSONMember(GetJSONMember(m, "content"), "text")
    If text
      ProcedureReturn GetJSONString(GetJSONMember(text, "text"))
    EndIf
    
  EndIf
EndProcedure






client_id = td::CreateClientID()
Debug #LOG + "Client ID: " + client_id

td::Execute(ReplaceString("{'@type': 'setLogVerbosityLevel', 'new_verbosity_level': 1, '@extra': 1.01234}", "'", ~"\""))


w.s =  ReplaceString("{'@type': 'getAuthorizationState', '@extra': 1.01234}",  "'", ~"\"")
td::Send(client_id, w)





While 1
  
  
  r.s = td::Receive(15)
  
  
  If r.s
;         Debug #LOG + "LOG: " + r.s
    
    If JSON_HasKey(r.s, "@type")
      
      Select JSON_ReadString(r.s, "@type")
          
          
          ; ####################################################################
          
          
        Case "updateAuthorizationState"
          Debug #LOG + "Authenticating..."
          
          
          ; Auth
          
          state.s =  ReadAuthState(r.s)
          Select state
              
            Case  "authorizationStateWaitTdlibParameters"
              
              Debug #LOG + "Add parameters.."
              
              parameters.s = "{ 'database_directory': 'tdlib', 'use_message_database': true, 'use_secret_chats': true, 'api_id': " + #API_ID + ", 'api_hash': '" + #API_HASH + "', 'system_language_code': 'en','device_model': '" + #NAME + "', 'application_version': '1.0','system_version': '1.0.0','use_file_database':	true, 'use_chat_info_database': true,'enable_storage_optimizer': true }";
              w = "{'@type': 'setTdlibParameters', 'parameters': " + parameters + "}"
              w = ReplaceString(w, "'", ~"\"")
              td::Send(client_id, w)
              
            Case "authorizationStateWaitEncryptionKey"
              Debug #LOG + "Encryption Key Request..."
              Debug #LOG + "Generate Random..."
              w = "{'@type': 'checkDatabaseEncryptionKey', 'encryption_key': 'randomencryption'}"
              w = ReplaceString(w, "'", ~"\"")
              td::Send(client_id, w)
              
            Case "authorizationStateWaitPhoneNumber"
              Debug #LOG + "Phone Number Request..."
              Debug #LOG + "Opening Console..."
              If OpenConsole(#NAME + " Console")
                Print("Enter Phone Number: ");
                phone.s = Input()
                If phone
                  w = "{'@type': 'setAuthenticationPhoneNumber', 'phone_number': '" + phone + "'}";
                  w = ReplaceString(w, "'", ~"\"")                                                ;
                  td::Send(client_id, w)                                                          ;
                  CloseConsole()                                                                  ;
                Else
                  Print("Phone number not provided...");
                  End 1                                ;
                EndIf
              EndIf
              
            Case "authorizationStateWaitCode"
              Debug #LOG + "OTP Code Request..."
              Debug #LOG + "Opening Console..."
              If OpenConsole(#NAME + " Console")
                Print("Enter Code: ");
                code.s = Input()
                If code
                  w = "{'@type': 'checkAuthenticationCode', 'code': '" + code + "'}";
                  w = ReplaceString(w, "'", ~"\"")                                  ;
                  td::Send(client_id, w)                                            ;
                  CloseConsole()                                                    ;
                Else
                  Print("Code not provided...");
                  End 1                        ;
                EndIf
              EndIf
              
            Case "authorizationStateWaitPassword"
              Debug #LOG + "Enter Password Request..."
              Debug #LOG + "Opening Console..."
              If OpenConsole(#NAME + " Console")
                Print("Enter Password: ");
                passwd.s = Input()
                If passwd
                  w = ~"{ \"@type\": \"checkAuthenticationPassword\", \"password\": \"" + passwd + ~"\"}"
                  td::Send(client_id, w);
                  CloseConsole()        ;
                Else
                  Print("Code not provided...");
                  End 1                        ;
                EndIf
              EndIf
              
            Case "authorizationStateReady"
              Debug #LOG + "Auth Complete...!"
              
            Case "authorizationStateClosed"
              Debug #LOG + "Auth State Closed..."
              Debug #LOG + "Please Fix Errors"
              
            Default
              Debug #LOG + "Unknown Auth State: " + state
              ; Auth Handler
          EndSelect
          
          
          
          
          ; ####################################################################          
          
          
        Case "ok"
          Debug #LOG + "Running...."
          
          
          ; Updates Handlers
        Case "updateNewMessage"
          chat_id = ReadMessageChatID(r)
          ;           Debug #LOG + "New Message from CHAT_ID: " + chat_id
          
          
          If chat_id = - ; test chat
            
            Debug r.s
            Debug "m: " + ReadMessageText(r.s)
            
            If ReadMessageText(r.s) = "+v"
              
              msg = CreateJSON(#PB_Any)
              ;
              _msg = SetJSONObject(JSONValue(msg))
              SetJSONString(AddJSONMember(_msg, "@type"), "sendMessage")
              SetJSONInteger(AddJSONMember(_msg, "chat_id"), chat_id)
              SetJSONNull(AddJSONMember(_msg, "message_thread_id"))
              SetJSONNull(AddJSONMember(_msg, "options"))
              SetJSONNull(AddJSONMember(_msg, "reply_markup"))
              ;             
              _content = SetJSONObject(AddJSONMember(_msg, "input_message_content"))
              
              SetJSONString(AddJSONMember(_content, "@type"), "inputMessageText") ; always use input + capital + text
              _text = SetJSONObject(AddJSONMember(_content, "text"))
              SetJSONString(AddJSONMember(_text, "@type"), "formattedText")
              SetJSONString(AddJSONMember(_text, "text"), "+ " + #NAME + " v1.0\nPureBasic Version: `6.00 LTS`\nSystem: Windows")
              SetJSONArray(AddJSONMember(_text, "entities"))
              
              Debug ComposeJSON(msg)
              
              td::Send(client_id, ComposeJSON(msg))
            EndIf
          EndIf
          
        Default
          
      EndSelect
      
      
    EndIf
  EndIf
Wend

; IDE Options = PureBasic 6.00 LTS (Windows - x64)
; CursorPosition = 264
; FirstLine = 232
; Folding = -
; EnableXP
; DPIAware
; Compiler = PureBasic 6.00 LTS (Windows - x64)