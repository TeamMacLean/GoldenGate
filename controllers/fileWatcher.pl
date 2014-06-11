use warnings;
use strict;
use File::ChangeNotify;

my $watcher =
     File::ChangeNotify->instantiate_watcher
         ( directories => [ '/tmp' ]
         );


 # blocking
 while ( my @events = $watcher->wait_for_events() ) {
 print "new event\n";
 #PROCESS IT!
 }