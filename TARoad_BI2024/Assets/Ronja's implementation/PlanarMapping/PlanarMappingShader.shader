Shader "Unlit/PlanarMappingShader"
{
    Properties{
        _Color("Tint", Color) = (0,0,0,1)
        _MainTex("Main Texture", 2D) = "white" {}
    }
    SubShader{
        Tags{ "RenderType" = "Opaque" "Queue" = "Geometry"}

        Pass{
            CGPROGRAM

                #include "UnityCG.cginc"

                #pragma vertex vert
                #pragma fragment frag

                sampler2D _MainTex;
                float4 _MainTex_ST;

                float4 _Color;

                struct a2v {
                    float4 vertex : POSITION;
                };

                struct v2f {
                    float4 position : SV_POSITION;
                    float2 uv : TEXCOORD0;
                    float4 wPos : TEXCOORD1;
                };

                v2f vert(a2v v){
                    v2f o;

                    o.position = UnityObjectToClipPos(v.vertex);
                    
                    o.wPos = mul(unity_ObjectToWorld, v.vertex);

                    //o.uv = TRANSFORM_TEX(v.vertex.xz, _MainTex);
                    o.uv = TRANSFORM_TEX(o.wPos.xz, _MainTex);

                    return o;
                }

                fixed4 frag(v2f i) : SV_TARGET{

                    fixed4 col = tex2D(_MainTex, i.uv);

                    //fixed4 col = fixed4(i.uv, 0, 1);
                    
                    //fixed4 col = fixed4(i.wPos.xxx , 1);

                    //fixed4 col = tex2D(_MainTex, i.wPos.xz);

                    col *= _Color;

                    return col;
                }

            ENDCG
        }
    }
    Fallback "Standard"
}
