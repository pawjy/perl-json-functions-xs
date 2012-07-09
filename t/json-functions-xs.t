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

sub _json_bytes2perl_2028 : Test(1) {
    eq_or_diff json_bytes2perl(encode 'utf-8', qq{{"\x{2028}":"\x{2029}"}}),
        {"\x{2028}" => "\x{2029}"};
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

sub _perl2json_chars_unicode : Test(1) {
    is perl2json_chars({qw/a b c/, "\x{3000}\x{D800}"}),
        qq{{"c":"\x{3000}\x{D800}","a":"b"}};
}

sub _perl2json_chars_null : Test(1) {
    eq_or_diff perl2json_chars undef, 'null';
}

sub _perl2json_chars_string : Test(1) {
    eq_or_diff perl2json_chars "undef", '"undef"';
}

sub _perl2json_chars_string_utf8 : Test(1) {
    eq_or_diff perl2json_chars "\x{5000}\x{132}a", qq{"\x{5000}\x{0132}a"};
}

sub _perl2json_chars_string_latin1 : Test(1) {
    eq_or_diff perl2json_chars "\x89\xC1\xFEa", qq{"\x{0089}\x{00C1}\x{00FE}a"};
}

sub _perl2json_chars_string_empty : Test(1) {
    eq_or_diff perl2json_chars '', '""';
}

sub _perl2json_chars_zero : Test(1) {
    eq_or_diff perl2json_chars 0, '0';
}

sub _perl2json_chars_u2028 : Test(1) {
    eq_or_diff perl2json_chars {"\x{2028}\x{2029}" => "\x{2028}\x{2029}"},
        q<{"\\u2028\\u2029":"\\u2028\\u2029"}>;
}

# ------ perl2json_chars_for_record ------

sub _perl2json_chars_for_record_lt : Test(1) {
    is perl2json_chars_for_record({"<A>" => "<b+>"}), qq'{
   "\\u003CA>" : "\\u003Cb\\u002B>"
}
';
}

sub _perl2json_chars_unicode_for_record : Test(1) {
    is perl2json_chars_for_record({qw/a b c/, "\x{3000}\x{D800}"}), qq{{
   "a" : "b",
   "c" : "\x{3000}\x{D800}"
}
};
}

sub _perl2json_c4r : Test(1) {
    is perl2json_chars_for_record({qw/a b c/, "\x{3000}"}),
        qq'{
   "a" : "b",
   "c" : "\x{3000}"
}
';
}

sub _perl2json_chars_for_record_null : Test(1) {
    eq_or_diff perl2json_chars_for_record undef, 'null' . "\x0A";
}

sub _perl2json_chars_for_record_string : Test(1) {
    eq_or_diff perl2json_chars_for_record "undef", '"undef"' . "\x0A";
}

sub _perl2json_chars_for_record_string_utf8 : Test(1) {
    eq_or_diff perl2json_chars_for_record "\x{5000}\x{132}a", qq{"\x{5000}\x{0132}a"\x0A};
}

sub _perl2json_chars_for_record_string_latin1 : Test(1) {
    eq_or_diff perl2json_chars_for_record "\x89\xC1\xFEa", qq{"\x{0089}\x{00C1}\x{00FE}a"\x0A};
}

sub _perl2json_chars_for_record_string_empty : Test(1) {
    eq_or_diff perl2json_chars_for_record '', '""' . "\x0A";
}

sub _perl2json_chars_for_record_zero : Test(1) {
    eq_or_diff perl2json_chars_for_record 0, '0' . "\x0A";
}

sub _perl2json_chars_for_record_u2028 : Test(1) {
    eq_or_diff perl2json_chars_for_record {"\x{2028}\x{2029}" => "\x{2028}\x{2029}"}, q<{
   "\\u2028\\u2029" : "\\u2028\\u2029"
}
>;
}

# ------ perl2json_bytes ------

sub _perl2json_bytes : Test(1) {
    is perl2json_bytes({qw/a b c/, "\x{3000}"}),
        encode 'utf8', qq'{"c":"\x{3000}","a":"b"}';
}

