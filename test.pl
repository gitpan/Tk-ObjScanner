# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tk ;
use ExtUtils::Embed ; 
use Tk::ObjScanner ;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

package toto ;

sub new
  {
    my $type = shift ;
    my $self = { 'key1' => 'value1',
                 'key2' => {
                            'sub key1' => 'sv1',
                            'sub key2' => 'sv2'
                           }
               } ;
    bless $self,$type;
  }


package main;

use strict ;
my $toto ;
my $mw = MainWindow-> new ;

my $w_menu = $mw->Frame(-relief => 'raised', -borderwidth => 2);
$w_menu->pack(-fill => 'x');

my $f = $w_menu->Menubutton(-text => 'File', -underline => 0) 
  -> pack(side => 'left' );
$f->command(-label => 'Quit',  -command => sub{exit;} );

print "creating dummy object \n";
my $dummy = new toto ;

print "Creating obj scanner\n";
my $scan = $mw -> ObjScanner('caller' => $dummy) -> pack ;


MainLoop ; # Tk's

