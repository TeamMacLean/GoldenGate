#!/usr/bin/env perl
use ExtUtils::MakeMaker;

WriteMakefile(
  PREREQ_PM => {
      'Mojolicious'   => 0,
      'Mango'  => 0,
      'Data::Printer' => 0,
      'JSON'   => 0,
      'Bio::SeqIO'   => 0,
  }
);