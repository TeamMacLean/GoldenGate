use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    PREREQ_PM => {
        'Mojolicious'   => 0,
        'Mango'  => 0,
        'JSON'   => 0,
        'Bio::SeqIO' => 0,
    },
);