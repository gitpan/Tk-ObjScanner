package Tk::ObjScanner;

use strict;
use vars qw($VERSION @ISA $errno);

# Version 1.1805 - patches proposed by Rudi Farkas rudif@lecroy.com
# 1: Use Adjuster so that the user can adjust the relative heights of the 
# HList window and the dump window.
# 2: Provide 5 options for setting colors and images
# 3: Impose the same scrollbar style ('osoe') to HList and ROText.
# 4: Set -wideselection 0 for HList.
# The patches consist of code changes in sub Populate().

# Version 1.1803 - patch proposed by Rudi Farkas rudif@lecroy.com
# Purpose #1: fix the problem with call $scanner->configure();
#   dies with error 
# unknown option "oldcursor" at C:/Perl/site/lib/Tk/Derived.pm line 223.
# The patch consists of 
# - a modified ConfigSpecs line
#                     oldcursor => [$hlist, undef, undef, undef],
# Purpose #2: add 'open folder' image and display it when item has displayed children
# The patch consists of 
# - a line in sub Populate
#    $cw->{openImg} = $cw->Bitmap(-file => Tk->findINC('open_folder.xbm'));
# - method _redisplayImage()
# - 2 calls to _redisplayImage inside displaySubItem()

# Patch proposed by Rudi Farkas rudif@lecroy.com
# Purpose: while executing displaySubItem() which may take a long time
# if getting data from disk, another package or another machine,
# the default arrow cursor is replaced by a 'watch' cursor.
# The patch consists of
# - ConfigSpecs item : oldcursor => undef
# - method _swapCursor()
# - 3 calls to _swapCursor inside displaySubItem(), at entry and at 2 exits

use Carp ;
use Tk::Derived ;
use Tk::Frame;

@ISA = qw(Tk::Derived Tk::Frame);
*isa = \&UNIVERSAL::isa;

$VERSION = sprintf "%d.%03d", q$Revision: 1.22 $ =~ /(\d+)\.(\d+)/;

Tk::Widget->Construct('ObjScanner');

sub Populate
  {
    my ($cw,$args) = @_ ;

    require Tk::Menubutton ;
    require Tk::HList ;
    require Tk::ROText ;
    require Tk::Adjuster ;

    $cw->{chief} = delete $args->{'caller'} || delete $args->{'-caller'};

    my $destroyable = defined $args->{'destroyable'} ? 
      delete $args->{'destroyable'} : 1 ;

    croak "Missing caller argument in ObjScanner\n" 
      unless defined  $cw->{chief};

    my $title = delete $args->{title} || delete $args->{-title} 
      || ref($cw->{chief}).' scanner';

    my $background = delete $args->{'background'} 
      || delete $args->{'-background'} ;
    my $selectbackground = delete $args->{'selectbackground'} 
      || delete $args->{'-selectbackground'} ;

    $cw->{itemImg} = delete $args->{'itemImage'} 
      || delete $args->{'-itemImage'} 
        || $cw->Bitmap(-file => Tk->findINC('file.xbm'));
    $cw->{foldImg} = delete $args->{'foldImage'} 
      || delete $args->{'-foldImage'} 
        || $cw->Bitmap(-file => Tk->findINC('folder.xbm'));
    $cw->{openImg} = delete $args->{'openImage'} 
      || delete $args->{'-openImage'} 
        || $cw->Bitmap(-file => Tk->findINC('openfolder.xbm'));

    my $menuframe = $cw ->
      Frame (-relief => 'raised', -borderwidth => 1)-> 
        pack(pady => 2,  fill => 'x' ) ;

    my $menu = $cw->{menu}= $menuframe -> Menubutton 
      (-text => $title.' menu') 
          -> pack ( fill => 'x' , side => 'left');

    $menu -> command (-label => 'reload',
                      command => sub{$cw->updateListBox; });

    my $hlist=  $cw -> Scrolled
      (
       qw\HList -selectmode single -indent 35 -separator |
       -itemtype imagetext -wideselection 0 \,
      )-> pack ( qw/fill both expand 1 /) ;

    $hlist -> configure
      (
       -command => sub 
       {
         my $name = shift ;
         my $item = $hlist->info('data', $name); 
         #print "Double click $name, ref is", ref($item) ,".\n";
         $cw->displaySubItem($name,$item)
       }
      );

    $cw->Advertise(hlist => $hlist);
    
    my $adj1 = $cw->Adjuster()->packAfter($hlist);

    my $window = $cw->{dumpWindow} = 
      $cw -> Scrolled('ROText', height => 10)
        -> pack( -fill => 'both', -expand => 1) ;

    # add a destroy commend to the menu
    $menu -> command (-label => 'destroy', 
                      command => sub{$cw->destroy; }) if $destroyable ;

    $cw->ConfigSpecs
      (
       scrollbars=> ['DESCENDANTS', undef, undef, 'osoe'],
       -background => ['DESCENDANTS', 'background', 'Background', $background],
       -selectbackground => [$hlist, 'selectBackground', 'SelectBackground', 
                             $selectbackground],
       width => [$hlist, undef, undef, 80],
       height => [$hlist, undef, undef, 25],
       oldcursor => [$hlist, undef, undef, undef],
       DEFAULT => [$hlist]
      ) ;

    $cw->Delegates(DEFAULT => $hlist ) ;

    $cw->SUPER::Populate($args) ;

    $cw->{viewpseudohash} =1;

    $menuframe -> Checkbutton 
      (
       -text => 'view pseudo-hashes',
       -variable => \$cw->{viewpseudohash},
       -onvalue => 1, 
       -offvalue => 0,
       -command => sub{$cw->updateListBox;}
      ) -> pack(side => 'right');

    $cw->updateListBox;

    return $cw ;
  }

