package TweetBlocker::Runner;
use 5.10.1;
use strict;
use warnings;
use Mouse;
use Net::Twitter::Lite::WithAPIv1_1;

has [qw(consumer_key consumer_secret access_token access_token_secret)] => (
    is => "ro",
    isa => "Str",
    required => 1,
);

has client => (
    is => "ro",
    isa => "Object",
    default => sub {
        my ($self) = @_;
        Net::Twitter::Lite::WithAPIv1_1->new(
            consumer_key        => $self->consumer_key,
            consumer_secret     => $self->consumer_secret,
            access_token        => $self->access_token,
            access_token_secret => $self->access_token_secret,
            ssl                 => 1,
        );
    },
);

no Mouse;

sub run {
    my ($self, $url) = @_;
    my $tweet_id = $self->split_url($url);
    my @users    = $self->fetch_users($tweet_id);
    $self->block(@users);
}

sub block {
    my ($self, @users) = @_;
    for my $user_id (@users) {
        my $res = $self->client->create_block({user_id => $user_id});
        say "Blocked: ", $res->{screen_name};
    }
}

sub split_url {
    my ($self, $url) = @_;
    [split(/\//, URI->new($url)->path)]->[-1];
}

sub fetch_users {
    my ($self, $tweet_id) = @_;
    my $res = $self->client->show_status({id => $tweet_id, trim_user => 0});
    my $search_res = $self->client->search({
        q           => "to:". $res->{user}{screen_name},
        count       => 100,
        result_type => "recent",
    });

    my @users;
    push @users, $res->{user}{id};
    for my $tweet (@{$search_res->{statuses}}) {
        next if (($tweet->{in_reply_to_status_id} || "") ne $tweet_id);
        push @users, $tweet->{user}{id};
    }

    @users;
}

1;
