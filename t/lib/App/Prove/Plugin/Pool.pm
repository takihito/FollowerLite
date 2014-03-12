package t::lib::App::Prove::Plugin::Pool;

use strict;
use warnings;
use Test::RedisServer;


sub load {
    my ( $class, $prove ) = @_;

    my $redis_server = Test::RedisServer->new();
    $prove->{app_prove}{__PACKAGE__.'::redis_server'} = $redis_server;

    my $redis_socket = __PACKAGE__.'::redis_socket';
    $prove->{app_prove}{$redis_socket} = $redis_server->connect_info;
    $ENV{REDIS_SOCKET_POOL} = $prove->{app_prove}{$redis_socket};

    print sprintf "create redis server. socket:%s \n", $ENV{REDIS_SOCKET_POOL};

    return 1;
}

1;
