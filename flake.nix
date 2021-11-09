{
  inputs.nixpkgs.url = "github:nixpkgs/nixos";
  inputs.barcode-reader.url = "github:mrvandalo/barcode-reader";
  outputs = { self, nixpkgs , barcode-reader }: {
    nixosModule = 
        ({ pkgs, ... }: {
          imports = [ ./default.nix ];
          # defined overlays injected by the nixflake
          nixpkgs.overlays = [
            (_self: _super: {
              grocy-scanner = barcode-reader.packages.${pkgs.system};
            })
          ];
        })

  };
}
