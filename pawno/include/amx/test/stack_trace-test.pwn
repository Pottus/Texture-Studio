#include <a_samp>

#include "../amx_header"
#include "../stack_trace"

forward f1();
forward f3();

main() {
	f1();
}

public f1() {
	f2();
}

f2() {
	f3();
}

public f3() {
	new stack_trace[10];
	new length = GetStackTrace(stack_trace);
	PrintStackTrace(stack_trace, length);
	#emit halt 1
}
