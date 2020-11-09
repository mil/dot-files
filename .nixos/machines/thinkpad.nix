{ config, lib, pkgs, ... }:
{
  imports = [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];
  config = lib.mkIf (builtins.currentSystem == "x86_64-linux") {
    boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sdhci_pci" ];
    #boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];
    fileSystems."/" = { device = "/dev/mapper/c"; fsType = "ext4"; };
    boot.initrd.luks.devices."c".device = "/dev/sda2";
    fileSystems."/boot" = { device = "/dev/sda1"; fsType = "ext4"; };
    swapDevices = [ ];
    nix.maxJobs = lib.mkDefault 4;
    powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

    boot.kernelPackages = pkgs.linuxPackages_latest;

    services.xserver.videoDrivers = [ "intel" "modesetting" ];
    #services.xserver.videoDrivers = [ "vesa" ];

    systemd.services.miles-fixes = {
      description = "Fixes fan permissions";
      wantedBy = [ "multi-user.target" "post-resume.target" ];
      after = [ "multi-user.target" "post-resume.target" ];
      script = ''chown -R m /proc/acpi/ibm/fan'';
      serviceConfig.Type = "oneshot";
    };

    boot.extraModprobeConfig = ''
      options snd_hda_intel enable=0,1
      options thinkpad_acpi fan_control=1
      options rtl8192cu debug_level=5
    '';
    hardware.enableRedistributableFirmware = true;


    boot.loader.grub.enable = true;
    boot.loader.grub.version = 2;
    boot.loader.grub.device = "/dev/sda";
    boot.loader.grub.backgroundColor = "#cfcfcf";
    boot.loader.grub.splashImage = null;
    #services.jack.jackd.enable = true;

    virtualisation.docker.enable = true;
    #virtualisation.virtualbox.host.enable = true;
    #users.extraGroups.vboxusers.members = [ "m" ];

    environment.systemPackages = with pkgs; [
      #libreoffice    
      #terraform 
      #gimp
      #gnumeric
      #dbeaver 
      #guvcview 
      #openscad 
      #meshlab 
    ];
    #nixpkgs.config.chromium.enableWideVine = true;
  };
}
