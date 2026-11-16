package core

import (
	"fmt"
	"net"
	"testing"

	"github.com/metacubex/mihomo/adapter/outbound"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel/statistic"
)

func BenchmarkRequestTrafficCollectSteadyState(b *testing.B) {
	for _, count := range []int{1000, 10000} {
		b.Run(fmt.Sprint(count), func(b *testing.B) {
			local, remote := net.Pipe()
			direct := outbound.NewDirectWithOption(outbound.DirectOption{Name: "DIRECT"})
			tracker := statistic.NewTCPTracker(
				outbound.NewConn(local, direct), statistic.DefaultManager,
				&constant.Metadata{}, nil, 0, 0, false,
			)
			b.Cleanup(func() {
				_ = tracker.Close()
				_ = remote.Close()
			})
			watch := requestTrafficWatch{requests: make(map[string]*watchedRequest, count)}
			info := tracker.Info()
			for i := range count {
				watch.requests[fmt.Sprint(i)] = &watchedRequest{
					tracker:  tracker,
					upload:   info.UploadTotal.Load(),
					download: info.DownloadTotal.Load(),
				}
			}
			isOpen := func(string) bool { return true }
			queue := func([]RequestTraffic) bool { return true }
			b.ResetTimer()
			for b.Loop() {
				watch.collect(isOpen, queue)
			}
		})
	}
}
