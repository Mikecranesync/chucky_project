# Contributing to Chucky

Thank you for your interest in contributing to the Chucky project! This document provides guidelines and workflows for contributing to n8n workflows in this repository.

## 📋 Table of Contents

- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Working with n8n Workflows](#working-with-n8n-workflows)
- [Issue-Based Development](#issue-based-development)
- [Pull Request Process](#pull-request-process)
- [Deployment Process](#deployment-process)
- [Code Standards](#code-standards)
- [Testing](#testing)

## 🚀 Getting Started

### Prerequisites

1. **n8n Instance** - Local or development n8n instance for testing
2. **Git** - Version control
3. **GitHub Account** - Access to this repository
4. **Required Credentials** - API keys for testing (Google Gemini, Supabase, etc.)

### Initial Setup

1. **Fork and Clone** (if external contributor):
```bash
git clone https://github.com/hharp/chucky_project.git
cd chucky_project
```

2. **Set up n8n locally**:
```bash
# Using npx
npx n8n

# Or using Docker
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n
```

3. **Import workflows** for testing:
   - Open n8n at http://localhost:5678
   - Go to Workflows → Import from File
   - Import the workflow you want to modify

## 🔄 Development Workflow

### Issue-Based Development

**All work should start with a GitHub Issue.** This ensures proper tracking and discussion.

#### 1. Create an Issue

Use the appropriate template:
- **🔧 New Workflow Request** - For new workflows
- **🐛 Bug Report** - For bugs
- **🚀 Deployment Checklist** - For deployments

#### 2. Get Assigned

Wait for issue to be triaged and assigned (or self-assign if you're a maintainer).

#### 3. Create Feature Branch

```bash
# Create branch from main
git checkout main
git pull origin main
git checkout -b feature/issue-123-add-telegram-bot

# Naming convention: <type>/<issue-number>-<short-description>
# Types: feature, bugfix, hotfix, refactor, docs
```

### Working with n8n Workflows

#### 1. Develop in n8n

1. Open your local n8n instance
2. Import the existing workflow (if modifying)
3. Make your changes in the visual editor
4. Test thoroughly with sample data
5. Add error handling and logging
6. Document complex nodes with annotations

#### 2. Export Workflow

1. In n8n, click **Download** on the workflow
2. Save to the repository directory
3. **Important:** Review the exported JSON before committing:
   - Remove any credential values
   - Verify no sensitive data is included
   - Check for hardcoded URLs or secrets

#### 3. Validate JSON

```bash
# Validate JSON syntax
jq empty ChuckyDiscordRAG.json && echo "✅ Valid JSON" || echo "❌ Invalid JSON"

# Check for credentials (should return nothing)
grep -rE "(sk-|api_key|token|password).*:.*\"[a-zA-Z0-9]{20,}\"" *.json
```

#### 4. Commit Changes

```bash
git add ChuckyDiscordRAG.json
git commit -m "feat: add image compression before Gemini analysis

- Reduces API costs by compressing large images
- Maintains image quality at 85%
- Adds error handling for compression failures
- Updates Discord response with compression status

Fixes #123"
```

**Commit Message Format:**
```
<type>: <short summary>

<detailed description>

<footer with issue references>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactoring
- `docs`: Documentation changes
- `chore`: Maintenance tasks
- `perf`: Performance improvements

#### 5. Push and Create PR

```bash
git push origin feature/issue-123-add-telegram-bot
```

Then create a Pull Request on GitHub.

## 📝 Pull Request Process

### PR Checklist

Before creating a PR, ensure:

- [ ] Workflow tested locally
- [ ] JSON validated (CI will also check)
- [ ] No credentials exposed
- [ ] Error handling implemented
- [ ] Complex logic documented
- [ ] Related issue linked in description
- [ ] Changes described clearly

### PR Template

```markdown
## Description
Brief description of changes made.

## Related Issue
Fixes #123

## Type of Change
- [ ] New workflow
- [ ] Bug fix
- [ ] Enhancement
- [ ] Refactoring
- [ ] Documentation

## Changes Made
- Added image compression node before Gemini analysis
- Implemented retry logic for API timeouts
- Updated error messages for better user feedback

## Testing
Tested with:
- Small images (<1MB): ✅ Passed
- Large images (>5MB): ✅ Passed, compressed successfully
- Invalid images: ✅ Error handled gracefully
- Gemini API timeout: ✅ Retry logic worked

## Screenshots (if applicable)
[Add screenshots of workflow changes]

## Deployment Notes
- No database changes required
- Requires Gemini API key
- No breaking changes

## Checklist
- [ ] Code follows project standards
- [ ] Self-review completed
- [ ] Changes tested locally
- [ ] Documentation updated
- [ ] No credentials exposed
```

### PR Review Process

1. **Automated Checks** run:
   - JSON validation
   - Credential scanning
   - Workflow structure verification

2. **Code Review**:
   - At least one approval required
   - Address all review comments
   - Make requested changes

3. **Merge**:
   - Squash and merge (preferred)
   - Delete branch after merge
   - Automatic deployment to staging happens

## 🚀 Deployment Process

### Staging Deployment

**Automatic** - Happens automatically when PR is merged to `main`:
1. Merge PR
2. GitHub Actions deploys to staging
3. Test in staging environment
4. Monitor for issues

### Production Deployment

**Manual via IssueOps** - Controlled deployment with approval:

1. **Create Deployment Issue**:
   - Use "🚀 Deployment Checklist" template
   - List workflows to deploy
   - Complete pre-deployment checklist

2. **Add Label**:
   - Add `deploy-to-prod` label to issue

3. **Approve Deployment**:
   - GitHub will request approval (production environment)
   - Approve when ready

4. **Monitor**:
   - Watch deployment progress in issue comments
   - Verify deployment success
   - Complete post-deployment checklist

5. **Verify**:
   - Test in production
   - Monitor for 24 hours
   - Close issue when verified

### Emergency Hotfix

For critical production issues:

```bash
# Create hotfix branch from main
git checkout main
git pull origin main
git checkout -b hotfix/critical-discord-timeout

# Make minimal fix
# Test locally
# Commit and push

git add .
git commit -m "hotfix: fix critical Discord timeout issue

Emergency fix for production issue causing Discord
bot to timeout on all requests.

Fixes #456"

git push origin hotfix/critical-discord-timeout

# Create PR with "priority:critical" label
# Fast-track review and merge
# Deploy immediately using IssueOps
```

## 📏 Code Standards

### n8n Workflow Best Practices

#### 1. Error Handling

Always include error handling:
- Use **Error Trigger** nodes for workflow-level errors
- Add **IF** nodes to check for null/undefined values
- Implement retry logic for API calls
- Provide meaningful error messages

#### 2. Naming Conventions

- **Workflows**: `PascalCase_With_Underscores.json`
- **Nodes**: Descriptive names (e.g., "Gemini - Analyze Image" not "HTTP Request 1")
- **Variables**: `camelCase` in code nodes

#### 3. Documentation

- Add **Sticky Notes** to explain complex logic
- Comment code in **Code nodes** with JSDoc style
- Document expected input/output formats
- Explain why, not just what

#### 4. Performance

- Use **Limit** nodes during development
- Batch operations where possible
- Implement pagination for large datasets
- Cache frequently accessed data
- Monitor execution time

#### 5. Security

- **Never hardcode credentials** - use n8n credential manager
- **Validate inputs** - especially from webhooks
- **Sanitize outputs** - prevent XSS in responses
- **Use HTTPS** for all external calls
- **Rotate credentials** regularly

### Code Node Standards

```javascript
/**
 * Parse Gemini AI response and extract category information
 * @param {object[]} items - Input items from previous node
 * @returns {object[]} Parsed category data
 */
const parseGeminiResponse = () => {
  const items = $input.all();
  const output = [];

  for (const item of items) {
    try {
      const response = item.json.response;

      // Extract JSON from response
      const jsonMatch = response.match(/\{[\s\S]*\}/);
      if (!jsonMatch) {
        throw new Error('No JSON found in response');
      }

      const data = JSON.parse(jsonMatch[0]);

      // Validate required fields
      if (!data.primaryCategory) {
        throw new Error('Missing primaryCategory');
      }

      output.push({
        json: {
          category: data.primaryCategory,
          subcategory: data.subcategory || 'uncategorized',
          confidence: parseInt(data.confidence) || 0,
          description: data.description || '',
          keywords: data.keywords || [],
          isIndustrial: data.isIndustrial || false
        }
      });
    } catch (error) {
      // Handle parse errors gracefully
      output.push({
        json: {
          category: 'error',
          error: error.message,
          rawResponse: item.json.response
        }
      });
    }
  }

  return output;
};

return parseGeminiResponse();
```

## 🧪 Testing

### Local Testing

1. **Test with Sample Data**:
   - Create test data that covers edge cases
   - Test null/undefined values
   - Test with invalid inputs
   - Test error conditions

2. **Test Error Handling**:
   - Disable API credentials temporarily
   - Simulate timeouts
   - Test with malformed data
   - Verify error messages are user-friendly

3. **Performance Testing**:
   - Test with minimum data
   - Test with maximum expected load
   - Monitor execution time
   - Check memory usage

### Integration Testing

After deployment to staging:
1. Test end-to-end user flows
2. Verify integrations (Discord, Telegram, etc.)
3. Check database writes
4. Verify webhooks fire correctly
5. Test with real API credentials

### Production Verification

After production deployment:
1. Monitor first executions closely
2. Check error rates
3. Verify metrics are normal
4. Test with real users (if applicable)
5. Monitor for 24 hours

## 🏷️ Labels

Use these labels for organization:

**Type:**
- `type:bug` - Bug fixes
- `type:feature` - New features
- `type:enhancement` - Improvements
- `type:documentation` - Documentation
- `type:security` - Security issues
- `type:deployment` - Deployments
- `type:maintenance` - Maintenance tasks

**Priority:**
- `priority:critical` - Production down
- `priority:high` - Major issue
- `priority:medium` - Normal priority
- `priority:low` - Nice to have

**Status:**
- `status:needs-triage` - Needs review
- `status:ready` - Ready for work
- `status:in-progress` - Being worked on
- `status:blocked` - Blocked
- `status:deployed` - Deployed to production

**Component:**
- `component:n8n` - n8n workflows
- `component:supabase` - Database
- `component:gemini` - AI integration
- `component:discord` - Discord bot
- `component:telegram` - Telegram bot

## 📞 Getting Help

- **Questions:** Create a GitHub Discussion
- **Bugs:** Create a Bug Report issue
- **Documentation:** Check CLAUDE.md and README.md
- **Deployment:** See GITHUB_SETUP.md

## 🙏 Thank You

Your contributions help make Chucky better for everyone. Thank you for taking the time to contribute!
