package Hailo::Role::Arguments;

use 5.010;
use Moo::Role;
use Types::Standard qw(HashRef Str);
use namespace::clean -except => 'meta';

has arguments => (
    isa           => HashRef[Str],
    is            => 'ro',
    documentation => "Arguments passed from Hailo",
);

around arguments => sub {
    my ($orig, $self, @args) = @_;
    my $return = $self->$orig(@args);
    return wantarray ? @{$return} : $return;
};

1;

=encoding utf8

=head1 NAME

Hailo::Role::Arguments - A role which adds an 'arguments' attribute

=head1 ATTRIBUTES

=head2 C<arguments>

A C<HashRef[Str]> of arguments passed to us from L<Hailo|Hailo>'s
L<storage|Hailo/storage_args>, or
L<tokenizer|Hailo/tokenizer_args> arguments.

=head1 AUTHOR

E<AElig>var ArnfjE<ouml>rE<eth> Bjarmason <avar@cpan.org>

=head1 LICENSE AND COPYRIGHT

Copyright 2010 E<AElig>var ArnfjE<ouml>rE<eth> Bjarmason.

This program is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
