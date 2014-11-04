use Modern::Perl;
use Text::CSV;
use Data::Dumper;
use IO::All -utf8;
use HTTP::Tiny;

my $csv = Text::CSV->new();

my $filename = 'records.csv';

my $lines = io $filename;

while ( my $row = $csv->getline( $lines ) ) {
	my @bits = split(" - ", $row->[1]);
	if (defined $bits[4]) {
	my $target = $bits[4];
    my $response = HTTP::Tiny->new->get('http://data.ordnancesurvey.co.uk/datasets/os-linked-data/apis/search?query=' . $target);
    say "Looking for $target";
    say "";
    say $response->{content};
    say "";
    }
    
 }
 
 
