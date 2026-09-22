# mutants

Mutation testing for shell scripts and [bats-core](https://github.com/bats-core/bats-core).

Your suite is green. Does that actually mean the tests check anything? `mutants`
breaks your code on purpose, one small change at a time, and reruns the suite.
If a test fails, good, the mutation got killed. If everything still passes, that
change slipped through and nothing was really testing it.

I wrote this because a passing bats run kept giving me false confidence. Line
coverage told me a line ran, not that a test would notice if it were wrong.

## Install

```sh
install -Dm755 mutants ~/.local/bin/mutants
```

Needs bash, awk, and whatever runs your tests (bats, usually).

## Use

```sh
mutants --run "bats test" src/myscript.sh
```

```
mutants: checking baseline suite...
mutants: 3 mutants across src/myscript.sh

SURVIVED  src/myscript.sh:9  [ -lt -> -ge ]  if [ "$n" -lt -100 ]; then

Score: 2/3 killed (66%)  - 1 survived
```

That survivor on line 9 means the branch got mutated and not one test cared.

## How it works

Run the suite once (it has to start green). Then for every operator it knows,
flip it one occurrence at a time and rerun. Killed = a test failed. Survived =
they all passed. Originals are snapshotted up front and put back after each run,
including if you Ctrl+C out mid-way.

## Operators

`-eq`/`-ne`, `-lt`/`-ge`, `-gt`/`-le` and the other comparisons, `-z`/`-n`,
`==`/`!=`, `&&`/`||`, `true`/`false`, both directions. They're matched as
space-separated tokens, so `x=1` or a word that happens to contain `eq` is left
alone.

## Options

```
--run CMD        command to run per mutant (default "bats test", or $MUTANTS_RUN)
-h               help
```

Exit is non-zero if anything survived, so you can fail CI on it:

```yaml
- run: mutants --run "bats test" src/*.sh
```

## Rough edges

Operators have to be space-separated, the normal shell style; `a&&b` glued
together won't be mutated. And every mutant reruns the whole suite, so it costs
about `mutants x suite time`. Point it at the files that matter, not everything.

## License

MIT.
