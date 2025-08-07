# Phase 2 Test: Organizational Custom Rules FAIL case
# This demonstrates a security group that would PASS traditional IaC tools
# but FAILS Phase 2 because it exposes custom organizational port 8080

resource "aws_security_group" "custom_app_violation" {
  name        = "custom-app-violation-sg"
  description = "Security group with custom application port open - organizational violation"

  # Custom application port 8080 - Traditional tools would MISS this
  # Phase 2 organizational policies will CATCH this
  ingress {
    description = "Custom application port 8080 - ORGANIZATIONAL VIOLATION"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # This is the violation - open to internet
  }

  # Another custom organizational port
  ingress {
    description = "Custom management interface - ORGANIZATIONAL VIOLATION"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # This is also a violation
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "custom-app-violation-sg"
    Environment = "production"
    Purpose     = "demonstrates-organizational-violation"
  }
}
