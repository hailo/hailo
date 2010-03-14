package Hailo::Storage::Schema::Result::Token;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Hailo::Storage::Schema::Result::Token

=cut

__PACKAGE__->table("token");

=head1 ACCESSORS

=head2 id

  data_type: INTEGER
  default_value: undef
  is_auto_increment: 1
  is_nullable: 1
  size: undef

=head2 spacing

  data_type: INTEGER
  default_value: undef
  is_nullable: 0
  size: undef

=head2 text

  data_type: TEXT
  default_value: undef
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
  "spacing",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "text",
  {
    data_type => "TEXT",
    default_value => undef,
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

=head2 expr_token0s

Type: has_many

Related object: L<Hailo::Storage::Schema::Result::Expr>

=cut

__PACKAGE__->has_many(
  "expr_token0s",
  "Hailo::Storage::Schema::Result::Expr",
  { "foreign.token0_id" => "self.id" },
);

=head2 expr_token1s

Type: has_many

Related object: L<Hailo::Storage::Schema::Result::Expr>

=cut

__PACKAGE__->has_many(
  "expr_token1s",
  "Hailo::Storage::Schema::Result::Expr",
  { "foreign.token1_id" => "self.id" },
);

=head2 next_tokens

Type: has_many

Related object: L<Hailo::Storage::Schema::Result::NextToken>

=cut

__PACKAGE__->has_many(
  "next_tokens",
  "Hailo::Storage::Schema::Result::NextToken",
  { "foreign.token_id" => "self.id" },
);

=head2 prev_tokens

Type: has_many

Related object: L<Hailo::Storage::Schema::Result::PrevToken>

=cut

__PACKAGE__->has_many(
  "prev_tokens",
  "Hailo::Storage::Schema::Result::PrevToken",
  { "foreign.token_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.05003 @ 2010-03-14 16:32:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:OEvsslAzEmvD1s2y4Cb15A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
