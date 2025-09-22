{ config, pkgs, ... }:

let
  webdavRoot = "/srv/webdav";
  authFile = "/srv/webdav-htpasswd";
  defaultUser = "webdavadmin";
in
{
  systemd.tmpfiles.rules = [
    "d ${webdavRoot} 0775 root root -"
  ];

  environment.systemPackages = [ pkgs.apacheHttpd ];
  systemd.services.webdav-generate-password = {
    description = "Generate WebDAV password file if it doesn't exist";
    serviceConfig.Type = "oneshot";
    script = ''
      set -e
      if [ ! -f "${authFile}" ]; then
        echo "WebDAV password file not found. Generating a new one..."
        PASSWORD=$(head -c 12 /dev/urandom | base64)
        htpasswd -cb "${authFile}" "${defaultUser}" "$PASSWORD"
        chmod 600 "${authFile}"
        echo "✅ Successfully created WebDAV credentials."
        echo "➡️ Path: ${authFile}"
        echo "👤 User: ${defaultUser}"
        echo "🔑 Pass: $PASSWORD"
        echo "You can view the password again with: sudo cat ${authFile}"
      fi
    '';
    path = [ pkgs.apacheHttpd ];

    before = [ "container-webdav.service" ];
    wantedBy = [ "multi-user.target" ];
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];

  containers.webdav = {
    autoStart = true;

    bindMounts = {
      "/var/lib/webdav" = {
        hostPath = webdavRoot;
        isReadOnly = false;
      };
      "/etc/webdav-htpasswd" = {
        hostPath = authFile;
        isReadOnly = true;
      };
    };

    config = { pkgs, ... }: {
      system.stateVersion = "25.05";
      networking.firewall.enable = false;

      services.nginx = {
        enable = true;
        user = "root";
        group = "root";

        virtualHosts."_" = {
          default = true;
          listen = [{ port = 8080; addr = "0.0.0.0"; }];

          locations."/" = {
            root = "/var/lib/webdav";

            basicAuth = "Restricted - WebDAV Access";
            basicAuthFile = "/etc/webdav-htpasswd";

            extraConfig = ''
              dav_methods PUT DELETE MKCOL COPY MOVE;
              create_full_put_path on;
              dav_access user:rw group:rw all:r;
            '';
          };
        };
      };
    };
  };
}
