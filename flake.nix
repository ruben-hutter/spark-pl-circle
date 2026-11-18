{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (s: f nixpkgs.legacyPackages.${s});

      # gnatformat ist nicht in nixpkgs. Wir pinnen das Binary-Release aus
      # GNAT-FSF-builds — dieselbe Quelle wie im dev container (s.
      # .devcontainer/Dockerfile). Das Binary ist nur gegen libc dynamisch:
      # auf Linux reicht autoPatchelfHook, darwin linkt gegen das
      # System-libSystem.
      gnatformatHash = {
        x86_64-linux   = "sha256-C0gyTakwAdtwDKjk44sFdJn05Ik6yRekuslHfvWF2VU=";
        aarch64-linux  = "sha256-ZmBlFw/0bTNlJ+Tur5ZySTHgeLRgiBLZ9FA5lgHNrtw=";
        x86_64-darwin  = "sha256-R5MubeTCIKNVRjJhmRzDPRKSGjUu2RpsgqcJUe8ovoM=";
        aarch64-darwin = "sha256-O34xky8/ab30uRuu5bE4AqEdbItbz8z+OEdwZ2mpbhI=";
      };
      gnatformat = pkgs: pkgs.stdenv.mkDerivation {
        pname = "gnatformat";
        version = "26.0";
        src = pkgs.fetchurl {
          url = "https://github.com/alire-project/GNAT-FSF-builds/releases/download/gnatformat-26.0-1/gnatformat-${pkgs.stdenv.hostPlatform.uname.processor}-${pkgs.stdenv.hostPlatform.parsed.kernel.name}-26.0-1.tar.gz";
          hash = gnatformatHash.${pkgs.stdenv.hostPlatform.system};
        };
        nativeBuildInputs = pkgs.lib.optional pkgs.stdenv.isLinux pkgs.autoPatchelfHook;
        buildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [ pkgs.stdenv.cc.libc ];
        dontConfigure = true;
        dontBuild = true;
        installPhase = ''
          runHook preInstall
          cp -a . $out
          runHook postInstall
        '';
      };
    in {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [ gnat gprbuild (gnatformat pkgs) ];
        };
      });
    };
}
