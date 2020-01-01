
# a directory where building scripts (compilation, link and other) are located
scripts_dir := $(src_dir)/mk/scripts

# a namespace (underscores instead of slashes) name of the package
package_underscored_name := $(subst /,_,$(package_name))

# a relative path to a directory where package's object files
# will be created
package_obj_dir := $(obj_dir)/$(package_name)

# a relative path to a directory where package's include install
# files are located
package_include_dir := $(include_dir)/$(package_name)

# c, c++ and all objects files of the package
c_objects := $(addprefix $(package_obj_dir)/,$(subst .c,.$(o),$(c_sources)))
cpp_objects := $(addprefix $(package_obj_dir)/,$(subst .cpp,.$(o),$(cpp_sources)))
cxx_objects := $(addprefix $(package_obj_dir)/,$(subst .cxx,.$(o),$(cxx_sources)))
cc_objects := $(addprefix $(package_obj_dir)/,$(subst .cc,.$(o),$(cc_sources)))
objects := $(c_objects) $(cpp_objects) $(cxx_objects) $(cc_objects) $(package_external_objs)

# c, c++ object file depedencies
c_dep_files := $(addprefix $(package_obj_dir)/,$(subst .c,.d,$(c_sources)))
cpp_dep_files := $(addprefix $(package_obj_dir)/,$(subst .cpp,.d,$(cpp_sources)))
cxx_dep_files := $(addprefix $(package_obj_dir)/,$(subst .cxx,.d,$(cxx_sources)))
cc_dep_files := $(addprefix $(package_obj_dir)/,$(subst .cc,.d,$(cc_sources)))
dep_files := $(c_dep_files) $(cpp_dep_files) $(cxx_dep_files) $(cc_dep_files)

# install "object" files
install_targets := $(addprefix $(package_include_dir)/,$(install_sources))

# the package makefile
makefile := makefile

# a file, in which local package depedencies of the package
# is written
local_uses_file := $(package_obj_dir)/local.uses

# a file, in which global package depedencies of the package
# is written (partial order)
global_uses_file := $(package_obj_dir)/global.uses

# content of the global uses file
global_uses = $(shell if [ -f $(global_uses_file) ]; then cat $(global_uses_file); fi)

# content of the global uses file viewed as archives in the bin directory
global_uses_archives := $(addsuffix .$(a),$(addprefix $(obj_dir)/,$(subst /,_,$(global_uses))))

# the content of the global uses file viewed as shared libraries in the bin directory
global_uses_dynamic_libraries := $(addsuffix .$(so),$(addprefix $(bin_dir)/libdn.,$(subst /,_,$(global_uses))))

# the content of the global uses file viewed as -l link options, without pathes
global_uses_dynamic_minuslibs := $(addprefix -ldn.,$(subst /,_,$(global_uses)))

# content of the local uses file
local_uses = $(shell if [ -f $(local_uses_file) ]; then cat $(local_uses_file); fi)

# the content of the local uses file viewed as shared libraries in the bin directory
local_uses_dynamic_libraries := $(addsuffix .$(so),$(addprefix $(bin_dir)/libdn.,$(subst /,_,$(local_uses))))

# the content of the local uses file viewed as -l link options, without pathes
local_uses_dynamic_minuslibs := $(addprefix -ldn.,$(subst /,_,$(local_uses)))

# local static/dynamic link flags files
local_static_link_flags_file := $(package_obj_dir)/local.static_link_flags
local_dynamic_link_flags_file := $(package_obj_dir)/local.dynamic_link_flags

# global static/dynamic link flags files
global_static_link_flags_file := $(package_obj_dir)/global.static_link_flags
global_dynamic_link_flags_file := $(package_obj_dir)/global.dynamic_link_flags

# content of link flags files
global_static_link_flags = $(shell if [ -f $(global_static_link_flags_file) ]; then cat $(global_static_link_flags_file); fi) 
global_dynamic_link_flags = $(shell if [ -f $(global_dynamic_link_flags_file) ]; then cat $(global_dynamic_link_flags_file); fi) 

ifneq ($(exports_perl_filter),)
# linker .def file and flags
linker_def_file := $(package_obj_dir)/linker.def
else
linker_def_file :=
endif

# package local archive - main target of local build
local_archive := $(obj_dir)/$(package_underscored_name).$(a)

