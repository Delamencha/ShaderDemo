            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            #define USE_LIGHTING


            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT; //w 表示tangent sign 用于标识是否需要翻转
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 tangent : TEXCOORD2;
                float3 bitangent : TEXCOORD3;
                float4 wPos : TEXCOORD4;
                LIGHTING_COORDS(5,6)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            sampler2D _HeightMap;
            float _Gloss;
            float4 _Color;
            float _Bump;
            float _HeightIntensity;
            float4 _AmbientLight;
            sampler2D _DiffuseIBL;
            sampler2D _SpecularIBL;
            float _SpeculatIBLIntensity;

            #define TAU 6.28318530718
            
            float2 Rotate(float2 v, float angRad){
                float ca = cos(angRad);
                float sa = sin(angRad);
                return float2(ca * v.x - sa * v.y, ca * v.y + sa * v.x );
            }

            float2 DirToRectilinear(float3 dir){

                float x = atan2(dir.z, dir.x); //-tau/2 - tau/2
                x = x / TAU + 0.5; // 0 - 1 
                float y = dir.y * 0.5 + 0.5;
                return float2(x, y);
            }

            v2f vert (a2v v)
            {
                v2f o;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //o.uv = Rotate(o.uv - 0.5, _Time.y * 0.2) + 0.5;
                float heightValue = tex2Dlod(_HeightMap, float4(o.uv, 0, 0)).x * 2 - 1;
                v.vertex.xyz +=  v.normal * heightValue * _HeightIntensity;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = UnityObjectToWorldDir(v.tangent.xyz);
                o.bitangent = cross(o.normal, o.tangent);
                o.bitangent *= (v.tangent.w * unity_WorldTransformParams.w); //确保uv的翻转以及unity的tilling正确
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                TRANSFER_VERTEX_TO_FRAGMENT(o); //lighting
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 Albedo = tex2D(_MainTex, i.uv).rgb;
                float3 surfaceColor = Albedo * _Color.rgb;
                
                float3 tangentSpaceNormal = UnpackNormal(tex2D(_NormalMap, i.uv));
                tangentSpaceNormal = normalize(lerp(float3(0,0,1), tangentSpaceNormal, _Bump));
                float3x3 MTxTanToWorld = {i.tangent.x, i.bitangent.x, i.normal.x,
                            i.tangent.y, i.bitangent.y, i.normal.y,
                            i.tangent.z, i.bitangent.z, i.normal.z
                            };
                float3 N = mul(MTxTanToWorld, tangentSpaceNormal) ;

                #ifdef USE_LIGHTING
                    //difuuse,Lambert
                    //float3 N = normalize(i.normal); //被法线贴图的值替代
                    float3 L = normalize(UnityWorldSpaceLightDir(i.wPos)); //unity区分了不同light source 对应方向或坐标
                    float attenuation = LIGHT_ATTENUATION(i);  //会用到LIGHTING_COORDS(3,4) 中定义的插值寄存器
                                                            //attenuation 计算时会考虑dirctional light 和 point light 的区别
                    float3 Lambert = saturate(dot(N,L));
                    float3 diffuseLight = (Lambert * attenuation) *_LightColor0.xyz;

                    //specualr,Blinn-Phong
                    float3 V = normalize(_WorldSpaceCameraPos - i.wPos);
                    float3 H = normalize(L + V);
                    float3 specularLight = saturate(dot(H, N)) *(Lambert > 0);
                    //_Gloss remapping
                    float specualrExponent = exp2(_Gloss *11) + 2;
                    specularLight = _LightColor0.xyz * pow(specularLight, specualrExponent) * attenuation *_Gloss; //* _Gloss;

                    #ifdef IS_IN_BASE_PASS
                        float3 DiffuseIBL = tex2Dlod(_DiffuseIBL, float4(DirToRectilinear(N), 0, 0)).xyz;

                        float fresnel = pow((1- saturate(dot(V, N))), 5);
                        float3 reledctDir = reflect(-V, N);
                        float mip = (1 - _Gloss) * 6;
                        float3 SpecularIBL = tex2Dlod(_SpecularIBL, float4(DirToRectilinear(reledctDir), mip , mip )).xyz;
                        diffuseLight += DiffuseIBL ;
                        specularLight += SpecularIBL * _SpeculatIBLIntensity * fresnel;
                        //return float4(SpecularIBL, 1);
                    #endif


                    //fresnel effect 
                    // float fresnel = (1-dot(V, N)) * (cos(_Time.y * 3) * 0.4 + 0.4);
                    // fresnel = pow(fresnel, 2);

                    return fixed4(diffuseLight * surfaceColor + specularLight , 1);
                #else
                    #ifdef IS_IN_BASE_PASS
                    return surfaceColor;
                    #else 
                    return 0;
                    #endif
                #endif


            }

