package Hailo::Storage::SQLite;

use Moose;
use MooseX::Types::Moose qw<Int Str>;
use DBI;
use DBIx::Perlish;
use List::Util qw<shuffle>;
use List::MoreUtils qw<natatime>;
use namespace::clean -except => 'meta';

our $VERSION = '0.01';

has file => (
    isa      => Str,
    is       => 'ro',
    required => 1,
);

has order => (
    isa => Int,
    is  => 'rw',
);

has _dbh => (
    isa        => 'DBI::db',
    is         => 'ro',
    lazy_build => 1,
);

with 'Hailo::Storage';

sub _build__dbh {
    my ($self) = @_;

    return DBI->connect(
        "dbi:SQLite:dbname=".$self->file,
        '',
        '', 
        { sqlite_unicode => 1, RaiseError => 1 },
    );
}

sub BUILD {
    my ($self) = @_;

    DBIx::Perlish::init($self->_dbh);

    if (-s $self->file) {
        $self->order(db_fetch {
            info->attribute eq 'markov_order';
            return info->text;
        });
    }
    else {
        $self->_create_db();

        db_insert 'info', {
            attribute => 'markov_order',
            text      => $self->order,
        };
    }

    return;
}

sub start_training {
    my ($self) = @_;

    # allow for 50MB of in-memory cache
    $self->_dbh->do('PRAGMA cache_size = 50000');

    #start a transaction
    $self->_dbh->begin_work;

    return;
}

sub stop_training {
    my ($self) = @_;

    # finish a transaction
    $self->_dbh->commit;

    return;
}

sub _create_db {
    my ($self) = @_;

    my @statements = split /\n\n/, do { local $/ = undef; <DATA> };

    for my $i (0 .. $self->order-1) {
        push @statements, "ALTER TABLE expr ADD token${i}_id "
            .'TEXT REFERENCES token (token_id)';
    }
    $self->_dbh->do($_) for @statements;

    return;
}

# add a new expression to the database
sub add_expr {
    my ($self, %args) = @_;
    my $tokens = $args{tokens};

    return if defined $self->_expr_id($tokens);

    # add the tokens
    my @token_ids = $self->_add_tokens($tokens);

    # add the expression
    db_insert 'expr', {
        (map { +"token${_}_id" => $token_ids[$_] } 0 .. $self->order-1),
    };

    my $expr_id = $self->_dbh->selectrow_array('SELECT last_insert_rowid()');

    # add next/previous tokens for this expression, if any
    for my $pos_token (qw(next_token prev_token)) {
        next if !defined $args{$pos_token};
        my $token_id = $self->_add_tokens($args{$pos_token});

        my $count = db_fetch {
            my $t : table = $pos_token;
            $t->expr_id == $expr_id;
            $t->token_id == $token_id;
            return $t->pos_token_id;
        };

        if (defined $count) {
            db_update {
                my $t : table = $pos_token;
                $t->expr_id == $expr_id;
                $t->token_id == $token_id;
                $t->count = $t->count+1;
            };
        }
        else {
            db_insert $pos_token, {
                expr_id  => $expr_id,
                token_id => $token_id,
                count    => 1,
            };
        }
    }

    return;
}

# look up an expression id based on tokens
sub _expr_id {
    my ($self, $tokens) = @_;
    
    my @expr_ids;

    # go through the positions
    for my $pos (0 .. $self->order-1) {
        my $token = $tokens->[$pos];
        my $column = "token${pos}_id";

        # find all expressions beginning with the first token
        if ($pos == 0) {
            @expr_ids = db_fetch {
                expr->$column <- db_fetch {
                    token->text eq $token;
                    return token->token_id;
                };
                return expr->expr_id;
            };
        }

        # no expression begins with the first token, bail
        return if !@expr_ids;
        
        # limit the number of SQL variables we use, sqlite only allows 999
        my $iter = natatime(997, @expr_ids);

        # find expressions containing the next token at the right position
        my @fewer_ids;
        while (my @ids = $iter->()) {
            push @fewer_ids, db_fetch {
                expr->expr_id <- @ids;
                expr->$column <- db_fetch {
                    token->text eq $token;
                    return token->token_id;
                };
                return expr->expr_id;
            };
        }

        # only keep the expressions that matched
        @expr_ids = @fewer_ids;
    }

    # return the expression if it was found
    return $expr_ids[0] if @expr_ids == 1;

    return;
}

