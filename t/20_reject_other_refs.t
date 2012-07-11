#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 16;

use Class::Ref;

my $error_test = qr/not a valid reference for Class::Ref/;

# for LVALUE test
my $str = 'foo';

# for FORMAT test
format =
.

my %tests = (
    CODE    => sub { },
    FORMAT  => *STDOUT{FORMAT},
    GLOB    => \*_,
    LVALUE  => \substr($str, 0, 1),
    REF     => \\1,
    Regexp  => qr//,
    SCALAR  => \1,
    VSTRING => \v1.0,
    #IO => *STDIN{IO}, # not really testable
);

while (my ($type, $ref) = each %tests) {
    eval { Class::Ref->new($ref) };
    like $@, $error_test, "reject $type";
}

my $obj = Class::Ref->new({});

while (my ($type, $ref) = each %tests) {
    $obj->holder($ref);
    is ref $obj->holder, $type, "passthru $type";
}