sub isObject
  {
    my $ref = shift ; # not a method !
    return 0 unless $ref ;
    return  
      scalar grep ($ref eq $_, qw/REF SCALAR CODE GLOB ARRAY HASH/) ? 0 : 1;
  }

# function to find whether a reference is a pseudo hash
# return the nb of elements of the pseudo hash
sub isPseudoHash 
  {
    my $cw = shift ;
    my $item = shift;

    return 0 unless (defined $item          &&
                     $cw->{viewpseudohash}  &&
                     isa($item,'ARRAY')     &&
                     scalar @$item          &&
                     ref $item->[0] eq 'HASH');

    my $ret = scalar keys %{ $item->[0] } ;
    return 0 unless $ret >= scalar @$item - 1;

    for (values %{ $item->[0] }) 
      {
        return 0 if ($_ !~ /^\d+$/ || $_ < 1);
      }
    return $ret ;
  }

sub updateListBox
  {
    my $cw = shift ;

    my $h = $cw->Subwidget('hlist');
    my $root = 'root';
    #print "root adding $root \n";
    if ($h->infoExists($root))
      {
        #print "deleting root children\n";
        $cw->{dumpWindow}->delete('1.0','end');
        $h->deleteOffsprings($root);

        # set new text of root
        $h->entryconfigure($root,-text => "ROOT:".$cw->element($cw->{chief}));
      }
    else
      {
        $h->add
          (
           $root,
           -text => "ROOT:".$cw->element($cw->{chief}),
           -image => $cw->{foldImg},
           -data => $cw->{chief} 
          ) 
      }

    $cw->displaySubItem($root,$cw->{chief});
  }

