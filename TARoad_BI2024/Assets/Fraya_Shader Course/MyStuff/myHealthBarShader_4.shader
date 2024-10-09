Shader "Unlit/myHealthBarShader_4"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        _Health ("Health Point", Range(0.0, 1.0)) = 1.0
        _BorderSize ("Border Size", Range(0.0, 0.5)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent"}

        Pass{
        ZWrite Off

        Blend SrcAlpha OneMinusSrcAlpha
        
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            fixed _Health;
            fixed _BorderSize;
            sampler2D _MainTex;

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
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target{
                
                //先变化uv
                float2 coords = i.uv;
                coords.x *= 8;
                //再与每个点映射到需要比对距离的目标的点计算距离
                float sdf = distance(coords, float2(clamp(coords.x, 0.5, 7.5) , 0.5));
                sdf = 2 * sdf - 1;
                //裁剪
                clip(-sdf);
                //加边界
                float borderSdf = sdf + _BorderSize;
                //常规做法
                //fixed borderMask = step(0, -borderSdf);
                //用偏导对sdf单位化做法
                float pd = fwidth(borderSdf);
                float borderMask = 1-saturate(borderSdf/pd);


                fixed healthbarMask = i.uv < _Health;

                fixed3 healthBarColor = tex2D(_MainTex, float2(_Health, i.uv.y));

                if(_Health < 0.2){
                    fixed flash = cos(_Time.y * 5) * 0.4 + 1;
                    healthBarColor *=  flash;
                }
               

                return fixed4(healthBarColor * healthbarMask * borderMask,1);
            }


            ENDCG
        }
    }
}
