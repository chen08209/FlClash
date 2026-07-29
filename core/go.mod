module core

go 1.21

replace github.com/metacubex/mihomo => ./Clash.Meta

require (
	github.com/Microsoft/go-winio v0.6.2
	github.com/metacubex/mihomo v0.0.0-00010101000000-000000000000
	golang.org/x/exp v0.0.0-20240904232852-e7e105dedf7e
	golang.org/x/sync v0.11.0
)

require (
	github.com/RyuaNerin/go-krypto v1.3.0 // indirect
	github.com/Yawning/aez v0.0.0-20211027044916-e49e68abd344 // indirect
	github.com/ajg/form v1.5.1 // indirect
	github.com/akutz/memconn v0.1.0 // indirect
	github.com/alexbrainman/sspi v0.0.0-20231016080023-1a75b4708caa // indirect
	github.com/andybalholm/brotli v1.1.1 // indirect
	github.com/bahlo/generic-list-go v0.2.0 // indirect
	github.com/bodgit/plumbing v1.3.0 // indirect
	github.com/bodgit/windows v1.0.1 // indirect
	github.com/coder/websocket v1.8.12 // indirect
	github.com/coreos/go-iptables v0.8.0 // indirect
	github.com/dlclark/regexp2 v1.12.0 // indirect
	github.com/dunglas/httpsfv v1.0.2 // indirect
	github.com/enfein/mieru/v3 v3.33.0 // indirect
	github.com/ericlagergren/aegis v0.0.0-20250325060835-cd0defd64358 // indirect
	github.com/ericlagergren/polyval v0.0.0-20220411101811-e25bc10ba391 // indirect
	github.com/ericlagergren/siv v0.0.0-20220507050439-0b757b3aa5f1 // indirect
	github.com/ericlagergren/subtle v0.0.0-20220507045147-890d697da010 // indirect
	github.com/fsnotify/fsnotify v1.9.0 // indirect
	github.com/fxamacker/cbor/v2 v2.9.0 // indirect
	github.com/gaukas/godicttls v0.0.4 // indirect
	github.com/go-ole/go-ole v1.3.0 // indirect
	github.com/gobwas/httphead v0.1.0 // indirect
	github.com/gobwas/pool v0.2.1 // indirect
	github.com/gobwas/ws v1.4.0 // indirect
	github.com/godbus/dbus/v5 v5.1.1-0.20230522191255-76236955d466 // indirect
	github.com/gofrs/uuid/v5 v5.4.0 // indirect
	github.com/golang/groupcache v0.0.0-20241129210726-2c02b8208cf8 // indirect
	github.com/golang/snappy v1.0.0 // indirect
	github.com/google/btree v1.1.3 // indirect
	github.com/google/go-cmp v0.6.0 // indirect
	github.com/google/pprof v0.0.0-20240727154555-813a5fbdbec8 // indirect
	github.com/hashicorp/golang-lru/v2 v2.0.7 // indirect
	github.com/huin/goupnp v1.3.0 // indirect
	github.com/insomniacslk/dhcp v0.0.0-20250109001534-8abf58130905 // indirect
	github.com/josharian/native v1.1.0 // indirect
	github.com/jsimonetti/rtnetlink v1.4.0 // indirect
	github.com/klauspost/compress v1.17.9 // indirect
	github.com/klauspost/cpuid/v2 v2.2.6 // indirect
	github.com/klauspost/reedsolomon v1.12.3 // indirect
	github.com/mdlayher/netlink v1.7.2 // indirect
	github.com/mdlayher/socket v0.5.1 // indirect
	github.com/metacubex/age v0.0.0-20260603010618-28d156b4ea78 // indirect
	github.com/metacubex/amneziawg-go v0.0.0-20251104174305-5a0e9f7e361d // indirect
	github.com/metacubex/ascon v0.1.0 // indirect
	github.com/metacubex/bart v0.26.0 // indirect
	github.com/metacubex/bbolt v0.0.0-20250725135710-010dbbbb7a5b // indirect
	github.com/metacubex/blake3 v0.1.0 // indirect
	github.com/metacubex/chacha v0.1.5 // indirect
	github.com/metacubex/chi v0.1.0 // indirect
	github.com/metacubex/connect-ip-go v0.0.0-20260412152424-e1625567920a // indirect
	github.com/metacubex/cpu v0.1.1 // indirect
	github.com/metacubex/edwards25519 v1.2.0 // indirect
	github.com/metacubex/fswatch v0.1.1 // indirect
	github.com/metacubex/gopacket v1.1.20-0.20230608035415-7e2f98a3e759 // indirect
	github.com/metacubex/gvisor v0.0.0-20251227095601-261ec1326fe8 // indirect
	github.com/metacubex/hkdf v0.1.0 // indirect
	github.com/metacubex/hpke v0.1.0 // indirect
	github.com/metacubex/http v0.1.6 // indirect
	github.com/metacubex/jsonv2 v0.0.0-20260518173308-f4597c22f1df // indirect
	github.com/metacubex/kcp-go v0.0.0-20260105040817-550693377604 // indirect
	github.com/metacubex/mhurl v0.1.0 // indirect
	github.com/metacubex/mlkem v0.1.0 // indirect
	github.com/metacubex/nftables v0.0.0-20260426003805-208c2c1ba2cb // indirect
	github.com/metacubex/qpack v0.6.0 // indirect
	github.com/metacubex/quic-go v0.59.1-0.20260520020949-fcd18c7b6ace // indirect
	github.com/metacubex/randv2 v0.2.0 // indirect
	github.com/metacubex/restls-client-go v0.1.7 // indirect
	github.com/metacubex/sevenzip v1.6.4 // indirect
	github.com/metacubex/sing v0.5.7 // indirect
	github.com/metacubex/sing-mux v0.3.9 // indirect
	github.com/metacubex/sing-quic v0.0.0-20260527143057-68e10a6afdc3 // indirect
	github.com/metacubex/sing-shadowsocks v0.2.12 // indirect
	github.com/metacubex/sing-shadowsocks2 v0.2.7 // indirect
	github.com/metacubex/sing-shadowtls v0.0.0-20260517015314-c11c36474edc // indirect
	github.com/metacubex/sing-tun v0.4.20 // indirect
	github.com/metacubex/sing-vmess v0.2.5 // indirect
	github.com/metacubex/sing-wireguard v0.0.0-20260520151737-7e7c7c1b854c // indirect
	github.com/metacubex/smux v0.0.0-20260105030934-d0c8756d3141 // indirect
	github.com/metacubex/ssh v0.1.0 // indirect
	github.com/metacubex/tailscale v0.0.0-20260520011538-f23132fac4b7 // indirect
	github.com/metacubex/tailscale-wireguard-go v0.0.0-20260521124654-e1bf77ef79af // indirect
	github.com/metacubex/tfo-go v0.0.0-20251130171125-413e892ac443 // indirect
	github.com/metacubex/tls v0.1.6 // indirect
	github.com/metacubex/utls v1.8.4 // indirect
	github.com/metacubex/wireguard-go v0.0.0-20250820062549-a6cecdd7f57f // indirect
	github.com/metacubex/yamux v0.0.0-20250918083631-dd5f17c0be49 // indirect
	github.com/miekg/dns v1.1.63 // indirect
	github.com/mitchellh/go-ps v1.0.0 // indirect
	github.com/mroth/weightedrand/v2 v2.1.0 // indirect
	github.com/oasisprotocol/deoxysii v0.0.0-20220228165953-2091330c22b7 // indirect
	github.com/openacid/low v0.1.21 // indirect
	github.com/oschwald/maxminddb-golang v1.12.0 // indirect
	github.com/pierrec/lz4/v4 v4.1.27 // indirect
	github.com/pires/go-proxyproto v0.8.0 // indirect
	github.com/rasky/go-lzo v0.0.0-20200203143853-96a758eda86e // indirect
	github.com/safchain/ethtool v0.3.0 // indirect
	github.com/sagernet/netlink v0.0.0-20240612041022-b9a21c07ac6a // indirect
	github.com/samber/lo v1.53.0 // indirect
	github.com/sina-ghaderi/poly1305 v0.0.0-20220724002748-c5926b03988b // indirect
	github.com/sina-ghaderi/rabaead v0.0.0-20220730151906-ab6e06b96e8c // indirect
	github.com/sina-ghaderi/rabbitio v0.0.0-20220730151941-9ce26f4f872e // indirect
	github.com/sirupsen/logrus v1.9.4 // indirect
	github.com/stangelandcl/ppmd v0.1.1 // indirect
	github.com/tailscale/certstore v0.1.1-0.20260409135935-3638fb84b77d // indirect
	github.com/tailscale/go-winio v0.0.0-20231025203758-c4f33415bf55 // indirect
	github.com/tailscale/hujson v0.0.0-20221223112325-20486734a56a // indirect
	github.com/tailscale/peercred v0.0.0-20250107143737-35a0c7bd7edc // indirect
	github.com/u-root/uio v0.0.0-20230220225925-ffce2a382923 // indirect
	github.com/ulikunitz/xz v0.5.15 // indirect
	github.com/vishvananda/netns v0.0.5 // indirect
	github.com/vmihailenco/msgpack/v5 v5.4.1 // indirect
	github.com/vmihailenco/tagparser/v2 v2.0.0 // indirect
	github.com/x448/float16 v0.8.4 // indirect
	github.com/yosida95/uritemplate/v3 v3.0.2 // indirect
	gitlab.com/go-extension/aes-ccm v0.0.0-20230221065045-e58665ef23c7 // indirect
	gitlab.com/yawning/bsaes.git v0.0.0-20190805113838-0a714cd429ec // indirect
	go4.org/mem v0.0.0-20240501181205-ae6ca9944745 // indirect
	go4.org/netipx v0.0.0-20231129151722-fdeea329fbba // indirect
	golang.org/x/crypto v0.33.0 // indirect
	golang.org/x/mod v0.20.0 // indirect
	golang.org/x/net v0.35.0 // indirect
	golang.org/x/oauth2 v0.24.0 // indirect
	golang.org/x/sys v0.30.0 // indirect
	golang.org/x/term v0.29.0 // indirect
	golang.org/x/text v0.22.0 // indirect
	golang.org/x/time v0.10.0 // indirect
	golang.org/x/tools v0.24.0 // indirect
	google.golang.org/protobuf v1.34.2 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
)
