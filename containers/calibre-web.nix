{ config, pkgs, lib, ... }:
let
  cfgRoot  = "/srv/calibre-web";
  booksDir = "/srv/books";
in
{
  systemd.tmpfiles.rules = [
    "d ${cfgRoot}/config 0755 root root -"
    "d ${cfgRoot}/cache  0755 root root -"
    "d ${booksDir}       0755 root root -"
  ];

  containers.calibre-web = {
    autoStart = true;

    bindMounts = {
      "/var/lib/calibre-web"  = { hostPath = "${cfgRoot}/config"; isReadOnly = false; };
      "/var/cache/calibre-web" = { hostPath = "${cfgRoot}/cache"; isReadOnly = false; };
      "/books"                = { hostPath = booksDir; isReadOnly = false; };
    };

    config = { config, pkgs, ... }: {
      networking.hostName = "calibre-web";
      time.timeZone = "UTC";

      services.calibre-web.enable = true;
      services.calibre-web.listen = {
        ip = "0.0.0.0";
        port = 8083;
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
        after = [ "network.target" ];
        before = [ "calibre-web.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = { Type = "oneshot"; };
        path = [ pkgs.wget ];
        script = ''
          set -euo pipefail
          if [ ! -f /books/metadata.db ]; then
            wget https://github.com/janeczku/calibre-web/raw/master/library/metadata.db -O /books/metadata.db
            chmod 644 /books/metadata.db
          fi
        '';
      };

      system.stateVersion = "25.05";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8083 ];
}
