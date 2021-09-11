{
  description = "A simple project";

  inputs = {
    mars-std.url = "github:mars-research/mars-std";
  };

  outputs = { self, mars-std, ... }: let
    # System types to support.
    supportedSystems = [ "x86_64-linux" ];
  in mars-std.lib.eachSystem supportedSystems (system: let
    pkgs = mars-std.legacyPackages.${system};
    lib = pkgs.lib;

    kexec-tools = pkgs.stdenv.mkDerivation {
      name = "kexec-tools";

      src = lib.cleanSourceWith {
        filter = name: type: !(type == "directory" && baseNameOf name == "build");
        src = lib.cleanSource ./.;
      };

      nativeBuildInputs = [ pkgs.autoreconfHook ];
    };
  in {
    packages.kexec-tools = kexec-tools;
    defaultPackage = self.packages.${system}.kexec-tools;

    devShell = pkgs.mkShell {
      inputsFrom = [
        self.packages.${system}.kexec-tools
      ];

      nativeBuildInputs = with pkgs; [
        gdb
      ];
    };
  });
}
