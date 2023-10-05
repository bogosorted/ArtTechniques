Shader "bogoSorted/SmokeBezierMeshCurve"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _Color("Main Color", Color) = (1,1,1,1)
        _Fade ("_Fade", Range(0,1)) = 0.0
        _StartPos("_StartPos", Vector) = (1,1,1,1)
        _FinalPos("_FinalPos", Vector) = (1,1,1,1)
        _P0("_P0", Vector) = (1,1,1,1)
        _P1("_P1", Vector) = (1,1,1,1)


    }
    Subshader{
        Tags {"Queue" = "Transparent"  "RenderType" = "Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask RGB
        Pass{
            Cull OFF

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            uniform half4 _MainTex_ST;
            uniform half4 _Color;
            
            uniform half _Fade;
            
            uniform half4 _StartPos;
            uniform half4 _FinalPos;
            uniform half4 _P0;
            uniform half4 _P1;
            
            static const float CENTER = 0.5;
            static const float HALFPI = 1.57079632679;
            
           

            struct vertexInput
            {
                float4 vertex : POSITION;
                float4 textcoord : TEXCOORD0;
            };
            struct vertexOutput
            {
                float4 pos : SV_POSITION;
                float4 tex : TEXCOORD0; 
            };
            
            float random ( float2 _st) {
                return frac(sin(dot(_st.xy,float2(11.9898,78.233))) * 43758.5453123);
            }
            float noise (float2 _st) {
                float2 i = floor(_st);
                float2 f = frac(_st);

                float a = random(i);
                float b = random(i + float2(1.0, 0.0));
                float c = random(i + float2(0.0, 1.0));
                float d = random(i + float2(1.0, 1.0));

                float2 u = f * f * (3.0 - 2.0 * f);

                return lerp(a, b, u.x) +
                        (c - a)* u.y * (1.0 - u.x) +
                        (d - b) * u.x * u.y;
            }
            #define NUM_OCTAVES 5
            float fbm ( float2 _st) {
                float v = 0.0;
                float a = 0.5;
                float2 shift = float2(3.0,5.0);
                for (int i = 0; i < NUM_OCTAVES; ++i) {
                    v += a * noise(_st);
                    _st =  _st * 2.0 + shift  ;
                    a *= 0.5;
                }
                return v;
            }
        float3 smoke(float2 st){
                st *= 1.5;
                float3 color = float3(0.0,0.0,0.0);

                float2 q = float2(0.,0.);
                q.x = fbm(st) + cos(_Time.y)/42.;
                q.y = fbm(st + float2(1.0,1.0));

                float2 r = float2(0.,0.);
                r.x = fbm( st + 1.0*q + float2(1.7,9.2)+ 0.15 +_Time.y/5.);
                r.y = fbm( st + 1.0*q + float2(4.3,2.8)+ 0.126) - _Time.y/4.;

                float f = fbm(st+r);

                 color = lerp(float3(0.2235, 0.9608, 0.0),
                float3(0.1529, 1.0, 0.0392),
                clamp((f*f)*4.0,0.0,1.0));

                color = lerp(color,
                            float3(0.9882, 0.0, 0.0),
                            clamp(length(q),0.0,1.0));

                color = lerp(color,
                            float3(1.000,0.031,0.156),
                            clamp(length(r.x),0.0,1.0));
                float y = 1;
                float mask = smoothstep(0.4,1,abs(sin((st.x * 1.35) + 5.9)  ) *f* 3.) * step(st.y, 6.8888887 *(0.4 + distance(_FinalPos,_StartPos)/5)) + smoothstep(0.4,1,abs(sin((st.x/2 ))  ) *y* 3.)*step(6.888888 *(0.4 + distance(_FinalPos,_StartPos)/5),st.y );
                float3 result = clamp( float(f*f*f+.6*f*f+.5*f) , st.y - 2 - distance(_FinalPos,_StartPos)*1.48 , float(f*f*f+.6*f*f+.5*f) + distance(_FinalPos,_StartPos)/2 ) * color * mask * _Fade;

                return result;
                
            }
     
           vertexOutput vert(vertexInput v)
           {
                vertexOutput o;

                v.textcoord = v.vertex * float4(_MainTex_ST.xy,1 + _MainTex_ST.z,1) +float4(_MainTex_ST.zw,1,1);


                //_P0 = ((((_StartPos * 0.2) + (float4(1 * _FinalPos.x - _StartPos.x,5 * clamp(abs(_FinalPos.x - _StartPos.x)/3,0.2,1),1,1) * _FinalPos * 0.5) / 2)  + sin(_Time* abs(_P1)  + 4)))/12;
                //_P1 = (_FinalPos + normalize(_FinalPos - _StartPos) *- 1.5)  + sin(_Time* _P1  )/4; 

                //_P0 = lerp(_P0,lerp(_StartPos,_FinalPos, 0.2) + float4(sin(_Time.y)/6,0,0,0), abs(clamp(_FinalPos.x ,-3,3)/3) * -1 + 1);
                //_P1 = lerp(_P1,lerp(_StartPos,_FinalPos, 0.3) + float4(sin(_Time.y + 4)/6,0,0,0), abs(clamp(_FinalPos.x,-3,3)/3) * -1 + 1 );    

                float t = v.vertex.y;
                float4 A = lerp(_StartPos, _P0, t);
                float4 B = lerp(_P0, _P1, t);
                float4 C = lerp(_P1, _FinalPos, t);
                float4 D = lerp(A, B, t);
                float4 E = lerp(B, C, t);
                float4 P = lerp(D ,E, t);
                
                float4 normDir = normalize(E - D);
                float angle = (1 - dot(float4(0,1,0,0), normDir)) * -HALFPI;
                float cosAngle = cos(angle);
                float sinAngle = sin(angle);
                float3x3 rot = float3x3(cosAngle, -sinAngle, 0, sinAngle, cosAngle, 1, 0, 0, 1);

                v.vertex.x -= CENTER;
                
                float3 xPos = float3(v.vertex.x,0,0);
                float3 rotation = mul(rot,xPos);

                v.vertex.x = rotation.x + P.x ;
                v.vertex.y = rotation.y * (normDir.x >= 0 ? 1 : -1) + P.y;  
                v.vertex.z = abs(rotation.z) + abs(P.z)/30 - t/20;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.tex = v.textcoord;
                return o;
           }

           half4 frag(vertexOutput i) : SV_Target
           { 
              
                float3 oldCoord = i.tex; 
                fixed4 col = tex2D(_MainTex, i.tex/5) ;
                 
                _Color *= col;
                float3 smoke2 = (smoke(round(i.tex *float2(25,55*   (0.4 + distance(_FinalPos,_StartPos)/5)))/float2(25,55)) * oldCoord.y/3) * _Color;

                return float4(smoke2 ,clamp(length(smoke2) * 5.,0.0,1));
                //return float4(smoke2,1);
           }

            ENDCG
        }
    }
}