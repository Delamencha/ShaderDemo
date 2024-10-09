Shader "Unlit/MyLighting"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Gloss ("Gloss", Range(0,1)) = 1

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Geometry"}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float4 wPos : TEXCOORD2;
                
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Gloss;
            

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.wPos = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //difuuse,Lambert
                float3 N = normalize(i.normal);
                float3 L = _WorldSpaceLightPos0.xyz;
                float3 Lambert = saturate(dot(N,L));
                float3 Albedo = float3(1,1,1);
                float3 diffuseLight = Albedo * Lambert *_LightColor0.xyz;

                //specualr,Blinn-Phong
                float3 V = normalize(_WorldSpaceCameraPos - i.wPos);
                float3 H = normalize(L + V);
                float3 specularLight = saturate(dot(H, N)) *(Lambert > 0);
                //_Gloss remapping
                float specualrExponent = exp2(_Gloss *11) + 2;
                specularLight = _LightColor0.xyz * pow(specularLight, specualrExponent); //* _Gloss;

                //fresnel effect 
                // float fresnel = (1-dot(V, N)) * (cos(_Time.y * 3) * 0.4 + 0.4);
                // fresnel = pow(fresnel, 2);

                return fixed4(diffuseLight + specularLight , 1);
            }
            ENDCG
        }
    }
}
