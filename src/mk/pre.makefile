
# uncomment the following line for heavy debugging
# OLD_SHELL := $(SHELL)
# SHELL = $(warning [$@ ($^) ($?)])$(OLD_SHELL)

# export the make variable, so recursive makes will 
# take it
export MAKE

# very basic tools, the same on all architectures
cp := cp -rf
rm := rm -f
mv := mv -f
mkdir := mkdir -p
echo := echo -e
cat := cat
cpp := g++ -E -o
symlink := ln -sf
touch := touch
mark_executable := chmod a+x
gperf = $(scripts_dir)/run-gperf
ar := ar -r
uname-sm := $(shell uname -s -m)
uname := $(word 1,$(uname-sm))
uname-m := $(word 2,$(uname-sm))
checked_rm = tmpfile=$(1).$$$$; if [ -e $(1) ] ; then $(mv) $(1) $$tmpfile && $(rm) -r $$tmpfile; fi
perl := perl

make_symbolic_link = ln -sf $< $@ 
make_target_directory = $(mkdir) '$(dir $@)'
copy_source_to_target = $(make_target_directory) && cp -pf '$<' '$@'
copy_newer_source_to_target = \
	$(make_target_directory) && \
	if diff $< $@ >/dev/null 2>&1; then \
	echo $@ up to date >/dev/null; \
	else \
	$(echo) Copying to install dir: $@; \
	$(cp) $< $@; \
	fi
absolute_path = $(shell if [ -d $(1) ]; then cd $(1); pwd; else cd $(dir $(1)); echo $$PWD/$(notdir $(1)); fi; )

# common file extensions
so := so
a := a
o := o

# bitness may be 32 or 64
bitness := 64

# default tool_chain
ifeq ($(TOOL_CHAIN),)
	tool_chain := x86-user
else
	tool_chain := $(TOOL_CHAIN)
endif

# set arch
arch := $(tool_chain)
mk_arch := $(arch)
export mk_arch

# a relative path to "src" dir (where's mk/pre.makefile is located)
src_dir_str := $(subst /src/, ,$(shell pwd))
src_dir_str_count := $(words $(src_dir_str))
ifeq ($(src_dir_str_count),1)
src_dir := .
else
src_dir := $(subst / ,/,$(patsubst %,../,$(subst /, ,$(word $(src_dir_str_count),$(src_dir_str)))))
src_dir := $(patsubst %/,%,$(src_dir))
endif

# an absolute path to "src" dir
abs_src_dir := $(call absolute_path,$(src_dir))

ifeq ($(TARGET),)
	target := debug
else
	target := $(TARGET)
endif
mk_target := $(target)
export mk_target

target_debug := $(findstring debug, $(target))
target_release := $(findstring release, $(target))

prefix ?= $(src_dir)/..

# a relative path to objects root (under the build directory)
build_dir := $(prefix)/build.$(mk_target)
obj_dir := $(build_dir)/$(arch)
mk_obj_dir := $(obj_dir)
export mk_obj_dir

# this is root of installation for current target
install_dir := $(prefix)/install.$(mk_target)
abs_install_dir = $(call absolute_path,$(install_dir))

# this is root of include files in the installation
include_dir := $(install_dir)/shared
mk_include_dir := $(include_dir)
export mk_include_dir

# a relative path to binaries root (under the install directory)
bin_dir := $(install_dir)/$(arch)
mk_bin_dir := $(bin_dir)
export mk_bin_dir

# colored output
red := "\033[0;31m"
green := "\033[0;32m"
nc := "\033[0m"
