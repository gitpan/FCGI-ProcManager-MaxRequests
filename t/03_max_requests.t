use strict;
use Test::More;

BEGIN {
    eval "use IPC::Run;";
    if ($@) {
        plan skip_all => 'We need IPC::Run to run tests';
    }
    else {
        plan tests => 4;
    }
}

my ( $input, $out, $err, @pids );
my $h =
    IPC::Run::start( [ 'perl', '-Ilib', 't/script/test_server.pl' ], \$input, \$out, \$err, IPC::Run::timeout(30) );
foreach my $req ( 1 .. 5 ) {
    $input = "req $req\n";
    $h->pump until !length($input);
    $h->pump until $out =~ /server\((\d+)\): req $req/;
    push @pids, $1;
    $out = '';
}
$h->signal("TERM");

is( $pids[0], $pids[1], '1 and 2 requests was done by same process' );
isnt( $pids[1], $pids[2], '2 and 3 requests was done by distinct processes' );
is( $pids[2], $pids[3], '3 and 4 requests was done by same process' );
isnt( $pids[3], $pids[4], '4 and 5 requests was done by distinct processes' );

