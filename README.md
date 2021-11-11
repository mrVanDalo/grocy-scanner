# grocy scanner

This is a nixos module flake to handle a barcode scanner
in your kitchen to mark products as consumed,
in a convenient way.

Just start the service an start scanning products before you throw them in the trash.

## Example Configuration

```nix
services.grocy-scanner = {
  enable = true;
  host = "https://my-grocy-server.com";
  device = "/dev/input/by-id/usb-Belon.cn_2.4G_Wireless_Device_Belon_Smart-event-kbd";
  apiKeyFile = toString (pkgs.writeText "key" "my-api-key-not");
};
```
