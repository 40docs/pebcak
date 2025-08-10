
# FortiCNAPP OPAL Lab: Policy as Code Evolution

This repository provides a comprehensive lab demonstrating the evolution from basic Infrastructure as Code (IaC) scanning to advanced Policy as Code (PAC) validation. It showcases real-world scenarios that organizations implement as they mature their cloud security posture.

## 🎯 Lab Objectives

Learn how Policy as Code transforms infrastructure validation from basic best practices to granular, business-specific requirements that reflect actual production environments.

## 📦 What's Included

### Three Progressive Phases

**Phase 1**: Traditional IaC Scanning - Basic security group validation (SSH, RDP, database ports)

**Phase 2**: Enhanced PAC with Organizational Rules - Validates custom application ports specific to your organization

**Phase 3**: Environment & Business-Aware Policies - Context-sensitive validation based on environment tags and business function

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

**Location**: `policies/opal/phase1_traditional_iac/`

**What you'll learn**:
- Simple allow/deny policies
- Basic resource type validation
- Traditional security best practices

**Run the test**:
```bash
lacework iac policy test -d policies/opal/phase1_traditional_iac
```

### Phase 2: Enhanced PAC (Current Sample)

**Scenario**: Your organization has custom applications running on non-standard ports (like 8080) that traditional IaC tools miss, but your security team needs to protect.

**Location**: `policies/opal/phase2_enhanced_with_pac/`

**What you'll learn**:
- Validating specific configuration values
- Moving beyond binary yes/no checks
- Organizational compliance requirements

**Run the test**:
```bash
lacework iac policy test -d policies/opal/phase2_enhanced_with_pac
```

### Phase 3: Advanced PAC - Production Environment

**Scenario**: Your enterprise environment requires context-sensitive security controls:
- Production custom application ports must only accept traffic from corporate CIDR ranges
- Development environments have relaxed rules but still block critical infrastructure ports
- Customer-facing applications in production require monitoring tags
- Same security group configuration may pass in dev but fail in production

**Location**: `policies/opal/phase3_environment_business_aware/`

**What you'll learn**:
- Environment-aware policy logic (production vs development rules)
- Business function context (customer-facing vs internal)
- Corporate CIDR enforcement for production environments
- Tag-based monitoring requirements
- Same infrastructure may pass/fail based on context

**Run the test**:
```bash
lacework iac policy test -d policies/opal/phase3_environment_business_aware
```

---

## 🚀 Running the Complete Lab

### 1. Clone this repo

```bash
# This is part of the 40docs platform
cd policies
```

### 2. Run Tests with Actionable Output

Run each phase and extract only valuable information:

```bash
# Test all phases sequentially
for phase in phase1_traditional_iac phase2_enhanced_with_pac phase3_environment_business_aware; do
  echo "\n=== Testing $phase ==="
  lacework iac policy test -d policies/opal/$phase
done

# Phase 3 (Environment & Business-Aware) - Extract only violation messages
lacework iac policy test -d policies/opal/phase3_environment_business_aware --json 2>/dev/null | \
  jq -r 'if .results then .results[] | select(.violations) | .violations[] else "No test results found" end // "No violations"'

# Get pass/fail summary
lacework iac policy test -d policies/opal/phase3_environment_business_aware --json 2>/dev/null | \
  jq -r 'if .summary then "✅ Passed: " + (.summary.passed // 0 | tostring) + " | ❌ Failed: " + (.summary.failed // 0 | tostring) else "No summary available" end'

# Show failures with resource names (safer version)
lacework iac policy test -d policies/opal/phase3_environment_business_aware --json 2>/dev/null | \
  jq -r 'if .results then .results[] | select(.result == "FAIL" and .violations) | "❌ " + (.resource // "unknown") + ": " + (.violations | join("; ")) else "No failures found" end'

# Run all phases with summary
for phase in phase1_traditional_iac phase2_enhanced_with_pac phase3_environment_business_aware; do
  echo "\n=== $phase Summary ==="
  lacework iac policy test -d policies/opal/$phase --json 2>/dev/null | \
    jq -r 'if .summary then "✅ Passed: " + (.summary.passed // 0 | tostring) + " | ❌ Failed: " + (.summary.failed // 0 | tostring) else "No summary available" end'
done
```

### 3. Quick Testing Commands

For daily use, these one-liners extract only what you need:

```bash
# Just show me the problems
lacework iac policy test -d policies/opal/phase3_environment_business_aware --json 2>/dev/null | jq -r '.results[]?.violations[]?'

# CI/CD pipeline check (exit code matters)
lacework iac policy test -d policies/opal/phase3_environment_business_aware --json 2>/dev/null | jq -e '.summary.failed == 0'
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
- Organizational-specific ports (8080, 9000, 8443) need the same protection as traditional ports
- Custom policies extend beyond what generic IaC tools provide
- Business-specific requirements can't be addressed by one-size-fits-all solutions
- Shows evolution from generic to organization-specific security rules

**Phase 3 Insights:**
- Same infrastructure configuration may pass/fail based on environment context
- Production environments require stricter controls than development
- Business function tags (customer-facing vs internal) affect security requirements
- Corporate CIDR enforcement ensures production traffic comes from approved networks
- Context-aware policies enable appropriate security posture across SDLC stages

### Real-World Applications

**Financial Services Example:**
A bank might allow custom application ports (8080) in development for testing, but require production applications to only accept traffic from corporate networks (203.0.113.0/24) to prevent unauthorized access to sensitive financial systems.

**Healthcare Organization Example:**
A healthcare provider could permit relaxed security group rules in development environments, but enforce that production systems handling PHI only accept connections from approved corporate CIDR ranges and have proper monitoring tags.

**E-commerce Platform Example:**
An online retailer might allow open access to custom application ports in development for rapid prototyping, but require production customer-facing applications to restrict access to corporate networks and include business function tags for compliance tracking.

---

## 🔧 Extending the Lab

### Adding Your Own Policies

1. Create a new directory under `policies/opal/your_policy_name/`
2. Add `metadata.yaml` with required properties (category, severity, title, description)
3. Create `terraform/policy.rego` with your OPAL policy logic
4. Add test cases in `terraform/tests/pass/main.tf` and `terraform/tests/fail/main.tf`
5. Include realistic Terraform configurations that mirror production scenarios

### Best Practices for Policy Development

1. **Start Simple**: Begin with basic allow/deny logic (Phase 1 approach)
2. **Add Organizational Context**: Include business-specific requirements (Phase 2 approach)
3. **Consider Environment**: Implement context-sensitive rules (Phase 3 approach)
4. **Test Thoroughly**: Create comprehensive pass/fail test cases for all scenarios
5. **Document Intent**: Clear comments explaining business logic and security rationale
6. **Use Meaningful Names**: Function names should reflect business context (`has_environment_business_violation`)
7. **Tag-Based Logic**: Leverage resource tags for environment and business function awareness

---

## 📝 Notes

- Policy logic lives in `policy.rego`
- Use `print()` for debugging, but avoid committing debug statements
- OPAL v0.3.5+ is recommended for print statement output support
