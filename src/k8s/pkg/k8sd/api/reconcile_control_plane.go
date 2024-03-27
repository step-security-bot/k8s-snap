package api

import (
	"fmt"
	"net/http"

	"github.com/canonical/lxd/lxd/response"
	"github.com/canonical/microcluster/state"
)

func postReconcileControlPlane(s *state.State, r *http.Request) response.Response {
	fmt.Println("Reconcile called!")
	return response.EmptySyncResponse
	// return response.InternalError(fmt.Errorf("not implemented"))
}
