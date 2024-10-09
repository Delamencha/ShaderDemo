Shader "Unlit/myHealthBarShader_3"
{
    Properties{
        _HealthyColor("healthBar Color", Color) = (1,1,1,1)
        _DangerColor("danger Color", Color) = (1,1,1,1)
        _Health("health point", Range(0.0, 1.0)) = 1.0

    }
    SubShader{
        Tags{"RenderType" = "Transparent" "Queue" = "Transparent"}

        Pass{

            ZWrite Off

            //src * srcAlpha + dst * (1 - srcAlpha) 类lerp
            //src 当前shader的output dst 当前储存在frame buffer中的颜色
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            fixed _Health;
            fixed4 _HealthyColor;
            fixed4 _DangerColor;

            struct a2v {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };
            
            struct v2f{
                float4 pos : SV_POSITION; 
                float2 uv : TEXCOORD0;
            };

            v2f vert(a2v v){
                v2f o;
                o.pos =  UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy;
                return o;
            } 

            fixed InverseLerp (fixed a, fixed b, fixed v){
                return (v - a)/(b - a);
            }

            fixed4 frag(v2f i) : SV_Target{
                
                //clip(_Health - i.uv.x);
                fixed healthBarMask = _Health > i.uv.x;
                fixed healthValue = saturate(InverseLerp(0.2, 0.8, _Health)); 
                fixed3 healthBarColor = lerp(_DangerColor.xyz, _HealthyColor.xyz, healthValue);

                return fixed4(healthBarColor * healthBarMask, healthBarMask);
                
            }



            ENDCG
        }
    }
}