# package targets in the bin directory
dynamic_library_dn := $(bin_dir)/libdn.$(package_underscored_name).$(so)
dynamic_library_st := $(bin_dir)/libst.$(package_underscored_name).$(so)
executable_st := $(bin_dir)/$(package_underscored_name).exe
kernel_module := $(bin_dir)/$(package_underscored_name).ko

ifneq (,$(wildcard $(scripts_dir)/$(tool_chain)/link-dll-dynamic))
binaries_dynamic := $(dynamic_library_dn)
endif

ifneq (,$(findstring EXECUTABLE,$(package_targets))) 
binaries_static += $(executable_st)
startup_obj := $(package_obj_dir)/startup.$(o)
endif

ifneq (,$(findstring LIBRARY,$(package_targets)))
binaries_static += $(dynamic_library_st)
startup_obj := $(package_obj_dir)/startup.$(o)
endif

ifneq (,$(findstring KERNEL_MODULE,$(package_targets)))
binaries_static += $(kernel_module)
endif

# will build dynamic version only on Linux Debug; the following is 
# a list of package targets, as it is specified by user
binaries_debug := $(binaries_dynamic)
binaries := $(binaries_$(target_debug)) $(binaries_static)

# include flags
std_include_flags := -I$(package_obj_dir) -I$(abs_src_dir) $(package_include_flags)
c_include_flags := $(std_include_flags)
cpp_include_flags := $(std_include_flags)

# overall flags variables
define_flags := -DARCH=$(arch) -DARCH_STR=\"$(arch)\"
c_compile_flags := $(package_c_compile_flags) $(package_flags) $(c_include_flags) $(define_flags)
cpp_compile_flags := $(package_c_compile_flags) $(package_cpp_compile_flags) $(package_flags) $(cpp_include_flags) $(define_flags) -std=c++11

# standard libs
std_libs_flags := -ldl -lm

#############################################################################################

# install command for copying files to install tree
install_command = $(src_dir)/mk/install-file $< $@ 
install_command_no_legal = $(src_dir)/mk/install-file -no-legal $< $@ 

#############################################################################################

tree:
	@+$(perl) $(src_dir)/mk/topo_build.pl $(package_name) 

local:: $(local_archive) $(local_uses_file) \
	$(local_static_link_flags_file) $(local_dynamic_link_flags_file) \
	$(install_targets) $(local_targets)

global_targets += $(nonbinary_global_targets)
nonbinary_global: $(nonbinary_global_targets)
global: $(global_targets) $(binaries)

