use strict;
use warnings;

use Cwd            qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path($0)).'/../models';

my $partsFolder = dirname(abs_path($0)).'/../data/Parts';
use Part;

#list filed in parts folder
my $dir = $partsFolder;
    opendir(DIR, $dir) or die $!;
    while (my $file = readdir(DIR)) {
       next if ($file =~ m/^\./);

       my $part = new Part($partsFolder.'/'.$file);

	print "$file\n";
    }
closedir(DIR);



exit 0;