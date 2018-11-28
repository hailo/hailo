use v5.10.0;
use strict;
use warnings;

# Usage: git reset --hard; perl utils/moose-to-moo.pl $(git ls-files ':!utils/moose-to-moo.pl'); prove -Ilib -j8 -r t

BEGIN { $^I = ""; }
LINE: while (defined($_ = readline ARGV)) {
    s/use Moose;/use Moo;/g;
    s/use Moose::Role;/use Moo::Role;/g;
    s/use MooseX::Types::Moose ':all';/use Types::Standard ':all';/g;
    s/use MooseX::StrictConstructor;/use MooX::StrictConstructor;/g;
    s/__PACKAGE__->meta->make_immutable;/1;/g;
    s/use namespace::clean -except => 'meta';/use namespace::clean -except => 'new';/g;
}
continue {
    die "-p destination: $!\n" unless print $_;
}
