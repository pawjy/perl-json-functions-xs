package JSON::Functions::XS;
use strict;
use warnings;
our $VERSION = '1.1';
use Exporter::Lite;
use JSON::XS;
use Encode;

our @EXPORT = qw();
our @EXPORT_OK = qw(
    json_chars2perl
    json_bytes2perl
    file2perl
    perl2json_chars
    perl2json_chars_for_record
    perl2json_bytes
    perl2json_bytes_for_record
);

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
    }
    return $t;
}

1;
