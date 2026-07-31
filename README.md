# Fylla

[![CI](https://github.com/jbox-web/fylla/actions/workflows/ci.yml/badge.svg)](https://github.com/jbox-web/fylla/actions/workflows/ci.yml)

Fylla, the Norse word for `complete`, is an autocompletion script generator for the [Thor](https://whatisthor.com) framework.

It generates completion scripts for both zsh and bash.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fylla'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install fylla
```

## Usage

```ruby
require 'thor'
require 'fylla' # needs to come before anything that forces Thor configuration
require 'cli' # has code like `class CLI < Thor` which forces Thor configuration

Fylla.load('cli') # must come before `#start()`

CLI.start(ARGV)
```

`Fylla` must be loaded before `Thor.start` is called in order for it to be used.

`require 'fylla'` must be called before any Thor code is accessed _if you would like to use the `fylla:` option_.
The key is read when the option is built, so an option declared before the require silently keeps
its defaults. If you do not use the `fylla:` key at all, this requirement does not need to be met.

General use case will be to create a new subcommand or option that calls `Fylla.zsh_completion(self)`

`Fylla.zsh_completion` returns a string containing the entire zsh completion script, that you can
use to do what you see fit. `Fylla.bash_completion` does the same for bash.

The only requirement for calling `Fylla.zsh_completion(self)` is that `Thor` has loaded all commands/options/etc.

For some examples, you can reference the `spec` folder.

### The `fylla:` option key

Extra settings live under a `fylla:` hash, alongside Thor's own option settings:

```ruby
option :env,
       enum: %w[dev staging prod],
       fylla: {
         completion: "target environment", # text shown next to the switch
         filter: false                     # keep offering values already typed
       }
```

* `completion` overrides the text displayed next to the switch. It takes precedence over `desc`,
  which takes precedence over `banner`, which falls back to the upcased option name.
* `filter` only applies to `type: :array` options declared with an `enum:`. It defaults to `true`,
  which removes already-typed values from further completions.

### Side effects on Thor

Requiring `fylla` prepends three modules into Thor, which changes the behaviour of your whole
application, not only completion generation:

* `Thor::Option` gains the `fylla:` key described above.
* `Thor::Arguments` parses `type: :array` options as comma-separated (`--tags a,b,c`) in addition
  to Thor's space-separated form. Note that the split is currently decided on the first token only,
  and that Thor's `enum:` validation is not applied to array options while fylla is loaded.
* `Fylla.load` prepends the generator itself, adding `zsh_completion` and `bash_completion` to
  every Thor class in the process.

## Development

After checking out the repo, run `bundle install` to install dependencies. Then run `bin/rspec` to run the specs and `bin/rubocop` to lint. `bin/rake` runs the specs alone; RuboCop is a separate CI job. For an interactive prompt, run `bundle exec irb -Ilib -rfylla`.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jbox-web/fylla. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Fylla project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/jbox-web/fylla/blob/master/CODE_OF_CONDUCT.md).

## Todo list

* use desc if banner isn't present
* add completion parameter to Option class to use by default
* allow zsh_completion and bash_completion to be called from _anywhere_. This might be impossible. 
* allow supplying custom templates
