{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      # Kein x86_64-darwin: nixpkgs 26.11 (nixos-unstable) hat Intel-macOS
      # eingestellt (stdenv evaluiert dort nicht mehr), 26.05 endet Mitte
      # 2026 — deshalb auch keine Hash-Einträge dafür mehr.
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
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
            # uname.processor liefert auf macOS "arm64", die Release-Assets
            # heissen aber aarch64-darwin — deshalb parsed.cpu.name, das
            # überall den Asset-Namen (x86_64/aarch64) liefert.
            url = "https://github.com/alire-project/GNAT-FSF-builds/releases/download/${pname}-${version}-1/${pname}-${pkgs.stdenv.hostPlatform.parsed.cpu.name}-${pkgs.stdenv.hostPlatform.parsed.kernel.name}-${version}-1.tar.gz";
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
        aarch64-darwin = "sha256-ZXzyVDI+uR95dokY6L2Ih9baesYFZzKjjyHihIJn2hg=";
      };

      # Achtung: alr meldet diese Version als "26.0.1" (Dockerfile:
      # GPRBUILD_VERSION), aber das tatsächlich von alr installierte Tarball
      # trägt Tag und Version 26.0.0. Wir folgen dem Tarball — bitte nicht
      # "zurück" auf 26.0.1 "korrigieren".
      gprbuildHash = {
        x86_64-linux   = "sha256-4/J/JRXsBNlj9rra3mWVmTscCRuhXRkZp8darRt+1Js=";
        aarch64-linux  = "sha256-wSVCREcUSUSXPSTeQ6U7PnAI29owbg1UDbB+Y13qJOQ=";
        aarch64-darwin = "sha256-a/fYDIqXAthRxbmS18cqB6nb8T6N6ZR7gJJ+omZ7a+g=";
      };

      gnatformatHash = {
        x86_64-linux   = "sha256-C0gyTakwAdtwDKjk44sFdJn05Ik6yRekuslHfvWF2VU=";
        aarch64-linux  = "sha256-ZmBlFw/0bTNlJ+Tur5ZySTHgeLRgiBLZ9FA5lgHNrtw=";
        aarch64-darwin = "sha256-O34xky8/ab30uRuu5bE4AqEdbItbz8z+OEdwZ2mpbhI=";
      };

      # gnatprove 16.1.0 wie im dev container gepinnt (prime-alr-cache.sh:
      # "gnatprove ^16.1.0"). Der Tarball ist self-contained — python und
      # z3 liegen mit unter libexec/spark/bin/, ein separates python3 ist
      # nicht nötig.
      gnatproveHash = {
        x86_64-linux   = "sha256-glKL7ymFfiOTc/zDZzKDfXQ/WgCAXVAscEVUIv/JcZE=";
        aarch64-linux  = "sha256-7iK/DYD5o7+8HC5qy2gQKttC3PZ9GyRpOtMct5HLrVI=";
        aarch64-darwin = "sha256-JHcvES3XoLr0AzPpFCkiswzN0ZuPcEQerIAGt4zf2Q0=";
      };
    in {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [
            (fsfBuild pkgs "gnat" "16.1.0" gnatHash)
            (fsfBuild pkgs "gprbuild" "26.0.0" gprbuildHash)
            (fsfBuild pkgs "gnatformat" "26.0" gnatformatHash)
            (fsfBuild pkgs "gnatprove" "16.1.0" gnatproveHash)
            # alr als einzige Ausnahme aus nixpkgs: es baut selbst keine
            # Artefakte, das Byte-Identitäts-Argument der Toolchain trifft
            # hier nicht zu — so sparen wir uns die Hash-Pflege.
            pkgs.alire
          ];
        };
      });
    };
}
