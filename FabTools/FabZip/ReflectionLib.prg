// ReflectionLib.prg
#using System.Reflection

BEGIN NAMESPACE FabZip
	
	CLASS ReflectionLib
		
		STATIC METHOD InvokeMethod( Owner as Object, MethodName as String, Parameters as Object[] ) AS VOID
			LOCAL FormType as System.Type
			LOCAL MethodToInvoke as MethodInfo
			//
			if ( Owner != NULL )
				// Retrieve Type
				FormType := Owner:GetType()
				// Lookup for method
				MethodToInvoke := FormType:GetMethod( MethodName )
				If ( MethodToInvoke != NULL )
					// Then, execute the call
					MethodToInvoke:Invoke( Owner, Parameters )
				ENDIF
			ENDIF      
			RETURN   
			
		STATIC METHOD InvokeMethod( Owner as Object, MethodName as String ) AS VOID
			LOCAL FormType as System.Type
			LOCAL MethodToInvoke as MethodInfo
			//
			if ( Owner != NULL )
				// Retrieve Type
				FormType := Owner:GetType()
				// Lookup for method
				MethodToInvoke := FormType:GetMethod( MethodName )
				If ( MethodToInvoke != NULL )
					// Then, execute the call
					MethodToInvoke:Invoke( Owner, Null )
				ENDIF
			ENDIF      
			RETURN 
			
	END CLASS
	
END NAMESPACE // FabZip
