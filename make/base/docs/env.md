## Environment variables

### The `.env` file

The `.env` file is responsible for storing environment variables, such as the list of enabled [dependencies].

It is automatically created on each invocation of `make` through the `.env` [target] declared in the [make/utils/env.mk] Makefile.

It can be removed either manually or with the [clean] target.

### Stored environment variables

Variables stored in the [`.env`] file are those parsed from the included Makefiles which are declared either with
- [conditional variable assignment] ( e.g. : `FOO ?= bar` )
- immediate [variable assignment] ( e.g. : `FOO ::= bar` )
- immediate [variable assignment] with escape ( e.g. : `FOO :::= bar` )

>[!IMPORTANT]
>variables which value relies on a [shell function] **must** be declared with an immediate [variable assignment] inside of a `ifndef` [condition] for performance reasons.
>See the example bellow from the [host] dependency which illustrates this.

```shell
ifndef OS
OS					::= $(shell uname -s | tr "[:upper:]" "[:lower:]")
endif
```

#### List of stored environment variables

| Name                  | Aliases               | Description                       | Default value
|:--                    |:--                    |:--                                |:--
| `DEPENDENCIES`        | `DEPS`                | List of enabled [dependencies]    | `null`

>[!NOTE]
>[dependencies] can also define environment variables that will be stored in the [`.env`] file, like the `BIN_DIR` variable defined by the [host] dependency.

### Special variables

Special variables are **not** stored in the [`.env`] file and can be declared through the command line, they can have any value once they are declared.

| Name                  | Aliases               | Description                       | Default value
|:--                    |:--                    |:--                                |:--
| `VERBOSE`             |                       | Enables make recipes verbosity    | `undefined`
| `NOCOLORS`            |                       | Disables colored [display]        | `undefined`

#### Example

```shell
make VERBOSE=1 NOCOLORS=yes
```

[`.env`]: #the-env-file
[dependencies]: ./deps.md
[clean]: ./clean.md
[make/utils/env.mk]: ../make/utils/env.mk
[target]: https://www.gnu.org/software/make/manual/make.html#What-a-Rule-Looks-Like
[conditional variable assignment]: https://www.gnu.org/software/make/manual/make.html#Conditional-Variable-Assignment
[variable assignment]: https://www.gnu.org/software/make/manual/make.html#Variable-Assignment
[shell function]: https://www.gnu.org/software/make/manual/make.html#The-shell-Function
[condition]: https://www.gnu.org/software/make/manual/make.html#Syntax-of-Conditionals
[display]: ./display.md#disabling-colors
[special dependency]: ./deps.md#special-dependencies
[host]: ./deps/host.md
