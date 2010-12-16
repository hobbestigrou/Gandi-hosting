use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Net::Gandi',
    AUTHOR        => q{Natal Ngétal <hobbestig@cpan.org>},
    VERSION_FROM  => 'bin/gandi-hosting',
    ABSTRACT      => 'A CLI utility to manage your Gandi hosting resources',
    PREREQ_PM => {
        'Net::Gandi'       => 0,
        'Config::IniFiles' => 0,
        'File::Homedir'    => 0,
    },
);
