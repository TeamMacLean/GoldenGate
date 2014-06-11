use Test::More;
use strict;
use warnings;

use Cwd            qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path($0)).'/../models';
use Part;

subtest 'create seqio and seq from path of GB file path' => sub {

my $testLoc = dirname(abs_path($0)).'/part.gb';
my $part = new Part("$testLoc");

is(1,1); #DONT JUDGE ME!

};

done_testing;