package config

import (
	"encoding/json"
	"os"
	"path/filepath"
)

const (
	ConfigDir  = ".uppies"
	ConfigFile = "config"
)

type configData struct {
	Token string `json:"token"`
}

var Token string

func getConfigPath() string {
	home, err := os.UserHomeDir()
	if err != nil {
		panic(err)
	}
	return filepath.Join(home, ConfigDir, ConfigFile)
}

func LoadConfig() {
	configPath := getConfigPath()
	configDir := filepath.Dir(configPath)

	var data configData
	if _, err := os.Stat(configPath); os.IsNotExist(err) {
		// Create default config
		data = configData{
			Token: "",
		}
		// Ensure directory exists
		os.MkdirAll(configDir, 0755)
		// Write to file
		file, err := os.Create(configPath)
		if err != nil {
			panic(err)
		}
		defer file.Close()
		json.NewEncoder(file).Encode(data)
	} else {
		// Read from file
		file, err := os.Open(configPath)
		if err != nil {
			panic(err)
		}
		defer file.Close()
		json.NewDecoder(file).Decode(&data)
	}
	Token = data.Token
}