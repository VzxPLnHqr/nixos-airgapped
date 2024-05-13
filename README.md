### Airgapped NixOS

# WARNING: this is experimental. DO NOT USE FOR ANYTHING OF VALUE. 

[NixOS](https://nixos.org) is highly configurable and also reproducible. We can 
use these features to build a bootable image which has all of the stuff we want
and (hopefully) none of the stuff we do not want, such as:

- [X] enable whatever **offline** software we want (for QR code scanning and so on)
  - [X] offline version of [iancoleman.io/bip39](https://iancoleman.io/bip39)
  - [ ] offline version of [codex32](https://secretcodex32.com)
- [X] disable networking at non-kernel level
- [ ] kernel - disable all networking devices (including any wifi/bluetooth)
- [ ] kernel - disable all audio input/output at kernel level
- [ ] kernel - disable mounting of any additional devices (no rogue USB sticks allowed!)

### Strategy

Use `nix` to configure and build a custom NixOS image on a machine with internet access, burn to usb drive, and then run/install it on the airgapped machine.

### Example Usage

1. Make sure you are on a system with at least [Nix](https://nixos.org) (the package manager) installed, with flakes enabled.[^enable_flakes]
2. Clone this git repository.
3. Edit `configuration.nix` according to your preferences (see the comments in that file for help).
4. `$ nix build .#nixos-airgapped-iso` which will create an `.iso` file for you in `./result/iso`
5. insert your usb thumbdrive and find out which `/dev/X` it is by running `fdisk -l`
6. `$ sudo dd bs=4M if=/path/to/file.iso of=/dev/sdX status=progress oflag=sync`
7. did you remember to replace the relevant parts of the above `dd` command?

#### Boot it up!

1. Insert the usb thumdrive into the target device and turn it on.
2. Press `F7` or whatever you need to (check your device manufacturer for this!) to access your system BIOS and make sure it boots from the usb thumbdrive.
3. You now have an "airgapped" NixOS system!

### Disclaimer

Please do your own research and be sure that this level of (imperfect!) "airgapping" is sufficient for your needs. It may not be.

### Testing in a VM
1. build the vm: `$ nixos-rebuild build-vm --flake .#nixos-airgapped`
2. run the vm: `$ ./result/bin/run-nixos-vm`

#### Notes/References
1. [NixOS Kernel](https://nixos.wiki/wiki/Linux_kernel) - see "Custom configuration" section
1. [airbuntu](https://github.com/tulliolo/airbuntu) - how to build custom kernel to keep airgapped (ubuntu) pc offline
1. [a thread with some links/resources](https://discourse.nixos.org/t/more-airgap-questions/38748)

[^enable_flakes]: [wiki](https://nixos.wiki/wiki/Flakes) or [tutorial](https://www.tweag.io/blog/2020-05-25-flakes/)