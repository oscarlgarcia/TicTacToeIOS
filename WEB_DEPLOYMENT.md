# Flutter TicTacToe - Server Deployment

## 🌐 Web Server Deployment

This section covers deploying the Flutter TicTacToe app to various web servers and platforms.

## 🔧 Server Options

### 1. Firebase Hosting
**Setup:**
```bash
# Install Firebase CLI
curl -sL https://firebase.tools | bash
sudo mv firebase /usr/local/bin/

# Initialize Firebase project
firebase init hosting
```

**Deployment:**
```bash
# Build and deploy
flutter build web --web-renderer html
firebase deploy --only hosting
```

**Features:**
- Global CDN
- Automatic SSL
- Custom domains
- Rollback support

### 2. Netlify
**Setup:**
```bash
# Install Netlify CLI
npm install -g netlify-cli
```

**Deployment:**
```bash
# Build and deploy
flutter build web
netlify deploy --dir=build/web --prod
```

**netlify.toml:**
```toml
[build]
  publish = "build/web"
  command = "flutter build web"

[build.environment]
  FLUTTER_WEB_CANVASKIT_ENABLED = "true"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

### 3. Vercel
**Setup:**
```bash
# Install Vercel CLI
npm install -g vercel
```

**Deployment:**
```bash
# Build and deploy
flutter build web --web-renderer canvaskit
vercel --prod
```

**vercel.json:**
```json
{
  "version": 2,
  "builds": [
    {
      "src": "package.json",
      "use": "@vercel/static-build",
      "config": {
        "buildCommand": "flutter build web --web-renderer canvaskit",
        "outputDirectory": "build/web"
      }
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/index.html",
      "status": 200
    }
  ]
}
```

### 4. Nginx (Self-Hosted)
**Nginx Configuration:**
```nginx
server {
    listen 80;
    listen [::]:80;
    server_name tictactoe.yourdomain.com;
    root /var/www/tictactoe;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
    add_header X-XSS-Protection "1; mode=block";
    
    # Gzip compression
    gzip on;
    gzip_types text/css application/javascript application/json;
}
```

### 5. Apache (Self-Hosted)
**Apache Configuration:**
```apache
<VirtualHost *:80>
    ServerName tictactoe.yourdomain.com
    DocumentRoot /var/www/tictactoe
    
    DirectoryIndex index.html
    
    <Directory /var/www/tictactoe>
        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule ^(.*)$ index.html [QSA,L]
    </Directory>
    
    # Cache static assets
    <LocationMatch "\.(js|css|png|jpg|jpeg|gif|ico|svg)$">
        ExpiresActive On
        ExpiresDefault "access plus 1 year"
    </LocationMatch>
    
    # Security headers
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-XSS-Protection "1; mode=block"
</VirtualHost>
```

## 🚀 Docker Deployment

### Dockerfile
```dockerfile
# Dockerfile for Flutter Web
FROM nginx:alpine

# Copy built web files
COPY build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
```

### Docker Compose
```yaml
version: '3.8'

services:
  tictactoe-web:
    build: .
    ports:
      - "80:80"
    environment:
      - NGINX_HOST=tictactoe.local
      - NGINX_PORT=80
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./build/web:/usr/share/nginx/html
    restart: unless-stopped
```

### Build and Deploy Docker
```bash
# Build Docker image
docker build -t tictactoe-web .

# Run with Docker Compose
docker-compose up -d

