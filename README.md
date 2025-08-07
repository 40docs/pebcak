
# FortiCNAPP OPAL Lab: Policy as Code Evolution

This repository provides a comprehensive lab demonstrating the evolution from basic Infrastructure as Code (IaC) scanning to advanced Policy as Code (PAC) validation. It showcases real-world scenarios that organizations implement as they mature their cloud security posture.

## 🎯 Lab Objectives

Learn how Policy as Code transforms infrastructure validation from basic best practices to granular, business-specific requirements that reflect actual production environments.

## 📦 What's Included

### Three Progressive Phases

**Phase 1**: Basic IaC Scanning - Traditional security group and encryption checks

**Phase 2**: Enhanced PAC - Current sample policy validating specific resource configurations

**Phase 3**: Enterprise RDS Controls - Production-ready policies validating environment-specific RDS requirements with granular control

Each phase includes:

- `metadata.yaml`: Policy metadata
- `policy.rego`: OPAL policy logic
- `tests/pass`: Passing Terraform configurations
- `tests/fail`: Failing Terraform configurations
- Production-realistic Terraform examples

---

## ⚙️ Prerequisites

- [FortiCNAPP (Lacework) CLI](https://docs.fortinet.com/document/lacework-forticnapp/latest/cli-reference/68020/get-started-with-the-lacework-forticnapp-cli)
- Terraform CLI
- Unix-like shell (macOS/Linux or WSL)
- FortiCNAPP API Key & Secret

---

## 🔧 Installation & Configuration

### 1. Install the FortiCNAPP CLI

#### Bash (macOS/Linux)

```bash
curl https://raw.githubusercontent.com/lacework/go-sdk/main/cli/install.sh | sudo bash
```

#### Powershell (Windows)

```bash
Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/lacework/go-sdk/main/cli/install.ps1'))
```

#### Homebrew (macOS/Linux)

```bash
brew install lacework/tap/lacework-cli
```

#### Chocolatey (Windows)

```bash
choco install lacework-cli
```

---

### 2. Create API Key

The FortiCNAPP CLI requires an API key and secret to authenticate.

1. Log in to the **FortiCNAPP Console**
2. Navigate to **Settings > API keys**
3. Click **Add New**
4. Provide a name and optional description
5. Click **Save**
6. Click the **⋯ (more)** icon and select **Download**

This downloads a JSON file like:

```json
{
  "keyId": "ACCOUNT_ABCDEF01234559B9B07114E834D8570F567C824039756E03",
  "secret": "_abc1234e243a645bcf173ef55b837c19",
  "subAccount": "myaccount",
  "account": "myaccount.lacework.net"
}
```

---

### 3. Configure the CLI

You can configure using the interactive prompt:

```bash
lacework configure
```

Or with the downloaded API key file:

```bash
lacework configure -j /path/to/key.json
```

Example output:

```text
Account: example
Access Key ID: EXAMPLE_1234567890ABCDE1EXAMPLE1EXAMPLE123456789EXAMPLE
Secret Access Key: **********************************
You are all set!
```

The configuration is stored at:

```text
$HOME/.lacework.toml
```

**To configure the Lacework FortiCNAPP CLI for IaC Security:**

1. Run `lacework component install iac` in the Lacework FortiCNAPP CLI.
2. The Lacework FortiCNAPP CLI is now configured for IaC. You can now run `lacework iac ....`

---

## 🧪 Lab Walkthrough

This lab demonstrates the evolution of Policy as Code through three progressive phases, each building upon the previous to show increasing sophistication and real-world applicability.

### Phase 1: Basic IaC Scanning

**Scenario**: Your organization needs basic security validation - ensuring security groups don't allow unrestricted access and EC2 instances have encryption enabled.

**Location**: `policies/opal/phase1_basic_security/`

**What you'll learn**:
- Simple allow/deny policies
- Basic resource type validation
- Traditional security best practices

**Run the test**:
```bash
lacework iac policy test -d opal/phase1_basic_security
```

### Phase 2: Enhanced PAC (Current Sample)

**Scenario**: Your compliance team requires S3 buckets to log to specific, approved logging buckets for audit purposes.

**Location**: `policies/opal/phase2_enhanced_pac/`

**What you'll learn**:
- Validating specific configuration values
- Moving beyond binary yes/no checks
- Organizational compliance requirements

**Run the test**:
```bash
lacework iac policy test -d opal/phase2_enhanced_pac
```

### Phase 3: Advanced PAC - Production Environment

**Scenario**: Your enterprise environment requires granular control over infrastructure deployments:
- RDS instances must use approved parameter groups by environment
- Application Load Balancers must use specific SSL policies based on compliance requirements
- Lambda functions must have specific tags and environment variables for cost allocation and monitoring

**Location**: `policies/opal/phase3_enterprise_controls/`

**What you'll learn**:
- Complex policy logic with multiple resource types
- Environment-specific validation rules
- Integration with enterprise standards and tagging strategies
- Custom error messages for actionable feedback

**Run the test**:
```bash
lacework iac policy test -d opal/phase3_enterprise_controls
```

---

## 🚀 Running the Complete Lab

### 1. Clone this repo

```bash
git clone https://github.com/your-org/lab-forticnapp-opal.git
cd lab-forticnapp-opal/policies
```

### 2. Run Tests with Actionable Output

Run each phase and extract only valuable information:

```bash
# Quick demo with all phases
./demo_lab.sh

# Phase 3 (Advanced PAC) - Extract only violation messages
lacework iac policy test -d policies/opal/phase3_advanced_pac --json 2>/dev/null | \
  jq -r 'if .results then .results[] | select(.violations) | .violations[] else "No test results found" end // "No violations"'

# Get pass/fail summary
lacework iac policy test -d policies/opal/phase3_advanced_pac --json 2>/dev/null | \
  jq -r 'if .summary then "✅ Passed: " + (.summary.passed // 0 | tostring) + " | ❌ Failed: " + (.summary.failed // 0 | tostring) else "No summary available" end'

# Show failures with resource names (safer version)
lacework iac policy test -d policies/opal/phase3_advanced_pac --json 2>/dev/null | \
  jq -r 'if .results then .results[] | select(.result == "FAIL" and .violations) | "❌ " + (.resource // "unknown") + ": " + (.violations | join("; ")) else "No failures found" end'

# Load convenient aliases
source opal_aliases.sh
opal-violations  # Just violations
opal-summary     # Pass/fail counts
opal-check       # CI/CD style (exit codes)
```

### 3. Quick Testing Commands

For daily use, these one-liners extract only what you need:

```bash
# Just show me the problems
lacework iac policy test -d policies/opal/phase3_rds_controls --json 2>/dev/null | jq -r '.results[]?.violations[]?'

# CI/CD pipeline check (exit code matters)
lacework iac policy test -d policies/opal/phase3_rds_controls --json 2>/dev/null | jq -e '.summary.failed == 0'
```

### 3. Test Against Production-Like Infrastructure

Each phase includes realistic Terraform configurations that mirror actual enterprise deployments. You can examine the test files to understand how policies validate real-world scenarios.

---

## 🧪 Optional: Upload or Run Against Real Projects

### Upload your policy set

```bash
lacework iac policy upload -d .
```

### Run OPAL on a Terraform project

```bash
lacework iac tf-scan opal --disable-custom-policies=false -d /path/to/your/project
```

## 📝 Lab Learning Outcomes

### Key Insights from Each Phase

**Phase 1 Insights:**
- Basic security scanning catches fundamental misconfigurations
- Simple allow/deny policies are effective for binary security decisions
- Traditional approaches focus on "what should never happen" rather than "what should happen"
- Limited to basic security hygiene and best practices

**Phase 2 Insights:**
- Moves beyond binary checks to validate specific configuration values
- Introduces organizational compliance requirements
- Demonstrates how PAC can enforce business-specific rules
- Shows the bridge between generic security and organizational standards

**Phase 3 Insights:**
- Enterprise environments require granular, multi-resource validation
- Environment-specific rules ensure appropriate security posture across SDLC
- Comprehensive tagging strategies enable cost allocation and compliance tracking
- Custom error messages provide actionable feedback for developers
- Advanced policies can validate complex business logic and organizational standards

### Real-World Applications

**Financial Services Example:**
A bank might use Phase 3 policies to ensure all RDS instances in production use specific parameter groups that meet SOX compliance requirements, while development environments can use more flexible configurations.

**Healthcare Organization Example:**
A healthcare provider could implement policies that require specific SSL policies for ALBs handling PHI (Protected Health Information) and ensure Lambda functions processing patient data have appropriate monitoring and logging configurations.

**E-commerce Platform Example:**
An online retailer might enforce that all production databases have 30-day backup retention for disaster recovery, while requiring specific tagging for cost allocation across different business units.

---

## 🔧 Extending the Lab

### Adding Your Own Policies

1. Create a new directory under `policies/opal/your_policy_name/`
2. Add `metadata.yaml` with required properties
3. Create `terraform/policy.rego` with your policy logic
4. Add test cases in `terraform/tests/pass/` and `terraform/tests/fail/`

### Best Practices for Policy Development

1. **Start Simple**: Begin with basic allow/deny logic before adding complexity
2. **Provide Clear Messages**: Use `iac.deny_resource_with_message()` for actionable feedback
3. **Test Thoroughly**: Create comprehensive pass/fail test cases
4. **Environment Awareness**: Consider different requirements for dev/staging/production
5. **Document Intent**: Clear comments in your Rego code help with maintenance

---

## 📝 Notes

- Policy logic lives in `policy.rego`
- Use `print()` for debugging, but avoid committing debug statements
- OPAL v0.3.5+ is recommended for print statement output support
