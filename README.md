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

```
zstyle ":completion::complete:cabal::options:" depth 4
```
Maximan directory depth for searching for `*.cabal` files.

```
zstyle ":completion::complete:cabal::options:" 
zstyle ":completion::complete:cabal::options:" packages-tmp-file "/tmp/zsh-haskell-cabal-packages"
```
File which stores list of package names.  It will be created on demenad (e.g.
by completiting `cabal info` or `cabal install`, etc.).

![](https://raw.githubusercontent.com/coot/zsh-cabal/master/docs/screencast.gif)
