use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'gandi-hosting',
    AUTHOR        => q{Natal Ngétal <hobbestig@cpan.org>},
    VERSION_FROM  => 'bin/gandi-hosting',
    ABSTRACT      => 'A CLI utility to manage your Gandi hosting resources',
    EXE_FILES     => [ 'bin/gandi-hosting' ],
    PREREQ_PM => {
        'Net::Gandi'       => 0,
        'Config::IniFiles' => 0,
        'File::Homedir'    => 0,
    },
);
