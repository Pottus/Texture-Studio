ifndef PAWNCC
PAWNCC = pawncc
endif

INCLUDE = -i$(SAMP_SERVER_ROOT)/pawno/include -i../

AMX  = amx-test.amx
AMX += asm-test.amx
AMX += disasm-test.amx
AMX += dynamic_call-test.amx
AMX += jit-test.amx
AMX += phys_memory-test.amx
AMX += stack_trace-test.amx

all: clean $(AMX) windows

amx-test.amx: amx-test.pwn
	$(PAWNCC) $(PFLAGS) $(INCLUDE) $^ -o$@

asm-test.amx: asm-test.pwn
	$(PAWNCC) $(PFLAGS) $(INCLUDE) $^ -o$@

disasm-test.amx: disasm-test.pwn
	$(PAWNCC) $(PFLAGS) $(INCLUDE) $^ -o$@

dynamic_call-test.amx: dynamic_call-test.pwn
	$(PAWNCC) $(PFLAGS) $(INCLUDE) $^ -o$@

jit-test.amx: jit-test.pwn
	$(PAWNCC) $(PFLAGS) $(INCLUDE) $^ -o$@

phys_memory-test.amx: phys_memory-test.pwn
	$(PAWNCC) $(PFLAGS) $(INCLUDE) $^ -o$@

stack_trace-test.amx: stack_trace-test.pwn
	$(PAWNCC) $(PFLAGS) $(INCLUDE) $^ -o$@

clean: $(SUBDIRS)
	rm -rf $(AMX)

.PHONY: windows
windows:
	$(MAKE) -C $@

