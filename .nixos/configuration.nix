# Edit this configuration file to define what should be installed on your system.  Help is available in the configuration.nix(5) man page and in the NixOS manual 
# (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let 
  unstable = import <unstable>{};
  sacc = pkgs.callPackage /home/m/.nixos/pkgs/sacc.nix {};
  soundpipe = pkgs.callPackage /home/m/.nixos/pkgs/soundpipe.nix {};
  sporth = pkgs.callPackage /home/m/.nixos/pkgs/sporth.nix {};
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

  #documentation.dev.enable = true;

  # Yubikey
  programs.ssh.startAgent = false;
  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  services.pcscd.enable = true;
  services.udev.packages = with pkgs; [yubikey-personalization pkgs.libu2f-host];
  environment.shellInit = ''
    export GPG_TTY="$(tty)"
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
  '';
  #boot.binfmt.emulatedSystems = ["aarch64-linux" ];
    
  programs.zsh.enable = true;
  virtualisation.docker.enable = true;

  location.provider = "geoclue2";
  services.redshift = {
    enable = true;
    brightness = { day = "0.5"; night = "0.5"; };
    temperature = { day = 5500; night = 3700; };
  };



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
  services.xserver.verbose = 7;
  services.xserver.libinput.accelProfile = "flat";
#    services.xserver.libinput.enable = true;
  services.xserver.exportConfiguration = true;
  services.xserver.autorun = false;

  nixpkgs.config.packageOverrides = pkgs: {
    dunst = pkgs.dunst.override { dunstify = true; };
    mpv = pkgs.mpv.override {
      #jackaudioSupport = true;
      youtubeSupport = true;
    };


  git = pkgs.git.override {
    svnSupport       = false;
    guiSupport       = false;
    sendEmailSupport = true;
    withLibsecret    = false;
  };

    #zig = unstable.zig.overrideAttrs (oldAttrs: rec {
    #  src = builtins.fetchGit {
    #    rev = "245d98d32dd29e80de9732f415a4731748008acf";
    #    url = "https://github.com/zig/ziglang";
    #  };
    #});
    
    st = pkgs.st.overrideAttrs (oldAttrs: rec {
      src = builtins.fetchurl {
        url = "https://dl.suckless.org/st/st-0.8.4.tar.gz";
        sha256 = "19j66fhckihbg30ypngvqc9bcva47mp379ch5vinasjdxgn3qbfl";
      };
      patches = [
        /home/m/Repos/suckless-patches/personal/p1/st/patch-st-config-0.8.4.diff
        /home/m/Repos/suckless-patches/personal/p1/st/patch-st-invert-0.8.4.diff
      ];
    });
    dwm = pkgs.dwm.overrideAttrs (oldAttrs: rec {

      name = "dwm";
      makeFlags = [ "PREFIX=$(out)" ];

      src = builtins.fetchurl {
        url = "https://dl.suckless.org/dwm/dwm-6.2.tar.gz";
        sha256 = "03hirnj8saxnsfqiszwl2ds7p0avg20izv9vdqyambks00p2x44p";
      };
      patches = [
        /home/m/Repos/suckless-patches/personal/p1/dwm/patch-dwm-00-disableenterandmotionnotify.diff
        /home/m/Repos/suckless-patches/personal/p1/dwm/patch-dwm-bartabgroups-6.2.diff
        /home/m/Repos/suckless-patches/personal/p1/dwm/patch-dwm-attachbelow-6.2.diff
        /home/m/Repos/suckless-patches/personal/p1/dwm/patch-dwm-clientindicatorshidevacant-6.2.diff
        /home/m/Repos/suckless-patches/personal/p1/dwm/patch-dwm-combo-6.2.diff
        /home/m/Repos/suckless-patches/personal/p1/dwm/patch-dwm-config-6.2.diff
        /home/m/Repos/suckless-patches/personal/p1/dwm/patch-dwm-deck-6.2.diff
        /home/m/Repos/suckless-patches/personal/p1/dwm/patch-dwm-deck-double-6.2.diff
        /home/m/Repos/suckless-patches/personal/p1/dwm/patch-dwm-dragmfact-6.2.diff
        /home/m/Repos/suckless-patches/personal/p1/dwm/patch-dwm-inplacerotate-6.2.diff
        /home/m/Repos/suckless-patches/personal/p1/dwm/patch-dwm-swallow-6.2.diff
        /home/m/Repos/suckless-patches/personal/p1/dwm/patch-dwm-switchcol-6.2.diff
        /home/m/Repos/suckless-patches/personal/p1/dwm/patch-dwm-fakefullscreen-6.2.diff
        /home/m/Repos/suckless-patches/personal/p1/dwm/patch-dwm-transfer-6.2.diff
      ];
    });

    # TODO:
    dmenu = pkgs.dmenu.overrideAttrs (oldAttrs: rec {
      name = "dmenu";
      patches = [];
      makeFlags = [ "PREFIX=$(out)" ];
      src = builtins.fetchGit {
        #url = "https://git.suckless.org/dmenu";
        #rev = "65be875f5adf31e9c4762ac8a8d74b1dfdd78584";

        rev = "462727d670505aca88952ff37ea6f70f82b069bd"; #localdmenu
        #url = "https://github.com/mil/dmenu";
        url = "file:///home/m/Repos/dmenu";
      };
    });

    #solvespace = pkgs.solvespace.overrideAttrs (oldAttrs: rec {
    #  name = "solvespace";
    #  patches = [];
    #  buildInputs = oldAttrs.buildInputs ++ [ pkgs.mount ];
    #  makeFlags = [ "PREFIX=$(out)" ];
    #  src = pkgs.fetchgit {
    #    sha256 = "b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c";
    #    url = "https://github.com/solvespace/solvespace";
    #    fetchSubmodules = true;
    #  };
    #});

    surf = pkgs.surf.overrideAttrs (oldAttrs: rec {
      name = "surf";
      patches = [
        /home/m/Repos/suckless-patches/personal/p1/surf/patch-surf-buildfix-tip.diff
        /home/m/Repos/suckless-patches/personal/p1/surf/patch-surf-config-tip.diff
        /home/m/Repos/suckless-patches/personal/p1/surf/patch-surf-externalpipe-tip.diff
        /home/m/Repos/suckless-patches/personal/p1/surf/patch-surf-modal-tip.diff
        /home/m/Repos/suckless-patches/personal/p1/surf/patch-surf-useragent-tip.diff
      ];
      buildInputs = oldAttrs.buildInputs ++ [ pkgs.gcr  ];
      makeFlags = [ "PREFIX=$(out)" ];
      src = builtins.fetchGit {
        rev = "d068a3878b6b9f2841a49cd7948cdf9d62b55585"; #localsurf
        url = "https://git.suckless.org/surf";
        #url = "file:///home/m/Repos/surf"; 
      };
    });
    vis = pkgs.vis.overrideAttrs (oldAttrs: rec {
      patches = [/home/m/.nixos/patches/vis/noclear.diff];
    });

    #netsurf-browser = pkgs.netsurf.browser.overrideAttrs (oldAttrs: rec { uilib = "gtk"; });
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
  hardware.enableAllFirmware = true;

  # boot.kernelPatches = [{
  #    name = "enable-mediatek-wifi";
  #    patch = null;
  #    extraConfig = ''MT7601 y'';
  # }];


  networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.
  networking.wireless.userControlled.enable = false;
  users.users.m = {
    shell = pkgs.zsh;
    isNormalUser = true;
    home = "/home/m";
    description = "m";
    extraGroups = [ "wheel" "docker" "jackaudio" "adbusers" "dialout" "uucp" "video" "input" "audio"];
  };
  services.mingetty.autologinUser = "m";
  programs.light.enable = true;

  #users.mutableUsers = false;

  time.timeZone = "America/Chicago";
  environment.systemPackages = with pkgs; [
    # CLI
    htop wget killall ag finger_bsd
    binutils-unwrapped netcat-gnu telnet sshfs 
    mercurial w3m elinks sacc bc gnumake ncdu
    fish autojump highlight jq aria2 whois tree stow 
    inotifyTools libtidy screen picocom unzip p7zip lsof 
    recode lynx html2text moreutils psmisc nix-index zip dos2unix 
    exfat libarchive farbfeld unrar usbutils fzf rlwrap
    astyle sfeed shellcheck shfmt lf file entr dvtm abduco hdparm fasd
    aspell aspellDicts.en smu git ed

    # CLI Docs
    dict manpages posix_man_pages sdcv

    # Music
    jack_capture chuck jack2 puredata sox ffmpeg mpv youtube-dl soundpipe liblo #sporth  

    # Email
    isync msmtp mblaze

    # X progs
    xorg.xmodmap keynav xdotool scrot xcwd xtitle xorg.xinit xfontsel
    xorg.xf86inputlibinput xclip xsel autocutsel xcape xorg.xwininfo
    xorg.xev xorg.xhost xorg.xgamma xorg.xdpyinfo xorg.xwd xcalib
    arandr unclutter sxhkd  libxml2 sxiv libnotify dunst slock restic 
    yubikey-personalization yubikey-manager pinentry gnupg 
    #zathura 

    # Patched
    vis dwm dmenu st
    #surf

    # Langs, DBs
    go sqlite janet gcc python3Minimal unstable.zig
    
    # TODO move:
    libsndfile
    libsoundio
    ncurses

    # Bloated:
    #vmpk 
    #qjackctl
    #pianobar
    #rockbox_utility 
    #firefox 
    #chromium
    #imagemagick
    #geoipWithDatabase
    #appimage-run
    #solvespace 
    #openssl
    #python3
    #ruby
  ];
  #services.dictd.enable = true;
  services.dictd.DBs = with pkgs.dictdDBs; [ wiktionary wordnet ];

  services.sshd.enable = true;
  # networking.interfaces.enp0s25.ipv4.addresses = [ { address = "192.168.8.100"; prefixLength = 24; } ];



  swapDevices = [ { device = "/swapfile"; size = 2048; } ];

  programs.command-not-found.enable = true;
  system.stateVersion = "20.09"; # Did you read the comment?
}
