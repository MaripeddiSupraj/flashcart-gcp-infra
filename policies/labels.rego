package terraform.labels

import rego.v1

# Warn when a GCP resource supporting labels omits the 'owner' governance label.
warn contains msg if {
	some rc in input.resource_changes
	rc.provider_name == "registry.terraform.io/hashicorp/google"
	rc.change.actions[_] == "create"
	labels := object.get(rc.change.after, "terraform_labels", null)
	labels != null
	not labels.owner
	msg := sprintf("%s: missing required governance label 'owner'", [rc.address])
}
