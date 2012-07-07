use Module::Build;
my $build = Module::Build->new(
    module_name => 'Class::Ref',
    dist_author => 'William Cox <mydimension@gmail.com>',
    license     => 'perl',
    requires    => { perl => ' => 5.6.1', 'Scalar::Util' => 0 }
);
$build->create_build_script;
