Shader "Unlit/MySkybox"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 viewDir : TEXCOORD0;
            };

            struct v2f
            {
                float3 viewDir : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            #define TAU 6.28318530718

            float2 DirToRectilinear(float3 dir){

                float x = atan2(dir.z, dir.x); //-tau/2 - tau/2
                x = x / TAU + 0.5; // 0 - 1 
                float y = dir.y * 0.5 + 0.5;
                return float2(x, y);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.viewDir = v.viewDir; 
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float2 uv = DirToRectilinear(i.viewDir);
                fixed3 col = tex2Dlod(_MainTex, float4(uv, 0, 0)).xyz;

                return float4(col, 1);
            }
            ENDCG
        }
    }
}
