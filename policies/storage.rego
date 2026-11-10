package terraform.storage

import rego.v1

changes := [rc | some rc in input.resource_changes; rc.change.actions[_] != "delete"]

deny contains msg if {
	some rc in changes
	rc.type == "google_storage_bucket"
	rc.change.after.uniform_bucket_level_access == false
	msg := sprintf("%s: uniform_bucket_level_access must be true", [rc.address])
}

deny contains msg if {
	some rc in changes
	rc.type == "google_storage_bucket"
	rc.change.after.public_access_prevention != "enforced"
	msg := sprintf("%s: public_access_prevention must be 'enforced'", [rc.address])
}
