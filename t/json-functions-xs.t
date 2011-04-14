package test::JSON::Functions::XS;
use strict;
use warnings;
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

sub _json_chars2perl : Test(1) {
    is_deeply json_chars2perl('{"a":"b","c":"\u3000"}'), {qw/a b c/, "\x{3000}"};
}

sub _json_bytes2perl_1 : Test(1) {
    is_deeply json_bytes2perl('{"a":"b","c":"\u3000"}'), {qw/a b c/, "\x{3000}"};
}

sub _json_bytes2perl_2 : Test(1) {
    is_deeply json_bytes2perl('{"a":"b","c": "'.(encode 'utf8', "\x{3000}").'"}'), {qw/a b c/, "\x{3000}"};
}

sub _json_bytes2perl_broken : Test(1) {
    eq_or_diff json_bytes2perl('{"a":"b",'), undef;
}

sub _perl2json_chars : Test(1) {
    is perl2json_chars({qw/a b c/, "\x{3000}"}), qq'{"c":"\x{3000}","a":"b"}';
}

sub _json_chars2perl_broken : Test(1) {
    eq_or_diff json_chars2perl('{"a":"b",'), undef;
}

sub _perl2json_c4r : Test(1) {
    is perl2json_chars_for_record({qw/a b c/, "\x{3000}"}),
        qq'{
   "a" : "b",
   "c" : "\x{3000}"
}';
}

sub _perl2json_bytes : Test(1) {
    is perl2json_bytes({qw/a b c/, "\x{3000}"}),
        encode 'utf8', qq'{"c":"\x{3000}","a":"b"}';
}

sub _perl2json_b4r : Test(1) {
    is perl2json_bytes_for_record({qw/a b c/, "\x{3000}"}),
        encode 'utf8', qq'{
   "a" : "b",
   "c" : "\x{3000}"
}';
}

__PACKAGE__->runtests;

1;
