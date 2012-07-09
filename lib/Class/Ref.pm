package Class::Ref;

use strict;
use warnings;

use Scalar::Util ();

our $VERSION = 'v0.01';

my $test = sub {
    return unless $_[0];
    return unless ref $_[0];
    return if Scalar::Util::blessed $_[0];
    return if 'Regexp' eq Scalar::Util::reftype $_[0];
    return if 'SCALAR' eq Scalar::Util::reftype $_[0];    # seg faults
    1;
};

my $assign = sub {
    my $v = shift;
    $$v = pop if @_;
    my $o = $test->($$v) ? \__PACKAGE__->new($$v) : $v;
    return $o;
};

sub new {
    my ($class, $ref) = @_;
    die "not a valid reference for $class" unless $test->($ref);

    my $type = Scalar::Util::reftype $ref;
    return bless \$ref => "$class\::$type";
}

package Class::Ref::HASH;

use overload '%{}' => sub { ${ $_[0] } };

our $AUTOLOAD;

sub AUTOLOAD : lvalue {
    my $self = shift;
    my ($name) = $AUTOLOAD =~ /([^:]+)$/;
    my $o = $assign->(\$$self->{$name}, @_);
    $$o;
}

sub DESTROY { }

package Class::Ref::ARRAY;

use overload '@{}' => sub {
    tie my @a, __PACKAGE__ . '::Tie';
    @a = @{ ${ $_[0] } };    # shallow copy
    return \@a;
};

package Class::Ref::ARRAY::Tie;

use Tie::Array;
use base 'Tie::StdArray';

sub FETCH {
    my ($self, $i) = @_;
    my $o = $assign->(\$self->[$i]);
    $$o;
}

package Class::Ref::CODE;

use overload '&{}' => sub { ${ $_[0] } };

package Class::Ref::REF;

use overload '${}' => sub { ${ $_[0] } };

package Class::Ref::SCALAR;    # seg faults

use base 'Class::Ref::REF';

package Class::Ref::LVALUE;

use base 'Class::Ref::REF';

package Class::Ref::VSTRING;

use base 'Class::Ref::REF';

package Class::Ref::GLOB;

use overload '*{}' => sub { ${ $_[0] } };

package Class::Ref::FORMAT;

use base 'Class::Ref::GLOB';

package Class::Ref::IO;

use base 'Class::Ref::GLOB';

1;
