package main

import (
	"fmt"

	"github.com/spf13/cobra"
)

func main() {
	var rootCmd = &cobra.Command{
		Use:   "uppies",
		Short: "Uppies CLI tool",
	}

	var plzCmd = &cobra.Command{
		Use:   "plz",
		Short: "Execute the plz command",
		Run: func(cmd *cobra.Command, args []string) {
			fmt.Println("plz command executed")
		},
	}

	rootCmd.AddCommand(plzCmd)

	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
	}
}
