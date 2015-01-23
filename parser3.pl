#!/usr/bin/perl

use Modern::Perl;
use Data::Dumper;
use IO::All -utf8;
# use LWP::Simple;
# use JSON;
use Tie::Array::CSV;


# http://blogs.perl.org/users/joel_berger/2013/03/a-case-for-tiearraycsv.html

tie my @prots, 'Tie::Array::CSV', 'prots.csv';

tie my @yqls, 'Tie::Array::CSV', 'yql-results.csv';

# print $file[1][12];
 
# $file[1][12] = "EXTRA";

for my $prot (@prots) {
  print $prot;
  }
 

  for my $yql (@yqls) {
  print $yql;
  }
