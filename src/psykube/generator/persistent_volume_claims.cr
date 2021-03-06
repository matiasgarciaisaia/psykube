require "../kubernetes/persistent_volume_claim"
require "./concerns/*"

abstract class Psykube::Generator
  class PersistentVolumeClaims < Generator
    include Concerns::Volumes

    protected def result
      result = manifest_claims.map do |mount_path, volume|
        if claim = generate_persistent_volume_claim(mount_path, volume)
          assign_labels(claim, manifest)
          assign_labels(claim, cluster_manifest)
          claim.metadata.namespace = namespace
        end
        claim
      end.compact
      result unless result.empty?
    end

    private def manifest_claims
      manifest_volumes.select { |k, v| volume_is_claim? v }.compact
    end

    private def volume_is_claim?(volume : Manifest::Volume)
      !!volume.claim
    end

    private def volume_is_claim?(volume : String)
      true
    end

    private def generate_persistent_volume_claim(mount_path : String, volume : Manifest::Volume)
      generate_persistent_volume_claim(mount_path, volume.claim)
    end

    private def generate_persistent_volume_claim(mount_path : String, claim : Manifest::Volume::Claim)
      volume_name = name_from_mount_path(mount_path)
      Kubernetes::PersistentVolumeClaim.new(volume_name, claim.size, claim.access_modes).tap do |pvc|
        assign_annotations(pvc, {"volume.beta.kubernetes.io/storage-class" => claim.storage_class.to_s})
        assign_annotations(pvc, claim)
      end
    end

    private def generate_persistent_volume_claim(mount_path : String, nothing : Nil)
    end

    private def generate_persistent_volume_claim(mount_path : String, size : String)
      volume_name = name_from_mount_path(mount_path)
      Kubernetes::PersistentVolumeClaim.new(volume_name, size)
    end
  end
end
