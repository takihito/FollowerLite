package t::StoreTestData::Simple;

use strict;
use warnings;
use parent 't::StoreTestData';
use t::StoreTestData;
use Test::More;

sub create_friend_user {
    my $user101 = user_data('user101');
    my $user102 = user_data('user102');
    my $user103 = user_data('user103');
    follower_lite()->load_user($user101->{id})->add_follow($user101->{follow_users});
    follower_lite()->load_user($user102->{id})->add_follow($user102->{follow_users});
    follower_lite()->load_user($user103->{id})->add_follow($user103->{follow_users});
}


1;
