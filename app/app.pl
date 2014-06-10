use Mojolicious::Lite;

get '/' => {text => 'test'};
get '/json' => {json => }

app->start;