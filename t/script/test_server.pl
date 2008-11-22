#!/usr/bin/perl
use strict;
use warnings;

use FCGI::ProcManager::MaxRequests;

my $m = FCGI::ProcManager::MaxRequests->new({
        n_processes => 1,
        max_requests => 2,
    });
$m->pm_manage;

while (1) {
    my $msg = <STDIN>;
    $m->pm_pre_dispatch();
    chomp $msg;
    syswrite STDOUT, $m->role . "(" . $$ . "): $msg\n";
    $m->pm_post_dispatch();
}
