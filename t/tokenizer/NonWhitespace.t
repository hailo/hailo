use 5.010;
use utf8;
use strict;
use warnings;
use Test::More tests => 2;
use Hailo::Tokenizer::NonWhitespace;

binmode $_, ':encoding(utf8)' for (*STDIN, *STDOUT, *STDERR);

subtest make_tokens => sub {

    my $t = sub {
        my ($str, $tokens) = @_;

        is_deeply(
            [ Hailo::Tokenizer::NonWhitespace::make_tokens(Hailo::Tokenizer::NonWhitespace->new, $str) ],
            $tokens,
            "make_tokens: <<$str>> ==> " . (join ' ', map { qq[<<$_>>] } @$tokens) . ""
        );
    };

    for my $chr (map { chr } 11 .. 200) {
        next if $chr =~ /^\s$/;
        $t->($chr, [ $chr ]);
    }

    # $t->("", [ '' ]);
    $t->("", undef);
    $t->("foo bar", [ qw<foo bar> ]);
    $t->("Æ", [ 'Æ' ]);

    done_testing();
};

subtest make_output => sub {
    my @tokens = (
        [
            ' " why hello there. «yes». "foo is a bar", e.g. bla ... yes',
            [qw<" why hello there. «yes». "foo is a>, 'bar",', qw<e.g. bla ... yes>],
            '" Why hello there. «Yes». "Foo is a bar", e.g. bla ... yes.',
        ],
        [
            "someone: how're you?",
            [qw<someone: how're you?>],
            "Someone: How're you?",
        ],
        [
            'what?! well...',
            [qw<what?! well...>],
            'What?! Well...',
        ],
        [
            'hello. you: what are you doing?',
            [qw<hello. you: what are you doing?>],
            'Hello. You: What are you doing?',
        ],
        [
            'foo: foo: foo: what are you doing?',
            [qw<foo: foo: foo: what are you doing?>],
            'Foo: Foo: Foo: What are you doing?',
        ],
        [
            "I'm talking about this key:value thing",
            [qw<i'm talking about this key:value thing>],
            "I'm talking about this key:value thing."
        ],
        [
            "what? but that's impossible",
            [qw<what? but that's impossible>],
            "What? But that's impossible.",
        ],
        [
            'on example.com? yes',
            [qw<on example.com? yes>],
            "On example.com? Yes.",
        ],
        [
            "sá ''karlkyns'' aðili í [[hjónaband]]i tveggja lesbía?",
            [qw<sá ''karlkyns'' aðili í [[hjónaband]]i tveggja lesbía?>],
            "Sá ''karlkyns'' aðili í [[hjónaband]]i tveggja lesbía?",
        ],
        [
            "long    whitespace is preserved",
            ['long', '  ', qw<whitespace is preserved>],
            "Long    whitespace is preserved.",
        ],
    );

    my $toke = Hailo::Tokenizer::NonWhitespace->new();

    for my $test (@tokens) {
        my $tokens = [$toke->make_tokens($test->[0])];
        is_deeply($tokens, $test->[1], 'Tokens are correct');
        my $output = $toke->make_output($tokens);
        is_deeply($output, $test->[2], 'Output is correct');
    }

    done_testing();
};