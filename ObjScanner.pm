package Tk::ObjScanner;

use strict;
use vars qw($VERSION @ISA $errno);

use Carp ;
use Tk::Derived ;
use Tk::Frame;

@ISA = qw(Tk::Derived Tk::Frame);

$VERSION = '0.2';

Tk::Widget->Construct('ObjScanner');

sub Populate
  {
    my ($cw,$args) = @_ ;
    
    require Tk::Menubutton ;
    require Tk::Listbox ;
    require Tk::Multi::Text ;

    my $title = 'scanner';
    $title = delete $args->{title} if defined $args->{title} ;

    $cw->{chief} = delete $args->{'caller'} ;
    croak "Missing caller argument in ObjScanner\n" 
      unless defined  $cw->{chief};

    my $gf = $cw -> Frame (relief => 'raised', borderwidth => 3 ) -> pack ;

    my $leftframe = $gf -> Frame -> 
      pack (side => 'left', -expand => 'yes', -fill => 'y');
    my $menuframe = $leftframe ->
      Frame (-relief => 'raised', -borderwidth => 2)-> 
        pack(pady => 2,  fill => 'x' ) ;

    my $menu = $cw->{menu}= $menuframe -> Menubutton 
      (-text => $title.' menu') 
          -> pack ( fill => 'x' , side => 'left');

    $menu -> command (-label => 'reload', 
                      command => sub{$cw->updateListBox; });

    #pack listbox
    my $w_frame = $leftframe ->Frame(-borderwidth => '.5c');
    $w_frame->pack(-side => 'top', -expand => 'yes', -fill => 'y');

    my $w_frame_scroll = $w_frame->Scrollbar;
    $w_frame_scroll->pack(-side => 'right', -fill => 'y');

    my $w_frame_scroll_h = $w_frame->Scrollbar(orient=>'horiz');
    $w_frame_scroll_h->pack(-side => 'bottom', -fill => 'x');

    my $w_frame_list = $w_frame->Listbox
      (
       #font => '-bitstream-prestige-medium-r-normal--16-100-72-72-m-60-hp-roman8',
       -xscrollcommand => [$w_frame_scroll_h => 'set'],
       -yscrollcommand => [$w_frame_scroll => 'set'],
       -setgrid        => 1,
       -height         => 5,
       width => 25
      );
    
    $w_frame_scroll->configure(-command => [$w_frame_list => 'yview']);
    $w_frame_scroll_h->configure(-command => [$w_frame_list => 'xview']);
    $w_frame_list->pack(-side => 'left', -expand => 'yes', -fill => 'both');

    # bind double key click
    $w_frame_list->bind
      (
       '<Double-1>' => 
       sub  {
	 my $item = shift ;
	 my $key = $item->get ('active') ;
         $cw->dumpKeyContent($key) ;
       }
      ) ;

    # fill list box 
    $cw->{listbox}= $w_frame_list ;
    $cw->updateListBox;

    #pack MultiText
    my $window = $cw->{dumpWindow} = 
      $gf -> MultiText ('menu_button' => $menu) -> pack(side => 'right') ;

    $window -> setSize(15,60);

    # add a destroy commend to the menu
    $menu -> command (-label => 'destroy', 
                      command => sub{$cw->destroy; });

    $cw->ConfigSpecs(DEFAULT => [$window]) ;
    $cw->Delegates(DEFAULT => $window ) ;
  }

sub dumpKeyContent
  {
    my $cw = shift ;
    my $key =  shift ; # key to dump
    
    my %hash ;
    $hash{$key} = $cw->{chief}{$key} ;
    $cw->listScan(\%hash) ;
  }

sub listScan
  {
    my $cw = shift ;
    my $ref =  shift ; # thing to dump, must be a hash ref

    my $key ;
    my $refs = [] ;
    my $names = [] ;
    foreach $key (keys %$ref)
      {
	push @$names, $key ;
	push @$refs, $ref->{$key} ;
      }
    require Data::Dumper;
    my $d = Data::Dumper->new ( $refs, $names ) ;
    $cw->{dumpWindow}->insertText($d->Dumpxs) ;
  }

sub updateListBox
  {
    my $cw = shift ;
    $cw->{listbox}->delete(0,'end') ;
    $cw->{listbox}->insert('end', sort  keys %{$cw->{chief}} );
  }

1;

__END__

=head1 NAME

Tk::ObjScanner - Tk composite widget object scanner

=head1 SYNOPSIS

  use Tk::Multi::Text;
  
  my $mgr = Tk::ObjScanner->new( caller => $object, [title=>"windows"]);

=head1 DESCRIPTION

The scanner is a composite widget made of a listbox and a test window
(actually a Multi::Text). This widget acts as a scanner to the object passed
with the 'caller' parameter. The scanner will 
retrieve all keys of the hash/object and insert them in the listbox.

When the user double clicks on the key, the value will be displayed in the 
text window. If the key value is itself a ref, the content of the ref 
is recursively displayed in the text window (thanks to Data::Dumper).

=head1 Constructor parameters

The mandatory 'caller' parameter will contains the ref of the object to 
scan.

The optionnal 'title' argument contains the title of the menu created by the 
scanner.

=head1 WIDGET-SPECIFIC METHODS

=head2 updateListBox

Update the keys of the listbox. This method may be handy if the scanned object
wants to update the listbox if it has defined some new keys.



=head1 AUTHOR

Dominique Dumont, Dominique_Dumont@grenoble.hp.com

=head1 SEE ALSO

perl(1), Tk(3), Tk::Multi::Text(3), Data::Dumper(3)

=cut

