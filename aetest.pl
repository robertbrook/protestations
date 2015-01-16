use AnyEvent::HTTP::LWP::UserAgent;
use Coro;
# use Data::Dumper;
use IO::All;

my @demo = io('urls.txt')->slurp;
 
my $ua = AnyEvent::HTTP::LWP::UserAgent->new;
my @urls = @demo;
my @coro = map {
    my $url = $_;
    async {
        my $got = $ua->get($url);
        print $got->decoded_content . "\n";
        $got->decoded_content >> io('file.txt');
    }
} @urls;
$_->join for @coro;

