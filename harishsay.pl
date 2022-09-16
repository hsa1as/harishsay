#/bin/perl
##
## harishsay 1.00
## Authors - Avani & R Sai Ashwin 
## Inspired by  cowsay.  (c) 1999-2000 Tony Monroe.
##

use Text::Tabs qw(expand);
use Text::Wrap qw(wrap fill $columns);
use File::Basename;
use Getopt::Std;
use Cwd;

$version = "1.00";
$progname = basename($0);
$eyes = "oo";
$tongue = "  ";
$harishpath = $ENV{'HARISHPATH'} || '/usr/share/harishs';
@message = ();
$thoughts = "";

## Yeah, this is rude, I know.  But hopefully it gets around a nasty
## little version dependency.

$Text::Wrap::initial_tab = 8;
$Text::Wrap::subsequent_tab = 8;
$Text::Wrap::tabstop = 8;

## One of these days, we'll get it ported to Windows.  Yeah, right.

%opts = (
    'e'		=>	'oo',
    'f'		=>	'harish2.txt',
    'n'		=>	0,
    'T'		=>	'  ',
    'W'		=>	40,
);

getopts('bde:f:ghlLnNpstTr:wW:y', \%opts);

&display_usage if $opts{'h'};
&list_harishfiles if $opts{'l'};

$borg = $opts{'b'};
$dead = $opts{'d'};
$greedy = $opts{'g'};
$paranoid = $opts{'p'};
$stoned = $opts{'s'};
$tired = $opts{'t'};
$wired = $opts{'w'};
$young = $opts{'y'};
$eyes = substr($opts{'e'}, 0, 2);
$tongue = substr($opts{'T'}, 0, 2);
$the_harish = "";

&slurp_input;
$Text::Wrap::columns = $opts{'W'};
@message = ($opts{'n'} ? expand(@message) : 
	    split("\n", fill("", "", @message)));
&construct_balloon;
##&construct_face;
&get_harish;
print @balloon_lines;
print $the_harish;

sub list_harishfiles {
    my $basedir;
    my @dirfiles;
    chop($basedir = cwd);
    for my $d (split(/$pathsep/, $harishpath)) {
	print "Harish files in $d:\n";
	opendir(HARISHDIR, $d) || die "$0: Cannot open $d\n";
	for my $file (readdir HARISHDIR) {
	    if ($file =~ s/\.cow$//) {
		push(@dirfiles, $file);
	    }
	}
	closedir(HARISHDIR);
	print wrap("", "", sort @dirfiles), "\n";
	@dirfiles = ();
	chdir($basedir);
    }
    exit(0);
}

sub slurp_input {
    unless ($ARGV[0]) {
	chomp(@message = <STDIN>);
    } else {
	&display_usage if $opts{'n'};
	@message = join(' ', @ARGV);
    }
}

sub maxlength {
    my ($l, $m);
    $m = -1;
    for my $i (@_) {
	$l = length $i;
	$m = $l if ($l > $m);
    }
    return $m;
}

sub construct_balloon {
    my $max = &maxlength(@message);
    my $max2 = $max + 2;	## border space fudge.
    my $format = "%s %-${max}s %s\n";
    my @border;	## up-left, up-right, down-left, down-right, left, right
    if ($0 =~ /think/i) {
	$thoughts = 'o';
	@border = qw[ ( ) ( ) ( ) ];
    } elsif (@message < 2) {
	$thoughts = '\\';
	@border = qw[ < > ];
    } else {
	$thoughts = '\\';
	if ($V and $V gt v5.6.0) {		# Thanks, perldelta.
	    @border = qw[ / \\ \\ / | | ];
	} else {
	    @border = qw[ / \ \ / | | ];	
	}
    }
    push(@balloon_lines, 
	" " . ("_" x $max2) . " \n" ,
	sprintf($format, $border[0], $message[0], $border[1]),
	(@message < 2 ? "" : 
	    map { sprintf($format, $border[4], $_, $border[5]) } 
		@message[1 .. $#message - 1]),
	(@message < 2 ? "" : 
	    sprintf($format, $border[2], $message[$#message], $border[3])),
        " " . ("-" x $max2) . " \n"
    );
}


sub get_harish {




    my $f = $opts{'f'};
    my $full = "";
    if ($opts{'f'} =~ m,/,) {
	$full = $opts{'f'};
    } else {
	for my $d (split(/:/, $harishpath)) {
	    if (-f "$d/$f") {
		$full = "$d/$f";
		last;
	    } elsif (-f "$d/$f") {
		$full = "$d/$f";
		last;
	    }
	}
	if ($full eq "") {
	    die "$progname: Could not find $f Harishfile! $f $full\n";
	}
    }
    do $full;
    die "$progname: $@\n" if $@;
}

sub display_usage {
	die <<EOF;
cow{say,think} version $version, (c) 1999 Tony Monroe
Usage: $progname [-bdgpstwy] [-h] [-e eyes] [-f cowfile] 
          [-l] [-n] [-T tongue] [-W wrapcolumn] [message]
EOF
}
