# CHANGELOG

## 0.5.3 (unreleased)

**Features**

* Offer the commands declared through Thor's `map`. A command reachable as `install` because of
  `map "install" => :setup` is now completed under that name too, with its own function. Flag
  aliases stay out of the command list — they are options — and so does an alias spelled like a
  command that already exists, which would otherwise be listed twice. An alias pointing at a
  subcommand is not offered: the subcommand remains completable under its own name.

**Fixes**

* Escape the characters that are live inside a zsh optspec. An unescaped `[` or `]` in a
  description had comparguments reject the whole optspec, killing completion for that command; a
  `$(…)` or a backtick ran when the user pressed TAB. `zsh -n` sees none of this, so the specs now
  drive a real zsh to check what comparguments accepts.
* Restore the `enum:` validation Thor applies to array options. The comma-splitting override
  dropped it, so `--envs bogus` was accepted on an option declared `enum: %w[dev prod]`.
* Split every token of an array option on commas, not just the first, so `--tags a b,c` and
  `--tags a,b c` behave like `--tags a,b,c`. Empty segments are dropped.
* Give class options their equals sign and their enum completion action in subcommand functions;
  they were rendered as if they were flags.
* Offer class options inherited from a parent inside its subcommands in bash, as zsh already did.
* Raise `ArgumentError` when no executable name is available, instead of emitting a script naming
  every function `_` and exiting 0.
* Deduplicate class options by name: one declared at several nesting levels was listed once per
  level.
* Ship the ERB templates inside the packaged gem. `s.files` only matched `lib/**/*.rb`, so every
  installed gem was missing `lib/fylla/erb_templates/` and raised `Errno::ENOENT` on the first call
  to `zsh_completion` or `bash_completion`. The test suite could not catch this, as it loads `lib/`
  straight from the repository.
* Emit option aliases with a single dash. Thor stores them dash-prefixed since 1.3, and the
  templates added one of their own, so generated scripts offered `--a` where the alias is `-a` —
  a switch Thor rejects at runtime. **Generated scripts change accordingly.**

**Removed**

* The `fylla` executable. It ran a `require` and nothing else, exiting 0 without output.

**Dependencies**

* Require `thor >= 1.3.0`, up from `>= 0.19.0`. That is the release where
  `Thor::Arguments#validate_enum_value!` appeared — it is absent in 1.2.2 — and the comma array
  extension calls it to keep `enum:` validation working. The old floor was already fiction.

**Development**

* Extract the walk into `Fylla::Generator`. Only `zsh_completion` and `bash_completion` are added
  to Thor classes now; the helpers no longer land in the singleton class of every Thor class in
  the process.
* Read and compile each ERB template once instead of per node: 225 `File.read` for a 225-command
  CLI, against 2 now, and generation down from 26 ms to 7 ms
* Move the repository to `jbox-web`, and update the gem metadata that still pointed elsewhere
* Convert the test suite from Minitest to RSpec
* Cover the comma-array Thor extension, which had no test at all despite changing how every host
  application parses its own `type: :array` options
* Rework CI: restricted workflow permissions, Ruby 3.2 through 4.0 plus head, jruby and
  truffleruby, coverage published to qlty
* Document the `fylla:` option key, and the side effects requiring fylla has on Thor

## 0.5.2

Fix deprecation warnings in ERB
Switch deploy to GitHub Actions

## 0.5.1

* Fix completions for string enums, only complete a single arg, rather than multiple
args.

* Don't put = when option is a boolean
 
## 0.5.0

Move `completion:` option into a new `fylla:` hash option to allow for expanding the 
features of fylla. 

Modify the `zsh_completion` feature to generate completion for `enum:` options. 
  
  * By default it will remove duplicate matches when completing
  
Add new `filter:` option into `fylla:` in order to allow _not_ removing duplicate 
matches when completing `enum:` options

## 0.4.3

Fix null descriptions causing parsing failures 2.0 (`\` didn't work, trying `'"'"'`)

## 0.4.2

Fix null descriptions causing parsing failures

## 0.4.1

Small bug when the descriptions contain single or double quotes (in zsh)

## 0.4.0

Add `completion:` option for `option` hash. Specify this if 
`desc` or `banner` are not providing desired completion text

## 0.2.0

* add bash completion generation
* add code coverage metrics

## 0.1.0

Initial version of Fylla

* add zsh completion generation
* add zsh tests
* add rubocop formatting
* add yard documentation 
