# Docker VPS Setup for Chucky (n8n)

This guide shows you how to deploy your Chucky workflow on a VPS using Docker.

## Prerequisites

### VPS Requirements
- **OS**: Ubuntu 22.04 LTS (recommended)
- **RAM**: Minimum 2GB, Recommended 4GB+
- **Storage**: 20GB+ SSD
- **CPU**: 2 cores minimum
- **Providers**: DigitalOcean, Linode, Vultr, AWS EC2, etc.

### What You Need
- Domain name (for SSL/HTTPS access)
- VPS with root/sudo access
- SSH access to your VPS

## Quick Start (Copy-Paste Commands)

### Step 1: Connect to Your VPS

```bash
ssh root@your-vps-ip
```

### Step 2: Install Docker & Docker Compose

```bash
# Update system
apt update && apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
apt install docker-compose -y

# Verify installation
docker --version
docker-compose --version
```

### Step 3: Create n8n Directory Structure

```bash
# Create project directory
mkdir -p ~/n8n-chucky
cd ~/n8n-chucky

# Create data directories
mkdir -p .n8n
```

### Step 4: Create Docker Compose File

Create `docker-compose.yml`:

```bash
nano docker-compose.yml
```

Paste the configuration from the `docker-compose.yml` file in this directory.

### Step 5: Create Environment File

Create `.env`:

```bash
nano .env
```

Paste the configuration from the `.env.example` file in this directory.

### Step 6: Start n8n

```bash
# Start n8n in detached mode
docker-compose up -d

# Check logs
docker-compose logs -f n8n
```

### Step 7: Access n8n

- **Without SSL**: `http://your-vps-ip:5678`
- **With SSL**: `https://your-domain.com` (after setting up Traefik)

## Detailed Setup

### Option 1: Basic Setup (HTTP Only - Quick Test)

Use this for testing or internal networks:

```yaml
# docker-compose.yml
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=${N8N_USER}
      - N8N_BASIC_AUTH_PASSWORD=${N8N_PASSWORD}
      - N8N_HOST=${N8N_HOST}
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - NODE_ENV=production
      - WEBHOOK_URL=http://${N8N_HOST}:5678/
      - GENERIC_TIMEZONE=${TIMEZONE}
    volumes:
      - ./n8n_data:/home/node/.n8n
      - ./workflows:/home/node/.n8n/workflows
```

**.env file:**
```bash
N8N_USER=admin
N8N_PASSWORD=your-secure-password-here
N8N_HOST=your-vps-ip
TIMEZONE=America/New_York
```

### Option 2: Production Setup (HTTPS with Traefik)

**Recommended for production use with SSL/HTTPS**

Full configuration in `docker-compose.production.yml` and `.env.production.example`

---

## Import Chucky Workflow

### Method 1: Upload via UI

1. Access n8n at `http://your-vps-ip:5678`
2. Login with credentials from `.env`
3. Go to **Workflows** → **Import from File**
4. Upload `Chucky (30).json`

### Method 2: Copy File to VPS

```bash
# On your local machine
scp "C:\Users\hharp\chucky_project\Chucky (30).json" root@your-vps-ip:~/n8n-chucky/workflows/

# On VPS, restart n8n
cd ~/n8n-chucky
docker-compose restart n8n
```

---

## Configure Credentials

After importing the workflow, configure these credentials in n8n:

### 1. Google Drive OAuth2
- **Type**: OAuth2
- **Credential name**: Google Drive account 7
- **Setup**: Follow n8n's Google OAuth setup guide
- **Scopes needed**: `drive.readonly`, `drive.file`

### 2. Google Gemini/PaLM API
- **Type**: API Key
- **Credential name**: Google Gemini(PaLM) Api account 3
- **API Key**: Get from Google AI Studio
- **URL**: https://aistudio.google.com/app/apikey

### 3. Supabase API
- **Type**: Header Auth
- **Credential name**: Supabase account
- **URL**: Your Supabase project URL
- **API Key**: Your Supabase anon key
- **Headers**:
  - `apikey`: Your Supabase anon key
  - `Authorization`: `Bearer your-supabase-anon-key`

### 4. Postgres (for chat memory)
- **Type**: Postgres
- **Credential name**: Postgres account
- **Host**: Your Postgres host (Supabase provides this)
- **Database**: postgres
- **User**: postgres
- **Password**: Your Supabase database password
- **Port**: 5432

### 5. xAI (for Chucky's Brain)
- **Type**: API Key
- **Credential name**: xAi account
- **API Key**: Get from xAI platform

---

## Setup SSL/HTTPS (Production)

### Using Traefik (Recommended)

See `docker-compose.production.yml` for full Traefik configuration.

**Quick Setup:**

1. Point your domain to VPS IP
2. Update `.env.production`:
   ```bash
   DOMAIN_NAME=n8n.yourdomain.com
   LETS_ENCRYPT_EMAIL=you@email.com
   ```
3. Start with production config:
   ```bash
   docker-compose -f docker-compose.production.yml up -d
   ```
4. Access at: `https://n8n.yourdomain.com`

### Using Nginx Reverse Proxy

Alternative to Traefik - see `nginx.conf.example` for configuration.

---

## Useful Commands

