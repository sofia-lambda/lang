{
  description = "Nix Flake";

  inputs = {
    nixpkgs.url = "github:anmonteiro/nix-overlays";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = (nixpkgs.makePkgs {
        inherit system;
      }).extend (self: super: {
        ocamlPackages = super.ocaml-ng.ocamlPackages_5_3;
      }); 
      in
      {
        devShell = with pkgs; with ocamlPackages; mkShell {
          packages = [
            nixfmt
            ocamlformat
            ocaml
            dune_3
            ocaml-lsp
            utop
          ];
        };
      });
}