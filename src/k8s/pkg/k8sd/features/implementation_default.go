package features

import (
	"github.com/canonical/k8s/pkg/k8sd/features/cilium"
	"github.com/canonical/k8s/pkg/k8sd/features/coredns"
	"github.com/canonical/k8s/pkg/k8sd/features/localpv"
	metrics_server "github.com/canonical/k8s/pkg/k8sd/features/metrics-server"
)

// Default implements the Canonical Kubernetes built-in features.
// Cilium is used for networking (network + load-balancer + ingress + gateway).
// CoreDNS is used for DNS.
// MetricsServer is used for metrics-server.
// LocalPV Rawfile CSI is used for local-storage.
var Implementation Interface = &implementation{
	applyDNS:           coredns.ApplyDNS,
	applyNetwork:       cilium.ApplyNetwork,
	applyLoadBalancer:  cilium.ApplyLoadBalancer,
	applyIngress:       cilium.ApplyIngress,
	applyGateway:       cilium.ApplyGateway,
	applyMetricsServer: metrics_server.ApplyMetricsServer,
	applyLocalStorage:  localpv.ApplyLocalStorage,
}
