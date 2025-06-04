Shader "Custom/FresnelSurfaceShader"
{
    Properties
    {
        _Color("Tint", Color) = (0, 0, 0, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _Smoothness ("Smoothness", Range(0, 1)) = 0
        _Metallic ("Metalness", Range(0, 1)) = 0
        [HDR] _Emission ("Emission", Color)  = (0, 0, 0)

        _FresnelColor ("Fresnel Color", Color) = (1, 1, 1, 1)   
        [PowerSlider(4)] _FresnelExponent ("Fresnel Exponent", Range(0.25, 4)) = 1     
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Geometry"}


        CGPROGRAM

        #pragma surface surf Standard fullforwardshadows

        #pragma target 3.0

        sampler2D _MainTex;
        //float4 _MainTex_ST;
        float4 _Color;
        half _Smoothness;
        half _Metallic;
        half3 _Emission;
        float4 _FresnelColor;
        float _FresnelExponent;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldNormal;
            float3 viewDir;
            INTERNAL_DATA
        };


        void surf (Input i, inout SurfaceOutputStandard o)
        {
            fixed4 col = tex2D(_MainTex, i.uv_MainTex);
            col *= _Color;
            o.Albedo = col.rgb;

            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;

            float fresnel = dot(i.worldNormal, i.viewDir);

            fresnel = saturate(1 - fresnel);

            fresnel = pow(fresnel, _FresnelExponent);

            float3 fresnelColor = fresnel * _FresnelColor;

            o.Emission = _Emission + fresnelColor;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
