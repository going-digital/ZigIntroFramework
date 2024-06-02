#version 130

uniform int samplepos; // sample position of soundtrack
out vec4 outColour;

float scene(vec3 p){
  return -.428
    + .322*length(p-vec3(.64,-.44,.35))
    - .359*length(p-vec3(.0,-.02,.29))
    + .285*length(p-vec3(.53,-.45,-.63))
    + .231*length(p-vec3(.44,.01,-.54))
    + .187*length(p-vec3(.44,.0,-.54))
    - .832*length(p-vec3(.10,-.05,-.79))
    + .255*length(p-vec3(.37,-.30,-.52))
    + .066*length(p-vec3(.04,-.08,-.07))
    - .417*length(p-vec3(.41,-.15,.12))
    + .159*length(p-vec3(-.59,.07,.0))
    + .658*length(p-vec3(-.25,-.40,.46))
    - .158*length(p-vec3(.44,-.16,-.31))
    + .245*length(p-vec3(.07,-.04,-.14))
    + .158*length(p-vec3(.08,.36,.24))
    + .579*length(p-vec3(-.67,-.27,.45))
    - .246*length(p-vec3(.38,-.69,-.37))
    - .403*length(p-vec3(-.25,-.31,-.36))
    - .27*length(p-vec3(-.27,-.55,.18))
    + .42*length(p-vec3(.40,-.44,.20))
    + .152*length(p-vec3(.06,-.05,-.13))
    + .255*length(p-vec3(.46,.43,.48))
    - .183*length(p-vec3(-.21,-.14,.33))
    - .174*length(p-vec3(.37,-.14,.18))
    + .403*length(p-vec3(-.21,-.11,-.54))
    + .152*length(p-vec3(-.35,-.01,-.08))
    + .283*length(p-vec3(-.17,-.48,-.10))
    + .503*length(p-vec3(-.01,-.41,-.58))
    - .29*length(p-vec3(-.49,-.01,.28))
    - .362*length(p-vec3(.20,.01,.44))
    + .32*length(p-vec3(-.01,-.12,.49))
    - .342*length(p-vec3(-.7,.12,.31))
    + .257*length(p-vec3(.28,-.32,.42))
    + .229*length(p-vec3(.13,.69,-.41))
    + .232*length(p-vec3(.44,.04,-.11))
    - .425*length(p-vec3(.07,.23,.52))
    - .285*length(p-vec3(-.28,-.32,.17))
    + .09*length(p-vec3(.05,-.07,-.09))
    + .063*length(p-vec3(.03,.27,.18))
    + .259*length(p-vec3(.13,.69,-.41))
    - .272*length(p-vec3(.47,-.19,-.32))
    - .287*length(p-vec3(-.64,-.26,.06))
    - .31*length(p-vec3(-.03,.51,.62))
    + .193*length(p-vec3(.06,-.05,-.12))
    + .304*length(p-vec3(.37,-.3,-.52))
    - .394*length(p-vec3(-.23,-.75,.34))
    + .189*length(p-vec3(.07,-.04,-.14))
    - .516*length(p-vec3(.03,-.4,.73))
    - .503*length(p-vec3(-.35,-.13,.71))
    - .386*length(p-vec3(-.25,-.22,.71))
    - .258*length(p-vec3(.78,-.4,-.24))
    - .457*length(p-vec3(-.33,-.06,.33))
    - .394*length(p-vec3(.19,-.07,.34))
    - .358*length(p-vec3(-.22,-.13,.34))
    - .358*length(p-vec3(.13,-.52,-.38))
    + .212*length(p-vec3(-.0,.32,.19))
    + .661*length(p-vec3(-.05,-.05,.56))
    + .843*length(p-vec3(-.17,.06,.61))
    + .022*length(p-vec3(.03,-.05,-.05))
    - .401*length(p-vec3(-.27,-.21,-.33))
    + .245*length(p-vec3(.2,.18,.22))
    + .742*length(p-vec3(-.26,.18,.76))
    - .139*length(p-vec3(.44,-.15,-.31))
    - .336*length(p-vec3(.45,.22,.67))
    + .147*length(p-vec3(.34,.21,.34))
    - .285*length(p-vec3(.66,-.07,.35))
    - .232*length(p-vec3(-.83,-.56,-.20))
    + .535*length(p-vec3(-.40,-.37,.53))
    + .094*length(p-vec3(.05,-.09,-.07))
    - .381*length(p-vec3(-.30,-.15,.59))
    + .313*length(p-vec3(-.38,-.24,-.67))
    - .291*length(p-vec3(-.18,.29,.37))
    + .621*length(p-vec3(-.47,-.37,.65))
    + .325*length(p-vec3(.13,-.40,-.10))
    - .179*length(p-vec3(-.98,.70,.22))
    - .271*length(p-vec3(.45,-.17,-.31))
    - .16*length(p-vec3(.85,.99,-.29))
    + .155*length(p-vec3(-.56,-.04,-.05))
    + .455*length(p-vec3(.16,-.45,.36));
}

#define rot(a) mat2(cos(a+vec4(0,11,33,0)))
void main()
{
	vec2 a = vec2(1920, 1080); // This must match XRES and YRES in main.zig
	vec2 v = gl_FragCoord.xy / a * 2. - 1.;
	v.x *= a.x / a.y; // Top is Y=1, bottom is Y=-1, square pixels
    vec3 D = normalize(vec3(1.5,v)), p = vec3(-3,0,0);
    float y = .5, z = samplepos*.00003, l = 0., d = l;
    D.xz *= rot(y); D.xy *= rot(z);
    p.xz *= rot(y); p.xy *= rot(z);
    bool hit = false;
    for (int i = 0; i < 150 && d < 5. && !hit; i++)
        d = scene(p),
        hit = d < 1e-3,
        p += d*D,
        l += d;
    vec3 e = vec3(.01,0,0), n = normalize(scene(p) - vec3(scene(p-e),scene(p-e.yxy),scene(p-e.yyx)));
    outColour.xyz = hit ? .2*max(0.,n.z)+.8*reflect(D,n).xzy : D.xzy;
}