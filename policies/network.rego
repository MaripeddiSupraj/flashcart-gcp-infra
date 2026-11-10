# Conftest OPA rules run against `terraform show -json tfplan`.
# Test locally: conftest test plan.json --policy policies/ --all-namespaces
package terraform.network

import rego.v1

changes := [rc | some rc in input.resource_changes; rc.change.actions[_] != "delete"]

# GCP: block firewall rules opening SSH (22) or RDP (3389) to the internet.
deny contains msg if {
	some rc in changes
	rc.type == "google_compute_firewall"
	"0.0.0.0/0" in rc.change.after.source_ranges
	some a in rc.change.after.allow
	some p in a.ports
	p in {"22", "3389"}
	msg := sprintf("%s: SSH/RDP from 0.0.0.0/0 is forbidden; use IAP (35.235.240.0/20)", [rc.address])
}

# GCP: block Cloud SQL instances with public IPv4 enabled.
deny contains msg if {
	some rc in changes
	rc.type == "google_sql_database_instance"
	some s in rc.change.after.settings
	some ip in s.ip_configuration
	ip.ipv4_enabled == true
	msg := sprintf("%s: Cloud SQL ipv4_enabled must be false (use Private Service Access)", [rc.address])
}
