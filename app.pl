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

get '/picker' => sub {
my $self = shift;
 $self->render("picker");
};

get '/parts' => sub {
    my $self = shift;
            my $cursor = $mango->db('goldengate')->collection('parts')->find;
            my $docs = $cursor->all;
            $self->render(json => $docs);
};

post '/savegate' => sub {
    print 'saving new gate';
    my $self = shift;
    my $gateName = 'test';
    my $vec = '';
    my $pro = '';
    my $fiveu = '';
    my $nt2 = '';
    my $cds = '';
    my $ter = '';
    my $oid = $mango->db('goldengate')->collection('gates')->insert({'name'=>$gateName, 'vec'=>$vec, 'pro'=>$pro, '5u'=>$fiveu,'nt2'=>$nt2, 'cds'=>$cds, 'ter'=>$ter});
    print "new gate $oid\n";
};


app->start;