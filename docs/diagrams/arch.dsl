!constant  c4 "c4.dsl"

workspace "Canonical K8s Workspace" {
    model {

        admin = person "K8s Admin" "Responsible for the K8s cluster, has elevated permissions"
        user = person "K8s User" "Interact with the workloads hosted in K8s"
        charm = softwareSystem "Charm K8s" "Orchestrating the lifecycle management of K8s"

        external_lb = softwareSystem "Load Balancer" "External LB, offered by the substrate (cloud)" "Extern"
        storage = softwareSystem "Storage" "External storage, offered by the substrate (cloud)" "Extern"
        iam = softwareSystem "Identity management system" "External identity system, offered by the substrate (cloud)" "Extern"
        external_datastore = softwareSystem "External datastore" "postgress or etcd" "Extern"
  
       k8s_snap = softwareSystem "K8s Snap Distribution" "The Kubernetes distribution in a snap" {

            kubectl = container "Kubectl" "kubectl client for accessing the cluster"

            kubernetes = container "Kubernetes Services" "API server, kubelet, kube-proxy, scheduler, kube-controller" {
                systemd = component "systemd daemons" "Daemons holding the k8s services" 
                apiserver = component "API server"
                kubelet = component "kubelet"
                kube_proxy = component "kube-proxy"
                scheduler = component "scheduler"
                kube_controller = component "kube-controller"
            }

            rt = container "Runtime" "Containerd and runc"

            components = container "Components" "Core components for the k8s distribution" {
                cni = component "Cilium network CNI" "The network implementation of K8s (from Cilium)"
                storage_provider = component "LocalPV storage provider" "Simple storage for workloads"
                ingress = component "Ingress" "Ingress for workloads (from Cilium)"
                gw = component "Gateway" "Gateway API for workloads (from Cilium)"
                dns = component "DNS" "Internal DNS"
                rbac = component "RBAC" "User authorization"
                loadbalancer = component "Load-balancer" "The load balancer (from Cilium)"
            }

            k8sd = container "K8sd" "Deamon implementing the functionality available in the k8s snap" {
                cli = component "CLI" "The CLI the offered" "CLI"
                api = component "REST API" "The REST interface offered" "REST"
                cluster_manager = component "CLuster management" "Management of the cluster with the help of MicroCLuster"
                component_manager = component "Component management" "Management of the CNI, RBAC, DNS, storage, ingress"
            }

            state = container "State" "Datastores holding the cluster state" {
                k8sd_db = component "k8sd-dqlite" "MicroCluster DB"
                k8s_dqlite = component "k8s-dqlite" "Datastore holding the K8s cluster state"
            }
        }

        admin -> cli "Sets up and configured the cluster"
        admin -> kubectl "Uses to manage the cluster"
        user -> loadbalancer "Interacts with workloads hosted in K8s"
        charm -> api "Orchestrates the lifecycle management of K8s"

        k8s_snap -> storage "Hosted workloads use storage"
        k8s_snap -> iam "Users identity is retrieved"

        k8s_dqlite -> external_datastore "May be replaced by" "Any" "Runtime"
        loadbalancer -> external_lb "May be replaced by" "Any" "Runtime"

        component_manager -> cni "Handles"
        component_manager -> dns "Handles"
        component_manager -> rbac "Handles"
        component_manager -> storage_provider "Handles"

        cluster_manager -> systemd "Configures"

        systemd -> apiserver "Is a service"
        systemd -> kubelet "Is a service"
        systemd -> kube_proxy "Is a service"
        systemd -> kube_controller "Is a service"
        systemd -> scheduler "Is a service"

        cni -> apiserver "Keeps state in"
        dns -> apiserver "Keeps state in"
        apiserver -> k8s_dqlite "Uses by default"

        cni -> ingress "May provide" "HTTP/HTTPS" "Runtime"
        cni -> gw "May provide" "HTTP/HTTPS" "Runtime"
        cni -> loadbalancer "May provide" "HTTP/HTTPS" "Runtime"

        cluster_manager -> k8sd_db "Keeps state in"

        kubectl -> apiserver "Interacts"
        api -> systemd "Configures"
        api -> rt "Configures"
        api -> component_manager "Uses"
        api -> cluster_manager "Uses"

        cli -> api "CLI is based on the API primitives"

    }
    views {

        systemLandscape Overview "K8s Snap Overview" {
          include * 
          autoLayout
        }

        container k8s_snap {
            include *
            autoLayout
            title "K8s Snap Context View"
        }

        component state {
            include *
            autoLayout
            title "Datastores"
        }

        component components {
            include *
            autoLayout
            title "Components"
        }

        component k8sd {
            include *
            autoLayout
            title "k8sd"
        }

        component kubernetes {
            include *
            autoLayout
            title "Kubernetes services"
        }

        styles {
            element "Person" {
                background #08427b
                color #ffffff
                fontSize 22
                shape Person
            }

            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "Structurizr" {
                background #77FF44
                color #000000
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "Component" {
                background #85bbf0
                color #000000
            }
            element "BuiltIn" {
                background #1988f6
                color #FFFFFF
            }
            element "Extern" {
                background #dddddd
                color #000000
            }

            element "Extension" {
                background #FFdd88
                color #000000
            }

            element "File" {
                shape Folder
                background #448704
                color #ffffff
            }

            relationship "Relationship" {
                dashed false
            }

            relationship "Runtime" {
                dashed true
                color #0000FF
            }

        }
    }

}