
use Cwd;
use File::Basename;
use File::Compare;
use File::Copy;

$obj_dir = Cwd::abs_path("$ENV{'mk_obj_dir'}");
$include_dir = Cwd::abs_path("$ENV{'mk_include_dir'}");

# always start from "src"
chdir(dirname($0) . "/..");

sub package_namespace {
  my ($package) = (@_);
  $package =~ s|/|::|g;
  return "  ::" . $package;
}

my $package = @ARGV[0];

#shift(@ARGV);
my @deps = @ARGV;

my $package_obj_dir = "$obj_dir/$package";
my $file_name = "$package_obj_dir/startup.cpp";
my $file_name_for_update = "$package_obj_dir/startup.cpp.update";
@package_names = split("/", $package);

open FILE, "> $file_name_for_update";

for $dep (@deps) {
  next if not -r "$dep/init.h";
  print FILE "#include \"$dep/init.h\"\n";
}

print FILE $str = << "END_CODE";
#include <stdio.h>
#include <stdlib.h>
#include <utl/exception.h>
namespace {

void startup()
{
END_CODE

for $dep (reverse(@deps)) {
  next if not -r "$dep/init.h";
  print FILE package_namespace($dep), "::init(ip);\n";
}
print FILE "\n";

print FILE $str = << "END_CODE";
} // startup

struct Init { Init() {
  try { startup(); }
  catch (utl::Exception& ex) { fprintf(stderr, "Error during initialization: %s", ex.get_message()); exit(1); }
  catch (const char* ex) { fprintf(stderr, "Error during initialization: %s", ex); exit(1); }
  catch (...) { fprintf(stderr, "A fatal error occurred during initialization"); exit(1); }
} }; Init init;

} // namespace
END_CODE

close FILE;

if (compare($file_name, $file_name_for_update) != 0) {
  copy($file_name_for_update, $file_name);
}
