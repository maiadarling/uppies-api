package commands

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/spf13/cobra"
	"uppies/cli/config"
)

func resolvePath(path string) (string, error) {
	return filepath.Abs(path)
}

func plzRun(cmd *cobra.Command, args []string) {
	folder := args[0]

	// Resolve folder to absolute path
	absFolder, err := resolvePath(folder)
	if err != nil {
		fmt.Printf("Error resolving absolute path for %s: %v\n", folder, err)
		os.Exit(1)
	}

	// Complex logic here: analyze folder, archive, upload, call APIs, verify state, report back
	fmt.Printf("Starting plz process for folder: %s\n", absFolder)
	fmt.Printf("Using config: token=%s\n", config.Token)
}

func requireLogin(cmd *cobra.Command, args []string) {
	if config.Token == "" {
		fmt.Println("You must be logged in to use this command. Run 'uppies login' to authenticate.")
		os.Exit(1)
	}
}

func PlzCommand() *cobra.Command {
	return &cobra.Command{
		Use:     "plz [folder]",
		Short:   "Execute the plz command",
		Args:    cobra.ExactArgs(1),
		PreRun:  requireLogin,
		Run:     plzRun,
	}
}