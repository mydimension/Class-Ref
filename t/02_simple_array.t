#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 17;
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

is pop(@$obj), 'foobar', 'tied pop operator';
push @$obj, 'foobar';
is $obj->[3], 'foobar', 'tied push operator';

is shift(@$obj), 'foo', 'tied shift operator';
unshift @$obj, 'foo';
is $obj->[0], 'foo', 'tied unshift operator';

is delete($obj->[3]), 'foobar', 'tied delete operator';
ok !exists($obj->[3]), 'tied exists operator';

@$obj = ();
ok @$obj == 0, 'tied clear operator';

$#$obj = 5;
ok @$obj == 6, 'tied STORESIZE';
