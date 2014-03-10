package FollowerLite;
use strict;
use warnings;
our $VERSION = '0.01';
use Mouse;
use List::Util;
use Redis;

has sinter_target_count => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {2}
);

has recommend_min_result => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {1}
);

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
);

has tmp_user_key => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        my $self = shift;
        return sprintf "tmp_user_key:%s",$self->user_id;
    }
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

sub add_user {
    my ($self, $user) = @_;
    my $key  = $user->{id};
    my $list = $user->{follow_users};
    $self->redis->sadd($key, $_) foreach(@$list);
    return $self->redis->scard($key);
}

sub recommend_user_ids {
    my ($self, $user_id) = @_;
    my $list = $self->redis->sinter($self->user_id);
    my $checked_ids = [];
    for (1..16) {
       my @target_ids = (List::Util::shuffle @$list)[0..$self->sinter_target_count-1];
       my $target_key = join ":", @target_ids;
       next if grep(/^$target_key$/, @$checked_ids);
       if ( $self->_sinter_userids(@target_ids) ) {
           my $recommend_user_ids = $self->_remove_added_user_ids();
           return $recommend_user_ids if scalar @$recommend_user_ids >= $self->recommend_min_result;
       }
       push @$checked_ids, join ":",@target_ids;
   }
   return [];
}

sub _sinter_userids {
    my ($self, @user_ids) = @_;
   return $self->redis->sinterstore( $self->tmp_user_key, @user_ids);
}

sub _remove_added_user_ids {
    my ($self, $sinter_user_ids) = @_;
    my $user_ids = $self->redis->sdiff( $self->tmp_user_key, $self->user_id);
    return $user_ids;
}

sub is_friend {
    my ($self, $target_user_id) = @_;
    if ( $self->redis->sismember($self->user_id, $target_user_id) ) {
        return $self->redis->sismember($target_user_id, $self->user_id);
    }
}

no Mouse;

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
