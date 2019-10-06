# Edit this configuration file to define what should be installed on your system.  Help is available in the configuration.nix(5) man page and in the NixOS manual 
# (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let unstable = import <unstable>{};
in {
  imports = [ /etc/nixos/hardware-configuration.nix /etc/nixos/machine.nix ];
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
    options snd_hda_intel enable=0,1
    options thinkpad_acpi fan_control=1
  '';
  sound.extraConfig = ''
    #defaults.pcm.!card "USB"
    #defaults.ctl.!card "USB"
    #pcm.!default {
    #    type plug
    #    slave.pcm {
    #        @func getenv
    #        vars [ ALSAPCM ]
    #        default "hw:Scarlett 2i4 USB"
    #    }
    #}
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
    mpv = pkgs.mpv.override {
      jackaudioSupport = true;
      youtubeSupport = true;
    };

    dmenu = pkgs.dmenu.overrideAttrs (oldAttrs: rec {
      name = "dmenu";
      patches = [];
      makeFlags = [ "PREFIX=$(out)" ];
      src = builtins.fetchGit {
        #url = "https://git.suckless.org/dmenu";
        #rev = "65be875f5adf31e9c4762ac8a8d74b1dfdd78584";

        rev = "30246d565811ac0eb21c723dc16dba3274d33848"; #localdmenu
        url = "https://github.com/mil/dmenu";
        #url = "file:///home/m/Repos/dmenu";
      };
    });
    st = pkgs.st.overrideAttrs (oldAttrs: rec {
      name = "st";
      patches = [];
      src = builtins.fetchGit {
        rev = "1cf20a5d081c85ba1380ee980b5c76d051b54992"; #localst
        url = "https://github.com/mil/st";
        #url = "file:///home/m/Repos/st";
      };
    });
    dwm = pkgs.dwm.overrideAttrs (oldAttrs: rec {
      name = "dwm";
      patches = [];
      src = builtins.fetchGit {
        #url = "https://git.suckless.org/dwm";
        #rev = "caa1d8fbea2b92bca24652af0fee874bdbbbb3e5";
        rev = "b1b26736fe2dd4d44be594395fc51286377b82b9"; #localdwm
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
        url = "file:///home/m/Repos/surf"; 
        #url = "https://github.com/mil/surf";
      };
    });
    #firmware-linux-nonfree = pkgs.firmware-linux-nonfree.override {
    #  patches =[
    #    /home/m/.patches/firmware-linux-nonfree/firmware-linux-nonfree-config.patch
    #  ];
    #};


    vis = pkgs.vis.overrideAttrs (oldAttrs: rec {
      patches = [/home/m/.patches/vis/noclear.diff];
    });


    chuck = pkgs.chuck.overrideAttrs (oldAttrs: rec {
      name = "chuck";
      version = "1.4.0.0";
      src = builtins.fetchurl {
        url = "http://chuck.cs.princeton.edu/release/files/chuck-${version}.tgz";
        sha256 = "1b17rsf7bv45gfhyhfmpz9d4rkxn24c0m2hgmpfjz3nlp0rf7bic";
      };
      buildFlags = ["linux-jack"];
      buildInputs = oldAttrs.buildInputs ++ [ pkgs.libjack2 ];
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
    vis htop mutt newsboat wget 
    killall ag git w3m elinks  bc gnumake ncdu
    fish autojump ranger highlight
    docker jq aria2 whois tree stow 
    inotifyTools sshfs libtidy screen picocom
    unzip p7zip lsof recode lynx html2text moreutils psmisc
    nix-index zip dos2unix exfat libarchive
    imagemagick geoipWithDatabase ripgrep
    farbfeld unrar plowshare tldr usbutils
    pass

    # X progs
    xorg.xmodmap keynav xdotool scrot xcwd xtitle xorg.xinit xfontsel
    xorg.xf86inputlibinput xclip xsel autocutsel xcape xorg.xwininfo
    xorg.xev xorg.xhost xorg.xgamma xorg.xdpyinfo xorg.xwd xcalib
    arandr unclutter 

    # Core
    sxhkd i3 dwm dmenu st surf pkgs.libxml2 
    sxiv libnotify dunst slock terraform restic 
    yubikey-personalization yubikey-manager pinentry
    gnupg rockbox_utility

    # Guis
    gnumeric firefox dbeaver zathura guvcview gimp
    #libreoffice    

    # Music
    jack_capture chuck jack2 vmpk puredata sox qjackctl
    mplayer ffmpeg mpv youtube-dl pianobar


    # TODO remove and use nix shell or docker
    python37Packages.pip adoptopenjdk-bin leiningen
    boot unstable.zig unstable.stagit unstable.go gotools
    sqlite expect bind sass python3 ruby discount
    gcc gdb xlibsWrapper linux.dev linuxHeaders
    unstable.rustc unstable.cargo 
  ];
  sound.enable = true;
  services.xserver.libinput.enable = true;
  #services.sshd.enable = true;
  programs.command-not-found.enable = true;

  system.stateVersion = "19.03"; # Did you read the comment?
}
