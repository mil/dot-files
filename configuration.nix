# Edit this configuration file to define what should be installed on your system.  Help is available in the configuration.nix(5) man page and in the NixOS manual 
# (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{ imports = [ /etc/nixos/hardware-configuration.nix /etc/nixos/networks.nix ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.backgroundColor = "#cfcfcf";
  boot.loader.grub.splashImage = null;

  boot.extraModprobeConfig = ''
    options snd_hda_intel enable=0,1
    options thinkpad_acpi fan_control=1
  '';

  systemd.services.miles-fixes = {
    description = "Fixes fan permissions";
    wantedBy = [ "multi-user.target" "post-resume.target" ];
    after = [ "multi-user.target" "post-resume.target" ];
    script = ''
      chown -R m /proc/acpi/ibm/fan
    '';
    serviceConfig.Type = "oneshot";
  };

  # Yubikey
  services.pcscd.enable = true;

  services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="${pkgs.stdenv.shell} -c 'chown -R m /sys/class/backlight/%k/brightness'"
      ATTRS{product}=="USB Trackball", SYMLINK+="miltrackball", ENV{DISPLAY}=":0", RUN+="${pkgs.stdenv.shell} -c '/home/m/.bin/trackball'"
  '';

  hardware.u2f.enable = true;

  programs.fish.enable = true;
  virtualisation.docker.enable = true;

  fonts = {
    enableFontDir = true;
    enableDefaultFonts = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [inconsolata terminus proggyfonts terminus_font];
  };
  fonts.fontconfig.hinting.autohint = true;
  services.logind.lidSwitch = "ignore";
  
  nixpkgs.config.packageOverrides = pkgs: {
    dunst = pkgs.dunst.override {
      dunstify = true;
    };
    dmenu = pkgs.dmenu.override {
      patches =[
        /home/m/.patches/dmenu/height.patch
        /home/m/.patches/dmenu/scroll.patch
        /home/m/.patches/dmenu/printinputflag.patch
      ];
        #/home/m/.patches/dmenu/hint.patch
    };
    st = pkgs.st.override {
      patches =[
        /home/m/.patches/st/st-config.patch
        /home/m/.patches/st/st-externalpipe-0.8.2.patch
        /home/m/.patches/st/st-scrollback-0.8.2.patch
        /home/m/.patches/st/st-scrollback-mouse-0.8.2.patch
        /home/m/.patches/st/st-scrollback-mouse-altscreen-20190131-e23acb9.patch
      ];
    };
    chuck = pkgs.chuck.overrideAttrs (oldAttrs: rec {
      name = "chuck";
      version = "1.4.0.0";
    src = builtins.fetchurl {
      url = "http://chuck.cs.princeton.edu/release/files/chuck-${version}.tgz";
      sha256 = "1b17rsf7bv45gfhyhfmpz9d4rkxn24c0m2hgmpfjz3nlp0rf7bic";
    };
  patches = [];
    postPatch = ''
      substituteInPlace src/makefile --replace "/usr/local/bin" "$out/bin"
  '';
    });
    surf-head = pkgs.surf.overrideAttrs (oldAttrs: rec {
      name = "surf-head";
      patches = [
        /home/m/.patches/surf/config.h.patch
        /home/m/.patches/surf/notifyclip.patch
        /home/m/.patches/surf/titlebar.patch
        /home/m/.patches/surf/surf-modal-20190209-d068a38.diff
        /home/m/.patches/surf/surf-2.0-externalpipe.diff
        /home/m/.patches/surf/ua.patch
      ];
      buildInputs = oldAttrs.buildInputs ++ [ pkgs.gcr pkgs.gstreamer ];
      makeFlags = [ "PREFIX=$(out)" ];
      src = builtins.fetchGit {
        url = "https://git.suckless.org/surf";
        rev = "d068a3878b6b9f2841a49cd7948cdf9d62b55585";
      };

    });
  };

  services.logind.extraConfig = "HandleLidSwitch=ignore";

  networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.
  networking.wireless.userControlled.enable = true;

  users.users.m = {
    shell = pkgs.fish;
    isNormalUser = true;
    home = "/home/m";
    description = "m";
    extraGroups = [ "wheel" "docker" "jackaudio" ];
  };
  services.xserver.enable = true;
  services.xserver.exportConfiguration = true;
  services.xserver.autorun = false;
  #users.mutableUsers = false;

  time.timeZone = "America/Chicago";

  environment.systemPackages = with pkgs; [
    # Cli progs
    vis htop restic mutt newsboat wget 
    killall ag git w3m  bc
    fish autojump ranger highlight
    docker jq aria2 whois tree

    # X progs
    xorg.xmodmap keynav xdotool scrot xcwd xtitle xorg.xinit xfontsel
    xorg.xf86inputlibinput xclip xsel autocutsel
    arandr unclutter gnumeric

    inotifyTools
    adoptopenjdk-bin

    leiningen
    boot
    clojure
    ncdu
    go gotools
    
    sqlite unzip

    # Music
    jack_capture chuck jack2

    libreoffice
    i3 zathura sxiv libnotify dunst
    surf-head pkgs.libxml2 firefox 
    dmenu st 
    gnumake stow 
    dbeaver
    compton
    terraform

    # Media
    mpv youtube-dl
    yubikey-personalization
    yubikey-manager
    xurls
    libtidy
    screen

    # Todo remove
    python3
    ruby
  ];
  sound.enable = true;
  services.xserver.libinput.enable = true;
  #services.sshd.enable = true;
  programs.command-not-found.enable = true;

  system.stateVersion = "19.03"; # Did you read the comment?
}
