# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is the **pebcak** repository within the 40docs platform - a FortiCNAPP OPAL (Open Policy Agent Language) lab demonstrating Policy as Code evolution. It provides hands-on learning for cloud security teams transitioning from basic IaC scanning to sophisticated, business-aware policy validation.

### Lab Structure

The repository demonstrates progressive policy sophistication through three phases:

- **Phase 1**: Traditional IaC scanning (basic security group validation)
- **Phase 2**: Enhanced PAC with organizational rules (custom application ports)
- **Phase 3**: Environment & business-aware policies (context-sensitive validation)

Each phase includes realistic Terraform configurations, OPAL policy files, and comprehensive test cases.

## Common Development Commands

### Policy Testing Commands
```bash
# Test individual phases
lacework iac policy test -d policies/opal/phase1_traditional_iac
lacework iac policy test -d policies/opal/phase2_enhanced_with_pac  
lacework iac policy test -d policies/opal/phase3_environment_business_aware

# Extract actionable violations from test results
lacework iac policy test -d policies/opal/phase3_environment_business_aware --json 2>/dev/null | \
  jq -r '.results[]?.violations[]?'

# Get pass/fail summary for CI/CD
lacework iac policy test -d policies/opal/phase3_environment_business_aware --json 2>/dev/null | \
  jq -r 'if .summary then "✅ Passed: " + (.summary.passed // 0 | tostring) + " | ❌ Failed: " + (.summary.failed // 0 | tostring) else "No summary available" end'

# CI/CD pipeline check (exit code validation)
lacework iac policy test -d policies/opal/phase3_environment_business_aware --json 2>/dev/null | \
  jq -e '.summary.failed == 0'
```

### Manifest Validation Commands
```bash
# Validate Kubernetes manifests (if any)
kubectl apply --dry-run=client -f .

# Check Terraform syntax
terraform fmt -check=true
terraform validate
```

### Policy Development Commands
```bash
# Upload policy set to FortiCNAPP
lacework iac policy upload -d policies

# Test against real Terraform projects
lacework iac tf-scan opal --disable-custom-policies=false -d /path/to/terraform/project
```

## Architecture and Policy Structure

### Three-Phase Learning Architecture

**Phase 1: Traditional IaC** (`policies/opal/phase1_traditional_iac/`)
- Basic security group validation
- Catches SSH (22), RDP (3389), database ports (5432, 3306, 1433) open to internet
- Simple allow/deny logic focusing on fundamental misconfigurations

**Phase 2: Enhanced PAC** (`policies/opal/phase2_enhanced_with_pac/`)  
- Organizational-specific rules beyond generic security scanning
- Validates custom application ports (8080, 9000, 8443, 8181, 9090)
- Demonstrates how organizations extend basic policies with business-specific requirements

**Phase 3: Environment & Business-Aware** (`policies/opal/phase3_environment_business_aware/`)
- Sophisticated context-sensitive validation
- Same infrastructure configuration may pass/fail based on environment tags
- Business function awareness (customer-facing vs internal)
- Corporate CIDR enforcement for production environments

### Policy File Structure

Each phase follows consistent structure:
```
policies/opal/phase_name/
├── metadata.yaml          # Policy metadata (category, severity, description)
├── terraform/
│   ├── policy.rego        # OPAL policy logic in Rego language
│   └── tests/
│       ├── pass/          # Terraform configs that should pass policy
│       │   └── main.tf
│       └── fail/          # Terraform configs that should fail policy
│           └── main.tf
```

### Key Policy Concepts

**Progressive Complexity**:
- Phase 1: Binary validation (port X should never be open to 0.0.0.0/0)
- Phase 2: Organizational rules (port Y is sensitive for OUR company)
- Phase 3: Context-aware logic (port Z is acceptable in dev but not production)

**Rego Policy Patterns**:
- `input_type = "tf"` - Specifies Terraform input
- `resource_type = "aws_security_group"` - Targets specific resource types
- `default allow = false` - Explicit deny-by-default security posture
- `has_*_violation` functions - Modular violation detection
- Tag-based environment detection - Enables context-sensitive policies

## Important Coding Guidelines

### Policy Development Standards

**Rego Best Practices**:
- Use descriptive function names (`has_environment_business_violation`)
- Implement modular violation detection patterns
- Include comprehensive comments explaining business logic
- Follow explicit deny-by-default security posture
- Use meaningful variable names that reflect business context

**Test-Driven Policy Development**:
- Always create both passing and failing test cases
- Test cases should reflect realistic production scenarios
- Include edge cases and boundary conditions
- Validate policy logic against actual enterprise requirements

**Environment-Aware Policies**:
- Use consistent tag naming conventions (`Environment`, `BusinessFunc`)
- Implement different rule sets for different environments
- Consider both security requirements and developer productivity
- Document environment-specific expectations clearly

### Integration with FortiCNAPP

**CLI Configuration**:
- Policies require FortiCNAPP CLI with IaC component installed
- API key/secret authentication via `~/.lacework.toml`
- Use `lacework component install iac` for initial setup

**Enterprise Integration**:
- Upload validated policies to centralized FortiCNAPP tenant
- Integrate policy testing into CI/CD pipelines
- Use JSON output for automated processing and reporting
- Implement proper exit code handling for pipeline automation

### Policy Validation Workflow

**Development Cycle**:
1. Define business requirement and security objective
2. Identify resource types and configuration patterns
3. Write Rego policy with clear violation logic
4. Create comprehensive test cases (pass/fail scenarios)
5. Validate policy against realistic Terraform configurations
6. Test integration with FortiCNAPP platform
7. Document policy intent and usage guidelines

**Production Deployment**:
- Upload policies to FortiCNAPP tenant
- Configure automated scanning for Terraform projects
- Set up alerting and reporting for policy violations
- Establish remediation workflows for development teams

## Learning Objectives and Use Cases

### Skills Demonstrated

**For Security Teams**:
- Evolution from basic scanning to business-aware policies
- Implementation of organization-specific security requirements
- Context-sensitive policy logic based on environment and business function
- Integration of security policies with existing development workflows

**For Development Teams**:
- Understanding policy validation in infrastructure development
- Environment-specific security requirements
- Business context influence on security controls
- Automated security validation in CI/CD pipelines

### Real-World Applications

**Financial Services**: Environment-specific database encryption and network controls
**Healthcare**: PHI-aware resource tagging and access controls  
**E-commerce**: Customer-facing vs internal application security profiles
**Enterprise**: Corporate CIDR enforcement and business function validation

This repository serves as a comprehensive learning resource for organizations implementing Policy as Code maturity in their cloud security programs.