#!/usr/bin/perl

use Modern::Perl;
use Text::CSV;
use Data::Dumper;
use IO::All -utf8;
use LWP::Simple;
use JSON;
use XML::LibXML '1.70';



my $g = {
    type     => "FeatureCollection",
    features => []
};

my $parser = XML::LibXML->new();

my $csv = Text::CSV->new(
    {
        binary    => 1,    # Allow special character. Always set this
        auto_diag => 1,    # Report irregularities immediately
    }
);

my $filename = 'records.csv';

my @lines = io $filename;

while ( my $row = $csv->getline(@lines) ) {
    next if ( $. == 1 );
    last if ( $. == 2000 );
    my $title = $row->[1];

    my $catalogue_reference  = $row->[0];
    my @hh = split("/", $catalogue_reference);
		pop @hh;
		my $portref = "<a href='http://www.portcullis.parliament.uk/CalmView/Record.aspx?src=CalmView.Catalog&id=" . join("%2f", @hh) . "'>Portcullis</a>";
    my @title_parts          = split( " - ", $title );
    my @title_parts_reversed = reverse @title_parts;

    my $shire = $title_parts[1];

    my $nice_first = $title_parts_reversed[0];
    $nice_first =~ s/\.$//;       # trailing period
    $nice_first =~ s/^\s//;       # leading space
    $nice_first =~ s/\[\?\]//;    # leading space
    
	my $YJSON = get('http://query.yahooapis.com/v1/public/yql?q=SELECT%20*%20FROM%20geo.placefinder%20WHERE%20name%3D%22' . $nice_first . '%22%20and%20locale%3D%22GB%22%20%7C%20truncate(count%3D1)&format=json');
    my $YResponse    = decode_json $YJSON;
    
        if ( $YResponse->{query}->{results}->{Result}->{countrycode}  eq
            "GB" )
        {
			my $YLong = $YResponse->{query}->{results}->{Result}->{longitude};
			my $YLat = $YResponse->{query}->{results}->{Result}->{latitude};
            push(
                $g->{features},
                {
                    'type'   => "Feature",
                    geometry => {
                        type        => "Point",
                        coordinates => [
                            $YLong + 0,
                            $YLat + 0
                        ]
                    },
                    properties => {
                        name      => $nice_first,
                        source    => "YQL",
                        reference => $catalogue_reference,
                        href => $portref
                      }

                }
            );

        }


    my $OSJSON = get(
'http://data.ordnancesurvey.co.uk/datasets/os-linked-data/apis/search?query='
          . $nice_first );
    my $OSResponse    = decode_json $OSJSON;
    my $OSFirstResult = shift $OSResponse->{results};
    if ($OSFirstResult) {
        if ( $OSFirstResult->{type} eq
            "http://data.ordnancesurvey.co.uk/ontology/admingeo/CivilParish" )
        {

            push(
                $g->{features},
                {
                    'type'   => "Feature",
                    geometry => {
                        type        => "Point",
                        coordinates => [
                            $OSFirstResult->{longitude} + 0,
                            $OSFirstResult->{latitude} + 0
                        ]
                    },
                    properties => {
                        name      => $nice_first,
                        source    => "OS",
                        reference => $catalogue_reference,
                        href => $portref
                      }

                }
            );

        }
    }

    my $NOSMJSON = get(
'http://nominatim.openstreetmap.org/search/?email=robertbrook@fastmail.fm&format=json&countrycodes=gb&q='
          . $nice_first );
    my $NOSMResponse    = decode_json $NOSMJSON;
    my $NOSMFirstResult = shift $NOSMResponse;
    if ($NOSMFirstResult) {
    
		
		
        push(
            $g->{features},
            {
                'type'   => "Feature",
                id       => $catalogue_reference,
                geometry => {
                    type        => "Point",
                    coordinates => [
                        $NOSMFirstResult->{lon} + 0,
                        $NOSMFirstResult->{lat} + 0
                    ]
                },
                properties => {
                    name      => $nice_first,
                    source    => "OSM",
                    reference => $catalogue_reference,
                    
                    
                    href => $portref
                  }

            }
        );

    }

    my $GJSON =
      get(  'http://maps.googleapis.com/maps/api/geocode/json?address='
          . $nice_first
          . '&region=gb' );
    my $GResponse      = decode_json $GJSON;
    my $GFirstResult   = shift $GResponse->{results};
    my $GLatLongResult = $GFirstResult->{geometry}->{location};
    if ($GFirstResult) {

        push(
            $g->{features},
            {
                'type'   => "Feature",
                id       => $catalogue_reference,
                geometry => {
                    type        => "Point",
                    coordinates => [
                        $GLatLongResult->{lng} + 0, $GLatLongResult->{lat} + 0
                    ]
                },
                properties => {
                    name      => $nice_first,
                    source    => "Google",
                    reference => $catalogue_reference
                  }

            }
        );

    }

    my $DEEPJSON =
      get(  'http://unlock.edina.ac.uk/ws/search?name='
          . $nice_first
          . '&searchVariants=false&gazetteer=deep&format=json' );
    my $DEEPResponse    = from_json $DEEPJSON;
    my $DEEPFirstResult = shift $DEEPResponse->{features};
    my $DEEPProperties  = $DEEPFirstResult->{properties};
    if ( $DEEPFirstResult->{properties} ) {
        my ($DEEPCentroidLat, $DEEPCentroidLong)  =
          [ reverse split( /,/, $DEEPProperties->{centroid} ) ];
        my $LocationsXML = $DEEPProperties->{locations};
        my $dom =
          XML::LibXML->load_xml(
            string => "<locations>$LocationsXML</locations>" );

        my $results = $dom->findnodes('//geo');

        foreach my $geo ( $results->get_nodelist ) {
            my $long = sprintf( "%g", $geo->findvalue('@long') );
            my $lat  = sprintf( "%g", $geo->findvalue('@lat') );

            push(
                $g->{features},
                {
                    'type'   => "Feature",
                    id       => $catalogue_reference,
                    geometry => {
                        type        => "Point",
                        coordinates => [ $long + 0, $lat + 0 ]
                    },
                    properties => {
                        name      => $nice_first,
                        source    => "DEEP-" . $geo->findvalue('@source'),
                        reference => $catalogue_reference
                      }

                }
            );
        }

    }

# http://unlock.edina.ac.uk/ws/search?name=appleford&searchVariants=false&format=json

    say "Processing $nice_first";

}

my $gjson = to_json $g;

$gjson > io('file.json');

# https://github.com/blog/1541-geojson-rendering-improvements

