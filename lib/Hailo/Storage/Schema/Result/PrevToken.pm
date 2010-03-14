package Hailo::Storage::Schema::Result::PrevToken;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Hailo::Storage::Schema::Result::PrevToken

=cut

__PACKAGE__->table("prev_token");

=head1 ACCESSORS

=head2 id

  data_type: INTEGER
  default_value: undef
  is_auto_increment: 1
  is_nullable: 1
  size: undef

=head2 expr_id

  data_type: INTEGER
  default_value: undef
  is_foreign_key: 1
  is_nullable: 0
  size: undef

=head2 token_id

  data_type: INTEGER
  default_value: undef
  is_foreign_key: 1
  is_nullable: 0
  size: undef

=head2 count

  data_type: INTEGER
  default_value: undef
  is_nullable: 0
  size: undef

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_auto_increment => 1,
    is_nullable => 1,
    size => undef,
  },
  "expr_id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_foreign_key => 1,
    is_nullable => 0,
    size => undef,
  },
  "token_id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_foreign_key => 1,
    is_nullable => 0,
    size => undef,
  },
  "count",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 expr

Type: belongs_to

Related object: L<Hailo::Storage::Schema::Result::Expr>

=cut

__PACKAGE__->belongs_to(
  "expr",
  "Hailo::Storage::Schema::Result::Expr",
  { id => "expr_id" },
  {},
);

=head2 token

Type: belongs_to

Related object: L<Hailo::Storage::Schema::Result::Token>

=cut

__PACKAGE__->belongs_to(
  "token",
  "Hailo::Storage::Schema::Result::Token",
  { id => "token_id" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.05003 @ 2010-03-14 16:32:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wHFNZv0L+g7r5sX9UBeo1Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
