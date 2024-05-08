{
    description = "Latex Document Demo";
    inputs = {
        nixpkgs.url = github:NixOS/nixpkgs?ref=nixos-unstable;
        flake-utils.url = github:numtide/flake-utils;
    };
    
    outputs = {self, nixpkgs, flake-utils}:
        with flake-utils.lib; eachSystem allSystems
    (system:
        let 
            pkgs = nixpkgs.legacyPackages.${system};
            latex-pkgs = pkgs.texlive.combine {
                inherit (pkgs.texlive) 
                    scheme-medium latex-bin ltxcmds pdftexcmds infwarerr xkeyval  etoolbox haranoaji fontspec latexmk luatexja
                    amsmath physics latex-tools-dev siunitx; 
            };
        in rec {
            devShells.default = pkgs.mkShell rec {
                name = "latex-demo-document";
                src = self;
                buildInputs = [pkgs.coreutils latex-pkgs];
                phases = ["unpackPhase" "buildPhase" "installPhase"];
                shellHook = ''
                    export PATH="$PATH:${pkgs.lib.makeBinPath buildInputs}";
                    mkdir -p .cache/texmf-var
                    export TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var
                '';
            };
            packages = {
                document = pkgs.stdenvNoCC.mkDerivation 
                rec {
                    name = "latex-demo-document";
                    src = self;
                    buildInputs = [pkgs.coreutils latex-pkgs];
                    phases = ["unpackPhase" "buildPhase" "installPhase"];
                    buildPhase = ''
                        export PATH="${pkgs.lib.makeBinPath buildInputs}";
                        mkdir -p .cache/texmf-var
                        env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var make
                        mkdir -p $out
                        cp ./*.pdf $out/
                    '';
                    installPhase = ''
                        mkdir -p $out
                        cp ./*.pdf $out/
                    '';
                };
            };
            defaultPackage = packages.document;
        }
    );
}