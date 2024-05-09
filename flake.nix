{
  description = "NixOS Airgapped";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixos-generators }: {

    packages.x86_64-linux.nixos-airgapped-iso = nixos-generators.nixosGenerate {
        
        system = "x86_64-linux";

        modules = [

          ./configuration.nix

          ({ pkgs, config, ... }: {
            # Let 'nixos-version --json' know about the Git revision
            # of this flake.
            system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
          })
          
        ];

        # see different formats here: https://github.com/nix-community/nixos-generators
        # for nixos bootable installer ISO change to "install-iso"
        format = "iso";
    };

    packages.x86_64-linux.default = self.packages.x86_64-linux.hello;

  };
}
