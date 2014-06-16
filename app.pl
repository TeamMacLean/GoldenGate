use strict;
use warnings;
use Mojolicious::Lite;
use Mango;
use Mojo::Transaction::WebSocket;
use Data::Printer;
use JSON;

my $mango = Mango->new('mongodb://localhost:27017');

get '/' =>  sub {
my $self = shift;
$self->render("index");
};

my $clients = {};

websocket '/echo' => sub {
        my $self = shift;

        my $cursor = $mango->db('goldengate')->collection('parts')->find;
        my $docs = $cursor->all;
        $self->send({json => $docs});
    };



app->start;