# add tokens and/or return their ids
sub _add_tokens {
    my ($self) = shift;
    my $tokens = ref $_[0] eq 'ARRAY' ? shift : [@_];
    my @token_ids;

    for my $token (@$tokens) {
        my $old_token_id = db_fetch {
            token->text eq $token;
            return token->token_id;
        };
        
        if (defined $old_token_id) {
            push @token_ids, $old_token_id;
        }
        else {
            db_insert 'token', { text => $token };
            push @token_ids, $self->_last_rowid();
        }
    }

    return @token_ids > 1 ? @token_ids : $token_ids[0];
}

# return the primary key of the last inserted row
sub _last_rowid {
    my ($self) = @_;
    return $self->_dbh->selectrow_array('SELECT last_insert_rowid()');
}

sub token_exists {
    my ($self, $token) = @_;
    
    return 1 if defined db_fetch {
        token->text eq $token;
        return token->token_id;
    };
    return;
}

# return a random expression containing the given token
sub random_expr {
    my ($self, $token) = @_;

    my $token_id = $self->_add_tokens($token);
    my @expr;

    # try the positions in a random order
    POSITION: for my $pos (shuffle 0 .. $self->order-1) {
        my $column = "token${pos}_id";

        # find all expressions which include the token at this position
        my @expr_ids = shuffle db_fetch {
            expr->$column == $token_id;
            return expr->expr_id;
        };

        # try the next position if no expression has it at this one
        next if !@expr_ids;

        # we found some, let's pick a random one and return its tokens
        my $expr_id = (shuffle @expr_ids)[0];
        my $expr = db_fetch { expr->expr_id == $expr_id };

        for my $i (0 .. $self->order-1) {
            my $id = $expr->{"token${i}_id"};
            push @expr, db_fetch {
                token->token_id == $id;
                return token->text;
            };
        }
        last POSITION;
    }

    return @expr;
}

sub next_tokens {
    my ($self, $tokens) = @_;
    return $self->_pos_tokens('next_token', $tokens);
}

sub prev_tokens {
    my ($self, $tokens) = @_;
    return $self->_pos_tokens('prev_token', $tokens);
}

sub _pos_tokens {
    my ($self, $pos_table, $tokens) = @_;

    my $expr_id = $self->_expr_id($tokens);
    return db_fetch {
        my $pos : table = $pos_table;
        my $tok : token;
        $pos->expr_id == $expr_id;
        join $pos * $tok => db_fetch {
            $pos->token_id == $tok->token_id;
        };
        return -k $tok->text, $pos->count;
    };
}

sub save {
    # no op
}

__PACKAGE__->meta->make_immutable;

1;

=encoding utf8

=head1 NAME

Hailo::Storage::SQLite - A storage backend for L<Hailo|Hailo> using
L<DBD::SQLite|DBD::SQLite>

=head1 DESCRIPTION

This backend maintains information in an SQLite database.

It uses very little memory, but training is very slow. Some optimizations
are yet to be made (crafting more efficient queries, adding indexes, etc).

Importing 1000 lines of IRC output takes about 3 minutes on my laptop
(2.53 GHz Core 2 Duo).

=head1 AUTHOR

Hinrik E<Ouml>rn SigurE<eth>sson, hinrik.sig@gmail.com

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Hinrik E<Ouml>rn SigurE<eth>sson

This program is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__DATA__
CREATE TABLE info (
    attribute TEXT NOT NULL UNIQUE PRIMARY KEY,
    text      TEXT NOT NULL
)

CREATE TABLE token (
    token_id INTEGER PRIMARY KEY AUTOINCREMENT,
    text     TEXT NOT NULL
)

CREATE TABLE expr (
    expr_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT
)

CREATE TABLE next_token (
    pos_token_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    expr_id      INTEGER NOT NULL REFERENCES expr (expr_id),
    token_id     INTEGER NOT NULL REFERENCES token (token_id),
    count        INTEGER NOT NULL
)

CREATE TABLE prev_token (
    pos_token_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    expr_id      INTEGER NOT NULL REFERENCES expr (expr_id),
    token_id     INTEGER NOT NULL REFERENCES token (token_id),
    count        INTEGER NOT NULL
)