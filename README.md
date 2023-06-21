# Dragon Boy

This is an experimental Game Boy emulator written for study purposes using
[DragonRuby GTK](https://dragonruby.itch.io/dragonruby-gtk).

## Development

### Running tests

```sh
./run-tests
```

will run all tests. You can also specify a specific test file similar as if you were using `dragonruby --test` by
specifying the path relative to the `mygame` directory as an argument.

If you have Ruby installed you can also install the Gemfile and use `guard` for automatically executing changed tests.
