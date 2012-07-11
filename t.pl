#!/usr/bin/env perl

use strict;
use warnings;

use lib './lib';
use Class::Ref;
use Data::Dumper;

my $t = Class::Ref->new(['foo']);
$t->[1] = {bar => 1};

my $r = Class::Ref->new(
    {
        foo => {
            bar => 1,
            baz => [
                { a => 3 },
                'foobar'
            ]
        },
        code => sub { print "hello\n" },
    }
);

exit;
