﻿BEGIN NAMESPACE NewVZip
    #using System
    
    /// <summary>
    ///   A strongly-typed resource class, for looking up localized strings, etc.
    /// </summary>
    // This class was auto-generated by the StronglyTypedResourceBuilder
    // class via a tool like ResGen or Visual Studio.
    // To add or remove a member, edit your .ResX file then rerun ResGen
    // with the /str option, or rebuild your VS project.
    [global::System.CodeDom.Compiler.GeneratedCodeAttribute("System.Resources.Tools.StronglyTypedResourceBuilder", "2.0.0.0")] ;
    [global::System.Diagnostics.DebuggerNonUserCodeAttribute()] ;
    [global::System.Runtime.CompilerServices.CompilerGeneratedAttribute()] ;
    INTERNAL CLASS Form1
        
        STATIC PRIVATE resourceMan AS global::System.Resources.ResourceManager
        STATIC PRIVATE resourceCulture AS global::System.Globalization.CultureInfo
        [global::System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1811:AvoidUncalledPrivateCode")] ;
        INTERNAL CONSTRUCTOR()
            RETURN
        
        /// <summary>
        ///   Returns the cached ResourceManager instance used by this class.
        /// </summary>
        INTERNAL STATIC ACCESS ResourceManager() AS global::System.Resources.ResourceManager
            IF System.Object.ReferenceEquals(resourceMan, NULL)
                LOCAL temp := global::System.Resources.ResourceManager{"NewVZip.Form1", typeof(Form1):Assembly} AS global::System.Resources.ResourceManager
                resourceMan := temp
            ENDIF
            RETURN resourceMan
        
        /// <summary>
        ///   Overrides the current thread's CurrentUICulture property for all
        ///   resource lookups using this strongly typed resource class.
        /// </summary>
        INTERNAL STATIC ACCESS Culture() AS global::System.Globalization.CultureInfo
            RETURN resourceCulture
        INTERNAL STATIC ASSIGN Culture( value AS global::System.Globalization.CultureInfo )
            resourceCulture := value
        
        INTERNAL STATIC ACCESS ribbonButton5_Image() AS System.Drawing.Bitmap
            LOCAL obj := ResourceManager:GetObject("ribbonButton5.Image", resourceCulture) AS System.Object
            RETURN ((System.Drawing.Bitmap)(obj))
        
        INTERNAL STATIC ACCESS ribbonButton5_SmallImage() AS System.Drawing.Bitmap
            LOCAL obj := ResourceManager:GetObject("ribbonButton5.SmallImage", resourceCulture) AS System.Object
            RETURN ((System.Drawing.Bitmap)(obj))
        
        INTERNAL STATIC ACCESS ribbonOrbMenuItem1_Image() AS System.Drawing.Bitmap
            LOCAL obj := ResourceManager:GetObject("ribbonOrbMenuItem1.Image", resourceCulture) AS System.Object
            RETURN ((System.Drawing.Bitmap)(obj))
        
        INTERNAL STATIC ACCESS ribbonOrbMenuItem1_SmallImage() AS System.Drawing.Bitmap
            LOCAL obj := ResourceManager:GetObject("ribbonOrbMenuItem1.SmallImage", resourceCulture) AS System.Object
            RETURN ((System.Drawing.Bitmap)(obj))
        
        INTERNAL STATIC ACCESS ribbonOrbMenuItem2_Image() AS System.Drawing.Bitmap
            LOCAL obj := ResourceManager:GetObject("ribbonOrbMenuItem2.Image", resourceCulture) AS System.Object
            RETURN ((System.Drawing.Bitmap)(obj))
        
        INTERNAL STATIC ACCESS ribbonOrbMenuItem2_SmallImage() AS System.Drawing.Bitmap
            LOCAL obj := ResourceManager:GetObject("ribbonOrbMenuItem2.SmallImage", resourceCulture) AS System.Object
            RETURN ((System.Drawing.Bitmap)(obj))
        
        INTERNAL STATIC ACCESS ribbonOrbOptionButton1_Image() AS System.Drawing.Bitmap
            LOCAL obj := ResourceManager:GetObject("ribbonOrbOptionButton1.Image", resourceCulture) AS System.Object
            RETURN ((System.Drawing.Bitmap)(obj))
        
        INTERNAL STATIC ACCESS ribbonOrbOptionButton1_SmallImage() AS System.Drawing.Bitmap
            LOCAL obj := ResourceManager:GetObject("ribbonOrbOptionButton1.SmallImage", resourceCulture) AS System.Object
            RETURN ((System.Drawing.Bitmap)(obj))
    
    END CLASS
END NAMESPACE