# soft include the depedencies files
-include $(package_obj_dir)/*.d

title := $(green)$(subst release,rel,$(subst debug,deb,$(target)/$(arch)))$(nc)

$(local_archive): $(objects)
	@$(echo) [$(title)] $(abspath $@)
	@$(make_target_directory)
	@-$(rm) $@
	@$(scripts_dir)/$(tool_chain)/archive $@ $^

$(package_obj_dir)/%.$(o) : %.c
	@$(echo) [$(title)] $(abspath $<)
	@$(make_target_directory)
	@$(scripts_dir)/$(tool_chain)/compile-c $@ $< $(c_compile_flags)
	@$(touch) $(package_obj_dir)/$*.d

$(package_obj_dir)/%.$(o) : %.cpp
	@$(echo) [$(title)] $(abspath $<)
	@$(make_target_directory)
	@$(scripts_dir)/$(tool_chain)/compile-cpp $@ $< $(cpp_compile_flags)
	@$(touch) $(package_obj_dir)/$*.d

$(package_obj_dir)/%.$(o) : $(package_obj_dir)/%.cpp
	@$(echo) [$(title)] $(abspath $<)
	@$(make_target_directory)
	@$(scripts_dir)/$(tool_chain)/compile-cpp $@ $< $(cpp_compile_flags)
	@$(touch) $(package_obj_dir)/$*.d

$(package_obj_dir)/%.$(o) : %.cxx
	@$(echo) [$(title)] $(abspath $<)
	@$(make_target_directory)
	@$(scripts_dir)/$(tool_chain)/compile-cpp $@ $< $(cpp_compile_flags)
	@$(touch) $(package_obj_dir)/$*.d

$(package_obj_dir)/%.$(o) : %.cc
	@$(echo) [$(title)] $(abspath $<)
	@$(make_target_directory)
	@$(scripts_dir)/$(tool_chain)/compile-cpp $@ $< $(cpp_compile_flags)
	@$(touch) $(package_obj_dir)/$*.d

$(package_include_dir)/% : %
	@$(echo) [$(title)] $(abspath $<)
	@$(install_command)

$(package_include_dir)/% : $(package_obj_dir)/%
	@$(echo) [$(title)] $(abspath $<)
	@$(install_command)

startup_cpp := $(package_obj_dir)/startup.cpp
$(startup_cpp): $(global_uses_file) $(makefile)
	@$(perl) $(src_dir)/mk/dump_startup.pl $(package_name) $(global_uses)

$(startup_obj): $(startup_cpp)
	@$(echo) [$(title)] $(abspath $<)
	@$(make_target_directory)
	@$(scripts_dir)/$(tool_chain)/compile-cpp $@ $< $(cpp_compile_flags)

$(local_uses_file) : $(local_archive) $(makefile)
	@$(make_target_directory)
	@$(cat) $(dep_files) /dev/null | $(perl) $(src_dir)/mk/dep2uses.pl $(abs_src_dir) $(package_name) > $@
# add user defined depedecies
ifneq ($(strip $(package_uses)),)
	@$(echo) $(package_uses) >> $@
endif

$(local_dynamic_link_flags_file) : $(makefile)
	@$(make_target_directory)
	@$(echo) $(package_dynamic_link_flags) $(package_link_flags) $(package_flags) > $@

$(local_static_link_flags_file) : $(makefile)
	@$(make_target_directory)
	@$(echo) $(package_static_link_flags) $(package_link_flags) $(package_flags) > $@

# part of "binaries"
$(dynamic_library_st): $(objects) $(startup_obj) $(global_uses_archives) $(linker_def_file)
	@$(echo) [$(title)] $(abspath $@)
	@$(make_target_directory)
	@$(scripts_dir)/$(tool_chain)/link-dll-static $@ "$(linker_def_file)" $(objects) $(startup_obj) \
		$(global_uses_archives) $(std_libs_flags) $(global_static_link_flags) $(package_std_libs_flags)

# part of "binaries"
$(dynamic_library_dn): $(objects) $(startup_obj) $(local_uses_dynamic_libraries)
	@$(echo) [$(title)] $(abspath $@)
	@$(make_target_directory)
	@$(scripts_dir)/$(tool_chain)/link-dll-dynamic $@ $(objects) $(startup_obj) $(local_uses_dynamic_minuslibs) \
		$(std_libs_flags) $(global_dynamic_link_flags) $(package_std_libs_flags)


# part of "binaries"
$(executable_st): $(objects) $(startup_obj) $(global_uses_archives)
	@$(echo) [$(title)] $(abspath $@)
	@$(make_target_directory)
	@$(scripts_dir)/$(tool_chain)/link-exe-static $@ $(objects) $(startup_obj) $(global_uses_archives) \
		$(std_libs_flags) $(global_static_link_flags) $(package_std_libs_flags)

exports_obj_file := $(package_obj_dir)/export
$(exports_obj_file) : $(objects) $(global_uses_archives) $(exports_perl_filter)
	@echo -n "Generating export table ... "
	@nm $(objects) $(global_uses_archives) | grep -w T | awk '{ print $$3 }' | \
		perl $(exports_perl_filter) > $@
	@echo `cat $@ | wc -l` "functions exported"

# linker def file
$(linker_def_file) : $(exports_obj_file)
	@echo "{" > $@
	@echo "global:" >> $@
	@cat $(exports_obj_file) | sed 's/$$/;/g' >> $@
	@echo "local:" >> $@
	@echo "*;" >> $@
	@echo "};" >> $@

# part of "binaries"
$(kernel_module): $(objects) $(global_uses_archives)
	@$(echo) [$(title)] $(abspath $@)
	@$(make_target_directory)
	@$(scripts_dir)/$(tool_chain)/link-kernel-module $@ $^

clean::
	@$(echo) Cleaning $(package_name)
	@-($(rm) $(package_obj_dir)/* $(install_targets) $(local_targets) >/dev/null 2>&1; test 0)
	@-($(rm) $(package_include_dir)/* >/dev/null 2>&1 ; test 0)
	@-($(rm) $(binaries) $(local_archive) >/dev/null 2>&1 ; test 0)

print-%: 
	@$(echo) $*=\"$($*)\"

FORCE:

.DELETE_ON_ERROR:
