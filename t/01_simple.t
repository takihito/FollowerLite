use strict;
use Test::More;
use Test::Deep;
use Test::RedisServer;
use Redis;

BEGIN { use_ok 'FollowerLite' }

my $bamboo;

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

my $redis_server = Test::RedisServer->new();
my $socket = $redis_server->connect_info;

subtest "setup redis" => sub {
    $bamboo = FollowerLite->new({ redis => Redis->new(sock => $socket ) });
    isa_ok $bamboo->redis, 'Redis';
};

subtest "store follow user" => sub {
    is $bamboo->add_user($user1), scalar @{$user1->{follow_users}};
    is $bamboo->add_user($user2), scalar @{$user2->{follow_users}};
    is $bamboo->add_user($user3), scalar @{$user3->{follow_users}};
};

subtest "recommend user" => sub {
    $bamboo = FollowerLite->new({
        redis => Redis->new(sock => $socket ),
        user_id => $user3->{id},
    });
    my $user_ids = $bamboo->recommend_user_ids();
    cmp_deeply $user_ids, [4, 6];
};

subtest "user friend" => sub {
    $bamboo = FollowerLite->new({
        redis => Redis->new(sock => $socket ),
        user_id => $user3->{id},
    });
    ok !$bamboo->is_friend($user1->{id});
    ok $bamboo->is_friend($user2->{id});
};


done_testing;
