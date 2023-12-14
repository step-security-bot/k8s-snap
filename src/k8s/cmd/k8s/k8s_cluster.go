package k8s

import (
	"strconv"

	"github.com/canonical/k8s/pkg/k8s/client"
)

var (
	clusterCmdOpts struct {
		remoteAddress string
		port          string
		storageDir    string
	}
)

func init() {
	rootCmd.PersistentFlags().StringVar(&clusterCmdOpts.remoteAddress, "remote-address", "", "IP Address of another cluster member")
	rootCmd.PersistentFlags().StringVar(&clusterCmdOpts.port, "port", strconv.Itoa(client.DefaultPort), "Port on which the REST-API is exposed")
	// TODO: Use snap interface instead of hardcoded string
	rootCmd.PersistentFlags().StringVar(&clusterCmdOpts.storageDir, "storage-dir", "/var/snap/k8s/common/var/lib/k8sd", "Directory with the dqlite datastore")
}
