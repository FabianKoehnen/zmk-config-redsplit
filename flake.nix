{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, zmk-nix }: let
    forAllSystems = nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames zmk-nix.packages);
  in {
    packages = forAllSystems (system: rec {
      default = firmware;

      # firmware = zmk-nix.legacyPackages.${system}.buildSplitKeyboard {
      firmware = (import ./nix/builders.nix { inherit (nixpkgs.legacyPackages.${system}) callPackage; }).buildSplitKeyboard {
        name = "firmware";

        src = nixpkgs.lib.sourceFilesBySuffices self [ ".board" ".cmake" ".conf" ".defconfig" ".dts" ".dtsi" ".json" ".keymap" ".overlay" ".shield" ".yml" "_defconfig" ];

        board = "puchi_ble_v1";
        shield = "redsplit_%PART%";
        parts = [
          "left nice_view"
          "right"
        ];
        snippets = [
          "zmk-usb-logging"
        ];

        zephyrDepsHash = "sha256-R+2W/onIy4VfB61OkiNoZyez20VtVDbp2GnAALXwYt8=";

        # meta = {
        #   description = "ZMK firmware";
        #   license = nixpkgs.lib.licenses.mit;
        #   platforms = nixpkgs.lib.platforms.all;
        # };
      };

      flash = zmk-nix.packages.${system}.flash.override { inherit firmware; };
      update = zmk-nix.packages.${system}.update;
    });

    devShells = forAllSystems (system: {
      default = zmk-nix.devShells.${system}.default;
    });
  };
}
