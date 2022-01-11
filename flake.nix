{
  description = "A very basic flake";

  outputs = { self, nixpkgs }:
    let pkgs = import nixpkgs { system = "x86_64-linux"; };
    in with pkgs; {
      devShell.x86_64-linux = mkShell {
        buildInputs = [
          cmake
          zsh
          extra-cmake-modules
          libsForQt5.plasma-sdk
          libsForQt5.ki18n
        ];
      };
    };
}
