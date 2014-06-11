package Part;
#use strict;
#use warnings;
use Bio::SeqIO;

my $featureName = 'Golden_Gate_Par';

sub new
{

my $class = shift;
#    my $name = shift;
my $path = shift;


my $seqio_object = Bio::SeqIO->new(-file => "$path" );
my $seq_object = $seqio_object->next_seq;


for my $feat_object ($seq_object->get_SeqFeatures) {
    if($feat_object->primary_tag eq $featureName){
        print "FUCK YEA!\n";
    }
}

my $start = 'TODO';
my $end = 'TODO';
my $label = 'TODO';
my $self = {
#        _name => $name,
    _seqio  => $seqio_object,
    _seq  => $seq_object,
    _start => $start,
    _end => $end,
    _label => $label
};

#    print "$self->{_name}\n";
#    print "$self->{_seqio}\n";
#    print "$self->{_seq}\n";

#print;
#for my $feat_object ($self->{_seq}->get_SeqFeatures) {
#   print "primary tag: ", $feat_object->primary_tag, "\n";
#   for my $tag ($feat_object->get_all_tags) {
#      print "  tag: ", $tag, "\n";
#      for my $value ($feat_object->get_tag_values($tag)) {
#         print "    value: ", $value, "\n";
#      }
#   }
#}
#print;

bless $self, $class;

return $self;
}

1;