sub _perl2json_bytes_lt : Test(1) {
    is perl2json_bytes({"+<A>" => "<b>"}), qq'{"\\u002B\\u003CA>":"\\u003Cb>"}';
}

sub _perl2json_bytes_unicode : Test(1) {
    eq_or_diff perl2json_bytes({qw/a b c/, "\x{3000}\x{D800}"}),
        qq{{"c":"\xe3\x80\x80\xed\xa0\x80","a":"b"}};
}

sub _perl2json_bytes_null : Test(1) {
    eq_or_diff perl2json_bytes undef, 'null';
}

sub _perl2json_bytes_string : Test(1) {
    eq_or_diff perl2json_bytes "undef", '"undef"';
}

sub _perl2json_bytes_string_utf8 : Test(1) {
    eq_or_diff perl2json_bytes "\x{5000}\x{132}a", u8 qq{"\x{5000}\x{0132}a"};
}

sub _perl2json_bytes_string_latin1 : Test(1) {
    eq_or_diff perl2json_bytes "\x89\xC1\xFEa",
        u8 qq{"\x{0089}\x{00C1}\x{00FE}a"};
}

sub _perl2json_bytes_string_empty : Test(1) {
    eq_or_diff perl2json_bytes '', '""';
}

sub _perl2json_bytes_zero : Test(1) {
    eq_or_diff perl2json_bytes 0, '0';
}

sub _perl2json_bytes_u2028 : Test(1) {
    eq_or_diff perl2json_bytes {"\x{2028}\x{4000}\x{2029}" => "\x{2028}\x{2029}"},
        qq<{"\\u2028\xe4\x80\x80\\u2029":"\\u2028\\u2029"}>;
}

# ------ perl2json_bytes_for_record ------

sub _perl2json_bytes_for_record_lt : Test(1) {
    is perl2json_bytes_for_record({"<A>" => "<+b>"}), qq'{
   "\\u003CA>" : "\\u003C\\u002Bb>"
}
';
}

sub _perl2json_bytes_for_record_unicode : Test(1) {
    eq_or_diff perl2json_bytes_for_record({qw/a b c/, "\x{3000}\x{D800}"}), qq{{
   "a" : "b",
   "c" : "\xe3\x80\x80\xed\xa0\x80"
}
};
}

sub _perl2json_b4r : Test(1) {
    eq_or_diff perl2json_bytes_for_record({qw/a b c/, "\x{3000}"}),
        encode 'utf8', qq'{
   "a" : "b",
   "c" : "\x{3000}"
}
';
}

sub _perl2json_bytes_for_record_null : Test(1) {
    eq_or_diff perl2json_bytes_for_record undef, 'null' . "\x0A";
}

sub _perl2json_bytes_for_record_string : Test(1) {
    eq_or_diff perl2json_bytes_for_record "undef", '"undef"' . "\x0A";
}

sub _perl2json_bytes_for_record_string_utf8 : Test(1) {
    eq_or_diff perl2json_bytes_for_record "\x{5000}\x{132}a",
        u8 qq{"\x{5000}\x{0132}a"\x0A};
}

sub _perl2json_bytes_for_record_string_latin1 : Test(1) {
    eq_or_diff perl2json_bytes_for_record "\x89\xC1\xFEa",
        u8 qq{"\x{0089}\x{00C1}\x{00FE}a"\x0A};
}

sub _perl2json_bytes_for_record_string_empty : Test(1) {
    eq_or_diff perl2json_bytes_for_record '', '""' . "\x0A";
}

sub _perl2json_bytes_for_record_zero : Test(1) {
    eq_or_diff perl2json_bytes_for_record 0, '0' . "\x0A";
}

sub _perl2json_bytes_for_record_u2028 : Test(1) {
    eq_or_diff perl2json_bytes_for_record {"\x{2028}\x{4000}\x{2029}" => "\x{2028}\x{2029}"}, qq<{
   "\\u2028\xe4\x80\x80\\u2029" : "\\u2028\\u2029"
}
>;
}

__PACKAGE__->runtests;

1;