### Start/Stop n8n
```bash
cd ~/n8n-chucky

# Start
docker-compose up -d

# Stop
docker-compose down

# Restart
docker-compose restart

# View logs
docker-compose logs -f n8n

# View last 100 lines
docker-compose logs --tail=100 n8n
```

### Backup Workflows
```bash
# Backup entire n8n data directory
tar -czf n8n-backup-$(date +%Y%m%d).tar.gz .n8n/

# Download to local machine
scp root@your-vps-ip:~/n8n-chucky/n8n-backup-*.tar.gz .
```

### Update n8n
```bash
cd ~/n8n-chucky

# Pull latest image
docker-compose pull

# Restart with new image
docker-compose up -d
```

### Monitor Resources
```bash
# Check Docker stats
docker stats n8n

# Check disk usage
df -h

# Check memory
free -h
```

---

## Firewall Configuration

### Ubuntu UFW
```bash
# Allow SSH (important!)
ufw allow 22/tcp

# Allow HTTP/HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# If using basic setup (HTTP only)
ufw allow 5678/tcp

# Enable firewall
ufw enable
```

---

## Troubleshooting

### Issue: Can't access n8n

**Check if container is running:**
```bash
docker ps
```

**Check logs:**
```bash
docker-compose logs n8n
```

**Verify port is open:**
```bash
netstat -tulpn | grep 5678
```

### Issue: Webhook URLs not working

**Update environment variables:**
```bash
# Edit .env
WEBHOOK_URL=https://your-domain.com/
N8N_PROTOCOL=https
N8N_HOST=your-domain.com
```

**Restart:**
```bash
docker-compose restart
```

### Issue: Out of memory

**Check resources:**
```bash
docker stats n8n
free -h
```

**Increase swap:**
```bash
# Create 2GB swap
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

### Issue: SSL certificate errors

**Check Traefik logs:**
```bash
docker-compose logs traefik
```

**Verify DNS:**
```bash
dig your-domain.com
```

**Force certificate renewal:**
```bash
docker-compose down
rm -rf ./letsencrypt/acme.json
docker-compose up -d
```

---

## Security Best Practices

### 1. Change Default Passwords
```bash
# Generate strong password
openssl rand -base64 32

# Update .env
N8N_PASSWORD=generated-password-here
```

### 2. Enable Two-Factor Authentication
- Use Google Drive OAuth with MFA
- Use Supabase with MFA enabled

### 3. Restrict Access
```bash
# Allow only specific IP
ufw allow from your-ip-address to any port 5678
```

### 4. Regular Backups
```bash
# Add to crontab
crontab -e

# Daily backup at 2 AM
0 2 * * * cd ~/n8n-chucky && tar -czf /backups/n8n-$(date +\%Y\%m\%d).tar.gz .n8n/
```

### 5. Update Regularly
```bash
# Monthly updates
apt update && apt upgrade -y
docker-compose pull
docker-compose up -d
```

---

## Performance Optimization

### 1. Increase Memory Limit
```yaml
# In docker-compose.yml
services:
  n8n:
    deploy:
      resources:
        limits:
          memory: 4G
        reservations:
          memory: 2G
```

### 2. Use PostgreSQL for Queue Mode
For high-volume workflows, use queue mode with external PostgreSQL.

### 3. Enable Caching
```bash
# Add to .env
N8N_CACHE_ENABLED=true
```

---

## Cost Estimates

### VPS Monthly Costs

| Provider | Plan | RAM | Storage | Price |
|----------|------|-----|---------|-------|
| DigitalOcean | Basic | 2GB | 50GB | $12/mo |
| DigitalOcean | Performance | 4GB | 80GB | $24/mo |
| Linode | Nanode | 1GB | 25GB | $5/mo |
| Linode | Standard | 4GB | 80GB | $24/mo |
| Vultr | Regular | 2GB | 55GB | $12/mo |
| Vultr | High Frequency | 4GB | 128GB | $24/mo |

**Recommended**: 4GB RAM plan for production use ($24/mo)

### Additional Costs
- **Domain**: $10-15/year
- **Google Gemini API**: Pay-per-use (varies)
- **Supabase**: Free tier available, Pro at $25/mo
- **Backups**: $5-10/mo (optional)

**Total Estimated Monthly**: $25-50

---

## Next Steps After Setup

1. ✅ Import Chucky workflow
2. ✅ Configure all credentials
3. ✅ Test with 1-2 sample images
4. ✅ Set up automated backups
5. ✅ Configure monitoring/alerts
6. ✅ Enable SSL/HTTPS
7. ✅ Test webhook triggers

---

## Support Resources

- **n8n Docs**: https://docs.n8n.io/
- **n8n Community**: https://community.n8n.io/
- **Docker Docs**: https://docs.docker.com/
- **Chucky Project**: See CLAUDE.md for workflow documentation

---

## Quick Reference

**Start n8n:**
```bash
cd ~/n8n-chucky && docker-compose up -d
```

**View logs:**
```bash
docker-compose logs -f n8n
```

**Restart:**
```bash
docker-compose restart
```

**Stop:**
```bash
docker-compose down
```

**Backup:**
```bash
tar -czf n8n-backup.tar.gz .n8n/
```

**Update:**
```bash
docker-compose pull && docker-compose up -d
```
