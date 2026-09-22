# shmutate

Mutation testing for shell, aimed at [bats-core](https://github.com/bats-core/bats-core) suites.

It changes one operator in your script (say `-eq` to `-ne`), runs your tests,
then puts the file back. If the tests still pass, nothing was covering that
change. Those are what it reports.

I made it because green bats runs were lying to me. Coverage said a line ran,
not that a test would catch it being wrong.

## Install

```sh
install -Dm755 shmutate ~/.local/bin/shmutate
```

Needs bash and awk. Tests run through whatever you pass to `--run`, bats by default.

## Use

```sh
shmutate --run "bats test" src/myscript.sh
```

```
shmutate: checking baseline suite...
shmutate: 3 mutants across src/myscript.sh

SURVIVED  src/myscript.sh:9  [ -lt -> -ge ]  if [ "$n" -lt -100 ]; then

Score: 2/3 killed (66%)  - 1 survived
```

Line 9 got mutated and no test noticed.

## How it works

The suite has to pass first. Then for each operator it flips one occurrence,
reruns, and records whether a test failed (killed) or not (survived). Files are
copied aside before anything runs, so a Ctrl+C won't leave a mutated file behind.

## Operators

Comparisons (`-eq`/`-ne`, `-lt`/`-ge`, `-gt`/`-le` and the rest), `-z`/`-n`,
`==`/`!=`, `&&`/`||`, `true`/`false`, both ways. Matched as whole space-separated
tokens, so `x=1` and words that contain `eq` are left alone.

## Options

```
--run CMD    how to run the suite per mutant (default "bats test", or $SHMUTATE_RUN)
-h           help
```

Exits non-zero if anything survived, so CI can fail on it.

## Rough edges

Only space-separated operators, so `a&&b` is skipped. Each mutant reruns the
whole suite, so runtime is roughly mutants times suite. Aim it at the files that
matter.

## License

MIT.
