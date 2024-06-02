#version 130

uniform int samplepos; // sample position of soundtrack

out vec4 outColour;

void main(){
	vec2 a = vec2(1920, 1080); // This must match XRES and YRES in main.zig
	vec2 v = gl_FragCoord.xy / a * 2. - 1.;
	v.x *= a.x / a.y; // Top is Y=1, bottom is Y=-1, square pixels

	outColour = vec4(0);
	float b = atan(v.y, v.x) / 3.1415927;
	float z = mod(1. - length(v) + b + float(samplepos) / 44100., 2.);
	outColour.rgb += z;
}