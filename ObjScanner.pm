package Tk::ObjScanner;

use strict;
use vars qw($VERSION @ISA $errno);

use Carp ;
use Tk::Derived ;
use Tk::Frame;

@ISA = qw(Tk::Derived Tk::Frame);

$VERSION = '0.5';

Tk::Widget->Construct('ObjScanner');

sub Populate
  {
    my ($cw,$args) = @_ ;
    
    require Tk::Menubutton ;
    require Tk::Listbox ;
    require Tk::Multi::Text ;

    $cw->{chief} = delete $args->{'caller'} || delete $args->{'-caller'};
    croak "Missing caller argument in ObjScanner\n" 
      unless defined  $cw->{chief};

    my $title = delete $args->{title} || delete $args->{-title} ||
      ref($cw->{chief}).' scanner';

    my $leftframe = $cw -> Frame (bg => 'red')-> 
      pack (side => 'left', -fill => 'both');
    my $menuframe = $leftframe ->
      Frame (-relief => 'raised', -borderwidth => 2)-> 
        pack(pady => 2,  fill => 'x' ) ;

    my $menu = $cw->{menu}= $menuframe -> Menubutton 
      (-text => $title.' menu') 
          -> pack ( fill => 'x' , side => 'left');

    $menu -> command (-label => 'reload', 
                      command => sub{$cw->updateListBox; });

    #pack listbox
    my $sList = $leftframe->
      Scrolled('Listbox', -scrollbars => 'osoe') ->
      pack(-expand => 1, -fill => 'both');

    # bind double key click
    $sList->bind
      (
       '<Double-1>' => 
       sub  {
	 my $item = shift ;
	 my $key = $item->get ('active') ;
         $cw->dumpKeyContent($key) ;
       }
      ) ;

    # fill list box 
    $cw->{listbox}= $sList ;
    $cw->updateListBox;

    #pack MultiText
    my $window = $cw->{dumpWindow} = 
      $cw -> MultiText ('menu_button' => $menu ->cget('menu'))
        -> pack(side => 'right',-expand => 'yes', -fill => 'both') ;

    # add a destroy commend to the menu
    $menu -> command (-label => 'destroy', 
                      command => sub{$cw->destroy; });

    $cw->ConfigSpecs(
                     'scrollbars'=> [$window, undef, undef,'osoe'],
                     width => [$window, undef, undef, 60],
                     height => [$window, undef, undef, 15],
                     DEFAULT => [$window]) ;
    $cw->Delegates(DEFAULT => $window ) ;

    $cw->SUPER::Populate($args) ;
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

Copyright (c) 1997-1998 Dominique Dumont. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Tk(3), Tk::Multi::Text(3), Data::Dumper(3)

=cut

