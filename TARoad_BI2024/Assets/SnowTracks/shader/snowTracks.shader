Shader "Unlit/snowTracks"
{
    Properties
    {
        _SurfaceTex ("Surface Texture", 2D) = "white" {}
        [NoScaleOffset]_BottomTex ("Bottom Texture", 2D) = "white" {}
        [NoScaleOffset]_HeightMap ("Height Map", 2D) = "black" {}
        _SnowHeight ("snow height", Range(0.01, 0.1)) = 0.05
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

            struct a2v
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                half heightValue : TEXCOORD2;
            };

            sampler2D _SurfaceTex;
            float4 _SurfaceTex_ST;
            sampler2D _BottomTex;
            sampler2D _HeightMap;
            float _SnowHeight;

            v2f vert (a2v v)
            {
                v2f o;
                //1.using height map, offset vertex  
                half heightValue = tex2Dlod(_HeightMap, float4(v.uv, 0, 0)).r;
                v.vertex.xyz -= (heightValue ) * _SnowHeight * v.normal;
                o.heightValue = heightValue;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _SurfaceTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                
                fixed4 surfCol = tex2D(_SurfaceTex, i.uv);
                fixed4 botCol = tex2D(_BottomTex, i.uv);
                //2.using height map, blend between surface & ground
                fixed4 finalCol = lerp(surfCol, botCol, i.heightValue);

                return finalCol;
            }
            ENDCG
        }
    }
}
