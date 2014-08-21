#include <a_samp>

#include "amx"
#include "phys_memory"

ToCharString(s[], size = sizeof(s)) {
	for (new i = 0; i < size; i++) {
		s[i] = swapchars(s[i]);
	}
}

main() {
	printf("AMX address: %x", GetAmxAddress());
	printf("AMX base address: %x", GetAmxBaseAddress());

	new s[24 char];
	new s2[24];

	ReadPhysMemory(0x004AB8CC, s);
	ToCharString(s);

	strunpack(s2, s);
	print(s2); // prints "SA-MP Dedicated Server" on SA-MP 0.3d R2
}
