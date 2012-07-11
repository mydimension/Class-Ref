#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 9;
use Scalar::Util qw(reftype);

use Class::Ref;

my @array = ('foo', 'bar');

my $obj = Class::Ref->new(\@array);

isa_ok $obj, 'Class::Ref::ARRAY', 'blessed into ARRAY wrapper';

isa_ok tied(@$obj), 'Class::Ref::ARRAY::Tie';

is reftype $obj, 'REF', 'blessed ref is correct type';

is_deeply $$obj, \@array, 'inner ref is correct';

is $obj->[0], 'foo', 'FETCH values';

cmp_ok push(@$obj, 'baz'), '==', 3, 'push added correct amount';

$obj->[4] = 'foobar';
is $obj->[4], 'foobar', 'assigned new value';

is splice(@$obj, 2, 1), 'baz', 'splice';

is $obj->[3], 'foobar', 'index shift';
