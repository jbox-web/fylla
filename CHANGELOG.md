# CHANGELOG

## 0.5.3 (unreleased)

**Fixes**

* Ship the ERB templates inside the packaged gem. `s.files` only matched `lib/**/*.rb`, so every
  installed gem was missing `lib/fylla/erb_templates/` and raised `Errno::ENOENT` on the first call
  to `zsh_completion` or `bash_completion`. The test suite could not catch this, as it loads `lib/`
  straight from the repository.
* Emit option aliases with a single dash. Thor stores them dash-prefixed since 1.3, and the
  templates added one of their own, so generated scripts offered `--a` where the alias is `-a` —
  a switch Thor rejects at runtime. **Generated scripts change accordingly.**

**Development**

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
