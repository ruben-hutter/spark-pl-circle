{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (s: f nixpkgs.legacyPackages.${s});

      # gnat und gprbuild gibt es in nixpkgs nur in genau einer Version pro
      # Revision (aktuell 16.2/25.0.0) — nicht in den Versionen, die der dev
      # container über alr pinnt. Wir pinnen deshalb dieselben
      # Binary-Releases aus GNAT-FSF-builds, die alr im container installiert
      # (s. .devcontainer/Dockerfile) — so sind Host und Container
      # byte-identisch und im gemeinsamen obj/-Verzeichnis mischen sich keine
      # Toolchains mehr. gnatformat ist ohnehin nicht in nixpkgs und lief
      # schon immer über dieselbe Quelle.
      #
      # Die Binaries sind nur gegen libc/libstdc++ dynamisch gelinkt: auf
      # Linux setzt autoPatchelfHook die RPATHs auf die Nix-Store-Pfade,
      # darwin linkt gegen das System-libSystem.
      fsfBuild = pkgs: pname: version: hashes:
        pkgs.stdenv.mkDerivation {
          inherit pname version;
          src = pkgs.fetchurl {
            url = "https://github.com/alire-project/GNAT-FSF-builds/releases/download/${pname}-${version}-1/${pname}-${pkgs.stdenv.hostPlatform.uname.processor}-${pkgs.stdenv.hostPlatform.parsed.kernel.name}-${version}-1.tar.gz";
            hash = hashes.${pkgs.stdenv.hostPlatform.system};
          };
          nativeBuildInputs = pkgs.lib.optional pkgs.stdenv.hostPlatform.isLinux pkgs.autoPatchelfHook;
          buildInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            pkgs.stdenv.cc.libc
            pkgs.stdenv.cc.cc.lib # libstdc++ (u. a. für die C++-Teile von gnat)
            pkgs.ncurses # libncursesw/libtinfo (gdb im gnat-Tarball)
            pkgs.expat # gdb
            pkgs.xz # liblzma (gdb)
            pkgs.zstd # cc1/gnat1/lto1 (LTO-Plugins)
          ];
          dontConfigure = true;
          dontBuild = true;
          installPhase = ''
            runHook preInstall
            cp -a . $out
            runHook postInstall
          '';
        };

      # gnat 16.1.0 wie im dev container gepinnt (Dockerfile: GNAT_VERSION).
      gnatHash = {
        x86_64-linux   = "sha256-n3T1ioJ6KtQN2ExypBPnXqUoiODY9+JS+6TSZ2JAJwM=";
        aarch64-linux  = "sha256-jil0l/LW1oRZIKNjone271vEVOSKZtDWBridceMe5iM=";
        # Hash beim ersten macOS-Build von fetchurl ausdrucken lassen und
        # eintragen.
        x86_64-darwin  = nixpkgs.lib.fakeHash;
        aarch64-darwin = nixpkgs.lib.fakeHash;
      };

      # Achtung: alr meldet diese Version als "26.0.1" (Dockerfile:
      # GPRBUILD_VERSION), aber das tatsächlich von alr installierte Tarball
      # trägt Tag und Version 26.0.0. Wir folgen dem Tarball — bitte nicht
      # "zurück" auf 26.0.1 "korrigieren".
      gprbuildHash = {
        x86_64-linux   = "sha256-4/J/JRXsBNlj9rra3mWVmTscCRuhXRkZp8darRt+1Js=";
        aarch64-linux  = "sha256-wSVCREcUSUSXPSTeQ6U7PnAI29owbg1UDbB+Y13qJOQ=";
        x86_64-darwin  = nixpkgs.lib.fakeHash;
        aarch64-darwin = nixpkgs.lib.fakeHash;
      };

      gnatformatHash = {
        x86_64-linux   = "sha256-C0gyTakwAdtwDKjk44sFdJn05Ik6yRekuslHfvWF2VU=";
        aarch64-linux  = "sha256-ZmBlFw/0bTNlJ+Tur5ZySTHgeLRgiBLZ9FA5lgHNrtw=";
        x86_64-darwin  = "sha256-R5MubeTCIKNVRjJhmRzDPRKSGjUu2RpsgqcJUe8ovoM=";
        aarch64-darwin = "sha256-O34xky8/ab30uRuu5bE4AqEdbItbz8z+OEdwZ2mpbhI=";
      };
    in {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [
            (fsfBuild pkgs "gnat" "16.1.0" gnatHash)
            (fsfBuild pkgs "gprbuild" "26.0.0" gprbuildHash)
            (fsfBuild pkgs "gnatformat" "26.0" gnatformatHash)
          ];
        };
      });
    };
}
