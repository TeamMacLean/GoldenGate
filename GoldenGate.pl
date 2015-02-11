#!/usr/bin/env perl
use strict;
use warnings;

use Mojolicious::Lite;
use Mango;
use Mojo;
#use Mojo::Transaction::WebSocket;
use Data::Printer;
use JSON;
use Bio::SeqIO;
use Cwd            qw( abs_path );
use File::Basename qw( dirname );
use Bio::SeqFeature::Generic;
use Time::HiRes qw(gettimeofday);

my $mango = Mango->new('mongodb://localhost:27017');

my $partToReplaceInVector = 'Golden_Gate_Cas';
my $featureToPullFromPart = 'Golden_Gate_Par';
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
print("\n");
    my $self = shift;
#    body as json
    my $bodyDecoded = Mojo::JSON->new->decode( $self->req->body );
#    get vector from req
    my $vector = $bodyDecoded->[0];
#    get parts from req
    my $parts = $bodyDecoded->[1];


    my $areaToReplaceStart = 0;
    my $areaToReplaceEnd = 0;


#TWO MOST IMPORTANT PARTS OF THIS CODE
    my @goldenGateNewFeatures;
    my @partsFromVector;


#TODO get all features to be added

#FIXME ADD SUPPORT FOR CUSTOM SEQ

    foreach my $realPart (@$parts) {
    p $realPart;

        if($realPart->{file}){
        print "IT HAS A FILE\n";

            my $seqio_object_part = Bio::SeqIO->new(-file => $partsFolder."/".$realPart->{file} );
            my $seq_object_part = $seqio_object_part->next_seq;

            for my $feat_object ($seq_object_part->get_SeqFeatures) {
                if($feat_object->primary_tag eq $featureToPullFromPart){

                #TODO FIX LABEL
                $feat_object->primary_tag($realPart->{type});

p $feat_object;

                my $featureHash = {
                     feature => $feat_object,
                     seq => $seq_object_part->subseq($feat_object->start,$feat_object->end)
                };
                    push(@goldenGateNewFeatures, $featureHash);
                    last;
                }
            }
        } else {
            my $feat_object = Bio::SeqFeature::Generic->new(
                -primary      => $realPart->{type}, # -primary_tag is a synonym
            );
                my $featureHash = {
                    feature => $feat_object,
                    seq => $realPart->{seq}
                };
                push(@goldenGateNewFeatures, $featureHash);
                last;
        }
    }


#TODO get vector
    my $seqio_object_vector = Bio::SeqIO->new(-file => $vectorsFolder."/".$vector->{file} );
    my $seq_object_vector = $seqio_object_vector->next_seq;



#TODO JUST GET START AND END OF FEATURE TO REPLACE

    for my $feat_object ($seq_object_vector->get_SeqFeatures) {
        if($feat_object->primary_tag eq $partToReplaceInVector){
            print "YOU SHOULD SEE THIS ONLY ONCE!!!\n";
            $areaToReplaceStart = $feat_object->start-1;
            $areaToReplaceEnd = $feat_object->end+1;
         }
    }
    print("cannot have features between $areaToReplaceStart and $areaToReplaceEnd\n");


#TODO NOW PUT ALL TO ARRAY IF NOT IN RANGE TO REPLACED AREA
    for my $feat_object ($seq_object_vector->get_SeqFeatures) {
        if($feat_object->primary_tag ne $partToReplaceInVector){ #do not add the part we are removing to list
            if(!($feat_object->start > $areaToReplaceStart && $feat_object->start < $areaToReplaceEnd) || !($feat_object->end > $areaToReplaceStart && $feat_object->end < $areaToReplaceEnd)){ #is not in range or part being removed
                my $featureHash = {
                    feature => $feat_object,
                    seq => $seq_object_vector->subseq($feat_object->start,$feat_object->end)
                };
                push(@partsFromVector, $featureHash);
            }
        }
    }


#TODO REMOVE OVERHANGS HERE!!!!!!!!!!
my $looper = 0;
for my $f (@goldenGateNewFeatures){
if($looper > 0){
$f->{seq} = substr($f->{seq}, 4);
}
$looper+=1;
}


#TODO TELL FEATURES ABOUT POSITION DIFFERENCES

    my $lenRemoved = $areaToReplaceEnd - $areaToReplaceStart;

    print "amount removed = $lenRemoved\n";

    my $newFeaturesLength = 0;
    for my $f (@goldenGateNewFeatures){
    $newFeaturesLength+=length($f->{seq});
    }
    print "length to add = $newFeaturesLength\n";

    my $diffBetweenRemovedAndAdded = $newFeaturesLength - $lenRemoved;
    print "DIFF =  $diffBetweenRemovedAndAdded\n";

#TODO UPDATE FOR PART FEATURES
    my $tmp = $areaToReplaceStart;
    for my $f (@goldenGateNewFeatures){
        my $feature = $f->{'feature'};
        my $seq = $f->{seq};

        my $num = 0;
        $feature->start($tmp-$num);

        $tmp+=length($seq);
        $feature->end($tmp);
    }
#TODO UPDATE FOR VECTOR FEATURES
    for my $f (@partsFromVector){
        my $feature = $f->{'feature'};
        my $seq = $f->{'seq'};
        my $thisFeatureDiff = $feature->start() + $diffBetweenRemovedAndAdded;
        $feature->start($thisFeatureDiff+1);
        my $len = $feature->start()+length($seq)-1;
        $feature->end($len);
    }

#TODO PUT FULL SEQ TOGETHER
    my $beforeSplit = $seq_object_vector->subseq(1, $areaToReplaceStart);
    my $afterSplit = $seq_object_vector->subseq($areaToReplaceEnd, $seq_object_vector->length);
#    FIXME THESE MAY NEED TO BE -1'd and +1'd further up the channel



    my $finalSeq = $beforeSplit;
    for my $f (@goldenGateNewFeatures){
        $finalSeq.=$f->{'seq'};
        print " this seq $f->{'seq'}\n";
    }
    $finalSeq .= $afterSplit;


#    my $dog = length($afterSplit);
#    print "count this $dog\n";




#TODO TEST: FIND ALL FEATURES AGAIN
    #remove all features from vector
    $seq_object_vector->flush_SeqFeatures();


$seq_object_vector->seq($finalSeq);
#part features
    for my $f (@goldenGateNewFeatures){
        my $feature = $f->{'feature'};
        $seq_object_vector->add_SeqFeature($feature);
    }
#vector features
    for my $f (@partsFromVector){
        my $feature = $f->{'feature'};
        $seq_object_vector->add_SeqFeature($feature);
    }


#print "doing indexes\n";
#for my $f (@partsFromVector){
#    my $index = index($finalSeq, $f->{'seq'});
#    if ($index != -1) {
##    #    TODO set new start and end
##    #    TODO add feature to gb
#    } else {
#     print "COULD NOT FIND SEQ: $f->{'seq'}\n";
#    }
#}





#    $seq_object_vector->add_SeqFeature(@partsFromVector);
#    $seq_object_vector->add_SeqFeature(@goldenGateNewFeatures);







#p $seq_object_vector->seq;


#TODO generate output file
    #print output
#    p $seq_object_vector;

    my $timestamp = int (gettimeofday * 1000);
    my $io = Bio::SeqIO->new(-format => "genbank", -file => ">public/output/out_$timestamp.gb" );
    $io->write_seq($seq_object_vector);

#TODO render
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
