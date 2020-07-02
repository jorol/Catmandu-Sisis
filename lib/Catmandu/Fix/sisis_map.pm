package Catmandu::Fix::sisis_map;

our $VERSION = '0.01';

use Catmandu::Sane;
use Catmandu::Util qw(:is :data);
use Data::Dumper;
use Moo;

has path  => ( is => 'ro', required => 1 );
has key   => ( is => 'ro', required => 1 );
has mpath => ( is => 'ro', required => 1 );
has opts  => ( is => 'ro' );

around BUILDARGS => sub {
    my ( $orig, $class, $mpath, $path, %opts ) = @_;
    my ( $p, $key ) = parse_data_path($path) if defined $path && length $path;
    $orig->(
        $class,
        path  => $p,
        key   => $key,
        mpath => $mpath,
        opts  => \%opts
    );
};

sub fix {
    my ( $self, $data ) = @_;

    my $path  = $self->path;
    my $key   = $self->key;
    my $mpath = $self->mpath;
    my $opts  = $self->opts || {};
    $opts->{-join} = '' unless $opts->{-join};

    my $sisis_pointer = $opts->{-record} || 'record';
    my $sisis = $data->{$sisis_pointer};

    my $fields = sisis_field( $sisis, $mpath );

    return $data if !@{$fields};

    for my $field (@$fields) {
        my $field_value = sisis_subfield( $field, $mpath );

        next if is_empty($field_value);

        $field_value = [ $opts->{-value} ] if defined $opts->{-value};
        $field_value = join $opts->{-join}, @$field_value
            if defined $opts->{-join};
        $field_value = create_path( $opts->{-in}, $field_value )
            if defined $opts->{-in};
        $field_value = path_substr( $mpath, $field_value )
            unless index( $mpath, '/' ) == -1;

        my $match
            = [ grep ref, data_at( $path, $data, key => $key, create => 1 ) ]
            ->[0];

        if ( is_array_ref($match) ) {
            if ( is_integer($key) ) {
                $match->[$key] = $field_value;
            }
            else {
                push @{$match}, $field_value;
            }
        }
        else {
            if ( exists $match->{$key} ) {
                $match->{$key} .= $opts->{-join} . $field_value;
            }
            else {
                $match->{$key} = $field_value;
            }
        }
    }
    $data;
}

sub is_empty {
    my ($ref) = shift;
    for (@$ref) {
        return 0 if defined $_;
    }
    return 1;
}

sub path_substr {
    my ( $path, $value ) = @_;
    return $value unless is_string($value);
    if ( $path =~ /\/(\d+)(-(\d+))?/ ) {
        my $from = $1;
        my $to = defined $3 ? $3 - $from + 1 : 0;
        return substr( $value, $from, $to );
    }
    return $value;
}

sub create_path {
    my ( $path, $value ) = @_;
    my ( $p, $key, $guard ) = parse_data_path($path);
    my $leaf  = {};
    my $match = [
        grep ref,
        data_at( $p, $leaf, key => $key, guard => $guard, create => 1 )
    ]->[0];
    $match->{$key} = $value;
    $leaf;
}

# Parse a sisis_path into parts
# 0000  - field=0000
# 0009001  - field=0009, subfield 001
# 0002/6-10    - field=0009 from index 6 to 10
sub parse_sisis_path {
    my $path = shift;

    if ( $path =~ /(\d{4})(\[(.*)\])?(\/(\d+)(-(\d+))?)?/ ) {

        my $field    = $1;
        my $subfield = defined $3 ? $3 : '.*';
        my $from     = $5;
        my $to       = $6;

        return {
            field    => $field,
            subfield => $subfield,
            from     => $from,
            to       => $to
        };
    }
    else {
        return {};
    }
}

# Given a Catmandu::Importer::Sisis item return for each matching field the
# array of subfields
sub sisis_field {
    my ( $sisis_item, $path ) = @_;
    my $sisis_path = parse_sisis_path($path);
    my @results  = ();

    my $field = $sisis_path->{field};
    $field =~ s/\*/./g;

    for (@$sisis_item) {
        my ( $tag, @subfields ) = @$_;
        if ( $tag =~ /$field/ ) {
            push( @results, \@subfields );
        }
    }
    return \@results;
}

# Given a subarray of Catmandu::Importer::Sisis fields 
# return all the fields that match the $subfield regex
sub sisis_subfield {
    my ( $subfield, $path ) = @_;

    my $sisis_path = &parse_sisis_path($path);
    my $regex    = $sisis_path->{subfield};


    if ($subfield->[0] =~ /$regex/ ) {
        return [$subfield->[1]];
    }
    return [];
}

1;

=head1 SYNOPSIS

    # Copy all data from field 0000 into the my.id hash
    sisis_map('0000','my.title');

    # Copy the 001 subfield form field 0331 into the my.title hash
    sisis_map('0331[001]','my.title');

    # Copy subfields 001-003 into the my.authors array
    sisis_map('0101[00[123]]','my.authors.$append');

    # Copy the first 3 characters from subfield 001 of field 0015 into the my.language hash
    sisis_map('0015[001]/0-3','my.language');

=cut
