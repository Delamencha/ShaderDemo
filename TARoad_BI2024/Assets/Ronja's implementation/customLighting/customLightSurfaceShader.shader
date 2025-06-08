Shader "Custom/customLightSurfaceShader"
{
    Properties
    {
        _Color ("Tint", Color) = (0, 0, 0, 1)
        _MainTex ("Texture", 2D) = "white" {}
        [HDR] _Emission ("Emission", color) = (0,0,0)

        _Ramp("Toon Ramp", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Geometry"}

        CGPROGRAM

        #pragma surface surf Custom fullforwardshadows
        #pragma target 3.0


        sampler2D _MainTex;
        fixed4 _Color;
        half3 _Emission;

        sampler2D _Ramp;

        float4 LightingCustom(SurfaceOutput s, float3 lightDir, float atten){
            float towardsLight = dot(s.Normal, lightDir);
            towardsLight = towardsLight * 0.5 + 0.5;

            float3 lightIntensity = tex2D(_Ramp, towardsLight).rgb;

            float4 col;
            col.rgb = lightIntensity * s.Albedo * atten * _LightColor0.rgb;

            col.a = s.Alpha;

            return col;
        }

        struct Input
        {
            float2 uv_MainTex;
        };




        void surf (Input i, inout SurfaceOutput o)
        {
            fixed4 col = tex2D(_MainTex, i.uv_MainTex);
            col *= _Color;
            o.Albedo = col.rgb;
        }
        ENDCG
    }
    FallBack "Standard"
}
