
use Cwd;
use File::Path;
use File::Basename;
use File::Compare;
use File::Copy;

mkpath ($ENV{'mk_obj_dir'});
$obj_dir = Cwd::abs_path("$ENV{'mk_obj_dir'}");

# print ("OBJDIR $obj_dir\n");

# always starts from "src"
chdir(dirname($0) . "/..");
$ENV{'PWD'}="";

sub get_additional_makeflags {
  my $input_mflags = $ENV{MFLAGS};
  $input_mflags =~ s/\\\\/__THE_BACKSLASH__/g;
  $input_mflags =~ s/\\ /__LITERAL_SPACE__/g;
  my $result = "";
  local $_;
  foreach(split ' ', $input_mflags) {
    if(!/^-/) {
      next;
    }
    if(/^--/) {
      next;
    }
    if(/k/) {
      $result .= " -k";
    }
    if(/i/) {
      $result .= " -i";
    }
  }
  return $result;
}

my $exit_code = 0;
sub stop_on_error {
  my $input_mflags = $ENV{MFLAGS};
  $input_mflags =~ s/\\\\/__THE_BACKSLASH__/g;
  $input_mflags =~ s/\\ /__LITERAL_SPACE__/g;
  my $result ="";
  local $_;
  foreach(split ' ', $input_mflags) {
    if(!/^-/) {
      next;
    }
    if(/^--/) {
      next;
    }
    if(/k/) {
      return 0;
    }
    if(/i/) {
      return 0;
    }
  }
  return 1;
}

sub shell {
  my ($cmd) = (@_);

  # Keep formatted output for RND builds
  # print "Run: $cmd\n";

  my ($code) = system("sh -c \"$cmd\"");
  if ($code == 0) {
    return;
  }
  my $signal = $code & 255;
  my $exit_status = $code >> 8;
  if(($signal == 255) || ($exit_status == 127)) {
    print STDERR "Running \"$cmd\": Failed to run, aborted\n";
    exit(1);
  }
  if($signal > 0) {
    print STDERR "Running \"$cmd\": A signal (", $signal, ") was received by a child process, aborted\n";
    exit(1);
  }
  if(stop_on_error) {
    print STDERR "Running \"$cmd\": An error code (", $exit_status, ") was returned by a child process, aborted\n";
    exit($exit_status);
  } else {
    print STDERR "Running \"$cmd\": An error code (", $exit_status, ") was returned by a child process, continuing\n";
    if($exit_status < 0) {
      $exit_status = 1;
    }
    if($exit_status > $exit_code) {
      $exit_code = $exit_status;
    }
  }
}

sub package_obj_dir {
  my ($package) = (@_);
  return "$obj_dir/$package";
}

sub local_traverse {
  my @queue = @_;
  my %flags = ();
  my $deps = {};

  while (scalar(@queue)) {

    my @layer = ();
    while (scalar(@queue)) {
      $package = pop(@queue);
      next if exists $flags{$package};
      $flags{$package} = 1;
      $deps->{$package} = {};

      next if not -r "$package/makefile";
      push(@layer, $package);
    }

    my $targets = join(' ', map { "package/" . $_ } @layer);
    my $additional_makeflags = get_additional_makeflags;
    shell "$ENV{'MAKE'} -f mk/fork.makefile -rs $additional_makeflags $ENV{'MAKELOCAL'} $targets";

    while (scalar(@layer)) {
      $package = pop(@layer);
      my $lstref = $deps->{$package};
      my $package_obj_dir = package_obj_dir($package);

      open FILE, "< $package_obj_dir/local.uses";
      while (<FILE>) {
        chop;
        foreach $item (split) {
          if ($package eq $item) {
            next;
          }
          if (not exists $flags{$item}) {
            push(@queue, $item);
          }
          $lstref->{$item} = 1;
        }
      }
      close FILE;
    }
  }

  return $deps;
}

sub print_deps {
  my ($deps) = (@_);
  foreach $package (keys %$deps) {
    print "$package: ";
    foreach $use (keys %{$deps->{$package}}) {
      print "$use ";
    }
    print "\n";
  }
  print "\n";
}

