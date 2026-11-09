package core

import (
	"strings"

	"github.com/dlclark/regexp2"
)

// Splits and compiles each value as adapter/outboundgroup reads a filter.
func handleValidateFilters(params FiltersParams) []ValidationIssue {
	issues := []ValidationIssue{}
	for i, filter := range params.Filters {
		for _, part := range strings.Split(filter, "`") {
			if _, err := regexp2.Compile(part, regexp2.None); err != nil {
				issues = append(issues, ValidationIssue{Index: i, Message: err.Error()})
				break
			}
		}
	}
	return issues
}
