package setup

import (
	"fmt"
	"path"

	"github.com/canonical/k8s/pkg/snap"
	snaputil "github.com/canonical/k8s/pkg/snap/util"
)

// KubeScheduler configures kube-scheduler on the local node.
func KubeScheduler(snap snap.Snap) error {
	if _, err := snaputil.UpdateServiceArguments(snap, "kube-controller-manager", map[string]string{
		"--kubeconfig":                  path.Join(snap.KubernetesConfigDir(), "controller.conf"),
		"--authorization-kubeconfig":    path.Join(snap.KubernetesConfigDir(), "controller.conf"),
		"--authentication-kubeconfig":   path.Join(snap.KubernetesConfigDir(), "controller.conf"),
		"--profiling":                   "false",
		"--leader-elect-lease-duration": "30s",
		"--leader-elect-renew-deadline": "15s",
	}, nil); err != nil {
		return fmt.Errorf("failed to render arguments file: %w", err)
	}
	return nil
}