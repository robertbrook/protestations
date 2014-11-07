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

while ( my $row = $csv->getline($lines) ) {
    next if ( $. == 1 );
    my $title               = $row->[1];
    my $catalogue_reference = $row->[0];
    my @title_parts         = reverse split( " - ", $title );
    
    my $OSLatLong;
    my $NOSMLatLong;

    # 	say join ' --- ', @title_parts;

    my $nice_first = $title_parts[0];
    $nice_first =~ s/\.$//;       # trailing period
    $nice_first =~ s/^\s//;       # leading space
    $nice_first =~ s/\[\?\]//;    # leading space
    say "";

    my $OSJSON = get(
'http://data.ordnancesurvey.co.uk/datasets/os-linked-data/apis/search?query='
          . $nice_first );
    my $OSResponse    = decode_json $OSJSON;
    my $OSFirstResult = shift $OSResponse->{results};
    if ($OSFirstResult) {
        if ( $OSFirstResult->{type} eq
            "http://data.ordnancesurvey.co.uk/ontology/admingeo/CivilParish" )
        {
            $OSLatLong = [$OSFirstResult->{latitude}, $OSFirstResult->{longitude}] || [];
        }
    }    
    

    my $NOSMJSON = get(
'http://nominatim.openstreetmap.org/search/?email=robertbrook@fastmail.fm&format=json&countrycodes=gb&q='
          . $nice_first );
    my $NOSMResponse    = decode_json $NOSMJSON;
    my $NOSMFirstResult = shift $NOSMResponse;
    if ($NOSMFirstResult) {
    $NOSMLatLong = [$NOSMFirstResult->{lat}, $NOSMFirstResult->{lon}] || [];
    }
    
    say Dumper {"Name" => $nice_first, "OS" => $OSLatLong, "NOSM" => $NOSMLatLong};

}

# http://www.openstreetmap.org/#map=14/51.0076/-2.8466

