use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
    create_readme      => 1,
    create_makefile_pl => 'traditional',
    license            => 'perl',
    module_name        => 'Catalyst::Plugin::Log::Handler',
    dist_author        => 'Christoph Bussenius',
    requires => {
        'Class::Accessor'  => 0,
        'Test::More'       => 0,
        'Log::Handler'     => 0.11,
    },
    recommends         => {},
    sign               => 0,
);
$build->create_build_script;
