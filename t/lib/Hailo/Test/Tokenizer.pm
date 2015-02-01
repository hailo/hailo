package Hailo::Test::Tokenizer;
use 5.010;
use Moo;
use namespace::clean -except => 'new';
use Hailo::Tokenizer::Words;

with 'Hailo::Role::Tokenizer';

sub make_tokens { goto &Hailo::Tokenizer::Words::make_tokens }
sub make_output { goto &Hailo::Tokenizer::Words::make_output }

1;
