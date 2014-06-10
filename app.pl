use strict;
use warnings;
use Mojolicious::Lite;

my $appRoot = './';

#TODO TEST
#my $dir = $appRoot.'data';
#    opendir(DIR, $dir) or die $!;
#    while (my $file = readdir(DIR)) {
#        ignore files beginning with a period
#        next if ($file =~ m/^\./);
#	print "$file\n";
#    }
#closedir(DIR);
#exit 0;


get '/' => 'index';
app->start;