package Class::Ref;

use strict;
use warnings;

use Scalar::Util ();

our $VERSION = 'v0.01';

my $ref_o = sub {
    my $v = shift or return undef;
    return $v if not ref $v or Scalar::Util::blessed $v;
    my $class = __PACKAGE__ . '::' . Scalar::Util::reftype $v;
    return bless $v => $class;
};

sub new {
    my ($class, $ref) = @_;
    die "'$ref' is not a reference" unless ref $ref;
    die "don't give me a blessed reference" if Scalar::Util::blessed $ref;

    my $type = Scalar::Util::reftype $ref;
}

=comment

SCALAR
ARRAY
HASH
CODE
REF
GLOB
LVALUE - special case of a scalar that has an external influence if it is modified
FORMAT
IO
VSTRING - reference to a version string
Regexp

=cut

package Class::Ref::HASH;

use strict;
use warnings;

our $AUTOLOAD;

sub AUTOLOAD : lvalue {
    my $self = shift;
    my ($name) = $AUTOLOAD =~ /([^:]+)$/;
    $self->{$name} = pop if @_;
    return $ref_o->($self->{$name});
}

1;
