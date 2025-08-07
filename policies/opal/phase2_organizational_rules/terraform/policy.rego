package policies.phase2_organizational_rules

input_type := "tf"
resource_type := "aws_security_group"

# Phase 2: Organizational Custom Rules
# Extends traditional IaC security with organization-specific requirements
# Catches custom application ports that traditional tools miss

default allow = false

# Allow security groups that don't have sensitive ports open to internet
allow {
    not has_sensitive_port_open_to_internet
}

# Check if security group has sensitive ports open to internet
has_sensitive_port_open_to_internet {
    rule := input.ingress[_]
    "0.0.0.0/0" == rule.cidr_blocks[_]
    is_sensitive_port(rule.from_port, rule.to_port)
}

# Combined sensitive ports: traditional + organizational custom ports
is_sensitive_port(from_port, to_port) {
    # Traditional sensitive ports (what Phase 1 caught)
    traditional_ports := [22, 23, 3389, 5432, 3306, 1433]
    port := traditional_ports[_]
    from_port <= port
    to_port >= port
}

is_sensitive_port(from_port, to_port) {
    # ORGANIZATIONAL CUSTOM: Ports specific to your applications
    # These are what traditional IaC tools would miss
    custom_org_ports := [8080, 9000, 8443, 8181, 9090]
    port := custom_org_ports[_]
    from_port <= port
    to_port >= port
}
