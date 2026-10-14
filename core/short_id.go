package core

import (
	"bytes"

	"github.com/metacubex/mihomo/config"
	"go.yaml.in/yaml/v3"
)

// mihomo decodes an unquoted REALITY short-id as a YAML number (0123 is 83, 00
// is 0); the scalar keeps its literal text, so retagging it restores the id.
func unmarshalRawConfig(buf []byte) (*config.RawConfig, error) {
	if !bytes.Contains(buf, []byte("short-id")) {
		return config.UnmarshalRawConfig(buf)
	}
	var document yaml.Node
	if yaml.Unmarshal(buf, &document) != nil || !retagShortIDs(&document) {
		return config.UnmarshalRawConfig(buf)
	}
	rawConfig := config.DefaultRawConfig()
	if err := document.Decode(rawConfig); err != nil {
		return nil, err
	}
	return rawConfig, nil
}

func retagShortIDs(node *yaml.Node) bool {
	retagged := false
	if node.Kind == yaml.MappingNode {
		for i := 0; i+1 < len(node.Content); i += 2 {
			if node.Content[i].Value == "short-id" {
				retagged = retagNumber(node.Content[i+1]) || retagged
			}
		}
	}
	for _, child := range node.Content {
		retagged = retagShortIDs(child) || retagged
	}
	return retagged
}

func retagNumber(node *yaml.Node) bool {
	switch node.Kind {
	case yaml.ScalarNode:
		if node.Style == 0 && (node.Tag == "!!int" || node.Tag == "!!float") {
			node.Tag = "!!str"
			return true
		}
	case yaml.SequenceNode:
		retagged := false
		for _, item := range node.Content {
			retagged = retagNumber(item) || retagged
		}
		return retagged
	}
	return false
}
