# Author: Marcin Szamotulski
# Copyright: 2019
#
#compdef cabal

_cabal_commands() {
    local ret=1 state
    _arguments ':subcommand:->subcommand' && ret=0

    case $state in
      subcommand)
        subcommands=(
          "bench:Run benchmarks"
          "build:Compile targets within the project."
          "check:Check the package for common mistakes"
          "clean:Clean the package store and remove temporary files."
          "configure:Add extra project configuration."
          "exec:Give a command access to the store."
          "fetch:Downloads packages for later installation."
          "freeze:Freeze dependencies."
          "get:Download/Extract a package's source code (repository)."
	  "gen-bounds:Generate dependency bounds."
          "haddock:Build Haddock documentation."
          "help:Help about commands."
          "hscolour:Generate HsColour colourised code, in HTML format."
          "info:Display detailed information about a particular package."
          "init:Create a new .cabal package file."
          "install:Install packages."
          "list:List packages matching a search string."
	  "outdated:Check for outdated dependencies."
          "repl:Open an interactive session for the given component."
          "report:Upload build reports to a remote server."
          "run:Run an executable."
          "sdist:Generate a source distribution file (.tar.gz)."
          "test:Run test-suites."
          "unpack:Download/Extract a package's source code (repository)."
          "update:Updates list of known packages."
          "upload:Uploads source packages or documentation to Hackage."
	  "user-config:Display and update the user's global cabal configuration."
        )
        _describe -t subcommands 'cabal subcommands' subcommands && ret=0
    esac

    return ret
}

_cabal_list_files () {
  # find all cabal files, but do not descent into dist-newstyle, dist or
  # .stack-work directories
  find -name "dist-newstyle" -prune , -name "dist" -prune , -name ".stack-work" -prune , -type f -name "*.cabal"
}

_cabal_list_packages () {
  # find all cabal packages
  local file
  for file in $(_cabal_list_files); do
    grep '^\s*name:' $file | awk '{print $2}'
  done;
}

_cabal_list_components () {
  # find all components
  local file cmps
  for file in $(_cabal_list_files); do
    grep -P '^(test-suite|executable|benchmark|library)\s+\S' $file | awk '{print $2}' | sed -e 's/:/\\:/g'
    [[ $(grep -i "^library\s*$" ${file}) ]] && echo "lib:"$(basename ${file} .cabal)" " | sed -e 's/:/\\:/g';
  done;
}

_cabal_list_executables () {
  # find all executable components
  local file
  for file in $(_cabal_list_files); do
    grep -i '^\(test-suite\|executable\|benchmark\)\s+' $file | awk '{print $2}' | sed -e 's/:/\\:/g'
  done;
}

_cabal_list_benchmarks () {
  # find all benchmarks
  local file
  for file in $(_cabal_list_files); do
    grep -i '^benchmark\s+' $file | awk '{print $2}' | sed -e 's/:/\\:/g'
  done;
}

_cabal_components () {
  local -a components
  components=( $(_cabal_list_components) )
  _arguments "1:components:(${components})" \
             ${_cabal_build_options[@]}
              
}

_cabal_executables () {
  local -a components
  components=( $(_cabal_list_executables) )
  _arguments "1:components:(${components})" \
             ${_cabal_build_options[@]}
}

_cabal_benchmarks () {
  local -a components
  components=( $(_cabal_list_benchmarks) )
  _arguments "1:components:(${components})" \
             ${_cabal_build_options[@]}
}

_cabal_packages () {
  local -a pkgs
  pkgs=( $(_cabal_list_packages ) )
  _describe -t pkgs 'packages' pkgs
}

# completion for `pkg:package-name:(libs|tests|benches|exes)`
_cabal_pkgspecs () {
  local -a pkgs
  local file name
  for file in $(_cabal_list_files); do
    name=$(basename ${file} .cabal)
    [[ $(grep -i '^library'    ${file}) ]] && pkgs+=("pkg:${name}:libs")
    [[ $(grep -i '^test-suite' ${file}) ]] && pkgs+=("pkg:${name}:tests")
    [[ $(grep -i '^benchmark'  ${file}) ]] && pkgs+=("pkg:${name}:benches")
    [[ $(grep -i '^executable' ${file}) ]] && pkgs+=("pkg:${name}:exes")
  done 
  _multi_parts ":" pkgs
}

# find all ghc which are in $PATH
_cabal_find_ghc () {
  local -a ghcs
  for p in $( echo ${PATH} | sed 's/:/\n/g' ); do
    ghcs+=( $(find $p -name "ghc*" | grep -P 'ghc(-\d+\.\d+\.\d+)?$') )
  done
  _describe -t ghcs 'ghc' ghcs
}


# todo:
# cabal flags -f or --flag
# --reject-unconstrained-dependencies
# package db files
# --with-PROG=PATH
# --PROG-option
# --PROG-options

