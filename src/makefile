
roots@x86-user := \
	utl/test_thread \
	utl/test_string_buffer \
	tests/hello_world \

roots@arm-user := \
	tests/hello_world \

roots@arm-kmod := \
	tests/hello_kernel \

all: debug release

debug:
	@+make -f mk/topo_build.mk TOOL_CHAIN=x86-user TARGET=debug ROOTS="$(roots@x86-user)"
#	@+make -f mk/topo_build.mk TOOL_CHAIN=arm-user TARGET=debug ROOTS="$(roots@arm-user)"
#	@+make -f mk/topo_build.mk TOOL_CHAIN=arm-kmod TARGET=debug ROOTS="$(roots@arm-kmod)"

release:
	@+make -f mk/topo_build.mk TOOL_CHAIN=x86-user TARGET=release ROOTS="$(roots@x86-user)"
#	@+make -f mk/topo_build.mk TOOL_CHAIN=arm-user TARGET=release ROOTS="$(roots@arm-user)"
#	@+make -f mk/topo_build.mk TOOL_CHAIN=arm-kmod TARGET=release ROOTS="$(roots@arm-kmod)"

clean_debug:
	@echo Cleaning debug.
	@rm -rf ../install.debug ../build.debug

clean_release:
	@echo Cleaning release.
	@rm -rf ../install.release ../build.release

clean: clean_debug clean_release

help:
	@echo "Available targets: "
	@echo "     all [default] :  Build all."
	@echo "     clean         :  Clean all."
	@echo "     release       :  Build release."
	@echo "     debug         :  Build debug."
	@echo "     clean_release :  Clean release."
	@echo "     clean_debug   :  Clean debug."

print-%:
	@$(echo) $*=\"$($*)\"

.SILENT:

.PHONY: debug release all help
