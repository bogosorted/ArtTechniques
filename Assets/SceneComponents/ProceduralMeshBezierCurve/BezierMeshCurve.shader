Shader "Shaders/BezierMeshCurve"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _Color("Main Color", Color) = (1,1,1,1)

        _StartPos("_StartPos", Vector) = (1,1,1,1)
        _FinalPos("_FinalPos", Vector) = (1,1,1,1)
        _P0("_P0", Vector) = (1,1,1,1)
        _P1("_P1", Vector) = (1,1,1,1)


    }
    Subshader{

        Tags {"Queue" = "Transparent"  "RenderType" = "Transparent"}

        Pass{
            Cull OFF

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            uniform half4 _MainTex_ST;
            uniform half4 _Color;

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

           vertexOutput vert(vertexInput v)
           {
                vertexOutput o;

                v.textcoord = v.vertex * float4(_MainTex_ST.xy,1 + _MainTex_ST.z,1) +float4(_MainTex_ST.zw,1,1);

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

                v.vertex.x = rotation.x + P.x;
                v.vertex.y = rotation.y + P.y;
                v.vertex.z = rotation.z + P.z;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.tex = v.textcoord;
                return o;
           }

           half4 frag(vertexOutput i) : SV_Target
           { 
                fixed4 col = tex2D(_MainTex, i.tex);
                _Color *= col;
                return _Color;
           }

            ENDCG
        }
    }
}