# Phase 3 Test: Environment & Business-Aware FAIL cases
# These demonstrate violations of sophisticated business and environment rules

# PRODUCTION customer-facing app WITHOUT proper corporate CIDR restriction
resource "aws_security_group" "prod_customer_violation" {
  name        = "prod-customer-violation-sg"
  description = "Production customer-facing app with business policy violation"

  # Custom port open to internet in PRODUCTION - VIOLATES Phase 3 business rules
  ingress {
    description = "Custom app unrestricted - BUSINESS VIOLATION"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Should be restricted to corporate CIDR in PROD
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name         = "prod-customer-violation-sg"
    Environment  = "production"  # PROD requires stricter rules
    BusinessFunc = "customer-facing"
    # Missing MonitoringTags - another business rule violation
  }
}

# PRODUCTION app with missing monitoring tags for customer-facing function
resource "aws_security_group" "prod_missing_monitoring" {
  name        = "prod-missing-monitoring-sg"
  description = "Production customer-facing app missing monitoring tags"

  # Custom port with corporate CIDR but missing monitoring tags
  ingress {
    description = "Custom app with CIDR but missing monitoring"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["203.0.113.0/24"]  # Corporate CIDR is good
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name         = "prod-missing-monitoring-sg"
    Environment  = "production"
    BusinessFunc = "customer-facing"
    # Missing MonitoringTags - VIOLATES Phase 3 business requirements
  }
}

# DEVELOPMENT app with critical infrastructure port - even DEV has limits
resource "aws_security_group" "dev_critical_violation" {
  name        = "dev-critical-violation-sg"
  description = "Development app violating critical infrastructure rules"

  # SSH open to internet - VIOLATES even in DEV environment
  ingress {
    description = "SSH access - CRITICAL VIOLATION even in DEV"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Critical ports forbidden everywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name         = "dev-critical-violation-sg"
    Environment  = "development"
    BusinessFunc = "testing"
  }
}
