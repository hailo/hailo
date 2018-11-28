use v5.10.0;
use strict;
use warnings;

# Usage: git checkout -f lib t; perl utils/moose-to-moo.pl $(git ls-files ':!utils/moose-to-moo.pl'); prove -Ilib -j8 -r t

BEGIN { $^I = ""; }
LINE: while (defined($_ = readline ARGV)) {
    s/use Moose;/use Moo;/g;
    s/use Moose::Role;/use Moo::Role;/g;
    s/use MooseX::Types::Moose ':all';/use Types::Standard ':all';/g;
    s/use MooseX::StrictConstructor;/use MooX::StrictConstructor;/g;
    s/__PACKAGE__->meta->make_immutable;/1;/g;
    s/use namespace::clean -except => 'meta';/use namespace::clean -except => 'new';/g;

    s/^\s+is\s+=> 'ro', # for lazy_build\n//g;
    s/^(\s+)lazy_build(\s+)=> 1,\n/${1}is        $2=> 'lazy',\n${1}predicate $2=> 1,\n${1}clearer   $2=> 1,\n/g;

    s/isa\s+=>\K '(DBI::db|Hailo)'/ InstanceOf['$1']/g;
}
continue {
    die "-p destination: $!\n" unless print $_;
}
