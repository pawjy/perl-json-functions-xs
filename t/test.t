package test::JSON::Functions::XS;
use strict;
use warnings;
no warnings 'utf8';
use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;
use base qw(Test::Class);
use Test::More;
use Test::Differences;
use JSON::Functions::XS qw/
    json_chars2perl
    json_bytes2perl
    perl2json_chars
    perl2json_chars_for_record
    perl2json_bytes
    perl2json_bytes_for_record
/;
use Encode;

sub u8 ($) {
    return encode 'utf-8', $_[0];
}

# ------ json_chars2perl ------

sub _json_chars2perl : Test(1) {
    is_deeply json_chars2perl('{"a":"b","c":"\u3000"}'), {qw/a b c/, "\x{3000}"};
}

sub _json_chars2perl_literal : Test(1) {
    eq_or_diff json_chars2perl "null", undef;
}

sub _json_chars2perl_string : Test(1) {
    eq_or_diff json_chars2perl '"null"', 'null';
}

sub _json_chars2perl_string_utf8 : Test(1) {
    eq_or_diff json_chars2perl '"\u5010"', "\x{5010}";
}

sub _json_chars2perl_string_utf8_char : Test(1) {
    eq_or_diff json_chars2perl qq{"\x{6000}"}, "\x{6000}";
}

sub _json_chars2perl_broken : Test(1) {
    eq_or_diff json_chars2perl('{"a":"b",'), undef;
}

sub _json_chars2perl_string_empty : Test(1) {
    eq_or_diff json_chars2perl '""', '';
}

sub _json_chars2perl_zero : Test(1) {
    eq_or_diff json_chars2perl '0', 0;
}

# ------ json_bytes2perl ------

sub _json_bytes2perl_1 : Test(1) {
    is_deeply json_bytes2perl('{"a":"b","c":"\u3000"}'), {qw/a b c/, "\x{3000}"};
}

sub _json_bytes2perl_2 : Test(1) {
    is_deeply json_bytes2perl('{"a":"b","c": "'.(encode 'utf8', "\x{3000}").'"}'), {qw/a b c/, "\x{3000}"};
}

sub _json_bytes2perl_literal : Test(1) {
    eq_or_diff json_bytes2perl "null", undef;
}

sub _json_bytes2perl_string : Test(1) {
    eq_or_diff json_bytes2perl '"null"', 'null';
}

sub _json_bytes2perl_string_broken : Test(1) {
    eq_or_diff json_bytes2perl qq{"\x89\xE0\xC0ab"},
        "\x{FFFD}\x{FFFD}\x{FFFD}ab";
}

sub _json_bytes2perl_string_utf8 : Test(1) {
    eq_or_diff json_bytes2perl '"\u5010"', "\x{5010}";
}

sub _json_bytes2perl_string_utf8_char : Test(1) {
    eq_or_diff json_bytes2perl qq{"\x{6000}"}, "\x{6000}";
}

sub _json_bytes2perl_string_utf8_char_2 : Test(1) {
    eq_or_diff json_bytes2perl u8 qq{"\x{6000}"}, "\x{6000}";
}

sub _json_bytes2perl_string_empty : Test(1) {
    eq_or_diff json_bytes2perl '""', '';
}

sub _json_bytes2perl_string_empty_2 : Test(1) {
    eq_or_diff json_bytes2perl qq<  ""  \n>, '';
}

sub _json_bytes2perl_string_single : Test(1) {
    eq_or_diff json_bytes2perl "''", undef;
}

sub _json_bytes2perl_string_single_2 : Test(1) {
    eq_or_diff json_bytes2perl "'abc'", undef;
}

sub _json_bytes2perl_string_sp : Test(1) {
    eq_or_diff json_bytes2perl '" "', ' ';
}

sub _json_bytes2perl_zero : Test(1) {
    eq_or_diff json_bytes2perl '0', 0;
}

sub _json_bytes2perl_undef : Test(1) {
    eq_or_diff json_bytes2perl undef, undef;
}

sub _json_bytes2perl_empty : Test(1) {
    eq_or_diff json_bytes2perl '', undef;
}

sub _json_bytes2perl_empty_2 : Test(1) {
    eq_or_diff json_bytes2perl "\n", undef;
}

sub _json_bytes2perl_broken : Test(1) {
    eq_or_diff json_bytes2perl 'abcdef', undef;
}

sub _json_bytes2perl_broken_2 : Test(1) {
    eq_or_diff json_bytes2perl('{"a":"b",'), undef;
}

# ------ perl2json_chars ------

sub _perl2json_chars_undef : Test(1) {
    is perl2json_chars(undef), 'null';
}

sub _perl2json_chars : Test(1) {
    is perl2json_chars({qw/a b c/, "\x{3000}"}), qq'{"c":"\x{3000}","a":"b"}';
}

sub _perl2json_chars_lt : Test(1) {
    is perl2json_chars({"<A>" => "<b>+"}), qq'{"\\u003CA>":"\\u003Cb>\\u002B"}';
}

__PACKAGE__->runtests;

1;
