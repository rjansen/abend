package abend

import (
	"strings"
)

// List is a slice of errors
type List []error

// NewList creates a List instance for the provided errors slice. It retunrs nil when errors is empty
func NewList(errs ...error) List {
	if len(errs) == 0 {
		return nil
	}

	return List(errs)
}

func (list List) Error() string {
	switch len(list) {
	case 0:
		return ""
	case 1:
		return "errors.List{" + list[0].Error() + "}"
	}
	var builder strings.Builder
	builder.WriteString("errors.List{" + list[0].Error())
	for _, err := range list[1:] {
		builder.WriteString(", ")
		builder.WriteString(err.Error())
	}
	builder.WriteString("}")
	return builder.String()
}
