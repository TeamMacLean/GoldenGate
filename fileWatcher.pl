use File::ChangeNotify;

my $watcher =
    File::ChangeNotify->instantiate_watcher
        ( directories => [ './' ]
#          ,regex       => qr/\.(?:gb|genbank)$/
        );

if ( my @events = $watcher->new_events() ) {
# let app know there are more/less files and needs to rebuild db.
 }

$watcher->watch($handler);