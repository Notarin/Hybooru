{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages."${system}";
      lib = pkgs.lib;
    in
    {
      packages."${system}".default = pkgs.buildNpmPackage {
        name = "Hybooru";
        src = ./.;
        npmDepsHash = "sha256-Cf000iF/OHkZGwEA5g0vOAEnU30bsszJEcbSxs1TJZs=";
        nodejs = pkgs.nodejs_20;
        npmBuildScript = "build:prod";
        runtimeDeps = lib.makeBinPath [
          pkgs.nodejs_20
          pkgs.bash
          pkgs.python3Full
        ];
        installPhase = ''
          mkdir -p $out/bin
          cp -r dist/* $out/bin/
          cp -r node_modules $out/node_modules
          chmod +x $out/bin/*
          echo "#!${lib.getExe pkgs.bash}
          export PATH=$runtimeDeps
          cd $out/bin
          ${lib.getExe' pkgs.nodejs_20 "npm"} start" > $out/bin/Hybooru
          chmod +x $out/bin/Hybooru'';
        buildInputs = [ pkgs.python3Full ];
      };

      devShells."${system}".default = pkgs.mkShell {
        nativeBuildInputs = [
          pkgs.nodejs_20
          pkgs.python3Full
        ];
      };
    };
}
