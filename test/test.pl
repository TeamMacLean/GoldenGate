use Test::More;
use strict;
use warnings;

use Cwd            qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path($0)).'/../models';
use Part;

subtest 'create seqio and seq from path of GB file path' => sub {

my $testLoc = dirname(abs_path($0)).'/testPart.gb';
my $part = new Part("$testLoc");

my $start = $part->{_start};
my $end = $part->{_end};

is($start,848);
is($end,969);
};

done_testing;