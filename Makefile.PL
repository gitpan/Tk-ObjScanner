use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile
  (
   'NAME'	=> 'Tk::ObjScanner',
   'VERSION_FROM' => 'ObjScanner.pm',
   'dist' => {COMPRESS=>'gzip -9f', SUFFIX => 'gz'},
    PM            => 
   {  
    'ObjScanner.pm'   => '$(INST_LIB)/Tk/ObjScanner.pm',
    'demo/objscan.pl' => '$(INST_ARCHLIB)/Tk/demos/widtrib/objscan.pl'
   },
   ($] >= 5.005 ?
    (ABSTRACT   => 'A scanner to view an object\'s attribute',
     AUTHOR     => 'Dominique Dumont (domi@barrayar.grenoble.hp.com)') : ()),
   'PREREQ_PM' =>
   {
    'Tk' =>0,
    'Tk::Adjuster' => 0,
    'Tk::HList' => 0,
    'Tk::ROText' => 0
   }
);
