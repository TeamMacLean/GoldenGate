package Part;
use strict;
use warnings;
use Bio::SeqIO;

my $featureName = 'Golden_Gate_Par';

sub new {

    my $class = shift;
    my $path = shift;

    my $seqio_object = Bio::SeqIO->new(-file => "$path" );
    my $seq_object = $seqio_object->next_seq;

    my $ggFeature = undef;

    for my $feat_object ($seq_object->get_SeqFeatures) {
        if($feat_object->primary_tag eq $featureName){
        print "found gg feature, breaking\n";
        $ggFeature = $feat_object;
        last;
        }
    }

    my $start = $ggFeature->location->start;
    my $end = $ggFeature->location->end;
    my $label = 'TODO';
    my $self = {
        _seqio  => $seqio_object,
        _seq  => $seq_object,
        _start => $start,
        _end => $end,
        _label => $label
    };

    bless $self, $class;

    return $self;
}

1;