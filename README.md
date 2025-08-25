# DM is Blogging - Ghost Blog Infrastructure

Production-ready Ghost blog with enterprise-grade infrastructure on Google Cloud Platform.

**Live Site**: https://blog.itsdanmanole.com  
**Admin Panel**: https://blog.itsdanmanole.com/ghost/  
**Project**: `your-project-id`  
**Region**: `your-preferred-region` (e.g. Montreal)

---

## 🏗️ Architecture Overview

```
Internet → Cloudflare DNS → Google Load Balancer → Cloud CDN → Ghost VM → Ghost CMS
```

### Infrastructure Components

- **VM Instance**: `ghost-blog-vm` (e2-medium, Ubuntu 24.04)
- **Ghost Version**: v6.0.5 (Node.js 22.18.0)
- **Database**: SQLite (`ghost-local.db`)
- **Web Server**: Nginx (reverse proxy)
- **SSL**: Google-managed certificates (auto-renewal)
- **CDN**: Google Cloud CDN (global caching)
- **Load Balancer**: Google Cloud Load Balancer
- **DNS**: Cloudflare → Google Cloud

---

## 📋 Current Configuration

### Domain Configuration
- **Primary Domain**: `blog.itsdanmanole.com`
- **Root Domain**: `itsdanmanole.com` (redirects to blog subdomain)
- **SSL Certificate**: Covers both domains
- **DNS**: A records point to Load Balancer IP `YOUR_LB_IP`

### VM Details
- **Instance**: `your-vm-name`
- **Zone**: `your-zone`
- **Machine Type**: `e2-medium` (2 vCPU, 4GB RAM)
- **Static IP**: `YOUR_VM_IP`
- **OS**: Ubuntu 24.04.3 LTS

### Ghost Configuration
```json
{
  "url": "https://blog.itsdanmanole.com",
  "server": {
    "port": 2368,
    "host": "0.0.0.0"
  },
  "database": {
    "client": "sqlite3",
    "connection": {
      "filename": "/var/www/ghost/content/data/ghost-local.db"
    }
  },
  "process": "local"
}
```

---

## 🚀 Quick Commands

### SSH to VM
```bash
gcloud compute ssh your-vm-name --zone=your-zone
```

### Ghost Management
```bash
cd /var/www/ghost

# Check status
ghost status

# Start/stop/restart
ghost start --development
ghost stop
ghost restart

# View logs
ghost log
```

### Cache Management
```bash
# Clear entire CDN cache
gcloud compute url-maps invalidate-cdn-cache ghost-url-map --path="/*"

# Clear homepage only
gcloud compute url-maps invalidate-cdn-cache ghost-url-map --path="/"

# Clear specific post
gcloud compute url-maps invalidate-cdn-cache ghost-url-map --path="/post-slug/"
```

### Nginx Management
```bash
# Test configuration
sudo nginx -t

# Reload configuration
sudo systemctl reload nginx

# Check status
sudo systemctl status nginx
```

---

## 🔧 Common Operations

### Publishing Posts
1. Create/edit posts in Ghost Admin
2. Publish posts → appear immediately
3. If posts don't appear, clear CDN cache:
   ```bash
   gcloud compute url-maps invalidate-cdn-cache ghost-url-map --path="/"
   ```

### Deleting Posts
1. Delete from Ghost Admin
2. Clear cache for both post and homepage:
   ```bash
   gcloud compute url-maps invalidate-cdn-cache ghost-url-map --path="/post-slug/"
   gcloud compute url-maps invalidate-cdn-cache ghost-url-map --path="/"
   ```
3. **Auto-cleanup**: Posts disappear automatically within 30 minutes

### Theme Changes
1. Upload/activate theme in Ghost Admin
2. If theme doesn't appear, restart Ghost:
   ```bash
   cd /var/www/ghost
   ghost restart
   ```
3. Clear CDN cache:
   ```bash
   gcloud compute url-maps invalidate-cdn-cache ghost-url-map --path="/*"
   ```

---

## 🛡️ Security & Performance

### Security Features
- ✅ **Firewall**: Only ports 80/443 exposed (port 2368 blocked)
- ✅ **SSL/TLS**: Google-managed certificates with auto-renewal
- ✅ **Security Headers**: HSTS, XSS protection, content-type validation
- ✅ **Auto-updates**: System security patches enabled

### Performance Optimizations
- ✅ **Global CDN**: Cloud CDN with 30-minute cache
- ✅ **Load Balancer**: Google's global infrastructure
- ✅ **Gzip Compression**: Enabled for text content
- ✅ **Asset Caching**: 1-year cache for static files
- ✅ **Health Checks**: Automatic failover if issues occur

### Cache Configuration
- **Default TTL**: 30 minutes
- **Maximum TTL**: 1 hour
- **Client TTL**: 30 minutes
- **Static Assets**: 1 year cache

---

## 📁 File Locations

### Ghost Files
- **Ghost Installation**: `/var/www/ghost/`
- **Ghost Binary**: `/var/www/ghost/current/`
- **Content**: `/var/www/ghost/content/`
- **Database**: `/var/www/ghost/content/data/ghost-local.db`
- **Themes**: `/var/www/ghost/content/themes/`
- **Config**: `/var/www/ghost/config.development.json`

