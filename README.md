# Configuration on remote host
```
sudo iptables -t nat -I PREROUTING -p tcp --dport 443 -j REDIRECT --to-ports 4443
sudo iptables -t nat -I PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8000
```

# Configuration on local host
## Making secret/secret.nix

```
{
  vpn = {
    ip = "<IP>";
    enabled = true;
    pin = "<YOUR_PIN_SHA256>";
  };

  ssh-tunnel = {
    enabled = false;
    ip = "<IP>";
    user = "<REMOTE_USERNAME>";
    sshkey_path = "<SSH_KEY_PATH>";
    email = "<EMAIL_FOR_LETS_ENCRYPT_CERT>";
    domain = "<YOUR_A_DOMAIN>";
  };

  system = {
    user = "<YOUR_SYSTEM_USER_NAME_HERE>";
  };

  containers = {
    jellyfin = {
      ip = "192.168.101.30";
      bind_ip = "192.168.101.29";
      port = 8096;
      forward = true;
    };
    webdav = {
      ip = "192.168.101.40";
      bind_ip = "192.168.101.39";
      port = 4918;
      users = [
        {
          username = "<YOUR_NICKNAME_HERE>";
          password = "<STRONG_PASSWORD_HERE>";
        }
      ];
      forward = true;
    };
    calibre-web = {
      ip = "192.168.101.50";
      bind_ip = "192.168.101.49";
      port = 8083;
      forward = true;
    };
    audiobookshelf = {
      ip = "192.168.101.60";
      bind_ip = "192.168.101.59";
      port = 13378;
      forward = true;
    };
    podgrab = {
      ip = "192.168.101.70";
      bind_ip = "192.168.101.69";
      port = 8080;
      password = "<STRONG_PASSWORD_HERE>";
      forward = true;
    };
    navidrome = {
      ip = "192.168.101.80";
      bind_ip = "192.168.101.79";
      port = 4533;
      forward = true;
    };
    immich = {
      ip = "192.168.101.90";
      bind_ip = "192.168.101.89";
      port = 2283;
      forward = true;
    };
  };
}
```

To create a sha256 hash of pin do the following on the remote machine:
```
openssl x509 -in server.crt -noout -pubkey \
  | openssl pkey -pubin -outform der \
  | openssl dgst -sha256 -binary \
  | openssl base64
```

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE # for ocserv

## TODOs
- [ ] Mount containers' fs as webdav/ntfs to have capability to distribute things between several machines
- [ ] Introduce feature flags to choose containers/apps
