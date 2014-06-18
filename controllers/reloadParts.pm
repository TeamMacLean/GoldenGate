use strict;
use warnings;
use Mango;


use Cwd            qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path($0)).'/../models';

my $partsFolder = dirname(abs_path($0)).'/../data/Parts';
use Part;

# list filed in parts folder
my $dir = $partsFolder;
    opendir(DIR, $dir) or die $!;
    while (my $file = readdir(DIR)) {
        next if ($file =~ m/^\./);

        my $part = new Part($partsFolder.'/'.$file);

#        print "have part\n";

        # PUT INTO DATABASE!
        my $mango = Mango->new('mongodb://localhost:27017');

        # Does it exist

        my $doc = $mango->db('goldengate')->collection('parts')->find_one({label => $part->{_label}});

        if(defined($doc)){
#           update it
            print "updating in db.\n";
        } else {
#           add new
            if($part->{_label} && $part->{_seq} && $part->{_overhang_l} && $part->{_overhang_r}){
            print "adding to db.\n";
                my $oid = $mango->db('goldengate')->collection('parts')->insert({'label'=>$part->{_label}, 'seq'=>$part->{_seq},'overhang_l'=>$part->{_overhang_l}, 'overhang_r'=>$part->{_overhang_r}});
                print $oid."\n";
            }
        }
#	print "$file\n";
    }
closedir(DIR);



exit 0;