sub displaySubItem
  {
    my $cw = shift ;
    my $name = shift ;
    my $item = shift ;
    my $h = $cw->Subwidget('hlist');

    $cw->{dumpWindow}->delete('1.0','end');

    my @children = $h->infoChildren($name) ;

    foreach my $child ( @children ) 
      {
        if ($h->info('hidden',$child)) {$h->show('entry',$child);}
        else {$h->hide('entry',$child);}
      }
    $cw->_redisplayImage($name);
    return if scalar(@children) > 0;

    $cw->_swapCursor('watch');

    my $ref = ref($item) ;
    my $isObject = isObject($ref) ;

    my $isPseudoHash = $cw->isPseudoHash($item);

    #print "ref is $ref\n";
    if (not defined $item)
      {
        #print "adding scalar $name , $item is a scalar\n";
        $cw->{dumpWindow}->delete('1.0','end');
        $cw->{dumpWindow}->insert('end',"undefined value\n");
      }
    elsif (isa($item,'ARRAY') and not $isPseudoHash)
      {
        my $i;
        foreach (@$item)
          {
            #print "adding array item $i: $_,",ref($_),"\n";
            my $img = ref($_) ? $cw->{foldImg} : $cw->{itemImg} ;
            $h->addchild($name,
                         -image => $img,
                         -text => '['.$i++."]-> ".$cw->element($_), 
                         -data => $_);
          }
      }
    elsif (isa($item,'REF'))
      {
        $h->addchild($name,
                     -image => $cw->{foldImg},
                     -text => $cw->element($$item), 
                     -data => $$item);
      }
    elsif (isa($item,'SCALAR'))
      {
        $h->addchild($name,
                     -image => $cw->{itemImg},
                     -text => $cw->element($$item), 
                     -data => $$item);
      }
    elsif (isa($item,'CODE') or isa($item,'GLOB'))
      {
        if (isa($item, 'UNIVERSAL'))
          {
            my ($what) = ($item =~ /\b([A-Z]+)\b/);
            $cw->{dumpWindow}-> insert
              ('end', "Sorry, can't display a $what based $ref object");
           }
        else
          {
            $cw->{dumpWindow}->
              insert('end',"Sorry, can't display ".$ref." reference");
          }
      }
    elsif (isa($item, 'HASH') or $isPseudoHash)
      {
        # hash or object

        foreach (sort keys %$item)
          {
            #print "adding hash key $name|$_ ", ref($item->{$_}),"\n";

            my $img = ref($item->{$_}) ? $cw->{foldImg} : $cw->{itemImg} ;
            $h->addchild($name, 
                    -text => "{$_}-> ".$cw->element($item->{$_}),
                    -image => $img,
                    -data => $item->{$_});        
          }
      }
    elsif (defined $item)
      {
        #print "adding scalar $name , $item is a scalar\n";
        $cw->{dumpWindow}->insert('end',$item);
      }
    $cw->_swapCursor();
    $cw->_redisplayImage($name);
  }

