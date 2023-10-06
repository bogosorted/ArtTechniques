Shader "bogoSorted/BasicLightModel"
{
    Properties
    {
        _AmbientLight ("AmbientLight", Color) = (1,1,1,1)     
        [Header(Specular Settings)]
        [Space(10)]   
        _Smoothness ("_Smoothness", Range(0.5, 1)) = 0.8
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 viewDir : TEXCOORD2;
                float4 normal : NORMAL;
                
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 normal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _AmbientLight;
            float4 _MainTex_ST;
            float _Smoothness;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = normalize(mul(unity_ObjectToWorld, float4(v.normal.xyz, 0))); 
                
                o.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                float diffuse = max(0, dot(i.normal, _WorldSpaceLightPos0));

                float3 halfVector = normalize(_WorldSpaceLightPos0 + i.viewDir);
                float specular = pow(max(0, dot(i.normal, halfVector)), _Smoothness * 100);
    
                fixed4 col = _AmbientLight * 0.1 + (diffuse + specular);
                return col;
            }
            ENDCG
        }
    }
}
