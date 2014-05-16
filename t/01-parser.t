use strict;
use warnings;
use Test::More;
use utf8;

use Sisis::Parser;
my $parser = Sisis::Parser->new( './t/sisis.dat' );
isa_ok( $parser, 'Sisis::Parser' );
my $record = $parser->next();
ok($record->{_id} eq '2', 'record_id' );
is_deeply($record->{record}->[0], ['0000', '_', '2'], 'first field');
ok($parser->next()->{_id} eq '3', 'next record');

done_testing;