# Edit this configuration file to define what should be installed on your system.  Help is available in the configuration.nix(5) man page and in the NixOS manual 
# (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let 
  unstable = import <unstable>{};
  sacc = pkgs.callPackage /home/m/.nixpkgs/sacc.nix {};
  soundpipe = pkgs.callPackage /home/m/.nixpkgs/soundpipe.nix {};
  sporth = pkgs.callPackage /home/m/.nixpkgs/sporth.nix {};
  idiotbox = pkgs.callPackage /home/m/.nixpkgs/idiotbox.nix {};
  json2tsv = pkgs.callPackage /home/m/.nixpkgs/json2tsv.nix {};
  tscrape = pkgs.callPackage /home/m/.nixpkgs/tscrape.nix {};
  sfeed = pkgs.callPackage /home/m/.nixpkgs/sfeed.nix {};
  njconnect = pkgs.callPackage /home/m/.nixpkgs/njconnect.nix {};

in {
  imports = [ /etc/nixos/hardware-configuration.nix /etc/nixos/machine.nix ];

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
    options rtl8192cu debug_level=5
  '';
  sound.extraConfig = ''
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

  fonts.fontconfig.defaultFonts.emoji = ["symbola"];


  systemd.extraConfig = ''
    DefaultTimeoutStopSec=5s
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

  documentation.dev.enable = true;


  # Yubikey
  hardware.u2f.enable = true;
  programs.ssh.startAgent = false;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
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
    fonts = with pkgs; [inconsolata terminus proggyfonts terminus_font symbola];
  };
  fonts.fontconfig.hinting.autohint = true;

  services.logind.lidSwitch = "ignore";
  services.ntp.enable = true;
  services.logind.extraConfig = "HandleLidSwitch=ignore";
  services.xserver.enable = true;
  services.xserver.exportConfiguration = true;
  services.xserver.autorun = false;

  #boot.kernelPackages = pkgs.linuxPackages_latest;
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
      makeFlags = [ "PREFIX=$(out)" ];

      src = builtins.fetchGit {
        #url = "https://git.suckless.org/dwm";
        #rev = "caa1d8fbea2b92bca24652af0fee874bdbbbb3e5";
        rev = "3c5398b8e386708624e9cc84a69748a687f77508"; #localdwm
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
        rev = "7152a472b944199778188ef85d9c3b0e6c7d65b1"; #localsurf
        #url = "file:///home/m/Repos/surf"; 
        url = "https://github.com/mil/surf";
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

    #chuck = pkgs.chuck.overrideAttrs (oldAttrs: rec {
    #  name = "chuck";
    #  version = "1.4.0.0";
    #  src = builtins.fetchurl {
    #    url = "http://chuck.cs.princeton.edu/release/files/chuck-${version}.tgz";
    #    sha256 = "1b17rsf7bv45gfhyhfmpz9d4rkxn24c0m2hgmpfjz3nlp0rf7bic";
    #  };
    #  buildFlags = ["linux-jack"];
    #  buildInputs = oldAttrs.buildInputs ++ [ pkgs.libjack2 ];
    #  patches = [];
    #  postPatch = ''
    #    substituteInPlace src/makefile --replace "/usr/local/bin" "$out/bin"
    #  '';
    #});
  };
  services.jack = {
    jackd.enable = true;
    alsa.enable = false;
    loopback = { enable = true; dmixConfig = '' period_size 2048 ''; }; 
    jackd.extraOptions = [
      "-r" "-d" "alsa" "-d" 
      #"h w:USB"
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
    extraGroups = [ "wheel" "docker" "jackaudio" "adbusers" "dialout" "uucp"];
  };
  services.mingetty.autologinUser = "m";

  #users.mutableUsers = false;

  time.timeZone = "America/Chicago";


  environment.systemPackages = with pkgs; [
    # Cli progs
    vis htop mutt wget 
    killall ag
    finger_bsd binutils-unwrapped netcat-gnu telnet sshfs 
    git mercurial
    w3m elinks  sacc
    bc gnumake ncdu
    fish autojump highlight
    docker jq aria2 whois tree stow 
    inotifyTools libtidy screen picocom
    unzip p7zip lsof recode lynx html2text moreutils psmisc
    nix-index zip dos2unix exfat libarchive
    imagemagick geoipWithDatabase ripgrep
    farbfeld unrar plowshare tldr usbutils
    pass fzf rlwrap fd astyle
    idiotbox tscrape sfeed json2tsv
    shellcheck shfmt lf file entr

    # X progs
    xorg.xmodmap keynav xdotool scrot xcwd xtitle xorg.xinit xfontsel
    xorg.xf86inputlibinput xclip xsel autocutsel xcape xorg.xwininfo
    xorg.xev xorg.xhost xorg.xgamma xorg.xdpyinfo xorg.xwd xcalib
    arandr unclutter 

    # Core
    sxhkd dwm dmenu st surf pkgs.libxml2 
    sxiv libnotify dunst slock terraform restic 
    yubikey-personalization yubikey-manager pinentry
    gnupg rockbox_utility

    # Guis
    gnumeric firefox dbeaver zathura guvcview gimp
    #libreoffice    

    # Music
    jack_capture chuck jack2 vmpk puredata sox qjackctl
    ffmpeg mpv youtube-dl pianobar njconnect
    soundpipe sporth liblo

    # TODO remove and use nix shell or docker
    #python37Packages.pip adoptopenjdk-bin leiningen
    #boot zig unstable.stagit unstable.go gotools
    #sqlite expect bind sass python3 ruby discount
    python3
    #gcc gdb xlibsWrapper linux.dev linuxHeaders
    #unstable.rustc unstable.cargo lua unstable.rakudo
    ruby

    # Docs
    manpages
    posix_man_pages
  ];

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "m" ];

  sound.enable = true;
  services.xserver.libinput.enable = true;
  #services.sshd.enable = true;
  programs.command-not-found.enable = true;

  system.stateVersion = "19.09"; # Did you read the comment?
}
