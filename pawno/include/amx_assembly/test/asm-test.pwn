#include "../asm"
#include "../dynamic_call"

forward HandleAsmError(ctx[AsmContext], AsmError:error);

main() {
	// Have to use print() somewhere to make GetNativeAddressFromName() work.
	print("Doing #emit at runtime!");

	new code[10];
	new ctx[AsmContext];

	AsmInit(ctx, code);
	AsmSetErrorHandler(ctx, GetPublicAddressFromName("HandleAsmError"));

	// Build a function that prints a string and returns:
	//
	// PrintString(const string[]) {
	//     printf(string);
	// }
	//
	// NOTE: "print" must be called somwhere else in order to for this work!

	@emit proc
	@emit push.arg      0
	@emit push.num.args 1
	@emit sysreq        "print"
	@emit pop.args      1
	@emit retn

	if (AsmGetError(ctx) == ASM_ERROR_NONE) {
		CallFunction(AsmGetCode(ctx), ref("Hello!"));
	}
}

public HandleAsmError(ctx[AsmContext]) {
	printf("AsmError: %d", _:AsmGetError(ctx));
}
