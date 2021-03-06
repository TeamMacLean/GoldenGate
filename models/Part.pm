package Part;
use strict;
use warnings;
use Bio::SeqIO;
use JSON;
use Data::Printer;
use File::Basename;

my $featureName = 'Golden_Gate_Par';

sub new {

    my $class = shift;
    my $path = shift;
    my $file = shift;

    my $seqio_object = Bio::SeqIO->new(-file => "$path/$file" );
    my $seq_object = $seqio_object->next_seq;

    my $ggFeature = undef;

    for my $feat_object ($seq_object->get_SeqFeatures) {
        if($feat_object->primary_tag eq $featureName){
#        print "found gg feature, breaking\n";
        $ggFeature = $feat_object;
        last;
        }
    }

    my $label = 'unknown';
    my $type = 'unknown';

    if (defined($ggFeature)){
        my $start = $ggFeature->location->start;
        my $end = $ggFeature->location->end;


        if ($ggFeature->has_tag("label")){

        for my $value ($ggFeature->get_tag_values('label')) {
            $label = $value
        }
    }

        my $seq = $ggFeature->spliced_seq->seq;
        my $ohr = substr $seq, -4;
        my $ohl = substr $seq, 0, 4;

        $type = ( split( /_/,  basename($file) ))[1];

        my $self = {
            _label => $label,
            _seq  => $seq,
            _overhang_l => $ohl,
            _overhang_r => $ohr,
            _file => $file,
            _type => $type
        };

        bless $self, $class;

        return $self;
    } else {
        print "could not find gg part in $file, skipping.\n";
        return undef;
    }
}


1;