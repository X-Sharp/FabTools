USING VO

[STAThread] ;
FUNCTION Start() AS VOID
   LOCAL oApp AS MyStartApp

   TRY
      oApp := MyStartApp{}
      oApp:Start()
   CATCH e AS Exception
      ErrorBox{ NIL, e:ToString() }:Show()
   END TRY
   RETURN

