{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    # later do some dynamic pkgs architecture passing
    generatePackage = import ./. nixpkgs "x86_64-linux";
  };
}
