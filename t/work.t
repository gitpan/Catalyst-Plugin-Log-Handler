#!perl
use strict;
use warnings;
#
# This test verifies that all log level functions work correctly.
#

use Test::More;
use constant LEVELS => qw(debug info warn error fatal);

{
    local $@;
    eval 'use 5.6.0; 1' or plan skip_all => "I don't think that this works on your perl version.";
}

$^O =~ /MSWin32/i and plan skip_all => 'This test requires an operating system.';

my $pipe;

my $pid = open $pipe, '-|';
defined $pid or die $!;

unless ($pid) {
    require Catalyst::Plugin::Log::Handler;

    {
        package Catalyst::Plugin::Log::Handler::Test;
        use base qw(Class::Accessor::Fast Catalyst::Plugin::Log::Handler);

        __PACKAGE__->mk_accessors(qw(log config));
    }

    my $c = Catalyst::Plugin::Log::Handler::Test->new({
            config => {
                'Log::Handler' => {
                    filename => \*STDOUT,
                    mode => 'append',
                    newline => 1,
                },
            },
        });

    $c->setup();

    for my $level (LEVELS) {
        $c->log->$level("This is a $level test message.");
    }
    $c->log->handler->crit('This is a crit test message.');
    
    exit(0);
}

my $logtext = do {local $/; <$pipe>};
defined $logtext or die $!;

print "This was logged: (\n$logtext)\n";

close $pipe or die "Child exit status: $?\n";

my $numberlevels = () = LEVELS;

plan (tests => 2 + $numberlevels);

my $numberlines = () = $logtext =~ /^.+$/gm;

ok (1 + $numberlevels == $numberlines, 'newlines');

for my $level (LEVELS, 'crit') {
    ok($logtext =~ /This is a \Q$level\E test message/, $level);
}
