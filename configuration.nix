{ pkgs, lib, sources, config, ... }:

{
  imports = [
    # Some values in ./personal.nix need to be changed!
    ./personal.nix
  ];

  # Declarative users
  users.mutableUsers = false;

  users.users = {
    # Configure a normal default user
    me.isNormalUser = true;
    # No password
    me.hashedPassword = "";
  };

  # Add the default user to the wheel group, and make wheel more privileged
  users.users.me.extraGroups = [ "wheel" ];
  security.sudo.wheelNeedsPassword = false;
  nix.settings.trusted-users = [ "root" "@wheel" ];

  # Let's not touch channels
  environment.extraSetup = ''
    rm --force $out/bin/nix-channel
  '';

  # Put nixpkgs into /etc/nixpkgs for convenience
  environment.etc.nixpkgs.source = sources.nixpkgs;

  # Set Nixpkgs overlays and config
  nixpkgs = {
    overlays = import ./nixpkgs/overlays.nix;
    config = import ./nixpkgs/config.nix;
  };
  # Make all nix commands on the system use the same Nixpkgs
  nix.nixPath = [
    "nixpkgs=/etc/nixpkgs"
    "nixpkgs-overlays=/etc/nixos/nixpkgs/overlays.nix"
  ];
  environment.variables.NIXPKGS_CONFIG = lib.mkForce "/etc/nixos/nixpkgs/config.nix";

  # Avoid the stateVersion warning.
  # Setting this to system.nixos.release is fine because we have no state
  system.stateVersion = config.system.nixos.release;

  # Auto-login the default user on consoles
  services.getty.autologinUser = "me";

  # Set up zsh
  programs.zsh = {
    enable = true;

    # Put everything we want to persist into /etc/nixos
    # The history is interesting to keep around for searchability
    histFile = "/etc/nixos/history";

    # Unset the default zsh options, in particular:
    # - No SHARE_HISTORY, because it makes the history file less readable
    # - No HIST_IGNORE_DUPS, so that the history file shows all commands
    # - Yes INC_APPEND_HISTORY, such that even when the VM is quit unexpectedly, we have the history
    setOptions = [ "INC_APPEND_HISTORY" ];
  };

  # Prevent the new user dialog in zsh
  system.userActivationScripts.zshrc = "touch .zshrc";

  # Set zsh as the default shell
  users.defaultUserShell = "/run/current-system/sw/bin/zsh";

  # Set up some programs
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };

  programs.git.enable = true;

  environment.defaultPackages = with pkgs; [
    vm-switch
  ];

  virtualisation.vmVariant.virtualisation = {
    # Make the screen size auto-scale
    qemu.options = [ "-vga virtio" ];

    # Don't persist any state, also allows Ctrl-C without problems
    diskImage = null; # "./nixos.qcow2";

    # Except the current directory, which is shared in /etc/nixos
    sharedDirectories.share = {
      source = toString ./.;
      target = "/etc/nixos";
    };

    # Allows Nix commands to re-use and write to the host's store
    mountHostNixStore = true;
    writableStoreUseTmpfs = false;
  };
}
