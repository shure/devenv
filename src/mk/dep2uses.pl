
use File::Basename;

my $src_dir = $ARGV[0];
my $package_name = $ARGV[1];
my %result = ();

while (<STDIN>) {
  for (split) {
    next if /\\/;
    next if /.*:$/;
    next if /.*\.cpp$/;
    s+.*/src/++g;
    $_ = dirname($_);
    next if /\./;
    next if /^$package_name$/;
    next if not -f "$src_dir/$_/makefile";
    next if -f "$src_dir/$_/nopackage";
    $result{$_} = 1;
  }
}

while (my($item, $dummy) = each(%result)) {
  print "$item\n";
}

print "\n";
