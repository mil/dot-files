# Edit this configuration file to define what should be installed on your system.  Help is available in the configuration.nix(5) man page and in the NixOS manual 
# (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let unstable = import <unstable>{};
in {
  imports = [ /etc/nixos/hardware-configuration.nix /etc/nixos/networks.nix ];
  programs.adb.enable = true;


	# Prevent DHCP from holding boot
	systemd.services.systemd-user-sessions.enable = false;

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.backgroundColor = "#cfcfcf";
  boot.loader.grub.splashImage = null;
  boot.tmpOnTmpfs = true;

  boot.extraModprobeConfig = ''
    #options snd_hda_intel enable=0,1
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

  services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="${pkgs.stdenv.shell} -c 'chown -R m /sys/class/backlight/%k/brightness'"
      ATTRS{product}=="USB Trackball", SYMLINK+="miltrackball", ENV{DISPLAY}=":0", RUN+="${pkgs.stdenv.shell} -c '/home/m/.bin/trackball'"
  '';


  # Yubikey
  hardware.u2f.enable = true;
  programs.ssh.startAgent = false;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  services.pcscd.enable = true;
  services.udev.packages = with pkgs; [yubikey-personalization];
  environment.shellInit = ''
    export GPG_TTY="$(tty)"
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
  '';



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

#boot.kernelPatches = [
#{
#	name = "foo";
#	patch = /home/m/.patches/firmware-linux-nonfree/fix-wifi.diff;
#}
#
#];
  
  nixpkgs.config.packageOverrides = pkgs: {
    dunst = pkgs.dunst.override { dunstify = true; };

    dmenu = pkgs.dmenu.overrideAttrs (oldAttrs: rec {
      name = "dmenu";
      patches = [];
      makeFlags = [ "PREFIX=$(out)" ];
      src = builtins.fetchGit {
        #url = "https://git.suckless.org/dmenu";
        #rev = "65be875f5adf31e9c4762ac8a8d74b1dfdd78584";

        rev = "46d61998b88877f3e0351d3a57ced8e9f8b26ec5"; #localdmenu
        url = "https://github.com/mil/dmenu";
        #url = "file:///home/m/Repos/dmenu";
      };
    });

    st = pkgs.st.overrideAttrs (oldAttrs: rec {
      name = "st";
      patches = [];
      src = builtins.fetchGit {
        #url = "https://git.suckless.org/st";
        #rev = "caa1d8fbea2b92bca24652af0fee874bdbbbb3e5";

        rev = "1cf20a5d081c85ba1380ee980b5c76d051b54992";
        url = "https://github.com/mil/st";
        #url = "file:///home/m/Repos/st";
        #url = "file:///home/m/Repos/st";
      };
    });


    dwm = pkgs.dwm.overrideAttrs (oldAttrs: rec {
      name = "dwm";
      patches = [];
      src = builtins.fetchGit {
        #url = "https://git.suckless.org/dwm";
        #rev = "caa1d8fbea2b92bca24652af0fee874bdbbbb3e5";

        rev = "ac0ebeab8aff515cccb4b5fe04b871c374362cd5"; #localdwm
        url = "https://github.com/mil/dwm";
        #url = "file:///home/m/Repos/dwm";
      };
    });


    surf = pkgs.surf.overrideAttrs (oldAttrs: rec {
      name = "surf";
      patches = [];
      buildInputs = oldAttrs.buildInputs ++ [ pkgs.gcr  ];
      makeFlags = [ "PREFIX=$(out)" ];
      src = builtins.fetchGit {
        rev = "0a12229e591a3d9f7c3336e5d28dbcc274a715e2"; #localsurf
        #url = "file:///home/m/Repos/surf"; 
        url = "https://github.com/mil/surf";
      };
    });
    #w3m = pkgs.w3m.overrideAttrs (oldAttrs: rec {
    #  name = "w3m";
    #  patches = [
    #    /home/m/.patches/w3m/never-clearscreen.diff
    #  ];
    #});

    firmware-linux-nonfree = pkgs.firmware-linux-nonfree.override {
      patches =[
        /home/m/.patches/firmware-linux-nonfree/firmware-linux-nonfree-config.patch
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


  };

  nixpkgs.config.allowUnfree =true;
  hardware.enableRedistributableFirmware = true;
  #  hardware.enableAllFirmware = true;
  #     boot.kernelPatches = [ {
  #        name = "enable-mediatek-wifi";
  #        patch = null;
  #        extraConfig = ''
  #		MT7601 y
  #              '';
  #        } ];

  services.logind.extraConfig = "HandleLidSwitch=ignore";

  networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.
  networking.wireless.userControlled.enable = false;

  users.users.m = {
    shell = pkgs.fish;
    isNormalUser = true;
    home = "/home/m";
    description = "m";
    extraGroups = [ "wheel" "docker" "jackaudio" "adbusers" "dialout" "uucp"];
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
    nix-index

    inotifyTools
    python37Packages.pip
    adoptopenjdk-bin

    leiningen
    boot
    ncdu
    unstable.zig
    unstable.stagit
    unstable.go 
    gotools

    sqlite unzip
    # Music
    jack_capture 
    chuck jack2
    vmpk
    puredata

    #libreoffice    
    i3 zathura sxiv libnotify dunst
    surf
    pkgs.libxml2 firefox 
    dmenu st 
    gnumake stow 
    dbeaver
    compton
    terraform
    sshfs
    # Media
    mpv 
    youtube-dl

    # Todo re-org
    yubikey-personalization
    yubikey-manager
    xurls
    libtidy
    wmutils-core
    screen
    slock
    picocom
    guvcview
    xcape
    elinks
    dos2unix
    exfat
    sass
    rockbox_utility
    libarchive
    zip
    python3
    ruby
    p7zip
    rakudo
    discount
    gcc
    rofi
    yubikey-manager
    lsof
    pinentry
    gimp
    recode
    sxhkd
    dwm
    imagemagick
    alpine
    expect
    xlibsWrapper
    lynx html2text
    gnupg
    psmisc
    linux.dev
    moreutils
    linuxHeaders
    xcalib
    bind
    gdb
    geoipWithDatabase
    ripgrep
    unstable.rustc
    linux.dev
    unstable.cargo
    sox
    xorg.xwd
    farbfeld
    unrar
    plowshare
    xorg.xev


  ];
  sound.enable = true;
  services.xserver.libinput.enable = true;
  #services.sshd.enable = true;
  programs.command-not-found.enable = true;

  system.stateVersion = "19.03"; # Did you read the comment?
}
