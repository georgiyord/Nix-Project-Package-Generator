flake_nixpkgs: arch:
{
  url, # Language hello world examples for testing: https://github.com/anveshmuppeda/HelloWorldArchive
  hash,
  mode ? "git",
  rev ? null,
  buildInputs ? [ ],
  nativeBuildInputs ? [ ],
  env ? { },
  ...
}@args:
let
  pkgs = flake_nixpkgs.legacyPackages.${arch};
  validModes = [
    "raw"
    "git"
  ];
  modeSafe =
    assert (pkgs.lib.elem mode validModes);
    mode;
  name =
    if args ? name then
      args.name
    else
      builtins.head (
        pkgs.lib.splitString "." (pkgs.lib.last (pkgs.lib.splitString "/" (pkgs.lib.removeSuffix "/" url)))
      );
  fileSuffixExists =
    ext: path:
    builtins.any (name: pkgs.lib.hasSuffix ext name) (builtins.attrNames (builtins.readDir path));
in
if modeSafe == "raw" then
  pkgs.stdenv.mkDerivation {
    inherit name;
    src = pkgs.fetchurl {
      url = url;
      hash = hash;
    };
    system = arch;
    builder = ./builderRaw.sh;
    nativeBuildInputs = with pkgs; [
      github-linguist
    ];
    depsBuildTarget = with pkgs; [
      dotnet-sdk_11
      gnucobol.bin
      go
      groovy
      jdk
      nodejs
      kotlin
      perl
      php
      python3
      R
      ruby
      rustc
      scala
      typescript
    ];
  }

else
  let
    repo = fetchGit {
      inherit url rev;
      narHash = hash;
      submodules = true;
    };
  in

  if builtins.pathExists (repo.outPath + "/Cargo.toml") then
    pkgs.rustPackages.rustPlatform.buildRustPackage (
      args
      // {
        src = repo.outPath;
        inherit name;
        cargoLock = {
          lockFile = repo.outPath + "/Cargo.lock";
          allowBuiltinFetchGit = true;
        };
      }
    )
  else if fileSuffixExists ".sln" repo.outPath then
    assert pkgs.lib.assertMsg (args ? nugetDeps) ''
      https://nixos.org/manual/nixpkgs/stable/#generating-and-updating-nuget-dependencies


      This is a .NET package. Please supply a nugetDeps attribute with a path to a json file containing the dependencies. 
      Build the fetch-deps subpackage and run it WHILE GIVING THE LOCATION OF YOUR nugetDeps PATH!!!
    '';
    pkgs.buildDotnetModule (
      args
      // {
        src = repo.outPath;
        inherit name;
      }
    )
  # else if builtins.pathExists (repo.outPath + "/package.json") then
  #   pkgs.buildNpmPackage (
  #     args
  #     // {
  #       src = repo.outPath;
  #       inherit name;
  #       makeCacheWritable = true;
  #       nativeBuildInputs = with pkgs; [
  #         nodejs
  #       ];
  #       # preConfigure = ''
  #       #   cd build/npm
  #       #   npm ci
  #       #   echo "ASDFASDFASDFASDFASDFASDFASDFASDF"
  #       # '';
  #     }
  #   )
  else if builtins.pathExists (repo.outPath + "/setup.py") then
    pkgs.python3Packages.buildPythonApplication (
      args
      // {
        src = repo.outPath;
        inherit name;
        pyproject = true;

        build-system = with pkgs.python3Packages; [
          setuptools
        ];
      }
    )
  else if builtins.pathExists (repo.outPath + "/go.mod") then
    pkgs.buildGoModule (
      args
      // {
        src = repo.outPath;
        inherit name;
      }
    )
  # Java with gradle tooling
  else if builtins.pathExists (repo.outPath + "/build.gradle") then
    pkgs.stdenv.mkDerivation (
      finalAttrs:
      (
        args
        // {
          src = repo.outPath;
          inherit name;
          mitmCache =
            if args.mitmCacheUsePkg then
              args.gradle.fetchDeps {
                pkg = finalAttrs.finalPackage;
                data = args.gradleDeps;
              }
            else
              args.gradle.fetchDeps {
                pname = name;
                data = args.gradleDeps;
              };
          meta.sourceProvenance = with pkgs.lib.sourceTypes; [
            fromSource
            binaryBytecode # mitm cache
          ];
        }
      )
    )
  else
    throw "Cannot identify language of given repository for packaging"
