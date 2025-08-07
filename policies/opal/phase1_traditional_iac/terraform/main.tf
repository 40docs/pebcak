# Security Group Test Configuration - Phase 1: Traditional IaC Violations
# Minimal infrastructure focused ONLY on security group rules

# Security group with SSH violation - traditional tools catch this
resource "aws_security_group" "ssh_violation" {
  name        = "ssh-violation-sg"
  description = "Security group with SSH open to internet - traditional violation"

  # SSH access - Phase 1 will catch this
  ingress {
    description = "SSH access from internet - VIOLATION"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "ssh-violation-sg"
    Environment = "production"
  }
}

# Security group with database violation - traditional tools catch this
resource "aws_security_group" "database_violation" {
  name        = "database-violation-sg"
  description = "Security group with PostgreSQL open to internet - traditional violation"

  # PostgreSQL access - Phase 1 will catch this
  ingress {
    description = "PostgreSQL access from internet - VIOLATION"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "database-violation-sg"
    Environment = "production"
  }
}

# Security group that should PASS - only standard web ports
resource "aws_security_group" "web_app_clean" {
  name        = "web-app-clean-sg"
  description = "Clean web application security group - should pass all phases"

  # Standard web traffic - should pass Phase 1
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
  }
}
