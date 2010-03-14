package Hailo::Storage::Schema::ResultSet::Token;

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

__PACKAGE__->load_components('Helper::ResultSet::Random');

1;

=head1 NAME

Hailo::Storage::Schema::ResultSet::Token - Add portable C<RANDOM()> capability to L<Token|Hailo::Storage::Schema::Result::Token> results

=head1 DESCRIPTION

Adds L<DBIx::Class::Helper::ResultSet::Random> to
L<Token|Hailo::Storage::Schema::Result::Token> result sets which
allows us to do the portable equivalent of C<ORDER BY RANDOM()>.

=head1 AUTHOR

E<AElig>var ArnfjE<ouml>rE<eth> Bjarmason <avar@cpan.org>

=head1 LICENSE AND COPYRIGHT

Copyright 2010 E<AElig>var ArnfjE<ouml>rE<eth> Bjarmason.

This program is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
