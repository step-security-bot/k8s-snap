!constant  c4 "c4.dsl"

workspace "Canonical K8s Workspace" {
    model {

        admin = person "K8s Admin" "Responsible for the K8s cluster, has elevated permissions"
        user = person "K8s User" "Interact with the workloads hosted in K8s"
        charm = softwareSystem "Charm K8s" "Orchestrating the lifecycle management of K8s"

        lb = softwareSystem "Load Balancer" "External LB, offered by the substrate (cloud)" "Extern"
        storage = softwareSystem "Storage" "External storage, offered by the substrate (cloud)" "Extern"
        iam = softwareSystem "Identity management system" "External identity system, offered by the substrate (cloud)" "Extern"
        external_datastore = softwareSystem "External datastore" "postgress or etcd" "Extern"
  
        k8s_snap = softwareSystem "K8s Snap Distribution" "The Kubernetes distribution in a snap" {

            ui = container "User Interfaces" "The interfaces the K8s snap offers" {
                cli = component "CLI" "The CLI the offered" "CLI"
                api = component "REST API" "The REST interface offered" "REST"
                workload_api = component "Workloads" "The API exposed by the hosted workloads" "Web services"
            }

            logic = container "K8s" "" {
                k8s_services = component "Kubernetes services" "proxy, scheduler control manager"
                apiserver = component "Kube API server" "The upstream Kubernetes API server"
                rt = component "Runtime" "Kubelet, containerd and runc"
            }

            components = container "Components" "Default supported components" {
                component_manager = component "Component management" "Managements of the CNI, RBAC, DNS, hostpath-storage, ingress"
                cni = component "Cilium network CNI" "The network implementation of K8s"
                storage_provider = component "Local host storage provider" "Simple storage for workloads"
                ingress = component "Ingress" "Ingress for workloads"
                dns = component "DNS" "Internal DNS"
                rbac = component "RBAC" "User authorization"
            }

            state = container "State" "Datastores holding the cluster state" {
                k8sd = component "k8sd" "MicroCluster DB and REST API implementation"
                k8s_dqlite = component "k8s-dqlite" "Datastore holding the K8s cluster state"
            }
        }

        admin -> cli "Sets up and configured the cluster"
        user -> workload_api "Interacts with workloads hosted in K8s"
        charm -> api "Orchestrates the lifecycle management of K8s"

        k8s_snap -> lb "Uses a LB to expose workloads"
        k8s_snap -> storage "Hosted workloads use storage"
        k8s_snap -> iam "Users identity is retrieved"

        k8s_dqlite -> external_datastore "May be replaced by" "Any" "Runtime"
        workload_api -> rt "Instantiated by"
        workload_api -> lb "Exposed by"
        apiserver -> k8s_dqlite "Uses by default"

        component_manager -> cni "Handles"
        component_manager -> dns "Handles"
        component_manager -> rbac "Handles"
        component_manager -> storage_provider "Handles"
        component_manager -> ingress "Handles"

        cni -> k8s_dqlite "Keeps state in"
        cni -> ingress "May provide" "HTTP/HTTPS" "Runtime"
        cni -> lb "May provide" "HTTP/HTTPS" "Runtime"
        dns -> k8s_dqlite "Keeps state in"
        ingress -> k8s_dqlite "Keeps state in"

        cli -> apiserver "Interacts via kubectl"
        api -> k8s_services "Configures"
        api -> rt "Configures"
        api -> apiserver "Configures"
        api -> components "Configures"

        cli -> api "CLI is based on the API primitives"
        api -> k8sd "Uses k8sd as the DB layer"

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

        component ui {
            include *
            autoLayout
            title "K8s Snap Interfaces"
        }

        component logic {
            include *
            autoLayout
            title "K8s Logic"
        }

        component components {
            include *
            autoLayout
            title "Components"
        }

        component state {
            include *
            autoLayout
            title "Datastores"
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