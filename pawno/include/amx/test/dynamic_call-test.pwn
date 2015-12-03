#include "dynamic_call"

forward test(i, &j, s[], t[]);

main() {
	new x = 456;

	print("public - method #1");
	CallFunction(GetPublicAddressFromName("test"), 123, ref(x), ref("hell"), ref("yeah"));

	print("public - method #2");
	Push(123);
	Push(ref(x));
	Push(ref("hell"));
	Push(ref("yeah"));
	Call(GetPublicAddressFromName("test"));

	print("native - method #1");
	CallNativeByAddress(GetNativeAddressFromName("printf"), ref("Hello, %s!"), ref("World"));

	print("native - method #2");
	Push(ref("Hello, %s!"));
	Push(ref("World"));
	SysreqD(GetNativeAddressFromName("printf"));
}

public test(i, &j, s[], t[]) {
	printf("test: %d %d %s %s", i, j, s, t);
}
