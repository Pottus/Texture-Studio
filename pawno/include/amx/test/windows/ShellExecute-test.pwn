#include "windows/ShellExecute"

static stock ToCharString(s[], size = sizeof(s)) {
	for (new i = 0; i < size; i++) {
		s[i] = swapchars(s[i]);
	}
}

main() {
	new File[] = !"notepad.exe";
	new Operation[] = !"open";
	new Parameters[] = !"server.cfg";

	ToCharString(File);
	ToCharString(Operation);
	ToCharString(Parameters);

	new result = ShellExecute(Operation, File, Parameters, SW_SHOW);
	printf("ShellExecute() returned %d", result);
}
