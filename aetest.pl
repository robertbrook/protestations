use AnyEvent::HTTP::LWP::UserAgent;
use Coro;
use Data::Dumper;

my @demo = ();

for (1..100) {
push @demo, 'http://membersdataportal.digiminster.com/member/' . $_;
}
 
my $ua = AnyEvent::HTTP::LWP::UserAgent->new;
my @urls = @demo;
my @coro = map {
    my $url = $_;
    async {
        my $r = $ua->head($url);
        print "url $url\n";
    }
} @urls;
$_->join for @coro;