sub element
  {
    my $cw = shift ;
    my $elt = shift;

    my ($what,$nb);
    my $pseudo = $cw->isPseudoHash($elt) ;

    my $ref = ref($elt) ;

    if (not defined $elt)
      {
        $what =  'undefined';
      }
    elsif ($ref and isa($elt,'UNIVERSAL'))
      {
        my $base ;
        if ($pseudo) {$base = 'PSEUDO-HASH';} 
        elsif (isa($elt,'SCALAR')) {$base = 'SCALAR'}
        elsif ($elt =~ /=([A-Z]+)\(/) {$base = $1 ;}
        else {$base = "some magic with $elt" ;}  # desperate measure
        $what = "$ref OBJECT based on $base";
      }
    elsif ($pseudo)
      {
        $what = 'PSEUDO-HASH';
      }
    elsif ($ref)
      {
        # a ref but not an object
        $what = $ref ;
      }
    elsif ($elt =~ /\n/)
      {
        # multi-line string
        $what =  'double click here to display value';
      }
    else
      {
        # plain scalar
        $what =  "'$elt'" ;        
      }
    
    if (defined $elt)
      {
        if ($pseudo)              {$nb = $pseudo;}
        elsif (isa($elt,'ARRAY')) {$nb = scalar @$elt}
        elsif (isa($elt,'HASH'))  {$nb = scalar keys(%$elt)}
      }

    $what .= " ($nb)" if defined $nb;
    return $what ;
  }

sub _swapCursor {
    my ($cw, $cursor) = @_;
    my $parent = $cw->parent;
    if (defined($cursor)) {
       $cw->{oldcursor} = $parent->cget('-cursor'); # save
       $parent->configure(-cursor => $cursor);      # replace
    }
    else {
        $parent->configure(-cursor => $cw->{oldcursor}); # restore
    }
    $parent->update;   # does not seem to be absolutely necessary
}

sub _redisplayImage {
    my ($cw, $name) = @_;
    my $h = $cw->Subwidget('hlist');
    my @children = $h->infoChildren($name);
    return if @children == 0;
    my $image = $h->info('hidden',$children[0]) ? $cw->{foldImg} : $cw->{openImg};
    $h->entryconfigure($name, '-image' => $image);
}

1;

__END__


=head1 NAME

Tk::ObjScanner - Tk data scanner

=head1 SYNOPSIS

  use Tk::ObjScanner;
  
  my $scanner = $mw->ObjScanner( caller => $object, 
                                 title=>"windows") -> pack ;
                                 
  my $mw -> ObjScanner
  (
   caller 		    => $object,
   title 		    => 'demo setting the scanner options',
   background 	    => 'white',
   selectbackground => 'beige',
   foldImage 		=> $mw->Photo(-file => Tk->findINC('folder.xpm')),
   openImage 		=> $mw->Photo(-file => Tk->findINC('openfolder.xpm')),
   itemImage 		=> $mw->Photo(-file => Tk->findINC('textfile.xpm')),
  )
  -> pack(expand => 1, fill => 'both') ;

=head1 DESCRIPTION

The scanner provides a GUI to scan the attributes of an object. It can
also be used to scan the elements of a hash or an array.

The scanner is a composite widget made of a L<Tk::HList> and a text
window (actually a L<TK::ROText>). This widget acts as a scanner to
the object (or hash ref) passed with the 'caller' parameter. The
scanner will retrieve all keys of the hash/object and insert them in
the HList.

When the user double clicks on a key, the corresponding value will be added
in the HList.

If the value is a scalar, the scalar will be displayed in the text window.
(Which is handy if the value is a multi-line string)

=head1 Constructor parameters

=over 4

=item *

caller: The ref of the object or hash or array to scan (mandatory).

=item *

title: the title of the menu created by the scanner (optional)

=item *

destroyable: If set, a menu entry will allow the user to destroy the scanner
widget. (optional, default 1) . You may want to set this parameter to 0 if
the destroy can be managed by a higher level object.

=item *

background: the background color for subwidgets (optional)

=item *

selectbackground: the select background color for HList (optional)

=item *

itemImage: the image for a scalar item (optional, default 'file.xbm')

=item *

foldImage: the image for a composite item (array or hash) when closed (optional, default 'folder.xbm')

=item *

openImage: the image for a composite item (array or hash) when open (optional, default 'openfolder.xbm')

=back

=head1 WIDGET-SPECIFIC METHODS

=head2 updateListBox

Update the keys of the listbox. This method may be handy if the
scanned object wants to update the listbox of the scanner 
when the scanned object gets new attributes.

=head1 CAVEATS

The name of the widget is misleading as any data (not only object) may
be scanned. This widget is in fact a DataScanner.

ObjScanner may fail if an object involves a lot of internal perl
magic.  In this case, I'd be glad to hear about and I'll try to fix
the problem.

ObjScanner does not detect recursive data structures. It will just
keep on displaying the tree until the user gets tired of clicking on
the HList items.

There's no sure way to detect if a reference is a pseudo-hash or
not. When a reference is believed to be a pseudo-hash, ObjScanner will
display the content of the reference like a hash. If the reference is
should not be displayed like a pseudo-hash, you can turn off the
pseudo-hash view with the check button on the top right of the widget.

=head1 THANKS

To Rudi Farkas for all the improvements provided to ObjScanner.

To Slaven Rezic for the propotype code of the pseudo-hash viewer.

=head1 AUTHOR

Dominique Dumont, Dominique_Dumont@grenoble.hp.com

Copyright (c) 1997-2001 Dominique Dumont. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Tk(3), Tk::HList(3)

=cut

