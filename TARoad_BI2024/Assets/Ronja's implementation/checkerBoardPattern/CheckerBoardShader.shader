Shader "Unlit/CheckerBoardShader"
{
    Properties
    {
       _Scale ("Pattern Size", Range(0, 10)) = 1
       _EvenColor ("Color 1", Color) = (0, 0, 0, 1)
       _OddColor ("Color 2", Color) = (1, 1, 1 ,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Geometry"}

        Pass
        {
            CGPROGRAM
            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

            float _Scale;

            float4 _EvenColor;
            float4 _OddColor;
            

            struct a2v
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                float4 worldPos : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (a2v v)
            {
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);


                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 adjustedWorldPos = floor(i.worldPos.xyz / (_Scale/10));

                float chessboard = adjustedWorldPos.x + adjustedWorldPos.y + adjustedWorldPos.z;

                // float adjustedWorldPos = floor(i.worldPos.x / (_Scale/10));

                // float chessboard = adjustedWorldPos;

                chessboard = frac(chessboard * 0.5);
                chessboard *= 2;

                float4 color = lerp(_EvenColor, _OddColor, chessboard);

                return color;
            }

            ENDCG
        }
    }
    FallBack "Standard"
}
