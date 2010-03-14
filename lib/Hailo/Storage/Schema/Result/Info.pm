package Hailo::Storage::Schema::Result::Info;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Hailo::Storage::Schema::Result::Info

=cut

__PACKAGE__->table("info");

=head1 ACCESSORS

=head2 attribute

  data_type: TEXT
  default_value: undef
  is_nullable: 0
  size: undef

=head2 text

  data_type: TEXT
  default_value: undef
  is_nullable: 0
  size: undef

=cut

__PACKAGE__->add_columns(
  "attribute",
  {
    data_type => "TEXT",
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
);
__PACKAGE__->set_primary_key("attribute");


# Created by DBIx::Class::Schema::Loader v0.05003 @ 2010-03-14 16:32:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xu538P186Mgn0Nj5RHTy+A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
