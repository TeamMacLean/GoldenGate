use strict;
use Module::Build;
#created by eumm-migrate.pl

my $build = Module::Build->new(
  'dist_abstract' => 'A tool for TSLSynBio',
  'license' => 'MIT',
  'build_requires' => {
  },
  'dist_author' => 'Martin Page <wookoouk@gmail.com>',
  'module_name' => 'goldengate',
  'meta_merge' => {
    'keywords' => [
      'tsl','bioinformatics',
    ],
    'resources' => {
      'repository' => 'http://github.com/wookoouk/goldengate'
    }
  },
  'requires' => {
    'Mojolicious' => 0,
    'Mango' => 0,
    'Data::Printer' => 0,
    'JSON' => 0,
    'Bio::SeqIO' => 0,
  },
  'dist_version_from' => 'goldengate'
);

$build->create_build_script();