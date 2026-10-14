package core

import (
	"strings"

	"github.com/dlclark/regexp2"
)

// Splits and compiles each value as adapter/outboundgroup reads a filter.
func handleValidateFilters(filters []string) []string {
	results := make([]string, len(filters))
	for i, filter := range filters {
		for _, part := range strings.Split(filter, "`") {
			if _, err := regexp2.Compile(part, regexp2.None); err != nil {
				results[i] = err.Error()
				break
			}
		}
	}
	return results
}
