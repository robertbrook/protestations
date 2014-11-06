#!/usr/bin/perl

use Modern::Perl;
use Text::CSV;
use Data::Dumper;
use IO::All -utf8;
use LWP::Simple;
use JSON;

my $csv = Text::CSV->new();

my $filename = 'records.csv';

my $lines = io $filename;

while ( my $row = $csv->getline($lines)) {
	
    my $title               = $row->[1];
    my $catalogue_reference = $row->[0];
    my @title_parts         = reverse split( " - ", $title );

    # 	say join ' --- ', @title_parts;

    my $nice_first = $title_parts[0];
    $nice_first =~ s/\.$//;       # trailing period
    $nice_first =~ s/^\s//;       # leading space
    $nice_first =~ s/\[\?\]//;    # leading space
    say "";
    say $nice_first;

    my $body = get(
'http://data.ordnancesurvey.co.uk/datasets/os-linked-data/apis/search?query='
          . $nice_first );
    say $body;
# 	say Dumper($body);
	}

