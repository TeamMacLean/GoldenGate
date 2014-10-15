use strict;
use warnings;
use Mojolicious::Lite;
use Mango;
use Mojo;
use Mojo::Transaction::WebSocket;
use Data::Printer;
use JSON;
use Bio::SeqIO;
use Cwd            qw( abs_path );
use File::Basename qw( dirname );
use Bio::SeqFeature::Generic;
use Time::HiRes qw(gettimeofday);

my $mango = Mango->new('mongodb://localhost:27017');
my $featureName = 'Golden_Gate_Par';
my $partsFolder = dirname(abs_path($0)).'/data/Parts';
my $vectorsFolder = dirname(abs_path($0)).'/data/Vectors';

get '/' =>  sub {
    my $self = shift;
    $self->render("picker");
};

get '/result' =>  sub {
    my $self = shift;
    $self->render("result");
};

get '/parts' => sub {
    my $self = shift;
            my $cursor = $mango->db('goldengate')->collection('parts')->find;
            my $docs = $cursor->all;
            $self->render(json => $docs);
};

get '/vectors' => sub {
    my $self = shift;
        my $cursor = $mango->db('goldengate')->collection('vectors')->find;
        my $docs = $cursor->all;
        $self->render(json => $docs);
};

post '/buildit' => sub {
    my $self = shift;
    my $request_object = $self->req;

    my $update = Mojo::JSON->new->decode( $self->req->body );


#    my $splitter = 'GGAGTGAGACCGCAGCTGGCACGACAGGTTTGCCGACTGGAAAGCGGGCAGTGAGCGCAACGCAATTAATGTGAGTTAGCTCACTCATTAGGCACCCCAGGCTTTACACTTTATGCTTCCGGCTCGTATGTTGTGTGGAATTGTGAGCGGATAACAATTTCACACAGGAAACAGCTATGACCATGATTACGCCAAGCTTGCATGCCTGCAGGTCGACTCTAGAGGATCCCCGGGTACCGAGCTCGAATTCACTGGCCGTCGTTTTACAACGTCGTGACTGGGAAAACCCTGGCGTTACCCAACTTAATCGCCTTGCAGCACATCCCCCTTTCGCCAGCTGGCGTAATAGCGAAGAGGCCCGCACCGATCGCCCTTCCCAACAGTTGCGCAGCCTGAATGGCGAATGGCGCCTGATGCGGTATTTTCTCCTTACGCATCTGTGCGGTATTTCACACCGCATATGGTGCACTCTCAGTACAATCTGCTCTGATGCCGCATAGTTAAGCCAGCCCCGACACCCGCCAACACCCGCTGACGCGCCCTGACGGGCTTGTCTGCTCCCGGCATCCGCTTACAGACAAGCTGTGACGGTCTCACGCT';

#    get vector from req
    my $vector = $update->[0];
#    get parts from req
    my $parts = $update->[1];

#    get io of vector
    my $seqio_object_vector = Bio::SeqIO->new(-file => $vectorsFolder."/".$vector->{file} );

    my $seq_object_vector = $seqio_object_vector->next_seq;

my @finalParts = [];
my $fullSeq = '';

my @features = $seq_object_vector->get_SeqFeatures(); # just top level
    foreach my $feat ( @features ) {
#	print "Feature ",$feat->primary_tag," starts ",$feat->start," ends ", $feat->end," strand ",$feat->strand,"\n";

        # features retain link to underlying sequence object
        my $thisSeq = $feat->seq->seq();
#        print "Feature sequence is ",$thisSeq,"\n";


#        push(@finalParts, $feat);
        $fullSeq = $fullSeq . $thisSeq;
    }

my $output_seq_obj = Bio::Seq->new(-seq => $fullSeq, -display_id => "CustomPart" );


$output_seq_obj->add_SeqFeature(@features);


my $timestamp = int (gettimeofday * 1000);
#
my $io = Bio::SeqIO->new(-format => "genbank", -file => ">public/output/GG_output_$timestamp.gb" );
$io->write_seq($output_seq_obj);

$self->render(text => "output/GG_output_$timestamp.gb");

};









post '/savebridge' => sub {
    my $self = shift;
#    my $request_object = $self->req;
#    my $update = Mojo::JSON->new->decode( $self->req->body );
#
##   p $update;
#    my $bridgeName = $update->[0];
#    my $vector = $update->[1];
#    my $parts = $update->[2];
#
#    my $oid = $mango->db('goldengate')->collection('bridges')->insert({'name'=>$bridgeName, 'vector'=>$vector, 'parts'=>$parts});
    $self->redirect_to('/');
};

get '/loadbridge' => sub {
    my $self = shift;
#    my $cursor = $mango->db('goldengate')->collection('bridges')->find;
#    my $docs = $cursor->all;
#    $self->render(json => $docs);
        $self->redirect_to('/');
};


app->start;