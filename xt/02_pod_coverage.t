use v5.10.0;
use Test::More;
use Test::Pod::Coverage;

my @modules = grep { $_ !~ /^Hailo::(?:Tokenizer|Storage|UI)::/ } all_modules();

plan tests => scalar @modules;

pod_coverage_ok($_, { also_private => [ qr/^[A-Z_]+$/ ] }) for @modules;
