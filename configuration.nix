{config, lib, pkgs, ...}: {

  imports =
    [ 
      ## Include the results of the hardware scan (if desired).
      # ./hardware-configuration.nix
    ];

  ## a lot of these options are taken from 
  ## https://github.com/drduh/YubiKey-Guide/blob/master/flake.nix#L222


  ## airgap our kernel directly
  ## (commented out for now)
  /*boot.kernelPatches = [ 
    {
      name = "airgapped-config";
      patch = null; # null if we are only making config changes (below)
      
      # attrset of extra configuration parameters without the CONFIG_ prefix
      # values should generally be lib.kernel.yes: 
      # lib.kernel.no or lib.kernel.module
      extraStructuredConfig = {
        # goal is to remove network functionality but the following seems to break  
        # NET = lib.mkForce lib.kernel.no;

        # remove radio adaptors
        # RADIO_ADAPTERS = lib.mkForce lib.kernel.no;
      };

      # seems to be necessary
      ignoreConfigErrors = true;                          

      # attrset of extra "features" the kernel is considered to have
      # (may be queried by other NixOS modules)
      features.airgapped = true;
    } 
  ];*/

  # from comment about raw-efi format 
  # see https://github.com/nix-community/nixos-generators?tab=readme-ov-file#format-specific-notes
  boot.kernelParams = [ "console=tty0" ];

  # Disable networking so the system is air-gapped
  # Comment all of these lines out if you'll need internet access
  boot.initrd.network.enable = false;
  networking = {
    resolvconf.enable = false;
    dhcpcd.enable = false;
    dhcpcd.allowInterfaces = [];
    interfaces = {};
    firewall.enable = true;
    useDHCP = false;
    useNetworkd = false;
    wireless.enable = false;
    networkmanager.enable = lib.mkForce false;
  };

  # Disable bluetooth
  hardware.bluetooth.enable = false;

  # Disable sound
  hardware.pulseaudio.enable = false;
  sound.enable = false;
  
  ## create a user named "user"
  ##   normally we would add things like a public key here
  ##   but since we are airgapped, none of that is necessary
  users.users.user = {
    isNormalUser = true;
    extraGroups = [
                   "wheel" # enable sudo for the user
                   "video"
                  ];

    # packages only available to this user
    packages = [ ];

    # If set to an empty string (""), this user will be able to log in 
    # without being asked for a password (but not via remote services 
    # such as SSH, or indirectly via su or sudo). This should only be 
    # used for e.g. bootable live systems. 
    initialHashedPassword = "";
  };

  # see previous note above
  users.users.root.initialHashedPassword = "";

  ## packages available to all users
  environment.systemPackages = with pkgs; [
    # Tools for backing up keys
    paperkey
    pgpdump
    parted
    cryptsetup

    # Password generation tools
    pwgen
    
    # Bitcoin wallet software
    sparrow

    # PDF and Markdown viewer
    okular
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  
  # Enable GNOME
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable Flakes and the new command-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.05";

}