sub make_packages_deps {
  my ($deps, @packages) = (@_);
  my $result = {};
  my @queue = @packages;

  while (scalar(@queue)) {
    my $current = pop(@queue);
    my $subhash = {};
    $result->{$current} = $subhash;
    foreach $use (keys %{$deps->{$current}}) {
      $subhash->{$use} = 1;
      if (not exists $result->{$use}) {
        push @queue, $use;
      }
    }
  }

  return $result;
}

sub find_undependant_package {
  my ($deps) = (@_);
  foreach $package (keys %$deps) {
    if (scalar(%{$deps->{$package}}) == 0) {
      return $package
    }
  }
  return "";
}

sub remove_package {
  my ($deps, $package) = (@_);
  delete ($deps->{$package});
  foreach $key (keys %$deps) {
    if (exists $deps->{$key}->{$package}) {
      delete $deps->{$key}->{$package};
    }
  }
}

sub topo_sort {
  my ($deps_orig, $package) = (@_);

  my @packages = ();
  if (defined $package) {
    @packages = ($package);
  } else {
    @packages = keys %$deps_orig;
  }
  my $deps = make_packages_deps($deps_orig, @packages);

  my @order = ();
  while (scalar(%$deps)) {
    my $to_remove = find_undependant_package($deps);
    if ($to_remove eq "") {
      print "\nError: Cyclic dependence discovered:\n";
      print_deps($deps);
      die;
    }
    if ($to_remove ne $package) {
      if (-r "$to_remove/makefile") {
        push @order, $to_remove;
      }
    }
    remove_package($deps, $to_remove);
  }

  return @order;
}

sub generate_global_data {
  my ($package, $data_tag, @global_uses) = (@_);

  # collect global data
  my %global_data = ();
  foreach $global_use (@global_uses, $package) {
    my $local_data_file = package_obj_dir($global_use) . "/local." . $data_tag;
    next if not -r $local_data_file;
    open FILE, "< $local_data_file";
    while (<FILE>) {
      chop;
      foreach $it (split) {
        $global_data{$it} = 1;
      }
    }
    close FILE;
  }

  # dump global data file
  my $file_name = package_obj_dir($package) . "/global." . $data_tag;
  my $file_name_new = $file_name . ".new";
  open FILE, "> $file_name_new";
  print FILE join("\n", keys(%global_data)), "\n";
  close FILE;

  if ((!-e $file_name) || (compare($file_name, $file_name_new) != 0)) {
    move($file_name_new, $file_name);
  } else {
    unlink($file_name_new);
  }
}

sub generate_global_uses {
  my ($deps) = (@_);

  foreach $package (keys %$deps) {
    next if not -r "$package/makefile";

    # get the global uses list
    my @global_uses = reverse(topo_sort($deps, $package));

    # dump the global uses into "global.uses" file
    my $package_obj_dir = package_obj_dir($package);
    my $file_name = "$package_obj_dir/global.uses";
    open FILE, "> $file_name";
    print FILE join("\n", @global_uses), "\n";
    close FILE;

    generate_global_data($package, "static_link_flags", @global_uses);
    generate_global_data($package, "dynamic_link_flags", @global_uses);
  }
}

sub global_traverse {
  my (@global_order) = (@_);

  foreach $package (@global_order) {
    next if not -r "$package/makefile";
    my $additional_makeflags = get_additional_makeflags;
    shell "cd $package && $ENV{'MAKE'} -sr $additional_makeflags global";
  }
}

my $argv_description = join(' ', @ARGV);
my $mk_arch = "($ENV{mk_arch})";

# print "Local build $mk_arch for $argv_description.\n";
my $deps = local_traverse(@ARGV);
generate_global_uses $deps;

if($exit_code) {
  print "Error in local build $mk_arch for $argv_description. Exiting\n";
  exit($exit_code);
}

# print "Analyzing dependencies $mk_arch for $argv_description.\n";
my @global_order = topo_sort($deps);

if($exit_code) {
  print "Error in analyzing dependencies $mk_arch for $argv_description. Exiting\n";
  exit($exit_code);
}

# print "Global build $mk_arch for $argv_description.\n";
global_traverse @global_order;

if($exit_code) {
  print "Error in global build $mk_arch for $argv_description. Exiting\n";
  exit($exit_code);
}

# print "Build $mk_arch for $argv_description done.\n";
