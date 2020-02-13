[STAThread] ;
FUNCTION Start() AS VOID
   LOCAL oApp AS VulcanApp

   TRY
      oApp := VulcanApp{}
      oApp:Start()
   CATCH e AS Exception
      ErrorBox{ NIL, e:ToString() }:Show()
   END TRY
   RETURN

