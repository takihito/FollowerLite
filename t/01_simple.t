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
    follow_users => [2,4,5,6,7]
};
my $user2 = {
    id           => 2,
    follow_users => [1,3,4,6,7]
};
my $user3 = {
    id           => 3,
    follow_users => [1,2,5,7]
};

my $socket = $ENV{REDIS_SOCKET_POOL};

subtest "setup redis" => sub {
    $follower_lite = FollowerLite->new({ redis => Redis->new(sock => $socket ) });
    isa_ok $follower_lite->redis, 'Redis';
};

subtest "store follow user" => sub {
    is $follower_lite->add_user($user1), scalar @{$user1->{follow_users}};
    is $follower_lite->add_user($user2), scalar @{$user2->{follow_users}};
    is $follower_lite->add_user($user3), scalar @{$user3->{follow_users}};
};

subtest "recommend user" => sub {
    $follower_lite = FollowerLite->new({
        redis => Redis->new(sock => $socket ),
        user_id => $user3->{id},
    });
    my $user_ids = $follower_lite->recommend_user_ids();
    cmp_deeply $user_ids, [4, 6];
};

subtest "friend follow follower " => sub {
    $follower_lite = FollowerLite->new({
        redis => Redis->new(sock => $socket ),
        user_id => $user3->{id},
    });
    ok !$follower_lite->is_friend($user1->{id});
    ok $follower_lite->is_friend($user2->{id});

    ok $follower_lite->is_follow($user1->{id});
    ok !$follower_lite->is_follower($user1->{id});
    ok $follower_lite->is_follower($user2->{id});
};


done_testing;
