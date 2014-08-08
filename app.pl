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
#    my $params = $self->param('parts');
    $self->render("result");
#    $self->render(json => {hello => $params});
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

    my $splitter = 'GGAGTGAGACCGCAGCTGGCACGACAGGTTTGCCGACTGGAAAGCGGGCAGTGAGCGCAACGCAATTAATGTGAGTTAGCTCACTCATTAGGCACCCCAGGCTTTACACTTTATGCTTCCGGCTCGTATGTTGTGTGGAATTGTGAGCGGATAACAATTTCACACAGGAAACAGCTATGACCATGATTACGCCAAGCTTGCATGCCTGCAGGTCGACTCTAGAGGATCCCCGGGTACCGAGCTCGAATTCACTGGCCGTCGTTTTACAACGTCGTGACTGGGAAAACCCTGGCGTTACCCAACTTAATCGCCTTGCAGCACATCCCCCTTTCGCCAGCTGGCGTAATAGCGAAGAGGCCCGCACCGATCGCCCTTCCCAACAGTTGCGCAGCCTGAATGGCGAATGGCGCCTGATGCGGTATTTTCTCCTTACGCATCTGTGCGGTATTTCACACCGCATATGGTGCACTCTCAGTACAATCTGCTCTGATGCCGCATAGTTAAGCCAGCCCCGACACCCGCCAACACCCGCTGACGCGCCCTGACGGGCTTGTCTGCTCCCGGCATCCGCTTACAGACAAGCTGTGACGGTCTCACGCT';

    my $vector = $update->[0];
    my $parts = $update->[1];

    my $seqio_object_vector = Bio::SeqIO->new(-file => $vectorsFolder."/".$vector->{file} );
    my $seq_object_vector = $seqio_object_vector->next_seq;

    my $vector_seq = $seq_object_vector->seq;

    my @vectorSplit = split(/$splitter/, $vector_seq);
    my @finalParts;

    #add start of vector to part list
    my $newFeat = new Bio::SeqFeature::Generic(-start => 1, -end => length($vectorSplit[0]), -strand => 1, -primary_tag => 'left_vector');
    push (@finalParts, $newFeat);






    my $fullSeq = $vectorSplit[0];

    foreach my $realPart (@$parts) {
        my $ggFeature = undef;
        my $seqio_object_part = Bio::SeqIO->new(-file => $partsFolder."/".$realPart->{file} );
        my $seq_object_part = $seqio_object_part->next_seq;

        for my $feat_object ($seq_object_part->get_SeqFeatures) {
            if($feat_object->primary_tag eq $featureName){
                $ggFeature = $feat_object;
                last;
             }
        }

        if (defined($ggFeature)){

        my $startPoint = length($fullSeq);
        my $endPoint = length($fullSeq)+length($ggFeature->spliced_seq->seq);
        print "from $startPoint to $endPoint\n";

        $fullSeq = $fullSeq.$ggFeature->spliced_seq->seq;

        my $newFeat = new Bio::SeqFeature::Generic(-start => $startPoint, -end => $endPoint, -strand => 1, -primary_tag => $realPart->{label});
        push (@finalParts, $newFeat);

        }


     } #end loop


        #add end of vector to part list
        my $startPoint = length($fullSeq);
        my $endPoint = length($fullSeq)+length($vectorSplit[1]);
        my $newFeat = new Bio::SeqFeature::Generic(-start => $startPoint, -end => $endPoint, -strand => 1, -primary_tag => 'left_vector');
        push (@finalParts, $newFeat);


$fullSeq = $fullSeq.$vectorSplit[1];

my $output_seq_obj = Bio::Seq->new(-seq => $fullSeq,
                            -display_id => "CustomPart" );

$output_seq_obj->add_SeqFeature(@finalParts); #add all features

my $timestamp = int (gettimeofday * 1000);

my $io = Bio::SeqIO->new(-format => "genbank", -file => ">public/output/GG_output_$timestamp.gb" );
$io->write_seq($output_seq_obj);

#file created



$self->render(text => "output/GG_output_$timestamp.gb");
};









post '/savebridge' => sub {
    my $self = shift;
    my $request_object = $self->req;
    my $update = Mojo::JSON->new->decode( $self->req->body );

#   p $update;
    my $bridgeName = $update->[0];
    my $vector = $update->[1];
    my $parts = $update->[2];

    my $oid = $mango->db('goldengate')->collection('bridges')->insert({'name'=>$bridgeName, 'vector'=>$vector, 'parts'=>$parts});
    $self->redirect_to('/');
};

get '/loadbridge' => sub {
    my $self = shift;
    my $cursor = $mango->db('goldengate')->collection('bridges')->find;
    my $docs = $cursor->all;
    $self->render(json => $docs);
};


app->start;