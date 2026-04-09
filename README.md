# sixtytwo

[![Package Version](https://img.shields.io/hexpm/v/sixtytwo)](https://hex.pm/packages/sixtytwo)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/sixtytwo/)

Base62 encoding and decoding for Gleam, targeting both Erlang and JavaScript.

Uses the standard `0-9A-Za-z` alphabet with Bitcoin/base-x style leading zero
preservation, compatible with [base-x](https://github.com/cryptocoinjs/base-x).

## Usage

```sh
gleam add sixtytwo
```

```gleam
import sixtytwo

sixtytwo.encode(<<"hello":utf8>>)
// -> "7tQLFHz"

sixtytwo.decode("7tQLFHz")
// -> Ok(<<"hello":utf8>>)
```

Further documentation can be found at <https://hexdocs.pm/sixtytwo>.
