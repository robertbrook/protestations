#!/usr/bin/perl

use Modern::Perl;
use Text::CSV;
use Data::Dumper;
use IO::All -utf8;
use LWP::Simple;
use JSON;
use XML::LibXML '1.70';

my $parser = XML::LibXML->new();

my $csv = Text::CSV->new();

my $filename = 'records.csv';

my $lines = io $filename;

while ( my $row = $csv->getline($lines) ) {
    next if ( $. == 1 );
    my %r;
    my $title = $row->[1];
    $r{'catalogue_reference'} = $row->[0];
    $r{'title'}               = $row->[1];
    my $catalogue_reference = $row->[0];
    my @title_parts = split( " - ", $title );
    my @title_parts_reversed = reverse @title_parts;

    my $GLatLong;
    
    $r{'shire'} = $title_parts[1];

    my $nice_first = $title_parts_reversed[0];
    $nice_first =~ s/\.$//;       # trailing period
    $nice_first =~ s/^\s//;       # leading space
    $nice_first =~ s/\[\?\]//;    # leading space
    $r{'target'} = $nice_first;

    my $OSJSON = get(
'http://data.ordnancesurvey.co.uk/datasets/os-linked-data/apis/search?query='
          . $nice_first );
    my $OSResponse    = decode_json $OSJSON;
    my $OSFirstResult = shift $OSResponse->{results};
    if ($OSFirstResult) {
        if ( $OSFirstResult->{type} eq
            "http://data.ordnancesurvey.co.uk/ontology/admingeo/CivilParish" )
        {
            $r{'OS'} = [ $OSFirstResult->{latitude}, $OSFirstResult->{longitude} ];
        }
    }

    my $NOSMJSON = get(
'http://nominatim.openstreetmap.org/search/?email=robertbrook@fastmail.fm&format=json&countrycodes=gb&q='
          . $nice_first );
    my $NOSMResponse    = decode_json $NOSMJSON;
    my $NOSMFirstResult = shift $NOSMResponse;
    if ($NOSMFirstResult) {
        $r{'NOSM'} = [ $NOSMFirstResult->{lat}, $NOSMFirstResult->{lon} ];
    }

    #     my $GJSON =
    #       get(  'http://maps.googleapis.com/maps/api/geocode/json?address='
    #           . $nice_first
    #           . '&region=gb' );
    #     my $GResponse      = decode_json $GJSON;
    #     my $GFirstResult   = shift $GResponse->{results};
    #     my $GLatLongResult = $GFirstResult->{geometry}->{location};
    #     if ($GFirstResult) {
    #         $GLatLong = [ $GLatLongResult->{lat}, $GLatLongResult->{lng} ];
    #     }

    my $DEEPJSON =
      get(  'http://unlock.edina.ac.uk/ws/search?name='
          . $nice_first
          . '&searchVariants=false&gazetteer=deep&format=json' );
    my $DEEPResponse    = decode_json $DEEPJSON;
    my $DEEPFirstResult = shift $DEEPResponse->{features};
    my $DEEPProperties  = $DEEPFirstResult->{properties};
    if ( $DEEPFirstResult->{properties} ) {
        $r{'DEEP-centroid'} = [ reverse split( /,/, $DEEPProperties->{centroid} ) ];
        my $LocationsXML = $DEEPProperties->{locations};
        my $dom =
          XML::LibXML->load_xml(
            string => "<locations>$LocationsXML</locations>" );

        my $results = $dom->findnodes('//geo');

        foreach my $geo ( $results->get_nodelist ) {
            $r{ 'DEEP-' . $geo->findvalue('@source') } = [ $geo->findvalue('@lat'), $geo->findvalue('@long') ];
        }

    }

# http://unlock.edina.ac.uk/ws/search?name=appleford&searchVariants=false&format=json

    say Dumper {%r};
}

