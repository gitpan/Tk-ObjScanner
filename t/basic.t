# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..4\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tk ;
use ExtUtils::testlib ; 
use Tk::ObjScanner ;
$loaded = 1;
my $idx = 1;
print "ok ",$idx++,"\n";
my $trace = shift || 0 ;

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

package Toto ;

sub new
  {
    my $type = shift ;

    # add recursive data only if interactive test
    my $tkstuff = $trace ? shift : "may be another time ..." ;

    my $scalar = 'dummy scalar ref value';
    open (FILE,"t/basic.t") || die "can't open myself !\n";
    my $glob = \*FILE ; # ???
    my $self = 
      {
       'key1' => 'value1',
       'array' => [qw/a b sdf/, {'v1' => '1', 'v2' => 2},'dfg'],
       'key2' => {
                  'sub key1' => 'sv1',
                  'sub key2' => 'sv2'
                 },
       'some_code' => sub {print "some_code\n";},
       'piped|key' => {a => 1 , b => 2},
       'scalar_ref_ref' => \\$scalar,
       'filehandle' => $glob,
       'empty string' => '',
       'non_empty string' => ' ',
       'long' => 'very long line'.'.' x 80 ,
       'is undef' => undef,
       'some text' => "some \n dummy\n Text\n",
       'tk widget' => $tkstuff
      };
    
    bless $self,$type;
  }


package main;

use strict ;
my $toto ;
my $mw = MainWindow-> new ;
$mw->geometry('+10+10');

my $w_menu = $mw->Frame(-relief => 'raised', -borderwidth => 2);
$w_menu->pack(-fill => 'x');

my $f = $w_menu->Menubutton(-text => 'File', -underline => 0) 
  -> pack(side => 'left' );
$f->command(-label => 'Quit',  -command => sub{$mw->destroy;} );

print "creating dummy object \n" if $trace ;
my $dummy = new Toto ($mw);

print "ok ",$idx++,"\n";

print "Creating obj scanner\n" if $trace ;
my $s = $mw -> ObjScanner
  (
   'caller' => $dummy, 
   #destroyable => 0,
   title => 'test scanner'
  );

$s -> pack(expand => 1, fill => 'both') ;

print "ok ",$idx++,"\n";

$mw->idletasks;

sub scan
  {
    my $topName = shift ;
    $s->yview($topName) ;
    $mw->after(200); # sleep 300ms

    foreach my $c ($s->infoChildren($topName))
      {
        my $item = $s->info('data', $c);
        $s->displaySubItem($c,$item);
        scan($c);
      }
    $mw->idletasks;
  }

if ($trace)
  {
    MainLoop ; # Tk's
  }
else
  {
    scan('root');
  }

print "ok ",$idx++,"\n";

