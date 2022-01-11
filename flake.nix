{
  outputs = { self, nixpkgs }:
    with import nixpkgs { system = "x86_64-linux"; };
    let
      build = writeShellScriptBin "build.sh" ''
        cmake -B build -DCMAKE_INSTALL_PREFIX="~/.local"
        make -C build
      '';
      install = writeShellScriptBin "install.sh" ''
        make -C build install
      '';

    in with pkgs; {
      devShell.x86_64-linux = mkShell {
        buildInputs = [ cmake zsh extra-cmake-modules appstream build install ]
          ++ (with libsForQt5; [ plasma-framework ki18n ]);
      };
    };
}
