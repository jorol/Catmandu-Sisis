package Sisis::Parser;

use strict;
use warnings;

our $VERSION = '0.01';

use charnames qw< :full >;
use Carp qw(croak);
use Readonly;

Readonly my $END_OF_FIELD       => qq{\N{LINE FEED}};
Readonly my $END_OF_RECORD      => q{};

=head1 SYNOPSIS

L<Sisis::Parser> is a parser for Sisisis records.

L<Sisis::Parser> expects UTF-8 encoded files as input. Otherwise provide a 
filehande with a specified I/O layer.

    use Sisis::Parser;

    my $parser = Sisis::Parser->new( $filename );

    while ( my $record_hash = $parser->next() ) {
        # do something        
    }

=head1 Arguments

=over

=item C<file>
 
Path to file with MAB2 Sisis records.

=item C<fh>

Open filehandle for file with MAB2 Sisis records.

=back

=head1 METHODS

=head2 new($filename | $filehandle)

=cut

sub new {
    my $class = shift;
    my $file  = shift;

    my $self = {
        filename   => undef,
        rec_number => 0,
        reader     => undef,
    };

    # check for file or filehandle
    my $ishandle = eval { fileno($file); };
    if ( !$@ && defined $ishandle ) {
        $self->{filename} = scalar $file;
        $self->{reader}   = $file;
    }
    elsif ( -e $file ) {
        open $self->{reader}, '<:encoding(UTF-8)', $file
            or croak "cannot read from file $file\n";
        $self->{filename} = $file;
    }
    else {
        croak "file or filehande $file does not exists";
    }
    return ( bless $self, $class );
}

=head2 next()

Reads the next record from MAB2 input stream. Returns a Perl hash.

=cut

sub next {
    my $self = shift;
    local $/ = $END_OF_RECORD;
    if ( my $data = $self->{reader}->getline() ) {
        $self->{rec_number}++;
        my $record = _decode($data);

        # get value from 0000 as id
        my ($id) = map { $_->[-1] } grep { $_->[0] =~ '0000' } @{$record};
        return { _id => $id, record => $record };
    }
    return;
}

=head2 _decode($record)

Deserialize a raw MAB2 record to an ARRAY of ARRAYs.

=cut

sub _decode {
    my $reader = shift;
    chomp($reader);

    my @record;

    my @fields = split($END_OF_FIELD, $reader);

    foreach my $field (@fields) {
        my ($tag, $subfield, $value);
        # 0015.001:ger
        # 0027:S
        if ($field =~ m/^(\d{4})(\.(\d{3}))?:(.*)?$/){            
            $tag = $1;
            $subfield = $3;
            $value = $4;
        }else{
            # "##### ..." fields are skipped
            next;
        }
        next if $tag eq '9999';
        if (defined $subfield) {
            push(@record, [$tag, $subfield, $value]);
        } else {
            push(@record, [$tag, '_', $value]);
        }
    }
    return \@record;    
}

=head1 SEE ALSO

L<Catmandu::Importer::MAB2>.

=cut

1;    # End of Sisis::Parser
