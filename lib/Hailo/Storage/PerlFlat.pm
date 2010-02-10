package Hailo::Storage::PerlFlat;
use 5.10.0;
use Moose;
use MooseX::StrictConstructor;
use Digest::MD4 qw(md4_hex);
use Data::Dump 'dump';
use namespace::clean -except => 'meta';

our $VERSION = '0.08';

extends 'Hailo::Storage::Perl';

with qw(Hailo::Role::Generic
        Hailo::Role::Storage);

sub _build__memory_area {
    # The hash we store all our data in
    my %memory;
    return \%memory;
}

sub _exists {
    my ($self, $k) = @_;
    my $mem = $self->_memory;

    $self->meh->trace("Checking if '$k' exists");

    return exists $mem->{$k};
}

sub _set {
    my ($self, $k, $v) = @_;
    my $mem = $self->_memory;

    $self->meh->trace("Setting '$k' = '$v'");

    $mem->{$k} = $v;
}

sub _get {
    my ($self, $k) = @_;
    my $mem = $self->_memory;

    $self->meh->trace("Getting '$k'");
    my $v = $mem->{$k};
    $self->meh->trace("Value for '$k' is '$v'");
    return $v;
}

# XXX: This is broken somehow!
sub _increment {
    my ($self, $k) = @_;
    my $mem = $self->_memory;

    $self->meh->trace("Incrementing $k");

    # This works:
    #return $mem->{$k}++;

    # Why doesn't this (or the other stuff passing tests in
    # t/bug/increment.t):

    no warnings 'uninitialized';
    my $now = $mem->{$k};
    my $after = defined $now ? $now + 1 : int $now;
    $mem->{$k} = $after;
    return $after;
}

sub _expr_exists {
    my ($self, $ehash) = @_;

    $self->meh->trace("expr_exists: Checking if 'expr-$ehash' exists");
    return $self->_exists("expr-$ehash");
}

sub _expr_add_tokens {
    my ($self, $ehash, $tokens) = @_;
    my $mem = $self->_memory;

    my $count = $#{ $tokens };
    $self->_set("expr-$ehash", $count);
    $self->_set("expr-$ehash-$_", $tokens->[$_]) for 0 .. $count;

    return;
}

sub _token_push_ehash {
    my ($self, $token, $ehash) = @_;
    my $mem = $self->_memory;

    my $count = $self->_increment("token-$token");
    $self->_set("token-$token-$count", $ehash);

    return;
}

sub _pos_token_ehash_increment {
    my ($self, $pos_token, $ehash, $token) = @_;

    # XXX: Do we increment the count when the '' token gets added?
    my $count = $self->_increment("$pos_token-$ehash");
    $self->_set("$pos_token-$ehash", $count);
    $self->_set("$pos_token-$ehash-$count", $token);
    $self->_increment("$pos_token-$ehash-token-$token");

    return;
}

sub token_exists {
    my ($self, $token) = @_;
    return 1 if $self->_exists("token-$token");
    return;
}

sub random_expr {
    my ($self, $token) = @_;
    my $token_k = "token-$token";
    my $token_v = $self->_get($token_k);
    my $token_num = int rand $token_v;
    $self->meh->trace("Got token num '$token_num' for k/v '$token_k'/'$token_v' ");
    my $ehash     = $self->_get("$token_k-$token_num");
    my @tokens    = map { $self->_get("expr-$ehash-$_") } 0 .. $self->_get("expr-$ehash");
    return @tokens;
}

sub next_tokens {
    my ($self, $tokens) = @_;
    my $ehash = $self->_hash_tokens($tokens);

    return $self->_x_tokens("next_token", $ehash);
}

sub prev_tokens {
    my ($self, $tokens) = @_;
    my $ehash = $self->_hash_tokens($tokens);
    return $self->_x_tokens("prev_token", $ehash);
}

sub _x_tokens {
    my ($self, $pos_token, $ehash) = @_;
    my $key = "$pos_token-$ehash";

    return unless $self->_exists($key);

    my $count = $self->_get($key);

    my %tokens = (
        map {
            my $k = $self->_get("$key-$_");
            $k => $self->_get("$key-token-$k");
        } 0 .. $count,
    );

    return \%tokens;
}

sub _hash_tokens {
     my ($self, $tokens) = @_;
     my $ehash = md4_hex("@$tokens");
     return substr $ehash, 0, 10;
}

__PACKAGE__->meta->make_immutable;

=encoding utf8

=head1 NAME

Hailo::Storage::PerlFlat - A storage backend for L<Hailo|Hailo> using flat Perl structures

=head1 DESCRIPTION

This backend maintains information in a flat Perl hash, with an option
to save to/load from a file with L<Storable|Storable>.

=head1 AUTHOR

E<AElig>var ArnfjE<ouml>rE<eth> Bjarmason <avar@cpan.org>

=head1 LICENSE AND COPYRIGHT

Copyright 2010 E<AElig>var ArnfjE<ouml>rE<eth> Bjarmason

This program is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

