package JSON::Functions::XS;
use strict;
use warnings;
our $VERSION = '1.0';
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

my $jsonc = JSON::XS->new->allow_blessed->convert_blessed;
my $jsoncr = JSON::XS->new->allow_blessed->convert_blessed->pretty->canonical;
my $jsonb = JSON::XS->new->utf8->allow_blessed->convert_blessed;
my $jsonr = JSON::XS->new->utf8->allow_blessed->convert_blessed->pretty->canonical;

sub json_chars2perl ($) {
    local $@;
    return eval { $jsonc->decode($_[0]) } || do { warn $@; undef };
}

sub json_bytes2perl ($) {
    return json_chars2perl decode 'utf8', $_[0];
}

sub file2perl ($) {
    my $file = shift;
    my $json = $file->slurp or die "$file: $!";
    return json_chars2perl decode 'utf8', $json;
}

sub perl2json_chars ($) {
    return $jsonc->encode($_[0]);
}

sub perl2json_chars_for_record ($) {
    return $jsoncr->encode($_[0]);
}

sub perl2json_bytes ($) {
    return $jsonb->encode($_[0]);
}

sub perl2json_bytes_for_record ($) {
    return $jsonr->encode($_[0]);
}

1;
