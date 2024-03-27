package app

import (
	"context"
	"fmt"

	"github.com/canonical/lxd/shared/api"
	"github.com/canonical/microcluster/client"
	"github.com/canonical/microcluster/state"
)

func onHeartbeat(s *state.State) error {
	cluster, err := s.Cluster(nil)
	if err != nil {
		return fmt.Errorf("failed to create cluster client: %w", err)
	}

	if err := cluster.Query(s.Context, true, func(ctx context.Context, c *client.Client) error {
		if err := c.Query(ctx, "POST", api.NewURL().Path("k8sd", "config", "reconcile"), nil, nil); err != nil {
			return fmt.Errorf("POST /k8sd/config/reconcile failed on %q: %w", c.URL().URL.Host, err)
		}
		return nil
	}); err != nil {
		return fmt.Errorf("failed to reconcile control plane configuration on all nodes: %w", err)
	}

	return nil
}
