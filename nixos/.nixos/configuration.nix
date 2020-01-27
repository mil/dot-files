# Edit this configuration file to define what should be installed on your system.  Help is available in the configuration.nix(5) man page and in the NixOS manual 
# (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let 
  #unstable = import <unstable>{};
  sacc = pkgs.callPackage /home/m/.nixos/pkgs/sacc.nix {};
  wxedid = pkgs.callPackage /home/m/.nixos/pkgs/wxedid.nix {};
  soundpipe = pkgs.callPackage /home/m/.nixos/pkgs/soundpipe.nix {};
  sporth = pkgs.callPackage /home/m/.nixos/pkgs/sporth.nix {};
  idiotbox = pkgs.callPackage /home/m/.nixos/pkgs/idiotbox.nix {};
  json2tsv = pkgs.callPackage /home/m/.nixos/pkgs/json2tsv.nix {};
  tscrape = pkgs.callPackage /home/m/.nixos/pkgs/tscrape.nix {};
  sfeed = pkgs.callPackage /home/m/.nixos/pkgs/sfeed.nix {};
  njconnect = pkgs.callPackage /home/m/.nixos/pkgs/njconnect.nix {};

in {
  imports = [
    /etc/nixos/hidden.nix
    /home/m/.nixos/machines/rpi3.nix
    /home/m/.nixos/machines/thinkpad.nix
  ];

  # Prevent DHCP from holding boot
  #boot.kernelParams = ["video=HDMI-A-1:D"];
  systemd.services.systemd-user-sessions.enable = false;

  #boot.tmpOnTmpfs = true;

  systemd.extraConfig = ''
    DefaultTimeoutStopSec=5s
  '';
  services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="${pkgs.stdenv.shell} -c 'chown -R m /sys/class/backlight/%k/brightness'"
      ATTRS{product}=="USB Trackball", SYMLINK+="miltrackball", ENV{DISPLAY}=":0", RUN+="${pkgs.stdenv.shell} -c '/home/m/.bin/trackball'"
  '';

  documentation.dev.enable = true;

  # Yubikey
  hardware.u2f.enable = true;
  programs.ssh.startAgent = false;
  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  services.pcscd.enable = true;
  services.udev.packages = with pkgs; [yubikey-personalization pkgs.libu2f-host];
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
    fonts = with pkgs; [inconsolata 
    #terminus 
    proggyfonts 
    terminus_font 
    symbola];

    fontconfig.defaultFonts.emoji = ["symbola"];
    fontconfig.hinting.autohint = true;
  };

  services.ntp.enable = true;
  services.logind.lidSwitch = "ignore";
  services.logind.extraConfig = "HandleLidSwitch=ignore";
  services.xserver.enable = true;
  services.xserver.libinput.enable = true;
  services.xserver.exportConfiguration = true;
  services.xserver.autorun = false;

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

        rev = "0ee22c922e7c129268af91f5d92b6f75eb059fcf"; #localdmenu
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
      makeFlags = [ "PREFIX=$(out)" ];

      src = builtins.fetchGit {
        #url = "https://git.suckless.org/dwm";
        #rev = "caa1d8fbea2b92bca24652af0fee874bdbbbb3e5";
        rev = "486ad05f4b1f473451c1d1e630725f7e68a60285"; #localdwm
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
        rev = "75a08427717d3552f20b4347fc849a59095c92f6"; #localsurf
        #url = "file:///home/m/Repos/surf"; 
        url = "https://github.com/mil/surf";
      };
    });

    vis = pkgs.vis.overrideAttrs (oldAttrs: rec {
      patches = [/home/m/.nixos/patches/vis/noclear.diff];
    });
  };


  sound = {
    extraConfig = ''
      #defaults.pcm.!card "USB"
      #defaults.ctl.!card "USB"
      #pcm.!default {
      #    type plug
      #    slave.pcm {
      #        @func getenv
      #        vars [ ALSAPCM ]
      #        default "hw :Scarlett 2i4 USB"
      #    }
      #}
    '';
    enable = true;
  };
  services.jack = {
    alsa.enable = true;
    #loopback = { enable = true; dmixConfig = '' period_size 2048 ''; }; 

    jackd.extraOptions = [
      "-r" "-d" "alsa" "-d" 
      #"h w:USB"
      #"hw:USB" 
      "hw:0" 
      "-r" "44100"
    ];
  };

  nixpkgs.config.allowUnfree =true;
  hardware.enableRedistributableFirmware = true;

  # hardware.enableAllFirmware = true;
  # boot.kernelPatches = [{
  #    name = "enable-mediatek-wifi";
  #    patch = null;
  #    extraConfig = ''MT7601 y'';
  # }];


  networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.
  networking.wireless.userControlled.enable = false;
  users.users.m = {
    shell = pkgs.fish;
    isNormalUser = true;
    home = "/home/m";
    description = "m";
    extraGroups = [ "wheel" "docker" "jackaudio" "adbusers" "dialout" "uucp" "video"];
  };
  services.mingetty.autologinUser = "m";

  #users.mutableUsers = false;

  time.timeZone = "America/Chicago";
  environment.systemPackages = with pkgs; [
    # Cli progs
    vis htop mutt wget killall ag
    finger_bsd binutils-unwrapped netcat-gnu telnet sshfs 
    git mercurial w3m elinks sacc bc gnumake ncdu
    fish autojump highlight jq aria2 whois tree stow 
    inotifyTools libtidy screen picocom unzip p7zip lsof 
    recode lynx html2text moreutils psmisc nix-index zip dos2unix 
    exfat libarchive imagemagick geoipWithDatabase farbfeld unrar 
    plowshare tldr usbutils pass fzf rlwrap astyle 
    idiotbox 
    tscrape sfeed json2tsv 
    shellcheck shfmt lf file entr dvtm abduco hdparm
    ii sic edid-decode busybox irssi discount httrack

    # X progs
    xorg.xmodmap keynav xdotool scrot xcwd xtitle xorg.xinit xfontsel
    xorg.xf86inputlibinput xclip xsel autocutsel xcape xorg.xwininfo
    xorg.xev xorg.xhost xorg.xgamma xorg.xdpyinfo xorg.xwd xcalib
    arandr unclutter sxhkd  libxml2 sxiv libnotify dunst slock restic 
    yubikey-personalization yubikey-manager pinentry gnupg rockbox_utility 
    zathura firefox

    # X Patched
    dwm dmenu st surf

    # Music
    jack_capture chuck jack2 vmpk puredata sox qjackctl ffmpeg mpv youtube-dl 
    pianobar soundpipe sporth liblo
    #njconnect

    # TODO remove and use nix shell or docker
    #python37Packages.pip adoptopenjdk-bin leiningen
    #boot zig unstable.stagit unstable.go gotools
    #sqlite expect bind sass python3 ruby discount
    #gcc gdb xlibsWrapper linux.dev linuxHeaders
    #unstable.rustc unstable.cargo lua unstable.rakudo

    # Lang: TODO remove
    python3 ruby

    # Docs
    dict aspellDicts.en manpages posix_man_pages sdcv
  ];
  #services.dictd.enable = true;
  services.dictd.DBs = with pkgs.dictdDBs; [ wiktionary wordnet ];

  #services.sshd.enable = true;
  # networking.interfaces.enp0s25.ipv4.addresses = [ { address = "192.168.8.100"; prefixLength = 24; } ];

  swapDevices = [ { device = "/swapfile"; size = 2048; } ];

  programs.command-not-found.enable = true;
  system.stateVersion = "19.09"; # Did you read the comment?
}
