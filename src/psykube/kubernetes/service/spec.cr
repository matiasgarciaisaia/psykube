require "../../concerns/mapping"

class Psykube::Kubernetes::Service::Spec
  Kubernetes.mapping(
    ports: {type: Array(Psykube::Kubernetes::Service::Spec::Port), default: [] of Port},
    selector: {type: Hash(String, String), default: {} of String => String},
    cluster_ip: {type: String, nilable: true, key: "clusterIP"},
    type: String?,
    external_ips: {type: Array(String), nilable: true, key: "externalIPs"},
    deprecated_public_ips: {type: Array(String), nilable: true, key: "deprecatedPublicIPs"},
    session_affinity: String?,
    load_balancer_ip: {type: String, nilable: true, key: "loadBalancerIP"},
    load_balancer_source_ranges: Array(String)?,
    external_name: Array(String)?,
  )

  def clean!
    super
    if @cluster_ip != "None"
      @cluster_ip = nil
    end
  end
end

require "./spec/*"
