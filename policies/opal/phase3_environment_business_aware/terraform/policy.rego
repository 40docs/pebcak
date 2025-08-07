package policies.phase3_environment_business_aware

# Phase 3: Environment & Business-Aware Security Rules
# Sophisticated policies that consider BOTH environment context AND business function
# Same infrastructure may pass/fail based on where and how it's used

input_type = "tf"
resource_type = "aws_security_group"

default allow = false

# Allow security groups based on sophisticated environment and business context
allow {
    not has_environment_business_violation
}

# Check for environment and business-aware violations
has_environment_business_violation {
    rule := input.ingress[_]
    "0.0.0.0/0" == rule.cidr_blocks[_]
    violates_environment_business_rules(rule)
}

# Check for monitoring violations for production customer-facing apps
has_environment_business_violation {
    input.tags.Environment == "production"
    input.tags.BusinessFunc == "customer-facing"
    not input.tags.MonitoringTags
    # Must have at least one custom app port to require monitoring
    rule := input.ingress[_]
    is_custom_app_port(rule.from_port, rule.to_port)
}

# Environment and business-aware rule checking
violates_environment_business_rules(rule) {
    # PRODUCTION + CUSTOM PORTS = Must be restricted to corporate CIDR
    input.tags.Environment == "production"
    is_custom_app_port(rule.from_port, rule.to_port)
    not rule_has_corporate_cidr_only(rule)
}

violates_environment_business_rules(rule) {
    # PRODUCTION + ANY FUNCTION = No infrastructure ports to internet
    input.tags.Environment == "production"
    is_infrastructure_port(rule.from_port, rule.to_port)
}

# DEVELOPMENT gets more relaxed rules - but still some restrictions
violates_environment_business_rules(rule) {
    input.tags.Environment == "development"
    is_critical_infrastructure_port(rule.from_port, rule.to_port)
}

# Check if rule uses corporate CIDR ranges only
rule_has_corporate_cidr_only(rule) {
    # All CIDR blocks must be corporate CIDRs
    count(rule.cidr_blocks) > 0  # Ensure there are CIDR blocks
    # Check that every CIDR is in the corporate list
    all_corporate_cidrs(rule.cidr_blocks)
}

# Helper to check if all CIDRs are corporate
all_corporate_cidrs(cidrs) {
    corporate_cidrs := ["203.0.113.0/24", "198.51.100.0/24", "10.0.0.0/8"]
    # Every CIDR in the list must be a corporate CIDR
    count(cidrs) == count([cidr | cidr := cidrs[_]; cidr_in_corporate_list(cidr, corporate_cidrs)])
}

# Helper to check if CIDR is in corporate list
cidr_in_corporate_list(cidr, list) {
    allowed := list[_]
    cidr == allowed
}

# Custom application ports (organization-specific)
is_custom_app_port(from_port, to_port) {
    custom_ports := [8080, 8443, 9000, 9090, 8181]
    port := custom_ports[_]
    from_port <= port
    to_port >= port
}

# Critical infrastructure ports (never allowed from internet, even in dev)
is_critical_infrastructure_port(from_port, to_port) {
    critical_ports := [22, 3389, 5432, 3306, 1433]
    port := critical_ports[_]
    from_port <= port
    to_port >= port
}

# General infrastructure ports
is_infrastructure_port(from_port, to_port) {
    infra_ports := [22, 23, 3389, 5432, 3306, 1433, 1521, 27017]
    port := infra_ports[_]
    from_port <= port
    to_port >= port
}
