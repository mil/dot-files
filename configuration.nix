# Edit this configuration file to define what should be installed on your system.  Help is available in the configuration.nix(5) man page and in the NixOS manual 
# (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let unstable = import <unstable>{};
in {
  imports = [ /etc/nixos/hardware-configuration.nix /etc/nixos/networks.nix ];
  programs.adb.enable = true;



  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.backgroundColor = "#cfcfcf";
  boot.loader.grub.splashImage = null;
  boot.tmpOnTmpfs = true;

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
    dunst = pkgs.dunst.override {
      dunstify = true;
    };

    dmenu = pkgs.surf.overrideAttrs (oldAttrs: rec {
      name = "dmenu";
      patches = [
        #/home/m/.patches/dmenu/non_blocking_stdin-4.9.diff
        #/home/m/.patches/dmenu/patched.diff
        #/home/m/.patches/dmenu/dmenu-numbers-4.9.diff


        #/home/m/.patches/dmenu/cust.diff
        /home/m/.patches/dmenu/dmenu-config.patch
        /home/m/.patches/dmenu/height.patch
	/home/m/.patches/dmenu/dmenu-nonblockingstdin-4.9.diff
        /home/m/.patches/dmenu/dmenu-numbers-4.9-nonblocking-compat.diff
        /home/m/.patches/dmenu/scroll.patch
        /home/m/.patches/dmenu/printinputflag.patch
      ];
      makeFlags = [ "PREFIX=$(out)" ];
      src = builtins.fetchGit {
        url = "https://git.suckless.org/dmenu";
	# e.g. 4.9
        rev = "65be875f5adf31e9c4762ac8a8d74b1dfdd78584";
      };
    });

    st = pkgs.st.override {
      patches =[
        /home/m/.patches/st/st-config.patch
        /home/m/.patches/st/st-externalpipe-0.8.2.patch
        /home/m/.patches/st/st-externalpipe-signal-0.8.2.diff
        /home/m/.patches/st/keysel.patch
        /home/m/.patches/st/st-scrollback-0.8.2.patch
        /home/m/.patches/st/st-scrollback-mouse-0.8.2.patch
        /home/m/.patches/st/st-scrollback-mouse-altscreen-20190131-e23acb9.patch
        #/home/m/.patches/st/sixel.patch
      ];
    };
    dwm = pkgs.dwm.override {
      patches =[
         /home/m/.patches/dwm/dwm-6.2-taggrid.diff
         /home/m/.patches/dwm/dwm-switchcol-6.1.diff
         /home/m/.patches/dwm/dwm-config.patch
         /home/m/.patches/dwm/gridanddeck.patch
         /home/m/.patches/dwm/pertag.patch
         /home/m/.patches/dwm/zoomswap.patch
         /home/m/.patches/dwm/movestack.patch
         /home/m/.patches/dwm/barheight.patch

         #/home/m/.patches/dwm/awesomebar.patch
         #/home/m/.patches/dwm/awesomebarswallow.patch
         /home/m/.patches/dwm/swallow_betterkill_awesomebar.patch
      ];
    };
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


    surf-head = pkgs.surf.overrideAttrs (oldAttrs: rec {
      name = "surf-head";
      patches = [
        /home/m/.patches/surf/config.h.patch
        /home/m/.patches/surf/notifyclip.patch
        /home/m/.patches/surf/titlebar.patch
        /home/m/.patches/surf/surf-modal-20190209-d068a38.diff
        /home/m/.patches/surf/ddg.diff
        /home/m/.patches/surf/surf-2.0-externalpipe.diff
        /home/m/.patches/surf/surf-externalpipe-signal-2.0.diff
        /home/m/.patches/surf/ua.patch
      ];
      buildInputs = oldAttrs.buildInputs ++ [ pkgs.gcr  ];
      makeFlags = [ "PREFIX=$(out)" ];
      src = builtins.fetchGit {
        url = "https://git.suckless.org/surf";
        rev = "d068a3878b6b9f2841a49cd7948cdf9d62b55585";
      };

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

    inotifyTools
    python37Packages.pip
    adoptopenjdk-bin

    leiningen
    boot
    ncdu
    unstable.go gotools

    sqlite unzip
    # Music
    jack_capture 
    chuck jack2

    #libreoffice    
    i3 zathura sxiv libnotify dunst
    surf-head 
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
    alpine
    zig
    expect
    xlibsWrapper
    lynx html2text
    gnupg
    psmisc
  ];
  sound.enable = true;
  services.xserver.libinput.enable = true;
  #services.sshd.enable = true;
  programs.command-not-found.enable = true;

  system.stateVersion = "19.03"; # Did you read the comment?
}
