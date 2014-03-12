use strict;
use Test::More;
use Test::Deep;
use Test::RedisServer;
use Redis;
#use t::Util;

BEGIN { use_ok 'FollowerLite' }

my $follower_lite;

my $user1 = {
    id           => 1,
    follow_users => [2,3]
};
my $user2 = {
    id           => 2,
    follow_users => [1,3]
};
my $user3 = {
    id           => 3,
    follow_users => [2]
};

subtest "setup redis" => sub {
    my $socket = $ENV{REDIS_SOCKET_POOL};
    $follower_lite = FollowerLite->new({ redis => Redis->new(sock => $socket ) });
    isa_ok $follower_lite->redis, 'Redis';
};


done_testing;
