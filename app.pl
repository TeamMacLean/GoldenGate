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

my $mango = Mango->new('mongodb://localhost:27017');

my $partsFolder = dirname(abs_path($0)).'/data/Parts';
my $vectorsFolder = dirname(abs_path($0)).'/data/Vectors';

get '/' =>  sub {
    my $self = shift;
    $self->render("picker");
};

get '/result' =>  sub {
    my $self = shift;
#    my $params = $self->param('parts');
    $self->render("index");
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

    my $vector = $update->[0];
    my $parts = $update->[1];

    my $seqio_object_vector = Bio::SeqIO->new(-file => $vectorsFolder."/".$vector->{file} );
    my $seq_object = $seqio_object_vector->next_seq;
    print "Vector : $vector->{label} \n";
    p $seq_object;

#    foreach my $realPart (@$parts) {
#    print "Part : $realPart->{label}\n";
#        my $seqio_object_vector = Bio::SeqIO->new(-file => $partsFolder."/".$realPart->{file} );
#        my $seq_object = $seqio_object_vector->next_seq;
#        p $seq_object;
#     }


    $self->render('index');
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
    $self->render('index');
};

get '/loadbridge' => sub {
    my $self = shift;
    my $cursor = $mango->db('goldengate')->collection('bridges')->find;
    my $docs = $cursor->all;
    $self->render(json => $docs);
};


app->start;