{config, lib, pkgs, ...}: {

  ## a lot of these options and methods for "airgapping" are taken from 
  ## https://github.com/drduh/YubiKey-Guide/blob/master/flake.nix

  imports =
    [ 
      ## Include the results of the hardware scan (if desired).
      # ./hardware-configuration.nix

      ####  host some static websites offline with useful tools
      ## iancolemanBIP39 (https://github.com/iancoleman/bip39)
      ./modules/iancolemanBIP39.nix
      ## codex32 (https://secretcodex32.com)
      ./modules/codex32.nix
    ];



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

  boot = {
    tmp.cleanOnBoot = true;
    # https://www.kernel.org/doc/html/latest/admin-guide/sysctl/kernel.html#unprivileged-bpf-disabled
    kernel.sysctl = {"kernel.unprivileged_bpf_disabled" = 1;};
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
                   "video" # for using webcam for QR code scanning
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

  # allow our user to do sudo things if necessary
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

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

    # web browser (for viewing static sites offline)
    firefox

    # misc
    python3
  ];

  # program-specific settings
  programs = {
    # Add firefox for running the diceware web app
    firefox = {
      enable = true;
      preferences = {
        # Disable data reporting confirmation dialogue
        "datareporting.policy.dataSubmissionEnabled" = false;
        # Disable welcome tab
        "browser.aboutwelcome.enabled" = false;
      };
      # Make preferences appear as user-defined values
      preferencesStatus = "user";
    };
    # we are offline, so no need for ssh agent to start
    ssh.startAgent = false;

    # enable some gnupg things (for offline use)
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  
  # Enable desktop environment
  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "user";
  };
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce = {
    enable = true;
    enableScreensaver = false;
  };

  # Enable Flakes and the new command-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.05";

  virtualisation.vmVariant = {
    # following configuration is added only when building VM with build-vm
    virtualisation = {
      memorySize =  4096; # Use 4096MiB memory.
      cores = 3;         
    };
  };

}