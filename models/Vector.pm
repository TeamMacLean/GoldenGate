package Part;
use strict;
use warnings;
use Bio::SeqIO;
use JSON;
use Data::Printer;

#my $featureName = 'GGAGTGAGACCGCAGCTGGCACGACAGGTTTGCCGACTGGAAAGCGGGCAGTGAGCGCAACGCAATTAATGTGAGTTAGCTCACTCATTAGGCACCCCAGGCTTTACACTTTATGCTTCCGGCTCGTATGTTGTGTGGAATTGTGAGCGGATAACAATTTCACACAGGAAACAGCTATGACCATGATTACGCCAAGCTTGCATGCCTGCAGGTCGACTCTAGAGGATCCCCGGGTACCGAGCTCGAATTCACTGGCCGTCGTTTTACAACGTCGTGACTGGGAAAACCCTGGCGTTACCCAACTTAATCGCCTTGCAGCACATCCCCCTTTCGCCAGCTGGCGTAATAGCGAAGAGGCCCGCACCGATCGCCCTTCCCAACAGTTGCGCAGCCTGAATGGCGAATGGCGCCTGATGCGGTATTTTCTCCTTACGCATCTGTGCGGTATTTCACACCGCATATGGTGCACTCTCAGTACAATCTGCTCTGATGCCGCATAGTTAAGCCAGCCCCGACACCCGCCAACACCCGCTGACGCGCCCTGACGGGCTTGTCTGCTCCCGGCATCCGCTTACAGACAAGCTGTGACGGTCTCACGCT';

my $featureName = 'Golden_Gate_Cas';

sub new {

    my $class = shift;
    my $path = shift;
    my $file = shift;

    my $seqio_object = Bio::SeqIO->new(-file => "$path/$file" );
    my $seq_object = $seqio_object->next_seq;

    my $ggFeature = undef;

    $seq_object->display_id;

#    for my $feat_object ($seq_object->get_SeqFeatures) {
#        if($feat_object->primary_tag eq $featureName){
#        print "found gg feature, breaking\n";
#        $ggFeature = $feat_object;
#        last;
#        }
#    }

    my $label = 'unknown';
    $label = $seq_object->display_id;
#    my $label = $file;

#    if (defined($ggFeature)){
#        my $start = $ggFeature->location->start;
#        my $end = $ggFeature->location->end;


#        if ($ggFeature->has_tag("label")){

#        for my $value ($ggFeature->get_tag_values('label')) {
#            $label = $value
#        }
#    }

        my $seq = $seq_object->seq;
#        my $ohr = substr $seq, -4;
#        my $ohl = substr $seq, 0, 4;


#        my @type = split /-/ ,$label;
#        p @type[0];


#        print $label."\n";
#        print $ohl."\n";
#        print $ohr."\n";
#        print $seq."\n";

        my $self = {
            _label => $label,
            _file => $file,
            _seq  => $seq
#            _overhang_l => $ohl,
#            _overhang_r => $ohr
        };

        bless $self, $class;

        return $self;
#    } else {
#        print "could not find vector in $file, skipping.\n";
#        return undef;
    }
#}


1;