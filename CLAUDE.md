# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Fylla is a Ruby gem that generates zsh and bash shell-completion scripts for
[Thor](https://github.com/rails/thor) CLI applications. It works by monkey-patching Thor
(via `Module#prepend`) and walking Thor's own command/subcommand/option registry, then rendering
that tree through ERB templates.

## Commands

```bash
bin/rake                                 # default task: test + rubocop
bin/rake test                            # all tests
bin/rake test TEST=test/zsh/enum_test.rb # one test file
bin/rubocop                              # lint only
```

Running a **single test method** must bypass rake — `TESTOPTS="-n /pattern/"` is swallowed by
`Rake::TestTask` and interpreted as a filename:

```bash
bundle exec ruby -Ilib -Itest test/fylla_test.rb -n /version/
```

CI (`.github/workflows/test.yaml`) runs `bundle exec rake` on Ruby 3.1.2 only. RuboCop targets
Ruby 2.6 (`.rubocop.yml`), so avoid newer syntax in `lib/`.

## Load-order constraint (the central gotcha)

`lib/fylla.rb` prepends `Fylla::Thor::Option` into `::Thor::Option` and `Fylla::Thor::Arguments`
into `::Thor::Arguments` **at require time**. Consequently:

- `require "fylla"` must happen *before* any `class X < Thor` is evaluated, otherwise the
  `fylla:` option key is silently dropped from already-declared options.
- `Fylla.load(executable_name)` prepends `Fylla::Thor::CompletionGenerator` into `::Thor` and must
  run before `Thor#start`. Tests call it in `setup` for exactly this reason.

`Fylla.zsh_completion(self)` / `Fylla.bash_completion(self)` take the *Thor instance* and dispatch
to the class-level `zsh_completion` / `bash_completion` injected by the prepend.

## Generation pipeline

1. `ClassMethods#create_command_map` (`lib/fylla/completion_generator.rb`) wraps the whole CLI in a
   synthetic root `ParsedSubcommand` with an empty name — this removes the "no top-level command"
   special case from everything downstream. An empty command name is therefore meaningful, not a
   bug; the bash `subcommand.erb` falls back to `@executable_name` for it.
2. `recursively_find_commands` zips `Thor.commands` against `Thor.subcommand_classes`: a nil match
   means a leaf → `ParsedCommand`; otherwise recurse → `ParsedSubcommand`.
3. `map_to_completion_string` walks that tree, accumulating a `context_name` breadcrumb
   (`_sub1_sub2`) that becomes the shell function name, and accumulating `class_options` down the
   subcommand chain (parent class options are inherited and `uniq`'d into children).
4. Each node renders `erb_templates/<style>/<command|subcommand>.erb` via `binding`, so the
   templates read the local variables of `generate_completion_string` directly (`command`,
   `context_name`, `class_options`, `@executable_name`). Renaming those locals breaks the templates.
   Trim mode is `-<>`; whitespace in the templates is load-bearing because tests assert on exact
   output.
5. Subcommands are emitted **depth-first, children before parents**, so a shell function is always
   defined before it is referenced.

`ParsedOption#initialize` is where zsh completion *actions* are computed (`_values -s ,` for
filtered arrays, `_sequence` for unfiltered, `: :(a b c)` for string enums), and where
`equals_type` decides whether a switch takes a value (`""` for `:boolean`, `"="` otherwise).
Option description precedence: `completion` → `description` → `banner` → upcased name.

## Thor extensions

- `completion_extension.rb` adds the `fylla:` key on Thor options:
  `option :x, fylla: { completion: "custom text", filter: false }`. `filter` defaults to `true`.
- `comma_array_extension.rb` overrides `Thor::Arguments#parse_array` so `--opt a,b,c` is split on
  commas (POSIX `getopt_long` style) instead of Thor's default space-separated consumption.

## Tests

Tests are golden-output tests: they build a Thor CLI fixture, generate the completion script, and
compare against a heredoc. Changing template whitespace or option ordering will fail many of them
at once.

- `test/zsh/test_commands/` and `test/bash/bash_clis/` hold the Thor fixtures. All zsh fixtures
  subclass `Zsh::ThorTest`, which defines the `generate_completions` command — hence that command
  appears in nearly every expected zsh script.
- `test_helper.rb` starts SimpleCov and defines `matches(expected)` for escaped-literal regexes.
- Test classes mutate global `ARGV` and call `Fylla.load` in `setup`; keep that pattern.
