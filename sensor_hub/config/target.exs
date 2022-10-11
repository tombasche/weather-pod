import Config

# Use shoehorn to start the main application. See the shoehorn
# library documentation for more control in ordering how OTP
# applications are started and handling failures.

config :shoehorn, init: [:nerves_runtime, :nerves_pack]

# Erlinit can be configured without a rootfs_overlay. See
# https://github.com/nerves-project/erlinit/ for more information on
# configuring erlinit.

config :nerves,
  erlinit: [
    hostname_pattern: "nerves-%s"
  ]

# Configure the device for SSH IEx prompt access and firmware updates
#
# * See https://hexdocs.pm/nerves_ssh/readme.html for general SSH configuration
# * See https://hexdocs.pm/ssh_subsystem_fwup/readme.html for firmware updates

keys =
  [
    Path.join([System.user_home!(), ".ssh", "id_rsa.pub"]),
    Path.join([System.user_home!(), ".ssh", "id_ecdsa.pub"]),
    Path.join([System.user_home!(), ".ssh", "id_ed25519.pub"])
  ]
  |> Enum.filter(&File.exists?/1)

if keys == [],
  do:
    Mix.raise("""
    No SSH public keys found in ~/.ssh. An ssh authorized key is needed to
    log into the Nerves device and update firmware on it using ssh.
    See your project's config.exs for this error message.
    """)

config :nerves_ssh,
  authorized_keys: Enum.map(keys, &File.read!/1)

wifi_ssid = System.get_env("WIFI_NAME")

if wifi_ssid == nil, do: Mix.raise("WIFI_NAME must be set - did you run ./firmware.sh?")

wifi_pw = System.get_env("WIFI_PASSWORD")

if wifi_pw == nil, do: Mix.raise("WIFI_PASSWORD must be set - did you run ./firmware.sh?")

# Configure the network using vintage_net
# See https://github.com/nerves-networking/vintage_net for more information
config :vintage_net,
  regulatory_domain: "US",
  config: [
    {"usb0", %{type: VintageNetDirect}},
    {"eth0",
     %{
       type: VintageNetEthernet,
       ipv4: %{method: :dhcp}
     }},
    {"wlan0",
     %{
       type: VintageNetWiFi,
       vintage_net_wifi: %{
         networks: [
           %{
             key_mgmt: :wpa_psk,
             ssid: wifi_ssid,
             psk: wifi_pw
           }
         ],
         ipv4: %{method: :dhcp}
       }
     }}
  ]

config :mdns_lite,
  hosts: [:hostname, "pod"],
  ttl: 120,
  services: [
    %{
      protocol: "ssh",
      transport: "tcp",
      port: 22
    },
    %{
      protocol: "sftp-ssh",
      transport: "tcp",
      port: 22
    },
    %{
      protocol: "epmd",
      transport: "tcp",
      port: 4369
    }
  ]

server = System.get_env("SERVER_URI")
if server == nil, do: Mix.raise("SERVER_URI must be set - did you run ./firmware.sh?")

config :sensor_hub, :weather_tracker_url, server

# 1 minute
config :sensor_hub, :polling_interval, 60_000

device_source = System.get_env("SOURCE")

if device_source == nil, do: Mix.raise("SOURCE must be set - did you run ./firmware.sh?")

# where the device is located
config :sensor_hub, :source, device_source
