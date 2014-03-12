use strict;
use Test::More;
use Test::Deep;
use Test::RedisServer;
use Redis;
#use t::Util;
use t::StoreTestData;

BEGIN { use_ok 'FollowerLite' }

my $follower_lite;

my $user11 = {
    id           => 11,
    follow_users => [12,13]
};
my $user12 = {
    id           => 12,
    follow_users => [11,13]
};
my $user13 = {
    id           => 13,
    follow_users => [12]
};

subtest "setup redis" => sub {
    my $socket = $ENV{REDIS_SOCKET_POOL};
    my $redis  = Redis->new(sock => $socket );
    ok $redis->get('store_test_data');
    my $follower_lite = FollowerLite->new({ redis => $redis });
    isa_ok $follower_lite->redis, 'Redis';
};

subtest "tweet and pub" => sub {
    my $socket = $ENV{REDIS_SOCKET_POOL};
}

done_testing;
