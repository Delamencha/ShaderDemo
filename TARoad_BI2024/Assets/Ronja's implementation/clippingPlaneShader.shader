Shader "Custom/clippingPlaneShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Smoothness ("Smoothness", Range(0,1)) = 0
        _Metallic ("Metallic", Range(0,1)) = 0.0
        [HDR]_Emission ("Emission", color) = (0,0,0)

        [HDR]_CutoffColor ("Cutoff Color", color) = (1,0,0,0)
        _Plane ("Clipping Plane", Vector) = (0, 1, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"  "Queue" = "Geometry"}
        
        Cull Off

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        fixed4 _Color;

        half _Smoothness;
        half _Metallic;
        half3 _Emission;

        float4 _Plane;

        float4 _CutoffColor;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
            float facing : VFACE; // 正面 +1 反面 -1
        };



        void surf (Input i, inout SurfaceOutputStandard o)
        {
            float distance = dot(i.worldPos, _Plane.xyz);
            distance = distance + _Plane.w;

            clip(-distance);

            float facing = i.facing * 0.5 + 0.5;

            fixed4 col = tex2D(_MainTex, i.uv_MainTex);
            col *= _Color;
            o.Albedo = col.rgb * facing;
            o.Metallic = _Metallic * facing;
            o.Smoothness = _Smoothness * facing;
            o.Emission = lerp(_CutoffColor, _Emission, facing);
        }
        ENDCG
    }
    FallBack "Standard"
}
