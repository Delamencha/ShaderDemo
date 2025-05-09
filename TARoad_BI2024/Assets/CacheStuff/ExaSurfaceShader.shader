Shader "Custom/ExaSurfaceShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Smoothness("Smoothness", Range(0,1)) = 0
        _Metallic("Metallic", Range(0,1)) = 0
        [HDR] _Emission("Emission", Color) = (0,0,0,1)

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Geometry"}

        CGPROGRAM

        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;
        fixed4 _Color;
        half _Smoothness;
        half _Metallic;
        half3 _Emission;

        struct Input{
            float2 uv_MainTex;
        };


        void surf (Input i, inout SurfaceOutputStandard o)
        {

            fixed4 col = tex2D (_MainTex, i.uv_MainTex) ;
            col *= _Color;
            o.Albedo = col.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;
            o.Emission = _Emission;
        }
        ENDCG
    }
    FallBack "Standard"
}
