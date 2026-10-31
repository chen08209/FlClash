//go:build wirediff

package core

import (
	"net/netip"
	_ "unsafe"

	"github.com/metacubex/mihomo/constant"
	_ "github.com/metacubex/mihomo/tunnel"
)

//go:linkname fixMetadata github.com/metacubex/mihomo/tunnel.fixMetadata
func fixMetadata(metadata *constant.Metadata)

//go:linkname preHandleMetadata github.com/metacubex/mihomo/tunnel.preHandleMetadata
func preHandleMetadata(metadata *constant.Metadata) error

//go:linkname resolveMetadata github.com/metacubex/mihomo/tunnel.resolveMetadata
func resolveMetadata(metadata *constant.Metadata) (constant.Proxy, constant.Rule, error)

const routeExplainMethod CoreMethod = "route.explain"

type explainFlow struct {
	Network         string `json:"network"`
	Type            string `json:"type"`
	SourceIP        string `json:"source-ip"`
	SourcePort      uint16 `json:"source-port"`
	DestinationIP   string `json:"destination-ip"`
	DestinationPort uint16 `json:"destination-port"`
	Host            string `json:"host"`
	SniffHost       string `json:"sniff-host"`
	InName          string `json:"in-name"`
	InIP            string `json:"in-ip"`
	InPort          uint16 `json:"in-port"`
	InUser          string `json:"in-user"`
	Process         string `json:"process"`
	ProcessPath     string `json:"process-path"`
	Uid             uint32 `json:"uid"`
	DSCP            uint8  `json:"dscp"`
}

type explainParams struct {
	Flows []explainFlow `json:"flows"`
}

func (flow explainFlow) metadata() *constant.Metadata {
	metadata := &constant.Metadata{
		NetWork:     constant.TCP,
		Type:        constant.INNER,
		SrcPort:     flow.SourcePort,
		DstPort:     flow.DestinationPort,
		InPort:      flow.InPort,
		InName:      flow.InName,
		InUser:      flow.InUser,
		Host:        flow.Host,
		SniffHost:   flow.SniffHost,
		Process:     flow.Process,
		ProcessPath: flow.ProcessPath,
		Uid:         flow.Uid,
		DSCP:        flow.DSCP,
	}
	if flow.Network == "udp" {
		metadata.NetWork = constant.UDP
	}
	if kind, err := constant.ParseType(flow.Type); err == nil {
		metadata.Type = *kind
	}
	metadata.SrcIP, _ = netip.ParseAddr(flow.SourceIP)
	metadata.DstIP, _ = netip.ParseAddr(flow.DestinationIP)
	metadata.InIP, _ = netip.ParseAddr(flow.InIP)
	return metadata
}

func handleRouteExplain(params *explainParams) []map[string]any {
	results := make([]map[string]any, 0, len(params.Flows))
	for _, flow := range params.Flows {
		results = append(results, explain(flow.metadata()))
	}
	return results
}

func explain(metadata *constant.Metadata) map[string]any {
	fixMetadata(metadata)
	if err := preHandleMetadata(metadata); err != nil {
		return map[string]any{"failed": true}
	}
	proxy, rule, err := resolveMetadata(metadata)
	if err != nil || proxy == nil {
		return map[string]any{"failed": true}
	}
	chains := []string{proxy.Name()}
	for next := proxy.Unwrap(metadata, false); next != nil; next = next.Unwrap(metadata, false) {
		chains = append([]string{next.Name()}, chains...)
	}
	result := map[string]any{"rule": "", "payload": "", "chains": chains}
	if rule != nil {
		result["rule"] = rule.RuleType().String()
		result["payload"] = rule.Payload()
	}
	return result
}

func init() {
	methodHandlers[routeExplainMethod] = withArguments(handleRouteExplain)
}
