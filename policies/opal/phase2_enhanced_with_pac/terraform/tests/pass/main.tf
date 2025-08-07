# Phase 2 Test: Organizational Custom Rules PASS case
# This demonstrates a security group that passes Phase 2 organizational policies
# Only standard web ports are exposed to the internet

resource "aws_security_group" "web_app_clean" {
  name        = "web-app-clean-sg"
  description = "Clean web application security group - should pass Phase 2"

  # Standard web traffic - allowed by all phases
  ingress {
    description = "HTTP access from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS access from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Custom port 8080 but restricted to specific IP - this should pass
  ingress {
    description = "Custom app restricted to corporate network"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["203.0.113.0/24"]  # Corporate CIDR, not 0.0.0.0/0
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "web-app-clean-sg"
    Environment = "production"
    Purpose     = "clean-organizational-compliant"
  }
}
