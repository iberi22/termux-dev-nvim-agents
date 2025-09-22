# 🔧 Repository CI/CD Setup Guide

This guide walks you through setting up the complete CI/CD automation for the Termux AI Setup repository.

## 📋 Prerequisites

- GitHub repository with admin access
- Git configured locally
- Basic command line knowledge

## 🚀 Quick Setup (Recommended)

### 1. Run Automated Setup

```bash
# Clone the repository (if not already done)
git clone https://github.com/iberi22/termux-dev-nvim-agents.git
cd termux-dev-nvim-agents

# Run comprehensive setup
bash scripts/setup-repo.sh

# Verify everything is configured
bash scripts/verify-setup.sh
```

### 2. Enable GitHub Integrations

#### CodeRabbit (AI Code Reviews) - **FREE for Open Source**

1. Visit [coderabbit.ai](https://app.coderabbit.ai/login)
2. Sign up with your GitHub account
3. Install CodeRabbit app for the repository
4. Configuration is already in `.coderabbit.yml` - no additional setup needed
5. CodeRabbit will automatically review PRs and create issues

#### GitHub Actions Permissions

1. Go to repository **Settings** → **Actions** → **General**
2. Set **Workflow permissions** to **"Read and write permissions"**
3. Enable **"Allow GitHub Actions to create and approve pull requests"**
4. Save changes

### 3. Configure Branch Protection

1. Go to repository **Settings** → **Branches**
2. Add rule for `main` branch:
   - ✅ **Require status checks to pass before merging**
   - ✅ **Require branches to be up to date before merging**
   - Select status checks: `Shell Lint & Syntax`, `Metadata Sanity Check`
   - ✅ **Require review from code owners** (optional)
   - ✅ **Dismiss stale reviews when new commits are pushed**
   - ✅ **Allow auto-merge**

### 4. Set Up Repository Labels

Add these labels in **Issues** → **Labels**:

| Label | Color | Description |
|-------|-------|-------------|
| `auto-merge` | `#00ff00` | PRs eligible for auto-merge |
| `ci-fix` | `#ff9900` | Automated CI fixes |
| `coderabbit-created` | `#6f42c1` | Issues created by CodeRabbit |
| `build failed` | `#ff0000` | CI build failure notifications |
| `enhancement` | `#84b6eb` | Feature requests/improvements |
| `bug` | `#fc2929` | Bug reports |

## 🛠️ Manual Setup (Step by Step)

### File Structure Overview

```
.github/
├── workflows/
│   ├── ci.yml              # Main CI pipeline
│   └── auto-deploy.yml     # Auto-merge and deployment
├── .coderabbit.yml         # CodeRabbit configuration
├── .shellcheckrc           # ShellCheck linting rules
├── scripts/
│   ├── lint.sh             # Local linting script
│   ├── pre-commit.sh       # Git pre-commit hook
│   ├── setup-repo.sh       # Complete repository setup
│   └── verify-setup.sh     # Setup verification
└── tests/
    └── bats/               # Bats test framework
        ├── test_core.bats
        ├── test_ssh_module.bats
        ├── test_integration.bats
        └── test_helper.bash
```

### 1. Core CI Pipeline (`.github/workflows/ci.yml`)

**Features:**
- Shell script linting with ShellCheck
- Syntax validation for all scripts
- Metadata and structure checks
- Comprehensive Bats testing
- Automatic issue creation on failures (main branch only)

**Key Components:**
- `jayqi/failed-build-issue-action@v1` for issue creation
- Custom ShellCheck configuration
- Bats test framework integration
- Conditional logic to avoid PR noise

### 2. Auto-Deployment (`.github/workflows/auto-deploy.yml`)

**Features:**
- Automatic PR merging when CI passes
- Auto-merge based on labels and title patterns
- Automated fix PR creation on CI failures
- Issue status management

**Trigger Conditions:**
- PR has `auto-merge` label OR
- PR title contains `[auto-merge]` OR
- PR created by `dependabot` OR
- PR has `ci-fix` label (automated fixes)

### 3. CodeRabbit Integration (`.coderabbit.yml`)

**Features:**
- AI-powered code reviews
- Shell scripting expertise
- Security vulnerability detection
- Custom rule sets for bash best practices
- Automatic issue creation for improvements

**Configuration:**
- Enhanced security analysis
- Shell script specific rules
- Bug and improvement templates
- Auto-review for open source repositories

### 4. Local Development Tools

#### ShellCheck Configuration (`.shellcheckrc`)
```bash
# Disable common false positives
disable=SC1091,SC2034,SC2086,SC2162,SC2016
format=gcc
```

#### Local Linting (`scripts/lint.sh`)
- Comprehensive shellcheck with color output
- Error counting and success rate calculation
- File-by-file processing with detailed reporting

#### Pre-commit Hook (`scripts/pre-commit.sh`)
```bash
#!/usr/bin/env bash
exec bash scripts/lint.sh --staged
```

### 5. Test Framework (`tests/bats/`)

**Test Suites:**
- **Core Tests** (`test_core.bats`): Basic functionality, file existence, syntax
- **SSH Module Tests** (`test_ssh_module.bats`): SSH-specific functionality
- **Integration Tests** (`test_integration.bats`): CI/CD and repository structure

**Helper Functions** (`test_helper.bash`):
- Mock Termux environment
- Syntax checking utilities
- Test setup and teardown

## 🎯 Usage Examples

### Development Workflow

1. **Make Changes Locally:**
   ```bash
   # Edit files
   vim modules/05-ssh-setup.sh
   
   # Lint locally before commit
   bash scripts/lint.sh
   
   # Run tests
   bats tests/bats/*.bats
   ```

2. **Create Pull Request:**
   ```bash
   git checkout -b feature/new-ssh-helper
   git add .
   git commit -m "Add new SSH helper functionality"
   git push origin feature/new-ssh-helper
   
   # Create PR with auto-merge label for automatic merging
   gh pr create --title "[auto-merge] Add SSH helper" --body "Automated improvement"
   ```

3. **Automated Process:**
   - CodeRabbit reviews the PR automatically
   - CI pipeline runs all tests and linting
   - If CI passes and conditions are met → **Auto-merge**
   - If CI fails → **Automatic issue creation**

### CI Failure Handling

When CI fails on the main branch:

1. **Automatic Issue Creation:**
   - GitHub issue created with failure details
   - Labels: `build failed`, `coderabbit-created`
   - Includes logs, error context, and suggested fixes

2. **Fix Workflow:**
   - Make fixes locally
   - Create PR with `ci-fix` label for auto-merge
   - CI validates fix → Auto-merge if successful

3. **Issue Resolution:**
   - Successful merge automatically closes related issues
   - Status updates posted to issue comments

## 🔍 Monitoring and Maintenance

### Check CI Status
```bash
# View recent workflow runs
gh run list

# Check specific workflow status  
gh run view [run-id]

# Re-run failed workflows
gh run rerun [run-id]
```

### Local Quality Checks
```bash
# Comprehensive linting
bash scripts/lint.sh

# Test all components
bats tests/bats/*.bats

# Verify complete setup
bash scripts/verify-setup.sh
```

### CodeRabbit Management
- Monitor reviews at [app.coderabbit.ai](https://app.coderabbit.ai)
- Adjust configuration in `.coderabbit.yml` as needed
- Review created issues and integrate feedback

## 🚨 Troubleshooting

### Common Issues

1. **CI Fails with Permission Errors:**
   - Check GitHub Actions permissions (Step 2 above)
   - Ensure GITHUB_TOKEN has write access

2. **CodeRabbit Not Reviewing:**
   - Verify app installation for repository
   - Check `.coderabbit.yml` syntax
   - Ensure repository is public (for free tier)

3. **Auto-merge Not Working:**
   - Check branch protection rules
   - Verify PR has correct labels
   - Ensure CI status checks are passing

4. **ShellCheck Issues:**
   - Review `.shellcheckrc` configuration
   - Update exclusions if needed
   - Test locally with `bash scripts/lint.sh`

### Debug Commands
```bash
# Check workflow syntax
yamllint .github/workflows/*.yml

# Validate GitHub Actions locally (if act installed)
act -n

# Test Bats framework
bats --version
bats tests/bats/test_core.bats --verbose

# Verify git hooks
ls -la .git/hooks/
```

## 📈 Advanced Configuration

### Custom Issue Templates
Edit `.coderabbit.yml` to customize issue creation:
```yaml
issue_creation:
  bug_template: |
    ## 🐛 Bug Report
    **Description:** {{ description }}
    **Files:** {{ files }}
    **Suggestions:** {{ suggestions }}
```

### Enhanced Branch Protection
Add additional status checks:
- `CodeQL` (for security scanning)
- `Dependency Review` (for security vulnerabilities)
- Custom status checks from third-party tools

### Notification Configuration
Configure Slack/Discord notifications:
```yaml
# In .github/workflows/ci.yml
- name: Notify Team
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## ✅ Completion Checklist

After setup, verify these items:

- [ ] `bash scripts/verify-setup.sh` passes all checks
- [ ] CodeRabbit app installed and reviewing PRs
- [ ] GitHub Actions have proper permissions
- [ ] Branch protection rules configured
- [ ] Repository labels created
- [ ] Pre-commit hooks working locally
- [ ] Test suite runs successfully
- [ ] CI pipeline creates issues on failures
- [ ] Auto-merge works for eligible PRs

## 🎉 Success Indicators

Your setup is complete when:

1. **Green CI Badge:** [![CI](https://github.com/user/repo/actions/workflows/ci.yml/badge.svg)](https://github.com/user/repo/actions/workflows/ci.yml)
2. **CodeRabbit Reviews:** Automatic PR reviews appear
3. **Auto-merge Works:** PRs merge automatically when conditions are met
4. **Issues Created:** CI failures automatically create detailed issues
5. **Local Tools Work:** `bash scripts/lint.sh` runs successfully

---

**🚀 Congratulations! You now have enterprise-level CI/CD automation for your Termux AI Setup repository.**

For questions or issues, create a GitHub issue or check the troubleshooting section above.
