use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile
  (
   'NAME'	=> 'Tk::ObjScanner',
   'VERSION' => '0.1',
   'dist' => {COMPRESS=>'gzip -9f', SUFFIX => 'gz'},
   'PREREQ_PM' =>
   {
    'Data::Dumper' => 0,
    'Tk::Multi' => 0
   }
);
