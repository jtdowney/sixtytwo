import qcheck
import sixtytwo
import unitest

pub fn main() -> Nil {
  unitest.main()
}

pub fn encode_empty_test() {
  assert sixtytwo.encode(<<>>) == ""
}

pub fn decode_empty_test() {
  assert sixtytwo.decode("") == Ok(<<>>)
}

pub fn encode_single_byte_test() {
  assert sixtytwo.encode(<<0>>) == "0"
  assert sixtytwo.encode(<<1>>) == "1"
  assert sixtytwo.encode(<<61>>) == "z"
  assert sixtytwo.encode(<<62>>) == "10"
  assert sixtytwo.encode(<<255>>) == "47"
}

pub fn decode_single_byte_test() {
  assert sixtytwo.decode("0") == Ok(<<0>>)
  assert sixtytwo.decode("1") == Ok(<<1>>)
  assert sixtytwo.decode("z") == Ok(<<61>>)
  assert sixtytwo.decode("10") == Ok(<<62>>)
  assert sixtytwo.decode("47") == Ok(<<255>>)
}

pub fn encode_leading_zeros_test() {
  assert sixtytwo.encode(<<0, 0>>) == "00"
  assert sixtytwo.encode(<<0, 0, 0>>) == "000"
  assert sixtytwo.encode(<<0, 0, 0, 0>>) == "0000"
  assert sixtytwo.encode(<<0, 1>>) == "01"
  assert sixtytwo.encode(<<0, 0, 42>>) == "00g"
  assert sixtytwo.encode(<<0, 255>>) == "047"
}

pub fn decode_leading_zeros_test() {
  assert sixtytwo.decode("00") == Ok(<<0, 0>>)
  assert sixtytwo.decode("000") == Ok(<<0, 0, 0>>)
  assert sixtytwo.decode("0000") == Ok(<<0, 0, 0, 0>>)
  assert sixtytwo.decode("01") == Ok(<<0, 1>>)
  assert sixtytwo.decode("00g") == Ok(<<0, 0, 42>>)
  assert sixtytwo.decode("047") == Ok(<<0, 255>>)
}

pub fn encode_cross_impl_test() {
  assert sixtytwo.encode(<<"hello":utf8>>) == "7tQLFHz"
  assert sixtytwo.encode(<<"Hello":utf8>>) == "5TP3P3v"
  assert sixtytwo.encode(<<"foobar":utf8>>) == "VytN8Wjy"
  assert sixtytwo.encode(<<0xDE, 0xAD, 0xBE, 0xEF>>) == "44pZgF"
  assert sixtytwo.encode(<<0xFF, 0xFF, 0xFF>>) == "18OWF"
}

pub fn decode_cross_impl_test() {
  assert sixtytwo.decode("7tQLFHz") == Ok(<<"hello":utf8>>)
  assert sixtytwo.decode("5TP3P3v") == Ok(<<"Hello":utf8>>)
  assert sixtytwo.decode("VytN8Wjy") == Ok(<<"foobar":utf8>>)
  assert sixtytwo.decode("44pZgF") == Ok(<<0xDE, 0xAD, 0xBE, 0xEF>>)
  assert sixtytwo.decode("18OWF") == Ok(<<0xFF, 0xFF, 0xFF>>)
}

pub fn encode_long_input_test() {
  assert sixtytwo.encode(<<"Hello!":utf8, 0xDE, 0xAD, 0xBE, 0xEF>>)
    == "1hy1KVieXz985n"
}

pub fn decode_long_input_test() {
  assert sixtytwo.decode("1hy1KVieXz985n")
    == Ok(<<"Hello!":utf8, 0xDE, 0xAD, 0xBE, 0xEF>>)
}

pub fn decode_invalid_char_test() {
  assert sixtytwo.decode("!") == Error(Nil)
  assert sixtytwo.decode("hello world") == Error(Nil)
  assert sixtytwo.decode("-") == Error(Nil)
  assert sixtytwo.decode("abc=") == Error(Nil)
}

pub fn encode_decode_roundtrip_test() {
  use input <- qcheck.given(qcheck.byte_aligned_bit_array())
  assert sixtytwo.decode(sixtytwo.encode(input)) == Ok(input)
}
