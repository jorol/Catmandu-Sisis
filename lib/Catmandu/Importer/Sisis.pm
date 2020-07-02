package Catmandu::Importer::Sisis;

our $VERSION = '0.01';

use Catmandu::Sane;
use Moo;
use Sisis::Parser;

with 'Catmandu::Importer';

has type => ( is => 'ro', default => sub {'sisis'} );
has id   => ( is => 'ro', default => sub {'0000'} );

sub mab_generator {
    my $self = shift;

    my $file;
    my $type = lc($self->type);
    if ( $type eq 'sisis' ) {
        $file = Sisis::Parser->new( $self->fh );
    }
    else {
        die "unknown format";
    }

    my $id = $self->id;

    sub {
        my $record = $file->next();
        return unless $record;
        return $record;
    };
}

sub generator {
    my ($self) = @_;
    
    my $type = lc($self->type);
    if ( $type =~ /sisis/ ) {
        return $self->mab_generator;
    }
    else {
        die "need Sisis data";
    }
}

=head1 SYNOPSIS

    use Catmandu::Importer::Sisis;

    my $importer = Catmandu::Importer::Sisis->new(file => "./t/sisis.dat", type=> "sisis");

    my $n = $importer->each(sub {
        my $hashref = $_[0];
        # ...
    });


=head1 Sisis

The parsed Sisis record is a HASH containing two keys '_id' containing the 0000 field (or the system
identifier of the record) and 'record' containing an ARRAY of ARRAYs for every field:

 {
  'record' => [
                [
                    '0000',
                    '_',
                    '2'
                ],
                [
                    '0002',
                    '_',
                    '20.01.2002'
                ],                [
                    '0009',
                    '001',
                    'HBZ'
                ],
        ],
  '_id' => '2'
 } 

=head1 METHODS

This module inherits all methods of L<Catmandu::Importer> and by this
L<Catmandu::Iterable>.

=head1 CONFIGURATION

In addition to the configuration provided by L<Catmandu::Importer> (C<file>,
C<fh>, etc.) the importer can be configured with the following parameters:

=over

=item type

Describes the Sisis syntax variant. Supported values (case ignored) include the
default value C<sisis> for Sisis data.

=back

=cut

1;
