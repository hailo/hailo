use v5.28.0;
use strict;
use warnings;
use Pod::Section qw(select_podsection);
use Test::More tests => 1;

my ($synopsis) = select_podsection('lib/Hailo.pm' , 'SYNOPSIS');
$synopsis =~ s/^.*?(?=\s+use)//s;

local $@;
eval <<SYNOPSIS;
open my \$filehandle, '<', __FILE__;
chdir 't/lib/Hailo/Test';
$synopsis
SYNOPSIS

is($@, '', "No errors in SYNOPSIS");
