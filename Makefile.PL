#!/usr/bin/env perl
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME => "GoldenGate",
    PREREQ_PM => {
        'Mojolicious'   => 0,
        'Mango'  => 0,
        'Data::Printer' => 0,
        'JSON'   => 0,
        'Bio::SeqIO'   => 0,
    }
);