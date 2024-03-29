
# This file was automatically generated by Dist::Zilla::Plugin::MakeMaker v5.019.
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "a GUI to scan any perl data structure or object",
  "AUTHOR" => "Dominique Dumont",
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Tk-ObjScanner",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Tk::ObjScanner",
  "PREREQ_PM" => {
    "B::Deparse" => 0,
    "Carp" => 0,
    "Data::Dumper" => 0,
    "Scalar::Util" => "1.01",
    "Tk" => 0,
    "Tk::Adjuster" => 0,
    "Tk::Derived" => 0,
    "Tk::Frame" => 0,
    "Tk::HList" => 0,
    "Tk::Menubutton" => 0,
    "Tk::ROText" => 0
  },
  "TEST_REQUIRES" => {
    "Benchmark" => 0,
    "FileHandle" => 0,
    "Math::BigInt" => 0,
    "Test::More" => 0,
    "Tie::Hash" => 0,
    "Tie::Scalar" => 0
  },
  "VERSION" => "2.016",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


my %FallbackPrereqs = (
  "B::Deparse" => 0,
  "Benchmark" => 0,
  "Carp" => 0,
  "Data::Dumper" => 0,
  "FileHandle" => 0,
  "Math::BigInt" => 0,
  "Scalar::Util" => "1.01",
  "Test::More" => 0,
  "Tie::Hash" => 0,
  "Tie::Scalar" => 0,
  "Tk" => 0,
  "Tk::Adjuster" => 0,
  "Tk::Derived" => 0,
  "Tk::Frame" => 0,
  "Tk::HList" => 0,
  "Tk::Menubutton" => 0,
  "Tk::ROText" => 0
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



