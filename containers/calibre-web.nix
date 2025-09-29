{ config, pkgs, lib, ... }:
let
  cfgRoot  = "/srv/calibre-web";
  booksDir = "/srv/books";
  secret = import ../secret/secret.nix;
in
{
  systemd.tmpfiles.rules = [
    "d ${cfgRoot} 0777 root root -"
    "d ${cfgRoot}/config 0777 root root -"
    "d ${cfgRoot}/cache 0777 root root -"

    "d ${booksDir}       0777 root root -"
  ];

  containers.calibre-web = {
    autoStart = true;
    extraFlags = [ "-U" ];
    enableTun = true;

    privateNetwork = true;
    localAddress = "${secret.containers.calibre-web.ip}";
    hostAddress = "${secret.containers.calibre-web.bind_ip}";

    bindMounts = {
      "/config"  = { hostPath = "${cfgRoot}"; isReadOnly = false; };
      "/books"   = { hostPath = booksDir; isReadOnly = false; };
    };

    config = { config, pkgs, ... }: {
      networking.hostName = "calibre-web";
      time.timeZone = "UTC";

      services.calibre-web.enable = true;
      services.calibre-web.listen = {
        ip = "0.0.0.0";
        port = secret.containers.calibre-web.port;
      };
      services.calibre-web.openFirewall = true;

      services.calibre-web.options = {
        calibreLibrary = "/books";
      	enableBookUploading = true;
      	enableBookConversion = true;
      };

      environment.systemPackages = [ pkgs.git pkgs.wget ];
      systemd.services.calibre-web-init = {
        description = "Initialize Calibre library if missing";
        after = [ "network-online.target" ];
        wants  = [ "network-online.target" ];
        before = [ "calibre-web.service" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "oneshot";
          User = "calibre-web";
          Group = "calibre-web";
          TimeoutStartSec = "30s";
        };
        path = [ pkgs.wget ];
        script = ''
          set -euo pipefail

          echo "[init] resolv.conf:"
          cat /etc/resolv.conf || true

          if [ ! -f /books/metadata.db ]; then
            echo "[init] downloading metadata.db…"
            wget -v --retry-connrefused --waitretry=3 --tries=5 \
              https://github.com/janeczku/calibre-web/raw/master/library/metadata.db \
              -O /tmp/metadata.db
            cp /tmp/metadata.db /books/metadata.db
            chmod 666 /books/metadata.db
            echo "[init] done."
          else
            echo "[init] metadata.db already exists, skipping."
          fi
        '';
      };

      system.stateVersion = "25.05";
    };
  };

  networking.firewall.allowedTCPPorts = [ secret.containers.calibre-web.port ];
}
