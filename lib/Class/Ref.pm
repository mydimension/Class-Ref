package Class::Ref;

use strict;
use warnings;

use Scalar::Util ();

our $VERSION = 'v0.01';

# disable defaults at your peril
our %nowrap = map { ($_ => 1) } (
    'Regexp', 'CODE', 'SCALAR', 'REF', 'LVALUE', 'VSTRING',
    'GLOB',   'IO',   'FORMAT'
);

my $bless = sub {
    my ($class, $ref) = @_;
    my $type = Scalar::Util::reftype $ref;
    return bless \$ref => "$class\::$type";
};

my $test = sub {
    return unless $_[0];
    return unless ref $_[0];
    return if Scalar::Util::blessed $_[0];
    return if $nowrap{ Scalar::Util::reftype $_[0] };
    1;
};

my $assign = sub {
    my $v = shift;
    $$v = pop if @_;
    my $o = $test->($$v) ? \__PACKAGE__->$bless($$v) : $v;
    return $o;
};

sub new {
    my ($class, $ref) = @_;
    die "not a valid reference for $class" unless $test->($ref);
    return $class->$bless($ref);
}

package Class::Ref::HASH;

use overload '%{}' => sub { ${ $_[0] } };

our $AUTOLOAD;

# TODO research usefulness of lvalue functionality
sub AUTOLOAD    #: lvalue
{
    my $self = shift;
    my ($name) = $AUTOLOAD =~ /([^:]+)$/;
    my $o = $assign->(\$$self->{$name}, @_);
    $$o;        # FIXME lvalue is lost if $o is a ref wrapper
}

sub DESTROY { }

package Class::Ref::ARRAY;

use overload '@{}' => sub {
    # tie a proxy array around the real one
    tie my @a, __PACKAGE__ . '::Tie', ${ $_[0] };
    \@a;
};

package Class::Ref::ARRAY::Tie;

# borrowed from Tie::StdArray (in Tie::Array)

# ready... steady... go cross-eyed!!
sub TIEARRAY { bless [$_[1]] => $_[0] }
sub FETCHSIZE { scalar @{ $_[0][0] } }
sub STORESIZE { $#{ $_[0][0] } = $_[1] - 1 }
sub STORE     { $_[0][0]->[$_[1]] = $_[2] }
sub FETCH     { ${ $assign->(\$_[0][0][$_[1]]) } }      # magic
sub CLEAR     { @{ $_[0][0] } = () }
sub POP       { pop @{ $_[0][0] } }
sub PUSH      { my $o = shift->[0]; push @$o, @_ }
sub SHIFT     { shift @{ $_[0][0] } }
sub UNSHIFT   { my $o = shift->[0]; unshift @$o, @_ }
sub EXISTS    { exists $_[0][0]->[$_[1]] }
sub DELETE    { delete $_[0][0]->[$_[1]] }

sub SPLICE {
    my $ob  = shift;
    my $sz  = $ob->FETCHSIZE;
    my $off = @_ ? shift : 0;
    $off += $sz if $off < 0;
    my $len = @_ ? shift : $sz - $off;
    splice @{ $ob->[0] }, $off, $len, @_;
}

##
## These are bypassed via %nowrap for safety/sanity
##

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
