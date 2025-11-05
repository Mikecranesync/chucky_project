# Remote Access Security Guide

**Version:** 1.0.0
**Date:** 2025-11-04
**Purpose:** Security best practices for remote /chucky access

---

## Security Layers

### 1. User Authentication

**Telegram User Whitelist**
```javascript
// In Parse & Validate Command node
const ALLOWED_USER_IDS = [
  987654321  // Your Telegram ID
];
```

**Best Practices:**
- ✅ Get user ID from @userinfobot (official)
- ✅ Never share bot token publicly
- ✅ Use different bots for dev/production
- ✅ Limit to minimum necessary users
- ✅ Remove users when they leave team

**Getting User ID:**
1. Message @userinfobot on Telegram
2. Bot replies with your ID
3. Add to whitelist

---

### 2. Command Sanitization

**Prevents:** Shell injection attacks

**Implementation:**
```javascript
const sanitized = command
  .replace(/[;&|`$()]/g, '')  // Remove shell operators
  .replace(/\.\.\\//g, '')     // Remove directory traversal
  .trim();
```

**Blocked Characters:**
- `;` - Command separator
- `|` - Pipe operator
- `` ` `` - Command substitution
- `$` - Variable expansion
- `()` - Subshell
- `../` - Directory traversal

**Example:**
```
User sends: /chucky test; rm -rf /
Sanitized: /chucky test rm -rf /
Result: Harmless command, injection prevented
```

---

### 3. Rate Limiting

**Prevents:** API abuse, quota exhaustion, DDoS

**Limits:**
- 10 commands per 5 minutes per user
- Tracks in workflow static data
- Auto-resets after window expires

**Configuration:**
```javascript
const MAX_COMMANDS = 10;
const RATE_LIMIT_WINDOW = 5 * 60 * 1000; // 5 min
```

**For Production:** Store in Supabase for persistence across workflow restarts.

---

### 4. Audit Logging

**Purpose:** Track all activity, detect anomalies

**Logged Data:**
- User ID & username
- Command text
- Timestamp
- Platform (telegram/discord/ssh)
- Execution time
- Success/failure
- Error messages

**Storage:** Supabase `chucky_audit` table

**Monitoring Queries:**
```sql
-- Failed commands (potential attacks)
SELECT * FROM chucky_audit
WHERE success = false
ORDER BY timestamp DESC;

-- Suspicious activity (many commands)
SELECT user_id, COUNT(*) as cmd_count
FROM chucky_audit
WHERE timestamp > NOW() - INTERVAL '1 hour'
GROUP BY user_id
HAVING COUNT(*) > 50;

-- Commands from new users
SELECT DISTINCT user_id, username
FROM chucky_audit
WHERE timestamp > NOW() - INTERVAL '1 day';
```

---

### 5. SSH Security

**VPS Access Protection**

**Best Practices:**
- ✅ Use SSH keys (not passwords)
- ✅ Disable root login
- ✅ Change default SSH port (22 → custom)
- ✅ Install fail2ban (blocks brute force)
- ✅ Use firewall (UFW/iptables)
- ✅ Regular security updates

**Setup SSH Keys:**
```bash
# On local machine
ssh-keygen -t ed25519 -C "chucky-remote"

# Copy to VPS
ssh-copy-id root@n8n.maintpc.com

# On VPS, disable password auth
sudo nano /etc/ssh/sshd_config
# Set: PasswordAuthentication no
sudo systemctl restart sshd
```

**Install fail2ban:**
```bash
sudo apt install fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

---

### 6. API Key Security

**Protect Claude API Key**

**Storage:**
- ✅ Environment variables (not hardcoded)
- ✅ VPS `~/.bashrc` (chmod 600)
- ✅ n8n credentials (encrypted)

**Best Practices:**
- ✅ Rotate keys regularly (every 90 days)
- ✅ Use separate keys for dev/prod
- ✅ Monitor API usage in Anthropic dashboard
- ✅ Set spending limits
- ✅ Revoke compromised keys immediately

**Check for exposed keys:**
```bash
# Never commit these to git!
git grep -E "sk-ant-api|AIza|n8n_api"
```

---

### 7. Network Security

**VPS Firewall**

**Allow only necessary ports:**
```bash
# Install UFW
sudo apt install ufw

# Default: deny incoming, allow outgoing
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (custom port recommended)
sudo ufw allow 22/tcp

# Allow HTTPS (for n8n)
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable
```

**HTTPS for n8n:**
- ✅ Use Let's Encrypt SSL certificate
- ✅ Force HTTPS redirects
- ✅ Enable HSTS headers

---

### 8. Credential Management

**n8n Credentials**

**Best Practices:**
- ✅ Use credential types (not raw text)
- ✅ Set appropriate permissions
- ✅ Don't share between projects
- ✅ Audit credential usage
- ✅ Rotate regularly

**Telegram Bot Token:**
- ✅ Never commit to git
- ✅ Store in n8n credentials
- ✅ Revoke if compromised (message @BotFather `/revoke`)

---

### 9. Monitoring & Alerts

**Set Up Alerts**

**Monitor:**
- Failed authentication attempts
- Rate limit hits
- Unusual command patterns
- Error spikes
- Slow response times

**Alert Channels:**
- Email notifications
- Telegram alerts to admin channel
- Supabase edge functions
- External monitoring (UptimeRobot)

**Example Alert Query:**
```sql
-- Alert if > 5 failed commands in 10 min
SELECT COUNT(*) as failures
FROM chucky_audit
WHERE success = false
  AND timestamp > NOW() - INTERVAL '10 minutes';
-- If > 5, send alert
```

---

### 10. Data Privacy

**User Data Protection**

**Minimize Data Collection:**
- Only log necessary information
- Don't log sensitive command contents
- Anonymize user data when possible

**Compliance:**
- ✅ GDPR: Allow data deletion requests
- ✅ Retention: Auto-delete old logs (>90 days)
- ✅ Encryption: Use Supabase RLS policies

**Auto-delete old logs:**
```sql
-- Run monthly
DELETE FROM chucky_audit
WHERE timestamp < NOW() - INTERVAL '90 days';
```

---

## Security Checklist

### Initial Setup
- [ ] User whitelist configured
- [ ] Command sanitization enabled
- [ ] Rate limiting active
- [ ] Audit logging to Supabase
- [ ] SSH keys configured
- [ ] Bot token secured
- [ ] API keys in environment variables
- [ ] Firewall configured
- [ ] HTTPS enabled
- [ ] fail2ban installed

### Regular Maintenance (Monthly)
- [ ] Review audit logs
- [ ] Check for failed authentications
- [ ] Update VPS packages
- [ ] Rotate API keys (quarterly)
- [ ] Review user whitelist
- [ ] Clean old audit logs
- [ ] Check API usage/costs
- [ ] Test backup restore

### Incident Response
- [ ] Document security incidents
- [ ] Revoke compromised credentials
- [ ] Review audit logs for affected period
- [ ] Notify affected users
- [ ] Update security measures
- [ ] Post-mortem analysis

---

## Common Vulnerabilities

### ❌ Avoid These Mistakes

**1. Hardcoded Credentials**
```javascript
// DON'T DO THIS!
const API_KEY = "sk-ant-api12345...";
```

**2. No Rate Limiting**
- Allows API abuse
- Can exhaust quotas
- Costs money

**3. Weak User Whitelist**
```javascript
// DON'T DO THIS!
const ALLOWED_USER_IDS = [];  // Empty = anyone!
```

**4. Disabled Audit Logging**
- Can't detect breaches
- No forensic trail

**5. Using HTTP (not HTTPS)**
- Man-in-the-middle attacks
- Credentials exposed

**6. Root SSH Access**
- Single point of failure
- No user accountability

**7. Default Passwords**
- Easily guessed
- Bot Father token leaked

---

## Security Incident Response

### If Compromised

**1. Immediate Actions:**
```
1. Deactivate n8n workflow
2. Revoke bot token (@BotFather `/revoke`)
3. Rotate API keys
4. Change VPS passwords
5. Check audit logs for damage
```

**2. Investigation:**
```sql
-- Check commands from suspicious user
SELECT * FROM chucky_audit
WHERE user_id = 'SUSPICIOUS_ID'
ORDER BY timestamp DESC;

-- Check failed authentications
SELECT * FROM chucky_audit
WHERE success = false
  AND timestamp > 'INCIDENT_TIME';
```

**3. Recovery:**
- Create new bot with @BotFather
- Generate new API keys
- Update all credentials in n8n
- Add additional security measures
- Document incident

**4. Prevention:**
- Update whitelists
- Strengthen rate limits
- Enable additional logging
- Set up alerts

---

## Production Hardening

### For High-Security Environments

**Additional Measures:**
1. **Two-Factor Authentication**
   - Require confirmation code
   - Time-based OTP

2. **IP Whitelisting**
   - Only allow from known IPs
   - VPN required

3. **Command Approval**
   - Require approval for destructive operations
   - Multi-user sign-off

4. **Encrypted Communications**
   - E2E encryption for sensitive data
   - Encrypted at rest in Supabase

5. **Regular Security Audits**
   - Penetration testing
   - Code reviews
   - Dependency scanning

6. **Disaster Recovery**
   - Regular backups
   - Failover systems
   - Incident response plan

---

## Resources

### Security Tools
- **SSH Hardening:** https://www.ssh.com/academy/ssh/security
- **fail2ban:** https://github.com/fail2ban/fail2ban
- **UFW Guide:** https://help.ubuntu.com/community/UFW
- **Let's Encrypt:** https://letsencrypt.org/

### Best Practices
- OWASP Top 10: https://owasp.org/www-project-top-ten/
- API Security: https://apisecurity.io/
- SSH Best Practices: https://infosec.mozilla.org/guidelines/openssh

### Monitoring
- UptimeRobot: https://uptimerobot.com/
- Datadog: https://www.datadoghq.com/
- Sentry: https://sentry.io/

---

**Version:** 1.0.0
**Last Updated:** 2025-11-04
**Maintain:** Regular security reviews
**Contact:** Security issues → GitHub issues (private)
