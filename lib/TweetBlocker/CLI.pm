package TweetBlocker::CLI;
use strict;
use warnings;
use TweetBlocker::Runner;
use Config::Pit;


sub run {
    my ($class, @args) = @_;
    my $url = $args[0] or die "required url";
    my $config = pit_get("twitter.com");
    my $blocker = TweetBlocker::Runner->new($config);
    $blocker->run($url);
}

1;
