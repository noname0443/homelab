{ config, pkgs, ... }:
let
  secret = import ./secret/secret.nix;
  webdavPort = toString secret.containers.webdav.port;
  audiobookshelfPort = toString secret.containers.audiobookshelf.port;
  podgrabPort = toString secret.containers.podgrab.port;
  calibrewebPort = toString secret.containers.calibre-web.port;
  jellyfinPort = toString secret.containers.jellyfin.port;
in
{
  systemd.services.homelab-ssh-tunnel = {
    description = "Persistent SSH tunnel to Homelab";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      User = "${secret.system.user}";
      ExecStart = ''
        ${pkgs.autossh}/bin/autossh -M 0 -N -T \
          -o "ServerAliveInterval=60" \
          -o "ServerAliveCountMax=3" \
          -o "ExitOnForwardFailure=yes" \
          -i ${secret.vps.sshkey_path} \
          -R 0.0.0.0:4443:127.0.0.1:443 \
          -R 0.0.0.0:8000:127.0.0.1:80 \
          -R 0.0.0.0:${webdavPort}:127.0.0.1:${webdavPort} \
          -R 0.0.0.0:${audiobookshelfPort}:127.0.0.1:${audiobookshelfPort} \
          -R 0.0.0.0:${podgrabPort}:127.0.0.1:${podgrabPort} \
          -R 0.0.0.0:${calibrewebPort}:127.0.0.1:${calibrewebPort} \
          -R 0.0.0.0:${jellyfinPort}:127.0.0.1:${jellyfinPort} \
          ${secret.vps.user}@${secret.vps.ip}
      '';

      Restart = "always";
      RestartSec = "10s";
    };
  };

  services.caddy = {
    enable = true;
    package = pkgs.caddy;
    email = "${secret.email}";
    virtualHosts = {
      "${secret.domain}" = {
        extraConfig = ''
          respond "Hello world!" 200
        '';
      };

      "${secret.domain}:${jellyfinPort}" = {
        extraConfig = ''
          reverse_proxy ${secret.containers.jellyfin.ip}:${jellyfinPort}
        '';
      };

      "${secret.domain}:${calibrewebPort}" = {
        extraConfig = ''
          reverse_proxy ${secret.containers.calibre-web.ip}:${calibrewebPort}
        '';
      };

      "${secret.domain}:${audiobookshelfPort}" = {
        extraConfig = ''
          reverse_proxy ${secret.containers.audiobookshelf.ip}:${audiobookshelfPort}
        '';
      };

      "${secret.domain}:${podgrabPort}" = {
        extraConfig = ''
          reverse_proxy ${secret.containers.podgrab.ip}:${podgrabPort}
        '';
      };

      "${secret.domain}:${webdavPort}" = {
        extraConfig = ''
          reverse_proxy ${secret.containers.webdav.ip}:${webdavPort}
        '';
      };
    };
  };
}
