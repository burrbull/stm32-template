# `stm32-template`

> A template for building applications for STM32 microcontrollers

## Dependencies

To build embedded programs using this template you'll need:

- The `cargo generate` subcommand. [Installation
  instructions](https://github.com/cargo-generate/cargo-generate#installation).

- `rust-std` components (pre-compiled `core` crate) for the ARM Cortex-M
  targets. Run:
  
``` console
$ rustup target add thumbv6m-none-eabi thumbv7m-none-eabi thumbv7em-none-eabi thumbv7em-none-eabihf
```

## Instantiate the template.

1. Run and enter project name
``` console
$ cargo generate --git https://github.com/burrbull/stm32-template/
 Project Name: app
```

2. Specify **chip product name** and answer on several other guide questions.

3. Your program is ready to compile:
``` console
cargo build --release
```

## Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall be
dual licensed as above, without any additional terms or conditions.

## Code of Conduct

Contribution to this crate is organized under the terms of the [Rust Code of
Conduct][CoC], the maintainer of this crate, promises
to intervene to uphold that code of conduct.

[CoC]: https://www.rust-lang.org/policies/code-of-conduct