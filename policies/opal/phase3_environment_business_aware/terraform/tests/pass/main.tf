# Phase 3 Test: Environment & Business-Aware PASS case
# This demonstrates configurations that pass Phase 3 sophisticated rules

# PRODUCTION customer-facing app with proper corporate CIDR restriction and monitoring
resource "aws_security_group" "prod_customer_compliant" {
  name        = "prod-customer-compliant-sg"
  description = "Production customer-facing app with proper business controls"

  # Standard web traffic - always allowed
  ingress {
    description = "HTTPS for customers"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Custom port with corporate CIDR restriction - PASSES Phase 3
  ingress {
    description = "Custom app restricted to corporate network"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["203.0.113.0/24"]  # Corporate CIDR, not 0.0.0.0/0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name           = "prod-customer-compliant-sg"
    Environment    = "production"
    BusinessFunc   = "customer-facing"
    MonitoringTags = "compliance-required"  # Required for customer-facing
  }
}

# DEVELOPMENT app with relaxed rules - same port 8080 but different environment
resource "aws_security_group" "dev_app_relaxed" {
  name        = "dev-app-relaxed-sg"
  description = "Development app with relaxed rules for testing"

  # Custom port open to internet - PASSES in DEV environment
  ingress {
    description = "Development testing port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allowed in DEV, forbidden in PROD
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name         = "dev-app-relaxed-sg"
    Environment  = "development"  # Key difference - DEV vs PROD
    BusinessFunc = "testing"
  }
}
