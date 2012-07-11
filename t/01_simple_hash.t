#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 13;
use Scalar::Util qw(reftype);

use Class::Ref;

my %hash = (foo => 'bar');

my $obj = Class::Ref->new(\%hash);

isa_ok $obj, 'Class::Ref::HASH', 'blessed into HASH wrapper';

isa_ok tied(%$obj), 'Class::Ref::HASH::Tie', 'hash tied';

is reftype $obj, 'REF', 'blessed ref is correct type';

is_deeply $$obj, \%hash, 'inner ref is correct';

is $obj->foo, 'bar', 'method access';
is $obj->{foo}, 'bar', 'hash access';

$obj->foo('baz');
is $obj->foo, 'baz', 'value changed';

eval { $obj->none };
like $@, qr/Can\'t locate object method "none" via package "Class::Ref::HASH"/,
  'deny access to non-existent keys';

{
    local $Class::Ref::allow_undef = 1;
    ok !defined($obj->none), 'non-existent key is undef';
    ok !exists $$obj->{none}, 'access of non-existent key does not create';
}

$obj->bah(undef);
ok !defined($obj->bah), 'assigned undef';
ok exists $$obj->{bah}, 'assignment of undef created key';

$obj->AUTOLOAD('foobar');
is $obj->AUTOLOAD, 'foobar', 'access AUTOLOAD hash key';
