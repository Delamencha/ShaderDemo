Shader "Unlit/TriPlannarMappingShader"
{

    Properties{
        _Color ("Tint", Color) = (0, 0, 0, 1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _Sharpness("Blend sharpness", Range(1, 64)) = 1
    }

    SubShader{
        Tags{"RenderType" = "Opaque" "Queue" = "Geometry"}

        Pass{
            CGPROGRAM

            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _Color;
            float _Sharpness;

            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f{
                float4 position : SV_POSITION;
                float4 worldPos : TEXCOORD0;
                float3 normal : TEXCOORD1;
            };

            v2f vert(a2v v){

                v2f o;

                o.position = UnityObjectToClipPos(v.vertex);

                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                float3 worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

                o.normal = normalize(worldNormal);

                return o;

            }

            fixed4 frag(v2f i) : SV_TARGET{
                
                float2 uv_front = TRANSFORM_TEX(i.worldPos.xy, _MainTex);
                float2 uv_side = TRANSFORM_TEX(i.worldPos.zy, _MainTex);
                float2 uv_top = TRANSFORM_TEX(i.worldPos.xz, _MainTex);

                fixed4 col_front = tex2D(_MainTex, uv_front);
                fixed4 col_side = tex2D(_MainTex, uv_side);
                fixed4 col_top = tex2D(_MainTex, uv_top);

                float3 weights = i.normal;

                weights = abs(weights);

                weights = pow(weights, _Sharpness);

                weights = weights / (weights.x + weights.y + weights.z);

                col_front *= weights.z;
                col_side *= weights.x;
                col_top *= weights.y;

                fixed4 col = col_front + col_side + col_top;

                col *= _Color;

                return col;

            }


            ENDCG
        }
    }

   FallBack "Standard"
}
