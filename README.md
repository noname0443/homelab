# Configuration on remote host
```
sudo iptables -t nat -I PREROUTING -p tcp --dport 443 -j REDIRECT --to-ports 4443
sudo iptables -t nat -I PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8000
```

# Configuration on local host
## Making secret/secret.nix

```
{
  extIP = "<REMOTE HOST IP>";
  extUSER = "<REMOTE HOST USER>";
  email = "<EMAIL FOR LETS ENCRYPT>";
  domain = "<YOUR HOMELAB DOMAIN>";
}
```

## F
```
```
