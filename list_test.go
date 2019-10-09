package abend

import (
	"errors"
	"fmt"
	"testing"

	"github.com/stretchr/testify/assert"
)

type (
	testList struct {
		name     string
		errs     []error
		expected testListExpected
	}

	testListExpected struct {
		list    List
		message string
	}
)

func TestList(t *testing.T) {
	tests := []testList{
		{
			name: "when has no errors",
			errs: []error{},
			expected: testListExpected{
				list:    nil,
				message: "",
			},
		},
		{
			name: "when has only one error",
			errs: []error{
				errors.New("mock_error_1"),
			},
			expected: testListExpected{
				list: List(
					[]error{
						errors.New("mock_error_1"),
					},
				),
				message: "errors.List{mock_error_1}",
			},
		},
		{
			name: "when has many errors",
			errs: []error{
				errors.New("mock_error_1"),
				errors.New("mock_error_2"),
				errors.New("mock_error_3"),
				errors.New("mock_error_4"),
				errors.New("mock_error_5"),
			},
			expected: testListExpected{
				list: List(
					[]error{
						errors.New("mock_error_1"),
						errors.New("mock_error_2"),
						errors.New("mock_error_3"),
						errors.New("mock_error_4"),
						errors.New("mock_error_5"),
					},
				),
				message: "errors.List{mock_error_1, mock_error_2, mock_error_3, mock_error_4, mock_error_5}",
			},
		},
	}

	for index, test := range tests {
		t.Run(
			fmt.Sprintf("%d-%s", index, test.name),
			func(t *testing.T) {
				list := NewList(test.errs...)
				assert.Equal(t, list, test.expected.list)
				assert.EqualError(t, list, test.expected.message)
			},
		)
	}
}
