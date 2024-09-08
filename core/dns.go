//go:build android

package main

import "C"
import (
	"github.com/metacubex/mihomo/dns"
	"github.com/metacubex/mihomo/log"
	"strings"
)

//export updateDns
func updateDns(s *C.char) {
	dnsList := C.GoString(s)
	go func() {
		log.Infoln("[DNS] updateDns %s", dnsList)
		dns.UpdateSystemDNS(strings.Split(dnsList, ","))
		dns.FlushCacheWithDefaultResolver()
	}()
}
