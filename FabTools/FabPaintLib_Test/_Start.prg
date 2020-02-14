USING VO

[STAThread] ;
FUNCTION Start() AS VOID
   LOCAL oApp AS XSharpApp

   TRY
      oApp := XSharpApp{}
      oApp:Start()
   CATCH e AS Exception
      ErrorBox{ NIL, e:ToString() }:Show()
   END TRY
   RETURN

