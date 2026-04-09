//// Base62 encoding and decoding for Gleam, targeting both Erlang and JavaScript.
////
//// Uses the standard `0-9A-Za-z` alphabet with Bitcoin/base-x style leading
//// zero preservation, compatible with `cryptocoinjs/base-x`.
////
//// ## Examples
////
//// ```gleam
//// sixtytwo.encode(<<"hello":utf8>>)
//// // -> "7tQLFHz"
////
//// sixtytwo.decode("7tQLFHz")
//// // -> Ok(<<"hello":utf8>>)
//// ```

import gleam/bit_array
import gleam/bool
import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string

const alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

const base = 62

/// Encode a bit array using base62. The input must be byte-aligned.
/// Leading zero bytes are preserved as `0` characters in the output.
pub fn encode(input: BitArray) -> String {
  use <- bool.guard(when: bit_array.byte_size(input) == 0, return: "")
  let leading_zeros = count_leading_zeros(input, 0)
  let prefix = string.repeat("0", leading_zeros)
  let encode_map = build_encode_map()

  let digits = bytes_to_base_digits(input, [])
  case digits {
    [] -> prefix
    _ -> {
      let encoded =
        list.map(digits, lookup_char(encode_map, _))
        |> string.concat
      prefix <> encoded
    }
  }
}

/// Decode a base62 string. Returns `Error(Nil)` on invalid input.
pub fn decode(input: String) -> Result(BitArray, Nil) {
  use <- bool.guard(when: input == "", return: Ok(<<>>))
  let decode_map = build_decode_map()
  let chars = string.to_graphemes(input)
  use values <- result.try(list.try_map(chars, dict.get(decode_map, _)))
  let leading_zeros = count_leading_zero_values(values)
  let bytes = base_digits_to_bytes(values)

  let decoded =
    list.repeat(0, leading_zeros)
    |> list.append(bytes)
    |> list.map(fn(b) { <<b>> })
    |> bit_array.concat

  Ok(decoded)
}

fn count_leading_zeros(input: BitArray, count: Int) -> Int {
  case input {
    <<0, rest:bytes>> -> count_leading_zeros(rest, count + 1)
    _ -> count
  }
}

fn count_leading_zero_values(values: List(Int)) -> Int {
  case values {
    [0, ..rest] -> 1 + count_leading_zero_values(rest)
    _ -> 0
  }
}

fn build_encode_map() -> Dict(Int, String) {
  string.to_graphemes(alphabet)
  |> list.index_map(fn(char, index) { #(index, char) })
  |> dict.from_list
}

fn lookup_char(encode_map: Dict(Int, String), index: Int) -> String {
  dict.get(encode_map, index) |> result.unwrap("")
}

fn build_decode_map() -> Dict(String, Int) {
  string.to_graphemes(alphabet)
  |> list.index_map(fn(char, index) { #(char, index) })
  |> dict.from_list
}

fn bytes_to_base_digits(input: BitArray, digits: List(Int)) -> List(Int) {
  case input {
    <<byte, rest:bytes>> -> {
      let new_digits = multiply_and_add(digits, 256, byte, base)
      bytes_to_base_digits(rest, new_digits)
    }
    _ -> digits
  }
}

fn base_digits_to_bytes(digits: List(Int)) -> List(Int) {
  list.fold(digits, [], fn(bytes, digit) {
    multiply_and_add(bytes, base, digit, 256)
  })
}

fn multiply_and_add(
  digits: List(Int),
  multiplier: Int,
  addend: Int,
  digit_base: Int,
) -> List(Int) {
  let reversed = list.reverse(digits)
  do_multiply_and_add(reversed, multiplier, addend, digit_base, [])
}

fn do_multiply_and_add(
  reversed_digits: List(Int),
  multiplier: Int,
  carry: Int,
  digit_base: Int,
  acc: List(Int),
) -> List(Int) {
  case reversed_digits {
    [] -> emit_carry(carry, digit_base, acc)
    [digit, ..rest] -> {
      let value = digit * multiplier + carry
      let new_digit = value % digit_base
      let new_carry = value / digit_base
      do_multiply_and_add(rest, multiplier, new_carry, digit_base, [
        new_digit,
        ..acc
      ])
    }
  }
}

fn emit_carry(carry: Int, digit_base: Int, acc: List(Int)) -> List(Int) {
  case carry {
    0 -> acc
    _ -> {
      let digit = carry % digit_base
      let remaining = carry / digit_base
      emit_carry(remaining, digit_base, [digit, ..acc])
    }
  }
}
