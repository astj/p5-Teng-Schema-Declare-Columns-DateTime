package Teng::Schema::Declare::Columns::DateTime;

use strict;
use warnings;
use Carp;

our $VERSION = '0.0.2';

use base qw(Class::Data::Inheritable);
__PACKAGE__->mk_classdata(format_class => 'DateTime::Format::MySQL');

use Teng::Schema::Declare;
use Class::Load ();

use Exporter::Lite;
our @EXPORT = qw(datetime_columns);

sub datetime_columns {
    my (@columns) = @_;

    my $columns_regexp = join('|', @columns);
    my $regexp = qr{^(?:$columns_regexp)$};
    my ($pkg) = caller;
    my $inflate = \&{$pkg . '::inflate'};
    my $deflate = \&{$pkg . '::deflate'};
    $inflate->($regexp => \&_inflate_datetime);
    $deflate->($regexp => \&_deflate_datetime);
}

sub _inflate_datetime {
    my ($col_value) = @_;
    my $format = __PACKAGE__->format_class;
    Class::Load::load_class($format);
    return $format->parse_datetime($col_value);
}

sub _deflate_datetime {
    my ($col_value) = @_;
    my $format = __PACKAGE__->format_class;
    Class::Load::load_class($format);
    return $format->format_datetime($col_value);
}

1;

__END__

=head1 NAME

Teng::Schema::Declare::Columns::DateTime - DSL extention of Teng::Schema::Declare for declaring datetime columns

=head1 SYNOPSIS

    package MyDB::Schema;
    use strict;
    use warnings;
    use Teng::Schema::Declare;
    use Teng::Schema::Declare::Columns::DateTime;

    table {
        name    "sample";
        pk      "id";
        columns qw( id name created_at updated_at );
        datetime_columns qw(created_at updated_at);
    };

    1;

=head1 DESCRIPTION

Teng::Schema::Declare::Columns::DateTime provides the method which declare a column used as DateTime object.

If you write below:

    table {
        name "sample";
        columns qw(created_at updated_at);
        datetime_columns qw(created_at updated_at);
    }

By default setting, this is same as

    table {
        name "sample";
        columns qw(created_at updated_at);
        inflate qr{^(?:created_at|updated_at)$} => sub {
            my ($col_value) = @_;
            return DateTime::Format::MySQL->parse_datetime($col_value);
        }
        deflate qr{^(?:created_at|updated_at)$} => sub {
            my ($col_value) = @_;
            return DateTime::Format::MySQL->format_datetime($col_value);
        }
    }

=head1 CLASS OPTIONS

You can configure some class setting.  For example,

    Teng::Schema::Declare::Columns::DateTime->format_class('DateTime::Format::Atom');

=head2 C<format_class>

datetime format class.  specified class needs DateTime Format interface(format_datetime and parse_datetime).

=head1 METHODS

=head2 C<datetime_columns>

DSL extention method for declaring datetime columns

=head1 REPOSITORY

https://github.com/shibayu36/p5-Teng-Schema-Declare-Columns-DateTime

=head1 AUTHOR

  C<< <shibayu36 {at} gmail.com> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2011, Yuki Shibazaki C<< <shibayu36 {at} gmail.com> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