_cabal_build_options=( {-h,--help} \
         	       {-v,--verbose=}':level:(0 1 2 3)' \
         	       '--builddir:buiddir:_files -/' \
         	       {-g,--ghc} \
         	       '--ghcjs' \
         	       '--uhc' \
         	       '--haskell-suite' \
         	       '--cabal-file:cabalfile:_files -g "*.cabal"' \
         	       '(-w --with-compiler)'{-w,--with-compiler}':compiler:_cabal_find_ghc' \
         	       '--with-hc-pkg:hcpkg:_files' \
         	       '--prefix:dir:_files -/' \
         	       '--binddir:dir:_files -/' \
         	       '--libdir:dir:_files -/' \
         	       '--libsubdir:dir:_files -/' \
         	       '--dynlibdir:dir:_files -/' \
         	       '--libexecdir:dir:_files -/' \
         	       '--libexecsubdir:dir:_files -/' \
         	       '--datadir:dir:_files -/' \
         	       '--datasubdir:dir:_files -/' \
         	       '--docdir:dir:_files -/' \
         	       '--htmldir:dir:_files -/' \
         	       '--haddockdir:dir:_files -/' \
         	       '--sysconfdir:dir:_files -/' \
         	       '--program-prefix' \
         	       '--program-suffix' \
         	       '--enable-library-vanilla' \
         	       '--disable-library-vanilla' \
         	       {-p,--disable-library-profiling} \
         	       '--disable-library-profiling' \
         	       '--enable-shared' \
         	       '--disable-shared' \
         	       '--enable-static' \
         	       '--disable-static' \
         	       '--enable-executable-dynamic' \
         	       '--disable-executable-dynamic' \
         	       '--enable-executable-static' \
         	       '--disable-executable-static' \
         	       '--enable-profiling' \
         	       '--disable-profiling' \
         	       '--enable-executable-profiling' \
         	       '--disable-executable-profiling' \
         	       '--profiling-detail:detail:(default none exported-functions all-functions)' \
         	       '--library-profiling-detail:detail:(default none exported-functions all-functions)' \
         	       {-O-,--enable-optimization=}':level:(0 1 2)' \
         	       '--disable-optimisation' \
         	       '--enable-debug-info:(0 1 2 3)' \
         	       '--disable-debug-info' \
         	       '--enable-library-for-ghci' \
         	       '--disable-library-for-ghci' \
         	       '--enable-split-sections' \
         	       '--disable-split-sections' \
         	       '--enable-split-objs' \
         	       '--disable-split-objs' \
         	       '--enable-executable-stripping' \
         	       '--disable-executable-stripping' \
         	       '--enable-library-stripping' \
         	       '--disable-library-stripping' \
         	       '--configure-option=OPT' \
         	       '--user' \
         	       '--global' \
         	       '--package-db' \
         	       {-f,--flags} \
         	       '--extra-lib-dirs:path:_files -/' \
         	       '--enable-deterministic' \
         	       '--disable-deterministic' \
         	       '--ipid=IPID' \
         	       '--cid=CID' \
         	       '--extra-lib-dirs:extralib:_file -/' \
         	       '--extra-framework-dirs:path:_files -/' \
         	       '--extra-prog-path:path:_files -/' \
         	       '--instantiate-with' \
         	       '--enable-tests' \
         	       '--disable-tests' \
         	       '--enable-coverage' \
         	       '--disable-coverage' \
         	       '--enable-library-coverage' \
         	       '--disable-library-coverage' \
         	       '--enable-benchmarks' \
         	       '--disable-benchmarks' \
         	       '--enable-relocatable' \
         	       '--disable-relocatable' \
         	       '--disable-response-files' \
         	       '--allow-depending-on-private-libs' \
         	       '--cabal-lib-version' \
         	       '--constraint' \
         	       '--preference' \
         	       '--solver' \
         	       '--allow-older' \
         	       '--allow-newer' \
         	       '--write-ghc-environment-files::(always never ghc8.4.4+)' \
         	       '--enable-documentation' \
         	       '--disable-documentation' \
         	       '--doc-index-file=TEMPLATE' \
         	       '--dry-run' \
         	       '--max-backjumps=NUM' \
         	       '--reorder-goals' \
         	       '--count-conflicts' \
         	       '--minimize-conflict-set' \
         	       '--independent-goals' \
         	       '--shadow-installed-packages' \
         	       '--strong-flags' \
         	       '--allow-boot-library-installs' \
         	       '--reject-unconstrained-dependencies::(none all)' \
         	       '--reinstall' \
         	       '--avoid-reinstalls' \
         	       '--force-reinstalls' \
         	       '--upgrade-dependencies' \
         	       '--only-dependencies' \
         	       '--dependencies-only \
         	       ''--index-state' \
         	       '--root-cmd::_file' \
         	       '--symlink-bindir::_file -/' \
         	       '--build-summary' \
         	       '--build-log' \
         	       '--remote-build-reporting' \
         	       '--report-planning-failure' \
         	       '--enable-per-component' \
         	       '--disable-per-component' \
         	       '--one-shot' \
         	       '--run-tests' \
         	       {-j,--jobs} \
         	       '--keep-going' \
         	       '--offline' \
         	       '--project-file=FILE' \
         	       '--haddock-hoogle' \
         	       '--haddock-html' \
         	       '--haddock-html-location=URL' \
         	       '--haddock-for-hackage' \
         	       '--haddock-executables' \
         	       '--haddock-tests' \
         	       '--haddock-benchmarks' \
         	       '--haddock-all' \
         	       '--haddock-internal' \
         	       '--haddock-css::_file' \
         	       '--haddock-hyperlink-source' \
         	       '--haddock-quickjump' \
         	       '--haddock-hscolour-css=_file' \
         	       '--haddock-contents-location' \
         	       '--test-log' \
         	       '--test-machine-log' \
         	       '--test-show-details' \
         	       '--test-keep-tix-files' \
         	       '--test-wrapper::_file' \
         	       '--test-fail-when-no-test-suites' \
         	       '--test-options' \
         	       '--test-option' \
                       '--only-configure' \
                     )

