package Class::Ref;

use strict;
use warnings;

use Scalar::Util ();

our $VERSION = v0.01;

our $raw_access = 0;

# disable defaults at your peril
our %nowrap = map { ($_ => 1) } (
    'Regexp', 'CODE', 'SCALAR', 'REF', 'LVALUE', 'VSTRING',
    'GLOB',   'IO',   'FORMAT'
);

my $bless = sub {
    my ($class, $ref) = @_;
    return $ref if $raw_access;
    my $type = Scalar::Util::reftype $ref;
    return bless \$ref => "$class\::$type";
};

my $test = sub {
    return unless $_[0] and ref $_[0];
    return if Scalar::Util::blessed $_[0];
    return if $nowrap{ Scalar::Util::reftype $_[0] };
    1;
};

my $assign = sub {
    my $v = shift;
    $$v = pop if @_;
    return $test->($$v) ? \__PACKAGE__->$bless($$v) : $v;
    #return $o;
};

sub new {
    my ($class, $ref) = @_;
    die "not a valid reference for $class" unless $test->($ref);
    return $class->$bless($ref);
}

package Class::Ref::HASH;

use overload '%{}' => sub {
    return ${ $_[0] } if $raw_access;
    tie my %h, __PACKAGE__ . '::Tie', ${ $_[0] };
    \%h;
  },
  fallback => 1;

our $AUTOLOAD;

sub AUTOLOAD {
    # enable access to $h->{AUTOLOAD}
    my ($name) = defined $AUTOLOAD ? $AUTOLOAD =~ /([^:]+)$/ : ('AUTOLOAD');

    # undef so that we can detect if next call is for $h->{AUTOLOAD}
    # - needed cause $AUTOLOAD stays set to previous value until next call
    undef $AUTOLOAD;

    # NOTE must do this after AUTOLOAD check
    # - when a wrapped HASH object is contained inside a wrapped ARRAY object
    #   this call to 'shift' trigger the tie logic pertaining to ARRAY.
    #   doing so screws up the value of $AUTOLOAD
    my $self = shift;

    # simulate a fetch for a non-existent key without autovivification
    return undef unless @_ or exists $$self->{$name};

    # keep this broken up in case I decide to implement lvalues
    my $o = $assign->(\$$self->{$name}, @_);
    $$o;
}

#sub DESTROY {}

package Class::Ref::HASH::Tie;

# borrowed from Tie::StdHash (in Tie::Hash)

#<<<
sub TIEHASH  { bless [$_[1]], $_[0] }
sub STORE    { $_[0][0]->{ $_[1] } = $_[2] }
sub FETCH    { ${ $assign->(\$_[0][0]->{ $_[1] }) } }
sub FIRSTKEY { my $a = scalar keys %{ $_[0][0] }; each %{ $_[0][0] } }
sub NEXTKEY  { each %{ $_[0][0] } }
sub EXISTS   { exists $_[0][0]->{ $_[1] } }
sub DELETE   { delete $_[0][0]->{ $_[1] } }
sub CLEAR    { %{ $_[0][0] } = () }
sub SCALAR   { scalar %{ $_[0][0] } }
#>>>

package Class::Ref::ARRAY;

# tie a proxy array around the real one
use overload '@{}' => sub {
    return ${ $_[0] } if $raw_access;
    tie my @a, __PACKAGE__ . '::Tie', ${ $_[0] };
    \@a;
  },
  fallback => 1;

package Class::Ref::ARRAY::Tie;

# borrowed from Tie::StdArray (in Tie::Array)

#<<< ready... steady... go cross-eyed!!
sub TIEARRAY  { bless [$_[1]] => $_[0] }
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
#>>>
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

use overload '${}' => sub { ${ $_[0] } };    # seg faults

package Class::Ref::SCALAR;

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

=head2 SEE ALSO
    Class::Hash
    Class::ConfigHash
    Hash::AsObject
=cut

1;