# Or run standalone
docker run -d -p 80:80 tictactoe-web
```

## 📱 PWA Configuration

### manifest.json
```json
{
  "name": "Tic Tac Toe",
  "short_name": "TicTacToe",
  "description": "Classic Tic Tac Toe game with modern UI",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#F5F5DC",
  "theme_color": "#8B4513",
  "orientation": "portrait-primary",
  "icons": [
    {
      "src": "icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ],
  "categories": ["games", "entertainment"],
  "lang": "en",
  "scope": "/",
  "prefer_related_applications": false,
  "shortcuts": [
    {
      "name": "New Game",
      "short_name": "New Game",
      "description": "Start a new Tic Tac Toe game",
      "url": "/game/new",
      "icons": [{ "src": "icons/new-game.png", "sizes": "96x96" }]
    }
  ]
}
```

### Service Worker Registration
```dart
// lib/service_worker.dart
import 'package:flutter/material.dart';

@JS('self')
@anonymous
abstract class ServiceWorkerUtils {
  external void skipWaiting();
  external void clientsClaim();
}

Future<void> serviceWorkerMain() async {
  final registration = await self.serviceWorker.getRegistration();
  if (registration != null) {
    await registration.update();
  }
}
```

## 🔒 Security Configuration

### HTTPS Setup
```bash
# Generate SSL certificate with Let's Encrypt
sudo certbot --nginx -d tictactoe.yourdomain.com

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

### Security Headers
```nginx
# Security headers in nginx.conf
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "DENY" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Content-Security-Policy "default-src 'self' https:cdn.example.com; script-src 'self' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self'; connect-src 'self' https://api.example.com" always;
```

## 📊 Monitoring and Analytics

### Server Monitoring
```bash
# Set up monitoring with Uptime Robot
# Configure alerts for downtime
# Monitor response times and error rates
```

### Analytics Integration
```dart
// lib/services/analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static Future<void> trackPageView(String pageName) async {
    await FirebaseAnalytics.instance.logScreenView(screenName: pageName);
  }
  
  static Future<void> trackGameEvent(String eventName, Map<String, dynamic> parameters) async {
    await FirebaseAnalytics.instance.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }
}
```

### Performance Monitoring
```dart
// lib/services/performance_service.dart
import 'package:firebase_performance/firebase_performance.dart';

class PerformanceService {
  static Future<void> measureGameLoad() async {
    final trace = FirebasePerformance.instance.newTrace('game_load');
    trace.start();
    
    // Game loading logic here
    
    await trace.stop();
  }
}
```

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow
```yaml
name: Deploy Web App

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test-and-build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter build web --web-renderer canvaskit
      - uses: actions/upload-artifact@v3
        with:
          name: web-build
          path: build/web

  deploy:
    needs: test-and-build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - uses: actions/download-artifact@v3
        with:
          name: web-build
          path: build/web
      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.FIREBASE_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          channelId: live
          projectId: tictactoe-flutter
```

## 🌍 CDN Configuration

### Cloudflare Setup
1. **Create Cloudflare account**
2. **Add custom domain**
3. **Configure DNS records**
4. **Enable caching rules**
5. **Set up page rules**

### Cache Configuration
```yaml
# Cloudflare Cache Rules
- Cache static assets for 1 year
- Cache HTML for 1 hour
- Bypass cache for admin pages
- Respect ETag headers
```

## 📱 Mobile Web App Features

### App Shell Architecture
```dart
// lib/app_shell.dart
class AppShell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic Tac Toe'),
        backgroundColor: Color(0xFF8B4513),
      ),
      body: GameBoard(),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
```

### Offline Support
```dart
// lib/services/offline_service.dart
class OfflineService {
  static Future<void> cacheGameData() async {
    final gameData = await getGameData();
    final box = Hive.box('game_cache');
    await box.put('game_data', gameData);
  }
  
  static Future<GameData?> getCachedGameData() async {
    final box = Hive.box('game_cache');
    return box.get('game_data');
  }
}
```

## 🎯 Performance Optimization

### Image Optimization
```bash
# Optimize images for web
flutter pub global activate webdev_optimize
webdev_optimize --input build/web/assets/images --output build/web/assets/images
```

### Bundle Size Optimization
```yaml
# pubspec.yaml
flutter:
  tree-shake-icons: true
  # Remove unused fonts
  # Minimize dependencies
  # Enable tree shaking
```

### Lazy Loading
```dart
// Implement lazy loading for better performance
class LazyGameBoard extends StatefulWidget {
  @override
  State<LazyGameBoard> createState() => _LazyGameBoardState();
}

class _LazyGameBoardState extends State<LazyGameBoard> {
  bool _loaded = false;
  
  @override
  void initState() {
    super.initState();
    _loadGameBoard();
  }
  
  Future<void> _loadGameBoard() async {
    // Load game components asynchronously
    await Future.delayed(Duration(milliseconds: 100));
    setState(() => _loaded = true);
  }
  
  @override
  Widget build(BuildContext context) {
    return _loaded ? GameBoard() : CircularProgressIndicator();
  }
}
```

---

## 🚀 Deployment Commands

### Quick Deploy Commands
```bash
# Deploy to Firebase
firebase deploy --only hosting

# Deploy to Netlify
netlify deploy --dir=build/web --prod

# Deploy to Vercel
vercel --prod

# Deploy to Docker
docker build -t tictactoe-web .
docker run -d -p 80:80 tictactoe-web
```

### Environment Variables
```bash
# Set environment variables
export FLUTTER_WEB_CANVASKIT_ENABLED=true
export FLUTTER_WEB_RENDERER=html
```

---

**The Flutter TicTacToe app is now fully configured for web deployment across multiple platforms and hosting providers!**