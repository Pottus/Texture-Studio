#include <a_samp>

#include "jit"

main() {
	printf("JIT is %spresent", IsJITPresent() ? ("") : ("not "));
}
