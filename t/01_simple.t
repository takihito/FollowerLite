use strict;
use Test::More;
use Test::Deep;
use Test::RedisServer;
use Redis;
use t::StoreTestData::Simple;

BEGIN { use_ok 'FollowerLite' }

my $socket = $ENV{REDIS_SOCKET_POOL};
my $user1 = user_data('user1');
my $user2 = user_data('user2');
my $user3 = user_data('user3');
my $follower_lite;

subtest "setup redis" => sub {
    my $redis  = Redis->new(sock => $socket );
    ok $redis->get('store_test_data');
    $follower_lite = FollowerLite->new({ redis => $redis });
    isa_ok $follower_lite->redis, 'Redis';
};

subtest "load user" => sub {
    my $fl_user = $follower_lite->load_user($user1->{id});
    isa_ok $fl_user, 'FollowerLite::User';
};

subtest "store follow user" => sub {
    my $fl_user1 = $follower_lite->load_user($user1->{id});
    is $fl_user1->add_follow($user1->{follow_users}), scalar @{$user1->{follow_users}};
    my $fl_user2 = $follower_lite->load_user($user2->{id});
    is $fl_user2->add_follow($user2->{follow_users}), scalar @{$user2->{follow_users}};
    my $fl_user3 = $follower_lite->load_user($user3->{id});
    is $fl_user3->add_follow($user3->{follow_users}), scalar @{$user3->{follow_users}};
};

subtest "recommend user" => sub {
    my $fl_user = $follower_lite->load_user($user3->{id});
    my $user_ids = $fl_user->recommend_user_ids();
    cmp_deeply $user_ids, [4, 6];
};

subtest "friend follow follower " => sub {
    t::StoreTestData::Simple::create_friend_user();
    my $user101 = user_data('user101');
    my $user102 = user_data('user102');
    my $user103 = user_data('user103');
    my $fl_user101 = $follower_lite->load_user($user101->{id});
    my $fl_user103 = $follower_lite->load_user($user103->{id});
    ok !$fl_user103->is_friend($user101->{id});
    ok $fl_user103->is_friend($user102->{id});
    ok $fl_user103->is_follow($user102->{id});
    ok $fl_user103->is_follower($user102->{id});
    ok !$fl_user101->is_follower($user103->{id});
};


done_testing;
