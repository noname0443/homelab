# Configuration on remote host
```
sudo iptables -t nat -I PREROUTING -p tcp --dport 443 -j REDIRECT --to-ports 4443
sudo iptables -t nat -I PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8000
```

# Configuration on local host
## Making secret/secret.nix

```
  vps = {
    ip = "<REMOTE_IP";
    user = "<REMOTE_USER>";
    sshkey_path = "<LOCAL_PATH_TO_SSH_KEY>";
  };

  system = {
    user = "<SYSTEM_USER_TO_RUN_AUTOSSH>";
  };

  email = "<EMAIL_FOR_LETS_ENCRYPT>";
  domain = "<YOUR_DOMAIN>";

  containers = {
    jellyfin = {
      ip = "192.168.101.30";
      bind_ip = "192.168.101.29";
      port = 8096;
    };
    webdav = {
      ip = "192.168.101.40";
      bind_ip = "192.168.101.39";
      port = 4918;
      users = [
        {
          username = "<USERNAME>";
          password = "<PASSWORD>";
        }
      ];
    };
    calibre-web = {
      ip = "192.168.101.50";
      bind_ip = "192.168.101.49";
      port = 8083;
    };
    audiobookshelf = {
      ip = "192.168.101.60";
      bind_ip = "192.168.101.59";
      port = 13378;
    };
    podgrab = {
      ip = "192.168.101.70";
      bind_ip = "192.168.101.69";
      port = 8080;
      password = "<SOME_PASSWORD>";
    };
  };
}
```

## TODOs
- [ ] Mount containers' fs as webdav/ntfs to have capability to distribute things between several machines
- [ ] Introduce feature flags to choose containers/apps
