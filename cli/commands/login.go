package commands

import (
	"fmt"

	"github.com/spf13/cobra"
)

func loginRun(cmd *cobra.Command, args []string) {
	fmt.Println("Logging in...")
}

func LoginCommand() *cobra.Command {
	return &cobra.Command{
		Use:     "login",
		Short:   "Authenticate with Uppies",
		Args:    cobra.NoArgs,
		PreRun:  nil,
		Run:     loginRun,
	}
}