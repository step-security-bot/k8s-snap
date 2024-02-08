package setup

import (
	"fmt"
	"os"
	"path"

	"github.com/canonical/k8s/pkg/snap"
	snaputil "github.com/canonical/k8s/pkg/snap/util"
	"gopkg.in/yaml.v2"
)

type k8sDqliteInit struct {
	Address string   `yaml:"Address,omitempty"`
	Cluster []string `yaml:"Cluster,omitempty"`
}

func K8sDqlite(snap snap.Snap, address string, cluster []string) error {
	b, err := yaml.Marshal(&k8sDqliteInit{Address: address, Cluster: cluster})
	if err != nil {
		return fmt.Errorf("failed to create init.yaml file for address=%s cluster=%v: %w", address, cluster, err)
	}

	if err := os.WriteFile(path.Join(snap.K8sDqliteStateDir(), "init.yaml"), b, 0600); err != nil {
		return fmt.Errorf("failed to write init.yaml: %w", err)
	}

	if _, err := snaputil.UpdateServiceArguments(snap, "containerd", map[string]string{
		"--storage-dir": snap.K8sDqliteStateDir(),
		"--listen":      fmt.Sprintf("unix://%s", path.Join(snap.K8sDqliteStateDir(), "k8s-dqlite.sock")),
	}, nil); err != nil {
		return fmt.Errorf("failed to write arguments file: %w", err)
	}
	return nil
}
