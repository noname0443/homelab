{ config, pkgs, ... }:
let
  navidromeRoot = "/srv/navidrome";
  secret = import ../secret/secret.nix;
in
{
  systemd.tmpfiles.rules = [
    "d ${navidromeRoot} 0777 root root -"
    "d /srv/media/music 0777 root root -"
  ];

  containers.navidrome = {
    autoStart = true;

    extraFlags = [ "-U" ];
    enableTun = true;

    privateNetwork = true;
    localAddress = "${secret.containers.navidrome.ip}";
    hostAddress = "${secret.containers.navidrome.bind_ip}";

    bindMounts = {
      "/music" = { hostPath = "/srv/media/music"; isReadOnly = true; };
      "/data" = { hostPath = "${navidromeRoot}"; isReadOnly = true; };
    };

    config = { pkgs, ... }: {
      system.stateVersion = "25.05";
      networking.firewall.allowedTCPPorts = [ secret.containers.navidrome.port ];

      services.navidrome = {
        enable = true;
        package = pkgs.navidrome;
        settings = {
          Port = secret.containers.navidrome.port;
          Address = "0.0.0.0";
          MusicFolder = "/music";
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ secret.containers.navidrome.port ];
}
