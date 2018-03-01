#!/usr/bin/env perl

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'SeqWare::Html',
    VERSION_FROM      => 'lib/SeqWare/Html.pm', # finds $VERSION, requires EU::MM from perl >= 5.5
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ABSTRACT_FROM     => 'lib/SeqWare/Html.pm', # retrieve abstract from module
    AUTHOR            => 'Genome Sequence Informatics, Ontario Institute for Cancer Research (http://oicr.on.ca)',
    LICENSE           => 'mit',
);