### Nginx Configuration
- **Sites Available**: `/etc/nginx/sites-available/nginx-ghost.conf`
- **Sites Enabled**: `/etc/nginx/sites-enabled/nginx-ghost.conf`
- **Main Config**: `/etc/nginx/nginx.conf`

### SSL Certificates
- **Certificate**: `/etc/letsencrypt/live/blog.itsdanmanole.com/fullchain.pem`
- **Private Key**: `/etc/letsencrypt/live/blog.itsdanmanole.com/privkey.pem`

---

## 🌐 Network Configuration

### Load Balancer Components
- **URL Map**: `ghost-url-map`
- **Backend Service**: `ghost-backend-service`
- **Health Check**: `ghost-health-check` (checks `/health`)
- **Instance Group**: `ghost-instance-group`
- **HTTP Target Proxy**: `ghost-http-proxy`
- **HTTPS Target Proxy**: `ghost-https-proxy`
- **SSL Certificate**: `ghost-ssl-cert`
- **Static IP**: `ghost-lb-ip` (`YOUR_LB_IP`)

### Firewall Rules
```bash
# Current firewall rule
NAME: allow-ghost-http
TARGET_TAGS: ghost-blog
ALLOWED: tcp:80,tcp:443
SOURCE: 0.0.0.0/0
```

---

## 🔍 Troubleshooting

### Common Issues

#### Posts Not Appearing
**Symptoms**: New posts don't show on homepage  
**Solution**: 
```bash
gcloud compute url-maps invalidate-cdn-cache ghost-url-map --path="/"
```

#### Deleted Posts Still Visible
**Symptoms**: Deleted posts still appear on site  
**Solution**:
```bash
# Clear both post and homepage cache
gcloud compute url-maps invalidate-cdn-cache ghost-url-map --path="/post-slug/"
gcloud compute url-maps invalidate-cdn-cache ghost-url-map --path="/"
```

#### Theme Not Loading
**Symptoms**: New theme not appearing after change  
**Solution**:
```bash
cd /var/www/ghost
ghost restart
gcloud compute url-maps invalidate-cdn-cache ghost-url-map --path="/*"
```

#### Site Not Accessible
**Symptoms**: Site returns 502/503 errors  
**Check**:
```bash
# Check Ghost status
cd /var/www/ghost && ghost status

# Check Nginx status
sudo systemctl status nginx

# Check VM health
gcloud compute backend-services get-health ghost-backend-service --global
```

### Log Locations
- **Ghost Logs**: `/var/www/ghost/content/logs/`
- **Nginx Logs**: `/var/log/nginx/`
- **System Logs**: `journalctl -u nginx` or `journalctl -f`

---

## 💰 Cost Optimization

### Current Resources & Estimated Costs
- **VM (e2-medium)**: ~$25/month
- **Load Balancer**: ~$20/month
- **Cloud CDN**: ~$5/month (traffic-based)
- **Static IP**: ~$3/month
- **Total Estimated**: ~$53/month

### Cost-Saving Measures Implemented
- ✅ Removed all unused Jekyll infrastructure
- ✅ Right-sized VM for blog workload
- ✅ SQLite instead of Cloud SQL for small-medium blogs
- ✅ Optimized CDN cache times for performance vs. cost

---

## 🔄 Maintenance Tasks

### Weekly
- [ ] Check Ghost admin for any issues
- [ ] Monitor site performance
- [ ] Review any error logs

### Monthly
- [ ] Check VM resource usage
- [ ] Review CDN cache hit rates
- [ ] Update Ghost if new version available
- [ ] Check SSL certificate expiry (auto-renewed)

### Quarterly
- [ ] Review cost optimization opportunities
- [ ] Backup Ghost content and configuration
- [ ] Update VM system packages

---

## 🎯 Future Enhancements

### Potential Upgrades
- **Premium Theme**: Ali Abdaal or Fumio theme for professional TAM portfolio
- **Email Newsletter**: Set up proper email service (currently Direct transport)
- **Analytics**: Google Analytics integration
- **Monitoring**: Set up uptime monitoring
- **Backups**: Automated Ghost content backups to Cloud Storage

### Theme Considerations
- **Current**: Default Ghost theme (Casper variant)
- **Target**: Professional portfolio theme for TAM goals
- **Budget**: $149 for premium theme (Ali Abdaal recommended)

---

## 📞 Support & Resources

### Key Documentation
- **Ghost Documentation**: https://ghost.org/docs/
- **Google Cloud Load Balancer**: https://cloud.google.com/load-balancing/docs
- **Nginx Configuration**: https://nginx.org/en/docs/

### Emergency Contacts
- **Ghost Support**: https://ghost.org/help/
- **Google Cloud Support**: https://cloud.google.com/support/
- **Domain Support**: Cloudflare dashboard

---

## 📝 Change Log

### 2025-08-25 - Initial Setup
- ✅ Ghost v6.0.5 installed on GCP VM
- ✅ Nginx reverse proxy configured
- ✅ SSL certificates (Let's Encrypt → Google-managed)
- ✅ Load balancer with CDN enabled
- ✅ Domain configuration (root → blog subdomain redirect)
- ✅ Security hardening (firewall, headers)
- ✅ Cache optimization (30-minute default TTL)
- ✅ Cleanup of old Jekyll infrastructure

### Future Updates
- Track theme changes, Ghost updates, infrastructure modifications here

---

**🚀 Your Ghost blog is production-ready and optimized for your TAM career goals!**

*Last Updated: August 25, 2025*