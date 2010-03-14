package Hailo::Storage::Schema::Result::Expr;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Hailo::Storage::Schema::Result::Expr

=cut

__PACKAGE__->table("expr");

=head1 ACCESSORS

=head2 id

  data_type: INTEGER
  default_value: undef
  is_auto_increment: 1
  is_nullable: 1
  size: undef

=head2 token0_id

  data_type: INTEGER
  default_value: undef
  is_foreign_key: 1
  is_nullable: 0
  size: undef

=head2 token1_id

  data_type: INTEGER
  default_value: undef
  is_foreign_key: 1
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
  "token0_id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_foreign_key => 1,
    is_nullable => 0,
    size => undef,
  },
  "token1_id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_foreign_key => 1,
    is_nullable => 0,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 token0

Type: belongs_to

Related object: L<Hailo::Storage::Schema::Result::Token>

=cut

__PACKAGE__->belongs_to(
  "token0",
  "Hailo::Storage::Schema::Result::Token",
  { id => "token0_id" },
  {},
);

=head2 token1

Type: belongs_to

Related object: L<Hailo::Storage::Schema::Result::Token>

=cut

__PACKAGE__->belongs_to(
  "token1",
  "Hailo::Storage::Schema::Result::Token",
  { id => "token1_id" },
  {},
);

=head2 next_tokens

Type: has_many

Related object: L<Hailo::Storage::Schema::Result::NextToken>

=cut

__PACKAGE__->has_many(
  "next_tokens",
  "Hailo::Storage::Schema::Result::NextToken",
  { "foreign.expr_id" => "self.id" },
);

=head2 prev_tokens

Type: has_many

Related object: L<Hailo::Storage::Schema::Result::PrevToken>

=cut

__PACKAGE__->has_many(
  "prev_tokens",
  "Hailo::Storage::Schema::Result::PrevToken",
  { "foreign.expr_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.05003 @ 2010-03-14 16:32:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:HW8plHxg8erk2e8UIaMWwg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
