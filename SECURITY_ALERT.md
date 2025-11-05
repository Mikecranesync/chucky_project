# 🚨 SECURITY ALERT - Exposed Credentials

**Date:** 2025-11-05
**Severity:** CRITICAL
**Status:** CREDENTIALS SANITIZED FROM DOCS - ROTATION REQUIRED

## Executive Summary

Discord bot credentials were found exposed in `DISCORD_SETUP_GUIDE.md`. The credentials have been removed from the documentation, but **MUST BE ROTATED IMMEDIATELY** in the Discord Developer Portal.

## Exposed Credentials

### 1. Discord Bot Token (CRITICAL)
**Location:** `DISCORD_SETUP_GUIDE.md` (lines 107, 191 - now removed)
**Value:** `MTQzNTAzMTIyMDAwOTMwNDA4NA.G6k_Mo.2vNKlcDlvaU2Ad6SbJibfb6wasdfkV2iWt2Kpg`
**Action Required:** ✅ IMMEDIATE ROTATION

### 2. Discord Client Secret (CRITICAL)
**Location:** `DISCORD_SETUP_GUIDE.md` (line 164 - now removed)
**Value:** `GeBfl2HHV8zgr415c9YKOaMXBuBPSEzp`
**Action Required:** ✅ IMMEDIATE ROTATION

### 3. Discord IDs (Low Risk - Public Information)
These are not secrets but have been sanitized for cleanliness:
- **Client ID / Application ID:** 1435031220009304084
- **Server (Guild) ID:** 1435030211442770002
- **Channel IDs:** Various (removed from docs)

**Note:** These IDs are not considered secrets as they're visible to anyone who has access to the Discord server or uses the bot. However, they've been removed to follow security best practices.

## Immediate Actions Required

### Step 1: Rotate Discord Bot Token (5 minutes)

1. Go to https://discord.com/developers/applications
2. Select your Chucky AI Bot application
3. Click **Bot** in left sidebar
4. Scroll to **Token** section
5. Click **Reset Token**
6. Click **Yes, do it!** to confirm
7. Click **Copy** to copy the new token
8. **IMMEDIATELY** store the new token in:
   - n8n Cloud → Credentials → Discord OAuth2 (update token)
   - Local `.env` file (if testing locally)
   - Password manager for backup
9. ✅ Mark this step complete when done

### Step 2: Regenerate Client Secret (5 minutes)

1. Still in Discord Developer Portal
2. Click **OAuth2** in left sidebar
3. Click **General** sub-tab
4. In **Client Secret** section, click **Reset Secret**
5. Click **Yes, do it!** to confirm
6. Click **Copy** to copy the new secret
7. **IMMEDIATELY** store the new secret in:
   - n8n Cloud → Credentials → Discord OAuth2 (update client secret)
   - Local `.env` file (if testing locally)
   - Password manager for backup
8. ✅ Mark this step complete when done

### Step 3: Update n8n Cloud Credentials (2 minutes)

1. Log into https://app.n8n.cloud
2. Go to **Credentials**
3. Find your Discord OAuth2 credential
4. Click **Edit**
5. Update:
   - Bot Token: [new token from Step 1]
   - Client Secret: [new secret from Step 2]
6. Click **Save**
7. Test by running a workflow with Discord node
8. ✅ Mark this step complete when done

### Step 4: Update Local Environment File (1 minute)

If you have a local `.env` file:

1. Open `.env` file
2. Update:
   ```
   DISCORD_BOT_TOKEN=[new token from Step 1]
   DISCORD_CLIENT_SECRET=[new secret from Step 2]
   ```
3. Save file
4. **NEVER commit .env to Git**
5. ✅ Mark this step complete when done

## What Was Done to Mitigate

### Documentation Sanitized
✅ `DISCORD_SETUP_GUIDE.md` - Removed all exposed credentials
✅ `.env.example` - Updated with proper placeholders
✅ Created this security alert document

### Next Steps After Rotation
1. Update `INFRASTRUCTURE_STATUS.md` with credential rotation date
2. Set calendar reminder to rotate again in 90 days
3. Consider implementing automated rotation
4. Review other documentation files for exposed secrets
5. Add pre-commit hooks to prevent future credential exposure

## Prevention Measures

### Already Implemented
- ✅ `.env.example` template created (no real values)
- ✅ `.gitignore` includes `.env`
- ✅ Documentation updated to reference environment variables
- ✅ GitHub Actions security scanning enabled

### To Implement
- [ ] Add pre-commit hooks to scan for secrets (using tools like `detect-secrets`)
- [ ] Set up credential rotation reminders (90-day cycle)
- [ ] Implement secret scanning in CI/CD
- [ ] Document credential storage policy
- [ ] Train team on security best practices

## Timeline

| Date | Event |
|------|-------|
| Unknown | Credentials exposed in documentation |
| 2025-11-05 | Credentials discovered during security audit |
| 2025-11-05 | Documentation sanitized |
| **PENDING** | **Credentials rotated in Discord Developer Portal** |
| **PENDING** | **n8n Cloud credentials updated** |

## Risk Assessment

**Before Rotation:**
- 🔴 **CRITICAL RISK** - Bot token and client secret exposed in documentation
- Anyone with read access to this repository could use these credentials
- Potential for unauthorized Discord bot actions
- Potential for service disruption

**After Rotation:**
- 🟡 **LOW RISK** - Old credentials invalidated
- Documentation sanitized
- Security scanning enabled
- Future exposure risk minimized

## Verification Checklist

After completing all steps above, verify:

- [ ] Old bot token no longer works (test with curl)
- [ ] Old client secret no longer works
- [ ] New credentials work in n8n Cloud
- [ ] Discord bot responds to test commands
- [ ] No errors in n8n workflow executions
- [ ] This document moved to archive/ folder
- [ ] Credential rotation date documented in INFRASTRUCTURE_STATUS.md

## Contact & Support

If you have questions or need help:
- Discord Developer Support: https://discord.com/developers/docs/intro
- n8n Community: https://community.n8n.io
- Security issues: Create GitHub issue with label `type:security`

---

**IMPORTANT:** Complete Steps 1-4 immediately, then archive this document. Do not commit real credentials to Git.
