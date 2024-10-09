Shader "Unlit/MyLighting_Multi"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [NoScaleOffset]_NormalMap ("normal map", 2D) = "bump" {}
        [NoScaleOffset]_HeightMap ("height map", 2D) = "bump" {}
        _Gloss ("Gloss", Range(0,1)) = 1
        _Color ("tint color", Color) = (1,1,1,1)
        _AmbientLight ("ambient light", Color) = (0,0,0,0)
        _Bump ("bump", Range(0,1)) = 1
        _HeightIntensity ("height intensity", Range(0,1)) = 0
        [NoScaleOffset]_DiffuseIBL ("diffuse IBL", 2D) = "black" {}
        [NoScaleOffset]_SpecularIBL ("specular IBL", 2D) = "black" {}
        _SpeculatIBLIntensity ("speculatIBL intensity", Range(0,1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Geometry"}

        //Base pass
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define IS_IN_BASE_PASS
            #include "MyLightingInc.cginc"

            ENDCG
        }

        //Add pass
        Pass
        {
            Tags {"LightMode" = "ForwardAdd"}
            Blend One One // src * 1 + dst *1
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd //让unity区分不同light source
            #include "MyLightingInc.cginc"

            ENDCG
        }
    }
}

