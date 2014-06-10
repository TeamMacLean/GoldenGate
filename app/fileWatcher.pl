use File::ChangeNotify;

my $watcher =
    File::ChangeNotify->instantiate_watcher
        ( directories => [ '../public/inputs' ],
          regex       => qr/\.(?:gb|genbank)$/,
        );

if ( my @events = $watcher->new_events() ) { ... }

$watcher->watch($handler);