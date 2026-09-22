# mutants

Mutation testing for shell scripts and [bats-core](https://github.com/bats-core/bats-core).

Your tests are green. But would they catch a bug? `mutants` injects one small
fault at a time into your shell code, runs your suite, and reports the mutations
your tests **failed** to notice. Those survivors are the gaps a coverage
percentage never shows you.

## Why

A passing test suite tells you the code works for the cases you thought of.
Line coverage tells you a line ran — not that a test would fail if that line
were wrong. Mutation testing closes that gap: if `mutants` can change `-eq` to
`-ne`, or `&&` to `||`, and every test still passes, then nothing actually
checked that behaviour.

There is a lot of mutation tooling for other languages and almost none for
shell. This is that tool, and it plugs straight into bats-core.

## Install

```sh
install -Dm755 mutants ~/.local/bin/mutants
```

Requires `bash`, `awk`, and whatever runs your tests (e.g. `bats`).

## Quick start

```sh
mutants --run "bats test" src/myscript.sh
```

```
mutants: checking baseline suite...
mutants: 3 mutants across src/myscript.sh

SURVIVED  src/myscript.sh:9  [ -lt -> -ge ]  if [ "$n" -lt -100 ]; then

Score: 2/3 killed (66%)  - 1 survived
```

Line 9 was mutated and every test still passed — nothing exercises that branch.

## How it works

1. Run your suite once. If it is not already green, `mutants` stops — you can't
   grade tests that are already failing.
2. For each mutable operator in the target file, generate one mutant per
   occurrence.
3. For each mutant: apply the single change, run the suite, and record whether a
   test failed (**killed**, good) or everything still passed (**survived**, a
   gap). The file is restored after every run.
4. Report the survivors and a kill score.

Only one mutation is live at a time, and the original files are snapshotted and
restored on exit — including on `Ctrl+C`.

## Mutation operators

| From | To | | From | To |
|---|---|---|---|---|
| `-eq` | `-ne` | | `-z` | `-n` |
| `-lt` | `-ge` | | `==` | `!=` |
| `-gt` | `-le` | | `&&` | `\|\|` |
| `-le` | `-gt` | | `true` | `false` |
| `-ge` | `-lt` | | | |

(and each pair's reverse). Operators are matched as whitespace-delimited tokens,
so assignments like `x=1` and text inside words are left alone.

## Options

```
--run CMD        test command per mutant (default: "bats test", or $MUTANTS_RUN)
--threshold N    minimum kill score % to exit 0 (default: 100)
-v, --verbose    also list killed mutants
-h, --help       help
```

Exit status is non-zero when the score is below the threshold, so it gates CI:

```yaml
- run: mutants --run "bats test" --threshold 90 src/*.sh
```

## Limitations

- Operators must be whitespace-delimited (the common shell style). Glued forms
  like `a&&b` are not mutated.
- Each mutant re-runs the whole suite, so runtime is `mutants x suite time`.
  Point it at the files you care about.

## License

MIT — see [LICENSE](LICENSE).
