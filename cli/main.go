package main

import (
	"fmt"

	"github.com/spf13/cobra"
	"uppies/cli/commands"
	"uppies/cli/config"
)

func main() {
	var rootCmd = &cobra.Command{
		Use:   "uppies",
		Short: "Uppies CLI tool",
	}

	config.LoadConfig()

	rootCmd.AddCommand(commands.LoginCommand())
	rootCmd.AddCommand(commands.PlzCommand())

	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
	}
}
