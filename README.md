# haskell plugin for zsh shell

* completion for **ghc** options
* completion for **cabal** command which expands cabal components (libraries,
    tests, benchmarks and executables) and pkgs specs.

# usage

The completion script will find and inspect all cabal files under current
directory which are not deeper than five directories away. It does not descent
under `dist-newstye`, `dist` or `.stack-work` directories.

Completion for the following package specs is supported:
* `component-name` - it can be either a component name or a package name
* `lib:library-component`,
* `exec:exec-component`,
* `bench:benchmark-component`,
* `test:test-component`
* `pkg:pkg-name:{libs,tests,exes,benches}`.
The last five are only triggered when `lib:`, `exec:`, `bench:`, 
`test:` or `pkg:` are given **explicitly**.  This is in order to avoid
providing too many completion results.

# configuration

* `CABAL_DEPTH` environmental variable guards the maximal directory depth for
  searching cabal files.  By default it is set to `4`.

![](https://raw.githubusercontent.com/coot/zsh-cabal/master/docs/screencast.gif)
