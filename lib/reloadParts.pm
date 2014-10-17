use strict;
use warnings;
use Mango;


use Cwd            qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path($0)).'/../models';

my $partsFolder = dirname(abs_path($0)).'/../data/Parts';
use Part;

my $mango = Mango->new('mongodb://localhost:27017');
my $db = $mango->db('goldengate');
my $collection = $db->collection('parts');
$collection->drop;


# list filed in parts folder
my $dir = $partsFolder;
opendir(DIR, $dir) or die $!;
while (my $file = readdir(DIR)) {
    next if ($file =~ m/^\./);
    my $part = new Part($partsFolder,$file);
    if($part->{_label} && $part->{_seq} && $part->{_overhang_l} && $part->{_overhang_r} && $part->{_type} && $part->{_file}){
        print "adding to db.\n";
        my $oid = $collection->insert({'label'=>$part->{_label}, 'seq'=>$part->{_seq},'overhang_l'=>$part->{_overhang_l}, 'overhang_r'=>$part->{_overhang_r},'type'=>$part->{_type}, 'file' =>$part->{_file}});
#        print $oid."\n";
    }
}
closedir(DIR);



exit 0;