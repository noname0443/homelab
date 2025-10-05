{ config, lib, ... }:
let
  secret = import ../secret/secret.nix;
  vpnEnabled = secret.vpn.enabled;
  sshEnabled = secret.ssh-tunnel.enabled;
in {
  imports =
    lib.optional vpnEnabled ./vpn.nix
    ++ lib.optional sshEnabled ./ssh-tunnel.nix;
}

