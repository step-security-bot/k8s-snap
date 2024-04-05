package utils

import (
	"context"
	"fmt"
	"log"

	apiv1 "github.com/canonical/k8s/api/v1"
	"github.com/canonical/microcluster/state"
)

// GetControlPlaneNode returns the node information if the given node name
// belongs to a control-plane in the cluster or nil if not.
func GetControlPlaneNode(ctx context.Context, s *state.State, name string) (*apiv1.NodeStatus, error) {
	client, err := s.Leader()
	if err != nil {
		log.Printf("failed to get microcluster leader client: %v", err)
		return nil, fmt.Errorf("failed to get microcluster leader client: %w", err)
	}

	members, err := client.GetClusterMembers(ctx)
	if err != nil {
		return nil, fmt.Errorf("failed to get microcluster members: %w", err)
	}

	for _, member := range members {
		if member.Name == name {
			return &apiv1.NodeStatus{
				Name:          member.Name,
				Address:       member.Address.String(),
				ClusterRole:   apiv1.ClusterRoleControlPlane,
				DatastoreRole: DatastoreRoleFromString(member.Role),
			}, nil
		}
	}
	return nil, nil
}

// IsControlPlaneNode returns true if the given node name belongs to a control-plane node in the cluster.
func IsControlPlaneNode(ctx context.Context, s *state.State, name string) (bool, error) {
	node, err := GetControlPlaneNode(ctx, s, name)
	if err != nil {
		return false, fmt.Errorf("failed to get control-plane node: %w", err)
	}
	return node != nil, nil
}

// IsWorkerNode returns true if the given node name belongs to a worker node in the cluster.
func IsWorkerNode(ctx context.Context, s *state.State, name string) (bool, error) {
	exists, err := CheckWorkerExists(ctx, s, name)
	if err != nil {
		return false, fmt.Errorf("failed to check if worker node %q exists: %w", name, err)
	}
	return exists, nil
}

// DatastoreRoleFromString converts the string-based role to the enum-based role.
func DatastoreRoleFromString(role string) apiv1.DatastoreRole {
	switch role {
	case "voter":
		return apiv1.DatastoreRoleVoter
	case "stand-by":
		return apiv1.DatastoreRoleStandBy
	case "spare":
		return apiv1.DatastoreRoleSpare
	case "PENDING":
		return apiv1.DatastoreRolePending
	default:
		return apiv1.DatastoreRoleUnknown
	}
}
