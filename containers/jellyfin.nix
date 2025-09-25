{ config, pkgs, lib, ... }:

let
  cfgRoot = "/srv/jellyfin";
in
{
  systemd.tmpfiles.rules = [
    "d ${cfgRoot}/config 0755 root root -"
    "d ${cfgRoot}/cache  0755 root root -"
    "d /srv/media/movies  0755 root root -"
    "d /srv/media/series  0755 root root -"
    "d /srv/media/study  0755 root root -"
    "d /srv/media/podcasts  0755 root root -"
    "d /srv/media/music  0755 root root -"
  ];

  containers.jellyfin = {
    autoStart = true;

    privateNetwork = true;
    hostAddress = "192.168.101.29";
    localAddress = "192.168.101.30";
    #forwardPorts = [
    #  { containerPort = 8096; hostPort = 8096; protocol = "tcp"; }
    #];


    allowedDevices = [
      { node = "/dev/dri"; modifier = "rwm"; }
    ];

    bindMounts = {
      "/var/lib/jellyfin" = { hostPath = "${cfgRoot}/config"; isReadOnly = false; };
      "/var/cache/jellyfin" = { hostPath = "${cfgRoot}/cache"; isReadOnly = false; };

      "/media/movies" = { hostPath = "/srv/media/movies"; isReadOnly = true; };
      "/media/series" = { hostPath = "/srv/media/series"; isReadOnly = true; };
      "/media/study" = { hostPath = "/srv/media/study"; isReadOnly = true; };
      "/media/music" = { hostPath = "/srv/media/music"; isReadOnly = true; };
      "/media/podcasts" = { hostPath = "/srv/media/podcasts"; isReadOnly = true; };

      "/dev/dri" = { hostPath = "/dev/dri"; isReadOnly = true; };
    };

    config = { config, pkgs, ... }: {
      networking.hostName = "jellyfin";
      time.timeZone = "UTC";

      services.jellyfin.enable = true;

      networking.firewall.enable = true;
      networking.firewall.allowedTCPPorts = [ 8096 8920 ];

      hardware.opengl.enable = true;
      environment.systemPackages = [ pkgs.pciutils ];

      users.users.jellyfin.extraGroups = [ "video" "render" ];

      services.jellyfin.user = "jellyfin";
      services.jellyfin.group = "jellyfin";

      services.openssh.enable = false;
      documentation.nixos.enable = false;
      system.stateVersion = "25.05";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8096 8920 ];
}
