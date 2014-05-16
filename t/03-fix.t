use strict;
use warnings;
use utf8;
use Test::More;

use Catmandu;
use Catmandu::Fix;
use Catmandu::Importer::Sisis;

my $fixer = Catmandu::Fix->new(fixes => [
	'sisis_map("0000", "id")',
	'sisis_map("0002[.*]", "date")',
	'sisis_map("0009[001]/0-3", "network")',
	'sisis_map("0714[00[02]]", "geographical_name")',
	'remove_field("record")',
	'remove_field("_id")']);
my $importer = Catmandu::Importer::Sisis->new(file => "./t/sisis.dat", type=> "sisis");
my $records = $fixer->fix($importer)->to_array;

ok( $records->[0]->{id} eq '2', 'fix id' );
ok( $records->[0]->{date} eq '20.01.2002', 'fix date' );
ok( $records->[0]->{network} eq 'HBZ', 'fix network' );
ok( $records->[0]->{geographical_name} eq '97 ; Lübbecke (Altkreis)', 'fix geographical_name' );
is_deeply( $records->[0], {'id' => '2', 'date' => '20.01.2002', 'network' => 'HBZ', 'geographical_name' => '97 ; Lübbecke (Altkreis)'}, 'fix record');

done_testing;