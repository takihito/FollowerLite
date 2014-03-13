package t::StoreTestData;

use strict;
use warnings;
use parent 'Exporter';

use FollowerLite;
use Module::Functions;

our @EXPORT = Module::Functions::get_public_functions;

our $redis;
our $follower_lite;

sub import {
    my $socket = $ENV{REDIS_SOCKET_POOL};
    $redis  = Redis->new(sock => $socket );
    $follower_lite = FollowerLite->new({ redis => $redis });
    # 全テスト共通
    unless ( $redis->get(__PACKAGE__)  ) {
        $redis->set(__PACKAGE__, $socket);
        $redis->set('store_test_data', 1);
        create_user();
        print "Store test data\n";
    }
    __PACKAGE__->export_to_level(1, @_);
    return 1;
}

sub apptest {
    my ($class, $note, $code) = @_;
    Test::More::subtest($note, $code);
}

sub follower_lite {
    return $follower_lite;
}

sub redis {
    return $redis;
}


sub create_user {
    my $user101 = user_data('user101');
    my $user102 = user_data('user102');
    my $user103 = user_data('user103');
    $follower_lite->load_user($user101->{id})->add_follow($user101->{follow_users});
    $follower_lite->load_user($user102->{id})->add_follow($user102->{follow_users});
    $follower_lite->load_user($user103->{id})->add_follow($user103->{follow_users});
}

sub user_data {
    my $user = shift;
    my $data = _user_mock_data();
    return $data->{$user}
}

sub _user_mock_data {
    return {
        user1   => { id => 1,   follow_users => [2,4,5,6,7] },
        user2   => { id => 2,   follow_users => [1,3,4,6,7] },
        user3   => { id => 3,   follow_users => [1,2,5,7] },
        user11  => { id => 11,  follow_users => [12,13] },
        user12  => { id => 12,  follow_users => [11,13] },
        user13  => { id => 13,  follow_users => [12] },
        user101 => { id => 101, follow_users => [102,103] },
        user102 => { id => 102, follow_users => [101,103] },
        user103 => { id => 103, follow_users => [102] },
    };
}

1;
