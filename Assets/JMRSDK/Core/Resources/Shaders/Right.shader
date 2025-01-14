﻿Shader "JMRSDK/Right" { // defines the name of the shader 
	Properties{
		_MainTex("_MainTex", 2D) = "black" {}
        distortionScale("distortionScale",Vector) = (0,0,0,0)
        distortionOffset("distortionOffset",Vector) = (0,0,0,0)
        ipdOffset("ipdOffset",Vector) = (0,0,0,0)
		screenResolution("screenResolution",Vector) = (1920,1080,0,0)
        rotationVector("rotationVector",Vector) = (0,0,0,0)
        screenratio("screenratio",Vector) = (0,0,0,0)
	}
		//the CG subshader
		SubShader{
		//only pass
		Pass{
		ZTest Always
		Cull Off
		ZWrite Off
		Fog{ Mode off }

		CGPROGRAM
        
#pragma vertex vert
#pragma fragment frag
#pragma target 3.0
#include "UnityCG.cginc"

	sampler2D _MainTex;
    fixed4 distortionScale;
    fixed4 distortionOffset;
    fixed4 ipdOffset;
	fixed4 screenResolution;
    fixed4 rotationVector;
    float4 screenratio;
    
	struct vertfrag {
		float4 position : POSITION;
		float4 worldpos : TEXCOORD1;
	};

	//passthrough vert shader (why even bother multiplying by mvp?)
	vertfrag vert(appdata_base v) {
		vertfrag o;
		o.position = UnityObjectToClipPos(v.vertex);
		o.worldpos = o.position; //because glsl is better
		return o;
	}
    
	float2 zkhao(float x, float x2, float x3, float x4, float y, float y2, float y3, float y4)
	{
				float a1;
				float a2;
				float a3;
				float a4;
				float a5;
				float a6;
				float a7;
				float a8;
				float a9;
				
				a1 = y;
				a2 = y2;
				a3 = y3;
				a4 = x;
				a5 = x*y;
				a6 = x*y2;
				a7 = x2;
				a8 = x2*y;
				a9 = x3;
                
			return float2(-138.44116248768688 +
					a1*(0.012142633490151211) +
					a2*(0.00023618053996354860) +
					a3*(-9.3986790128397502e-08) +
					a4*(1.3936390873011186) +
					a5*(-0.00025970278204490160) +
					a6*(-1.1013342138266324e-07) +
					a7*(-7.4773977178921314e-05) +
					a8*2.2305090330299038e-08 +
					a9 *(-4.2947178036101263e-09),
					51.729938775059708 +
					a1*(1.2152867043463178) +
					a2*(-0.00016311916418565442) +
					a3*(5.7313585155593927e-08) +
					a4*(-0.46775829625488352) +
					a5*(-0.00026124546700923013) +
					a6*(9.5823963375263332e-08) +
					a7* (0.00034681407062747693) +
					a8*(2.0896492108901654e-07) +
					a9*(1.2070308930134388e-07));
	}
			float2 getzkhaoDistortion(float2 smp) {
				float x = smp.x*screenResolution.x, y = smp.y*screenResolution.y, x2 = x*x,
					  y2 = y*y, x3 = x2*x, y3 = y2*y, x4 = x3*x, y4 = y3*y;
				float2	d1 = zkhao(x, x2, x3, x4, y, y2, y3, y4);		
				return float2(d1.x / screenResolution.x, d1.y / screenResolution.y);
			}
			
			fixed4 frag(vertfrag inp) : SV_Target{
				float2 smp = inp.worldpos.xy;
                
                float2 disp = smp*float2(distortionScale.x,distortionScale.y) + float2(0.5,0.5)+float2(distortionOffset.x, -distortionOffset.y);
                //fixed2 onePlusSize = float2(4.7716535,2.708661);
                //float2 newsize = float2(11.88,6.4);
            
                //float2 ratio = float2(newsize.x/onePlusSize.x,newsize.y/onePlusSize.y);
                float2 offset = float2(0,1-screenratio.y);
                disp = disp*screenratio + offset;
                //fixed2 onePlusSize = float2(4.795,2.708);
                //float2 newsize;
                //newsize.x = onePlusSize.x;
                //newsize.y = onePlusSize.y;
                
                //newsize.x = 4.64;  //Redmi 6 Pro
                //newsize.y = 2.46;  //Redmi 6 Pro
                ////newsize = newsize/2;
                                		
                //float2 ratio = float2(newsize.x/onePlusSize.x,newsize.y/onePlusSize.y);
                //float2 offset = float2(0,1-ratio.y);
                //disp = disp*ratio + offset;                            
                                                	
				disp.y = 1.0f - disp.y;					
				float2 disp1 = getzkhaoDistortion(disp);
                float2x2 rotationMatrix = float2x2(rotationVector.x, rotationVector.y, rotationVector.z, rotationVector.w);
                disp1-=0.5;
                disp1 = mul ( disp1, rotationMatrix );
                disp1+=0.5;
                if (disp1.x < 0 || disp1.x > 1.0 || disp1.y <0 || disp1.y > 1.0) 
                    return fixed4(0., 0., 0., 1.);
                disp1 = disp1+float2(-ipdOffset.x,ipdOffset.y);
				if (disp1.x < 0 || disp1.x > 1.0 || disp1.y < 0 || disp1.y > 1.0) return fixed4(0., 0., 0., 1.);
                
				return tex2D(_MainTex, disp1);
			}

			ENDCG
		}
	}
}