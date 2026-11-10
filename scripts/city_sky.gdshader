shader_type sky;
render_mode disable_fog;
uniform float clock_minutes = 720.0;
uniform float daylight = 1.0;
uniform float twilight = 0.0;
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453); }
float noise(vec2 p) {
 vec2 i=floor(p), f=fract(p); f=f*f*(3.0-2.0*f);
 return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);
}
void sky() {
 float up=clamp(EYEDIR.y,0.0,1.0);
 vec3 zenith=mix(vec3(0.008,0.015,0.045),vec3(0.12,0.38,0.68),daylight);
 vec3 horizon=mix(vec3(0.035,0.055,0.10),vec3(0.68,0.79,0.85),daylight);
 horizon=mix(horizon,vec3(0.76,0.35,0.18),twilight*0.7);
 vec3 col=mix(horizon,zenith,pow(up,0.45));
 vec2 stars=SKY_COORDS*vec2(900.0,450.0);
 float star=step(0.994,hash(floor(stars)))*(1.0-smoothstep(0.06,0.34,length(fract(stars)-0.5)));
 col+=vec3(0.75,0.85,1.0)*star*(1.0-daylight)*smoothstep(0.02,0.15,up);
 vec2 p=EYEDIR.xz/max(0.15,up)*1.3 + vec2(clock_minutes*0.002,clock_minutes*0.0006);
 float clouds=noise(p)*0.55+noise(p*2.03)*0.27+noise(p*4.07)*0.13+noise(p*8.1)*0.05;
 float cover=smoothstep(0.48,0.72,clouds)*smoothstep(0.0,0.12,up);
 vec3 cloud_color=mix(vec3(0.07,0.09,0.14),vec3(0.91,0.91,0.87),daylight);
 col=mix(col,cloud_color,cover*0.85);
 float angle=(clock_minutes/1440.0-0.25)*TAU;
 vec3 sun_dir=normalize(vec3(cos(angle),sin(angle),0.3));
 float sun=smoothstep(0.9993,0.9997,dot(EYEDIR,sun_dir));
 col+=sun*vec3(1.0,0.85,0.55)*daylight;
 COLOR=col;
}
