# Building a Production-Ready Ghost Blog on Google Cloud: Enterprise Architecture Deep Dive

As a Technical Account Manager candidate, I recently migrated my Jekyll blog to Ghost CMS with enterprise-grade infrastructure on Google Cloud Platform. This post documents the complete architecture, design decisions, and lessons learned.

## 🏗️ Architecture Overview

```
Internet → Cloudflare DNS → Google Load Balancer → Cloud CDN → Ghost VM → Ghost CMS
```

### Why This Architecture?

- **High Availability**: Load balancer with health checks
- **Global Performance**: Cloud CDN with 30-minute cache
- **Security**: SSL termination, firewall rules, security headers
- **Scalability**: Ready to scale horizontally when traffic grows

## 📊 Infrastructure Components

### Core Services
- **VM Instance**: `ghost-blog-vm` (e2-medium, 2 vCPU, 4GB RAM)
- **Operating System**: Ubuntu 24.04 LTS
- **Ghost Version**: v6.0.5 with Node.js 22.18.0
- **Database**: SQLite (production-ready for medium traffic)
- **Web Server**: Nginx reverse proxy

### Google Cloud Services
- **Compute Engine**: VM hosting with static IP
- **Cloud Load Balancing**: Global HTTP(S) load balancer
- **Cloud CDN**: Global content distribution
- **Cloud Domains**: SSL certificate management
- **VPC Firewall**: Security rule enforcement

## 🔧 Configuration Details

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

### Nginx Reverse Proxy
Key features implemented:
- Health check endpoint for load balancer
- Security headers (HSTS, XSS protection, content-type validation)
- Gzip compression for performance
- Static asset caching (1-year cache for images, CSS)
- JavaScript cache bypass (prevents admin portal issues)

### Load Balancer Setup
```bash
# Backend service with health check
gcloud compute backend-services create ghost-backend-service \
    --protocol=HTTP \
    --health-checks=ghost-health-check \
    --global

# CDN with optimized caching
gcloud compute backend-services update ghost-backend-service \
    --enable-cdn \
    --cache-mode=CACHE_ALL_STATIC \
    --default-ttl=1800 \
    --max-ttl=3600 \
    --global
```

## 🚀 Performance Optimizations

### CDN Configuration
- **Default TTL**: 30 minutes (balances freshness vs. performance)
- **Static Assets**: 1-year cache for images, CSS, fonts
- **Dynamic Content**: 30-minute cache with easy invalidation

### Cache Management Strategy
```bash
# Clear homepage (new posts)
gcloud compute url-maps invalidate-cdn-cache ghost-url-map --path="/"

# Clear specific post (deletions)
gcloud compute url-maps invalidate-cdn-cache ghost-url-map --path="/post-slug/"

# Full site refresh (theme changes)
gcloud compute url-maps invalidate-cdn-cache ghost-url-map --path="/*"
```

## 🛡️ Security Implementation

### Network Security
- **Firewall**: Only ports 80/443 exposed to internet
- **Internal Communication**: Ghost runs on localhost:2368 (not exposed)
- **SSL/TLS**: Google-managed certificates with auto-renewal

### Application Security
```nginx
# Security headers in Nginx
add_header X-Frame-Options SAMEORIGIN always;
add_header X-Content-Type-Options nosniff always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
```

## 💰 Cost Analysis

Monthly costs (CAD):
- **VM (e2-medium)**: ~$34
- **Load Balancer**: ~$27  
- **Cloud CDN**: ~$7 (traffic-based)
- **Static IP**: ~$4
- **Total**: ~$72 CAD/month

### Cost Optimization Opportunities
- Could reduce to ~$34/month by removing load balancer for personal blog
- Current setup optimized for demonstrating enterprise architecture skills

## 📈 Migration Journey

### From Jekyll to Ghost
**Challenges encountered:**
- Initial Cloud Run deployment failed (exit code 2 issues)
- Node.js version compatibility (upgraded 18 → 22)
- Database migration locks with MySQL → switched to SQLite
- Portal authentication issues with cached old IPs

**Solutions implemented:**
- VM-based deployment for stability
- Comprehensive health check system
- Cache invalidation automation
- Security-first configuration

## 🔍 Monitoring & Troubleshooting

### Health Monitoring
```bash
# Check Ghost status
cd /var/www/ghost && ghost status

# Verify load balancer health
gcloud compute backend-services get-health ghost-backend-service --global

# Monitor Nginx
sudo systemctl status nginx
```

### Common Issues & Solutions
1. **Posts not appearing**: CDN cache - invalidate homepage path
2. **Deleted posts visible**: Clear specific post + homepage cache  
3. **Theme changes not loading**: Restart Ghost + full cache clear
4. **Admin portal issues**: Check Ghost URL config + clear JS cache

## 🎯 Future Enhancements

### Technical Roadmap
- **True 3-tier architecture**: Migrate SQLite → Cloud SQL
- **Infrastructure as Code**: Terraform implementation
- **Monitoring**: Cloud Operations Suite integration
- **Automated backups**: Content to Cloud Storage

### Business Goals
This architecture supports my goal of becoming an AWS/Google Cloud TAM by demonstrating:
- Enterprise architecture patterns
- Cloud-native best practices
- Cost vs. performance trade-offs
- Security and compliance awareness

## 📚 Key Takeaways

1. **Over-engineering can be valuable** when it demonstrates skills for career goals
2. **Cache management is critical** for dynamic content sites
3. **Security should be implemented at every layer**
4. **Documentation and monitoring are as important as the architecture itself**

The complete source code and documentation is available on [GitHub](https://github.com/thatcoderdaniel/ghost-blog).

---

**Tech Stack**: Ghost CMS • Google Cloud Platform • Nginx • Ubuntu • Cloudflare DNS • Let's Encrypt SSL

*This architecture demonstrates enterprise-grade infrastructure patterns while maintaining cost efficiency for a personal technical blog.*

---

**Ghost Publishing Instructions:**
- **Title**: `Building a Production-Ready Ghost Blog on Google Cloud: Enterprise Architecture Deep Dive`
- **Tags**: `architecture`, `cloud`, `ghost`, `gcp`, `infrastructure`, `tam`
- **Feature Image**: Optional - consider a cloud architecture diagram
- **Excerpt**: `Complete technical deep dive into building enterprise-grade Ghost blog infrastructure on Google Cloud Platform, including architecture decisions, security implementations, and cost analysis.`