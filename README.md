This nix flake offers only a single builder function, that given a source (an URL path to a single file or to a git repository), it automatically decides which nixpkgs builder to calla and pass down arguments to.

There are only two modes supported, "raw" and "git", corresnponding to a single file and a git repository.
In raw mode, the language detection happens at build-time with a build script by using github-linguist and calling the corresponding compiler or toolchain.
In git mode, the language detection happens at evaluation-time, by fetching the git repository to the host, detects a file used by a specific toolchain and calls the corresponding builder in nixpkgs.

Languages supported in raw mode:
C,
COBOL,
C++,
Go,
Groovy,
Java,
JavaScript,
Kotlin,
Perl,
PHP,
Python,
R,
Ruby,
Rust,
Scala,
Shell Script,
TypeScript

Languages supported in git mode:
Rust,
C# (and probably other languages with .NET support),
Python,
Go,
Java with Gradle