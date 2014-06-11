use strict;
use warnings;
use Mojolicious::Lite;

get '/' => 'index';
app->start;