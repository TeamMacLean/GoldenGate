#!/usr/bin/env perl
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
    my $partToReplace = 'Golden_Gate_Cas';
#    get vector from req
    my $vector = $update->[0];
#    get parts from req
    my $parts = $update->[1];
#    get io of vector
    my $seqio_object_vector = Bio::SeqIO->new(-file => $vectorsFolder."/".$vector->{file} );
    my $seq_object_vector = $seqio_object_vector->next_seq;
    my @finalParts;
    my $beforeBridgeSeq;
    my $afterBridgeSeq;
    my @features = $seq_object_vector->get_SeqFeatures(); # just top level
    my $seq = $seq_object_vector->seq;
    my $beforeBridgeLength;
    my $originalSeqLength = length($seq);
    my $bridgeLength = 0;
    my $splitDifference = 0;

    my $ggStart;
    my $ggEnd;



#all features
    foreach my $feat ( @features ) {

        if($feat->primary_tag ne $partToReplace){
            my $thisSeq = $feat->seq->seq();

            my $start = $feat->start+$splitDifference;
            my $end = $feat->end+$splitDifference;

            my $oldStart = $feat->start;
            my $oldEnd = $feat->end;

#            print($start, "\n");
#            print($thisSeq, "\n");

            if (defined($ggStart) && defined($ggEnd)){


#               if its within range of a removed feature
                unless ($oldStart > $ggEnd && $oldStart < $ggStart || $oldEnd > $ggStart && $oldEnd < $ggEnd) {
                    my $newFeat = new Bio::SeqFeature::Generic(-start => $start, -end => $end, -strand => $feat->strand, -primary_tag => $feat->primary_tag);
#                   TODO get tags
                    foreach my $tag ($feat->get_all_tags) {
                        my @fullTag = $feat->get_tag_values($tag);
                        $newFeat->add_tag_value($tag, $fullTag[0]);
                    }

                    push(@finalParts, $newFeat);
                }
            }
        } else {

$ggStart = $feat->start;
$ggEnd = $feat->end;

#print($ggStart, "\n");

            my $newLength = 0;


            $beforeBridgeSeq = substr($seq, 0, ($feat->start)-1);
            $afterBridgeSeq = substr($seq, $feat->end, length($seq)-1);

            my $removedLength = (length($seq) - length($beforeBridgeSeq)) - length($afterBridgeSeq);
            $beforeBridgeLength = length($beforeBridgeSeq);

            my @ggParts;


            foreach my $realPart (@$parts) {
                my $seqio_object_part = Bio::SeqIO->new(-file => $partsFolder."/".$realPart->{file} );
                my $seq_object_part = $seqio_object_part->next_seq;

                for my $feat_object ($seq_object_part->get_SeqFeatures) {
                    if($feat_object->primary_tag eq $featureName){
                        push(@ggParts, $feat_object);
                        last;
                     }
                }
            }
            my $ggPartsLength = scalar @ggParts;
            my $i = 1;
            foreach my $part (@ggParts) {
                my $thisSeq = $part->seq->seq();
                $newLength = $newLength+length($thisSeq);

#                This get the overlap correct
                my $overhangOffset = 0;

                if($i < $ggPartsLength){
                #needs over hangs removed
                    $thisSeq = substr($thisSeq, 0, length($thisSeq)-4);
                    $overhangOffset = 4;
                } else {
                #doesnt need over hangs removed
                    $thisSeq = substr($thisSeq, 0, length($thisSeq));
                }


                $i = $i+1;

                $beforeBridgeSeq = $beforeBridgeSeq . $thisSeq;

                my $start = index($beforeBridgeSeq, $thisSeq);
                my $end = $start+length($thisSeq);

                #TODO get label
                my $newFeat = new Bio::SeqFeature::Generic(-start => $start, -end => $end+$overhangOffset, -strand => 1, -primary_tag => $feat->primary_tag);

                push (@finalParts, $newFeat);
            }

            $splitDifference = $newLength - $removedLength;

            print($removedLength, "\n");
                        print($newLength, "\n");
                        print($splitDifference, "\n");
        }
    }

    my $merged_seq = $beforeBridgeSeq . $afterBridgeSeq;

    my $output_seq_obj = Bio::Seq->new(-seq => $merged_seq, -display_id => "CustomPart" );

    $output_seq_obj->add_SeqFeature(@finalParts);
    my $timestamp = int (gettimeofday * 1000);
    my $io = Bio::SeqIO->new(-format => "genbank", -file => ">public/output/out_$timestamp.gb" );
    $io->write_seq($output_seq_obj);

#   Render Out
    $self->render(text => "output/out_$timestamp.gb");
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


app->start();
