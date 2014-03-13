package FollowerLite;
use strict;
use warnings;
our $VERSION = '0.01';
use Mouse;
use List::Util;
use Redis;

use FollowerLite::User;

has redis_server => (
    is      => 'rw',
    isa     => 'Str',
);

has name => (
    is      => 'rw',
    isa     => 'Str',
);

has user_id => (
    is      => 'rw',
    isa     => 'Int',
    default => sub {0}
);

has redis => (
    is      => 'rw',
    isa     => 'Redis',
    default => sub {
        my ($self) = @_;
        Redis->new(
          server => $self->redis_server || 'localhost:8080',
          name   => $self->name || 'name',
        );
    },
    lazy     => 1,
    required => 1
);

no Mouse;

sub load_user {
    my ($self, $user_id ) = @_;
    return FollowerLite::User->new({
        redis   => $self->redis,
        user_id => $user_id,
    });
}


1;
__END__

=head1 NAME

FollowerLite -

=head1 SYNOPSIS

  use FollowerLite;

=head1 DESCRIPTION

FollowerLite is

=head1 AUTHOR

takeda akihito E<lt>takeda.akihito@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