_cabal () {
  local context state state_descr line
  typeset -A opt_args
  _arguments \
    '1: :_cabal_commands' \
    '*:: :->command_args'
  case $state in
    command_args)
      case $words[1] in
	build)
	  _alternative 'cmps:components:_cabal_components' \
                       'pkg:pkgspec:_cabal_pkgspecs'
        ;;
        repl)
	  _alternative 'cmps:components:_cabal_components' \
                       'pkg:pkgspec:_cabal_pkgspecs'
        ;;
	run)
	  _alternative 'cmps:components:_cabal_executables' \
                       'pkg:pkgspec:_cabal_pkgspecs'
	;;
	bench)
	  _alternative 'cmps:components:_cabal_benchmarks' \
                       'pkg:pkgspec:_cabal_pkgspecs'
	;;
	exec)
	  _alternative 'cmps:components:_cabal_executables' \
                       'pkg:pkgspec:_cabal_pkgspecs'
	;;
	update)
	  _alternative 'cmps:components:_cabal_executables' \
                       'pkg:pkgspec:_cabal_pkgspecs'
        ;;
	configure)
	  _arguments "1:packages:_cabal_packages" \
                     ${_cabal_build_options[@]}
	;;
	haddock)
	  _alternative 'cmps:components:_cabal_components' \
                       'pkg:pkgspec:_cabal_pkgspecs'
	;;
	sdist)
	  _arguments {-h,--help} \
		     {-v,--verbose=}':level:(0 1 2 3)' \
		     '--builddir:buiddir:_files -/' \
		     '--project-file:projectfile:_files' \
		     {-l,--list-only} \
		     {-z,--null-sep} \
		     {-o,--output-dir}':outputdir:_files -/'
	;;
	upload)
	  _arguments {-h,--help} \
		     {-v,--verbose=}':level:(0 1 2 3)' \
		     '--publish' \
		     {-d,--documentation} \
		     {-u,--username} \
		     {-p,--password} \
		     {-P,--password-command} \
		     '1:targiles:_files'
	;;
	init)
	  _arguments {-h,--help} \
		     {-v,--verbose=}':level:(0 1 2 3)' \
		     {-i,--interactive} \
		     {-n,--non-interactive} \
		     {-q,--quite} \
		     {-m,--minimal} \
		     '--overwrite' \
		     '--package-dir:package directory:_files -/' \
		     {-p,--package-name} \
		     '--version' \
		     '--cabal-version' \
		     {-l,--license} \
		     {-a,--author} \
		     {-e,--email} \
		     {-u,--homepage} \
		     {-s,--synopsis} \
		     {-c,--category} \
		     {-x,--extra-source-file}':extra source file:_file' \
		     {--lib,--exe,--libandexe,--tests} \
		     '--test-dir:test dir:_file -/' \
		     '--simple' \
		     '--main-is:main file:_file' \
		     '--language' \
		     {-o,--expose-module} \
		     '--extension' \
		     {-d,--dependency} \
		     '--application-dir:application dir:_file -/' \
		     '--source-dir:source dir:_file -/' \
		     '--build-tool' \
		     '(-w --with-compiler)'{-w,--with-compiler}':compiler:_cabal_find_ghc' \

	;;
	outdated)
	  _arguments {-h,--help} \
		     {-v,--verbose=}':level:(0 1 2 3)' \
		     '--freeze-file' \
		     '--project-file:project file:_file' \
		     '--simple-output' \
		     '--exit-code' \
		     {-q,--quiet} \
		     '--ignore' \
		     '--minor'
	;;
      esac
  esac
}

compdef _cabal cabal
