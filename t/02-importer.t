use strict;
use warnings;
use Test::More;

use Catmandu;
use Catmandu::Importer::Sisis;

my $importer = Catmandu::Importer::Sisis->new(file => "./t/sisis.dat", type=> "Sisis");
my @records;
$importer->each(
    sub {
        push( @records, $_[0] );
    }
);
ok(scalar @records == 17, 'records');
ok( $records[0]->{'_id'} eq '2', 'record _id' );
is_deeply( $records[0]->{'record'}->[0], ['0000', '_', '2'],
    'first field'
);

done_testing;