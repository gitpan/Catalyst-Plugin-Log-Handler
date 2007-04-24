use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Catalyst::Plugin::Log::Handler',
    AUTHOR              => 'Christoph Bussenius <cpan@der-pepe.de>',
    VERSION_FROM        => 'lib/Catalyst/Plugin/Log/Handler.pm',
    ABSTRACT_FROM       => 'lib/Catalyst/Plugin/Log/Handler.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Catalyst-Plugin-Log-Handler-*' },
);
