output "instance_ids" {
  description = "IDs of created instances"
  value = merge(
    { for instance in module.g4dn_12xlarge_instance : instance.tags_all.Name => instance.id },
    { for instance in module.g4dn_xlarge_instance : instance.tags_all.Name => instance.id },
    { for instance in module.g4ad_8xlarge_instance : instance.tags_all.Name => instance.id },
    { for instance in module.g4ad_xlarge_instance : instance.tags_all.Name => instance.id },
    { for instance in module.t3_xlarge_instance : instance.tags_all.Name => instance.id },
    { for instance in module.t3_micro_instance : instance.tags_all.Name => instance.id },
  )
}
