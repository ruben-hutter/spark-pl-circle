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
      # Toolchains mehr.
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

      # ada_language_server für den Host-LSP (nvim: ada_ls) — derselbe
      # Binär-Release-Ansatz wie die Toolchain, denn der ALS ist an die
      # GNAT-Generation gekoppelt: 2027.0.202610121 ist auf dem Host-Rechner
      # erfolgreich gegen gnat 16.1.0 gelaufen (Mason-Install, gleiche
      # Version). Das Asset ist das VS-Code-Integration-Bundle: das Binary
      # liegt unter integration/vscode/ada/<arch>/<os>/, installiert wird
      # nur es (ohne .debug/dSYM). Linux braucht libgmp.so.10 und lässt
      # autoPatchelfHook die RPATHs setzen; darwin bringt libgmp.10.dylib
      # neben dem Binary mit (@executable_path) und läuft ohne.
      alsPlatform = {
        x86_64-linux   = "linux-x64";
        aarch64-linux  = "linux-arm64";
        aarch64-darwin = "darwin-arm64";
      };

      alsHash = {
        x86_64-linux   = "sha256-lxXwGbGTnBcYKTWTZzWc0pXwpOlhXW/qCAcFly4iCnA=";
        aarch64-linux  = "sha256-APGIK9p7s8Sx1ZRkP1l9UIzXiDN6AxQGXQCgq+Xqy6Y=";
        aarch64-darwin = "sha256-n0pJRGYT/hlsZhxjwyNduWM7An+XbqrWSJ7wQrMF2uw=";
      };

      alsBuild = pkgs: version:
        pkgs.stdenv.mkDerivation {
          pname = "ada_language_server";
          inherit version;
          src = pkgs.fetchurl {
            url = "https://github.com/AdaCore/ada_language_server/releases/download/${version}/als-${version}-${alsPlatform.${pkgs.stdenv.hostPlatform.system}}.tar.gz";
            hash = alsHash.${pkgs.stdenv.hostPlatform.system};
          };
          nativeBuildInputs = pkgs.lib.optional pkgs.stdenv.hostPlatform.isLinux pkgs.autoPatchelfHook;
          buildInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            pkgs.stdenv.cc.libc
            pkgs.stdenv.cc.cc.lib # libgcc_s
            pkgs.gmp # libgmp.so.10
          ];
          dontConfigure = true;
          dontBuild = true;
          installPhase = ''
            runHook preInstall
            mkdir -p $out/bin
            alsBin="$(find . -type f -name ada_language_server -not -path '*dSYM*')"
            install -m755 "$alsBin" $out/bin/ada_language_server
            # Darwin: libgmp.10.dylib liegt neben dem Binary und wird über
            # @executable_path gefunden — mit umziehen lassen (auf Linux
            # greift der Glob ins Leere).
            for dylib in "$(dirname "$alsBin")"/libgmp*.dylib; do
              [ -e "$dylib" ] && install -m644 "$dylib" $out/bin/
            done
            runHook postInstall
          '';
        };
    in {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          # Die Shell ist das Host-Minimum zum Editieren (nvim + ada_ls):
          # gnat/gprbuild für den Editor-Index, alr als CLI, der ALS als
          # LSP. Verifizieren, Bauen und Ausführen sind devpod-/Container-
          # Territorium — gnatprove und gnatformat bewusst nicht hier.
          packages = [
            (fsfBuild pkgs "gnat" "16.1.0" gnatHash)
            (fsfBuild pkgs "gprbuild" "26.0.0" gprbuildHash)
            (alsBuild pkgs "2027.0.202610121")
            # alr als einzige Ausnahme aus nixpkgs: es baut selbst keine
            # Artefakte, das Byte-Identitäts-Argument der Toolchain trifft
            # hier nicht zu — so sparen wir uns die Hash-Pflege.
            pkgs.alire
          ];
        };
      });
    };
}
