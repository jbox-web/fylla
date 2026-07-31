# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Fylla is a Ruby gem that generates zsh and bash shell-completion scripts for
[Thor](https://github.com/rails/thor) CLI applications. It works by monkey-patching Thor
(via `Module#prepend`) and walking Thor's own command/subcommand/option registry, then rendering
that tree through ERB templates.

## Commands

```bash
bundle install                              # install dependencies
bin/rake                                    # default task: spec
bin/rspec                                   # all examples
bin/rspec spec/fylla/zsh/enum_spec.rb       # one file
bin/rspec spec/fylla/zsh/enum_spec.rb:15    # one example, by line
bin/rubocop                                 # lint (its own CI job, not part of rake)
```

RuboCop targets Ruby 3.2 (`.rubocop.yml`), matching `required_ruby_version` in the gemspec.
CI (`.github/workflows/ci.yml`) runs `bin/rubocop` once and `bin/rspec` across the Ruby matrix,
then publishes `coverage/coverage.json` to qlty.

## Packaging invariant

`s.files` in the gemspec must keep matching `lib/**/*.erb`. The generator reads its templates from
disk at runtime, and the suite loads `lib/` straight from the checkout, so it never notices a
template missing from the built gem — a gem shipped without them raises `Errno::ENOENT` on the
first call. Verify a packaging change by building and installing into a scratch `GEM_HOME`, not by
running the suite.

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

All of it lives in `Fylla::Generator` (`lib/fylla/generator.rb`), a plain object. Only
`zsh_completion` and `bash_completion` are injected into Thor classes, so nothing else can collide
with a method the host application declares.

1. `#root_command` wraps the whole CLI in a synthetic `ParsedSubcommand` with a `nil` name — this
   removes the "no top-level command" special case from everything downstream. An empty command
   name is therefore meaningful, not a bug; the bash `subcommand.erb` falls back to
   `@executable_name` for it.
2. `#find_commands` zips `Thor.commands` against `Thor.subcommand_classes`: a nil match means a
   leaf → `ParsedCommand`; otherwise recurse → `ParsedSubcommand`.
3. `#render` walks that tree, accumulating a `context_name` breadcrumb (`_sub1_sub2`) that becomes
   the shell function name, and `class_options` down the subcommand chain. `#merge_class_options`
   parses only the Thor options and dedupes by name: re-parsing an already built `ParsedOption`
   would read attributes it does not carry and silently drop the enum action.
4. Each node renders `erb_templates/<style>/<command|subcommand>.erb` via `binding`, so the
   templates read the local variables of `#render_one` directly (`command`, `context_name`,
   `class_options`, `@executable_name`). Renaming those locals breaks the templates. Trim mode is
   `-<>`; whitespace in the templates is load-bearing because the specs assert on exact output.
5. Subcommands are emitted **depth-first, children before parents**, so a shell function is always
   defined before it is referenced.

`Fylla::Templates` reads and compiles the four templates once. They used to be re-read and
recompiled per node: 225 `File.read` for a 225-command CLI, against 2 now.

`ParsedOption#initialize` is where zsh completion *actions* are computed (`_values -s ,` for
filtered arrays, `_sequence` for unfiltered, `: :(a b c)` for string enums), and where
`equals_type` decides whether a switch takes a value (`""` for `:boolean`, `"="` otherwise).
Option description precedence: `completion` → `description` → `banner` → upcased name.

## Escaping

`Fylla::ShellEscape.zsh_optspec` is the only place a description gets escaped for an `_arguments`
optspec, and it must stay that way. The text crosses **two** layers — double-quote processing, then
comparguments' own bracket parser — which is why the backslash is quadrupled while everything else
is escaped once. A lone `[` or `]` gets the whole optspec rejected at completion time, killing
completion for the entire command, and `$(…)` or a backtick would run when the user hits TAB.

`zsh -n` cannot see any of this: the script is valid shell either way. `spec/fylla/shell_spec.rb`
drives a real zsh through `zpty` to check that comparguments accepts what we emit.

## Thor extensions

- `completion_extension.rb` adds the `fylla:` key on Thor options:
  `option :x, fylla: { completion: "custom text", filter: false }`. `filter` defaults to `true`.
- `comma_array_extension.rb` overrides `Thor::Arguments#parse_array` so `--opt a,b,c` is split on
  commas (POSIX `getopt_long` style) on top of Thor's space-separated form; the two mix freely.
  It calls `validate_enum_value!` exactly as Thor does — dropping that call silently disabled
  `enum:` validation for every array option in the host application.

## Specs

Examples are golden-output tests: they run a Thor fixture, capture the generated script, and match
it against a heredoc. Changing template whitespace or option ordering will fail many at once.

- `spec/support/` holds the Thor applications, grouped by target shell. All zsh fixtures subclass
  `Zsh::ThorTest`, which defines the `generate_completions` command — hence that command appears in
  nearly every expected zsh script. These files print on stdout on purpose, so they are excluded
  from `RSpec/Output`.
- `spec/spec_helper.rb` defines `FyllaTest`, included into every example group via
  `config.include`. It exposes `zsh_script(klass, name)`, `bash_script(klass, name)`,
  `capture_stdout` and `capture_stderr`. They call `Fylla.load` and return the script as a String,
  so examples assert with `expect(script).to include(...)` rather than wrapping the call in
  `expect { }`. Adding a helper there without the `config.include` fails every example at once
  with `NoMethodError`.
- `spec/support/shell_helper.rb` adds `bash_completions` (source a generated script in a real bash
  and read back `COMPREPLY`) and `zsh_arguments_error` (feed one optspec to a real zsh through
  `zpty` and report what comparguments says). Both skip when the shell is absent.
- `spec/fylla/` is split by concern (zsh options, zsh enums, zsh descriptions, bash scripts, the
  Thor argument extension, the shell round-trip), not one file per class — hence the
  `RSpec/SpecFilePathFormat` exclusion.

`lib/` sits at 100% line and branch coverage, and that alone proves very little about the scripts.
Two defects survived a fully covered suite: a description containing `[` produced a syntactically
valid script that `_arguments` refused at completion time, and the packaged gem shipped without
its templates. Hence `spec/fylla/shell_spec.rb`, and the packaging invariant above.
