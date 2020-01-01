
mkfile_dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

include $(mkfile_dir)/pre.makefile

all:
	@+$(perl) mk/topo_build.pl $(ROOTS)

