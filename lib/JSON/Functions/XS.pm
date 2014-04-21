package JSON::Functions::XS;
use strict;
use warnings;
no warnings 'utf8';
our $VERSION = '3.0';
use Carp;
use JSON::XS;
use Encode;

our @EXPORT = qw(
    json_chars2perl
    json_bytes2perl
    file2perl
    perl2json_chars
    perl2json_chars_for_record
    perl2json_bytes
    perl2json_bytes_for_record
);

sub import ($;@) {
  my $from_class = shift;
  my ($to_class, $file, $line) = caller;
  no strict 'refs';
  for (@_ ? @_ : @{$from_class . '::EXPORT'}) {
    my $code = $from_class->can ($_)
        or croak qq{"$_" is not exported by the $from_class module at $file line $line};
    *{$to_class . '::' . $_} = $code;
  }
} # import

my $jsonc = JSON::XS->new->allow_blessed->convert_blessed->allow_nonref;
my $jsoncr = JSON::XS->new->allow_blessed->convert_blessed->allow_nonref->pretty->canonical;
my $jsonb = JSON::XS->new->utf8->allow_blessed->convert_blessed->allow_nonref;
my $jsonr = JSON::XS->new->utf8->allow_blessed->convert_blessed->allow_nonref->pretty->canonical;

sub json_chars2perl ($) {
    local $@;
    for (scalar eval { $jsonc->decode($_[0]) }) {
        if ($@) {
            warn $@;
            return undef;
        } else {
            return $_;
        }
    }
}

sub json_bytes2perl ($) {
    return json_chars2perl(eval { decode 'utf-8', $_[0] } || $_[0]);
}

sub file2perl ($) {
    my $file = shift;
    my $json = $file->slurp or die "$file: $!";
    return json_chars2perl decode 'utf-8', $json;
}

sub perl2json_chars ($) {
    my $t = eval { $jsonc->encode($_[0]) };
    if ($@) {
        warn $@;
        return 'null';
    }
    if (defined $t) {
        $t =~ s/</\\u003C/g;
        $t =~ s/\+/\\u002B/g;
        $t =~ s/\x{2028}/\\u2028/g;
        $t =~ s/\x{2029}/\\u2029/g;
    }
    return $t;
}

sub perl2json_chars_for_record ($) {
    my $t = eval { $jsoncr->encode($_[0]) };
    if ($@) {
        warn $@;
        return 'null';
    }
    if (defined $t) {
        $t =~ s/</\\u003C/g;
        $t =~ s/\+/\\u002B/g;
        $t =~ s/\x{2028}/\\u2028/g;
        $t =~ s/\x{2029}/\\u2029/g;
    }
    return $t;
}

sub perl2json_bytes ($) {
    my $t = eval { $jsonb->encode($_[0]) };
    if ($@) {
        warn $@;
        return 'null';
    }
    if (defined $t) {
        $t =~ s/</\\u003C/g;
        $t =~ s/\+/\\u002B/g;
        $t =~ s/\xE2\x80\xA8/\\u2028/g;
        $t =~ s/\xE2\x80\xA9/\\u2029/g;
    }
    return $t;
}

sub perl2json_bytes_for_record ($) {
    my $t = eval { $jsonr->encode($_[0]) };
    if ($@) {
        warn $@;
        return 'null';
    }
    if (defined $t) {
        $t =~ s/</\\u003C/g;
        $t =~ s/\+/\\u002B/g;
        $t =~ s/\xE2\x80\xA8/\\u2028/g;
        $t =~ s/\xE2\x80\xA9/\\u2029/g;
    }
    return $t;
}

1;

=head1 LICENSE

Copyright 2009-2011 Hatena <http://www.hatena.ne.jp/>.

Copyright 2012-2014 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
