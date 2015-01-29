use 5.010;
use strict;
use Test::More tests => 1;
use Hailo;

my $version = $Hailo::VERSION // 'dev-git';

diag("Testing Hailo $version with $^X $]");
pass("Token test");
