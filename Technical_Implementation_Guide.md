# Technical Implementation Guide
## Funky Wiki Project - Developer Quick Start

**For:** Development Team  
**Phase:** Implementation Planning  

---

## Quick Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend       │    │   Database      │
│   (Existing)    │───▶│   Node.js       │───▶│   MongoDB       │
│   HTML/CSS/JS   │    │   Express API   │    │   + Redis       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Technology Stack

### Core Technologies
```json
{
  "backend": "Node.js 18+ with Express.js",
  "database": "MongoDB 6.0+",
  "cache": "Redis 7.0+",
  "auth": "JWT with Passport.js",
  "search": "MongoDB Full-Text Search"
}
```

### Key Dependencies
```bash
npm install express mongoose redis jsonwebtoken passport
npm install multer helmet cors morgan compression
npm install bcryptjs joi dotenv
```

## Project Structure

```
wiki-backend/
├── src/
│   ├── controllers/        # Route handlers
│   ├── models/            # Mongoose schemas
│   ├── middleware/        # Auth, validation, etc.
│   ├── routes/           # Express routes
│   ├── services/         # Business logic
│   └── utils/            # Helper functions
├── tests/                # Test files
├── config/               # Configuration files
├── docs/                 # API documentation
└── scripts/              # Deployment scripts
```

## Core Data Models

### Page Model
```javascript
const pageSchema = new mongoose.Schema({
  title: { type: String, required: true, index: true },
  slug: { type: String, required: true, unique: true },
  content: { type: String, required: true },
  author: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  tags: [{ type: String, index: true }],
  category: { type: String, index: true },
  status: { type: String, enum: ['draft', 'published'], default: 'draft' },
  version: { type: Number, default: 1 },
  history: [versionSchema],
  permissions: {
    read: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
    write: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }]
  }
}, { timestamps: true });
```

### User Model
```javascript
const userSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role: { type: String, enum: ['admin', 'editor', 'viewer'], default: 'viewer' },
  profile: {
    firstName: String,
    lastName: String,
    avatar: String,
    bio: String
  },
  preferences: {
    theme: { type: String, default: 'original' },
    animationSpeed: { type: String, default: 'normal' },
    soundEnabled: { type: Boolean, default: false }
  }
}, { timestamps: true });
```

## API Design

### Authentication Endpoints
```
POST /api/auth/register     # User registration
POST /api/auth/login        # User login
POST /api/auth/logout       # User logout
GET  /api/auth/me           # Get current user
PUT  /api/auth/profile      # Update profile
```

### Page Management Endpoints
```
GET    /api/pages           # List pages (with search/filter)
POST   /api/pages           # Create new page
GET    /api/pages/:id       # Get specific page
PUT    /api/pages/:id       # Update page
DELETE /api/pages/:id       # Delete page
GET    /api/pages/:id/history # Get page history
```

### Search Endpoints
```
GET /api/search?q=query     # Full-text search
GET /api/search/suggest     # Search suggestions
GET /api/tags               # Get all tags
GET /api/categories         # Get all categories
```

## Development Setup

### 1. Environment Setup
```bash
# Create project directory
mkdir wiki-backend && cd wiki-backend

# Initialize Node.js project
npm init -y

# Install dependencies
npm install express mongoose redis jsonwebtoken passport
npm install --save-dev nodemon jest supertest

# Create environment file
cp .env.example .env
```

### 2. Environment Variables
```bash
# .env
NODE_ENV=development
PORT=3001
MONGODB_URI=mongodb://localhost:27017/wiki
REDIS_URL=redis://localhost:6379
JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRE=7d
UPLOAD_PATH=./uploads
MAX_FILE_SIZE=10485760
```

### 3. Database Setup
```bash
# Start MongoDB (using Docker)
docker run -d --name wiki-mongo -p 27017:27017 mongo:6

# Start Redis (using Docker)
docker run -d --name wiki-redis -p 6379:6379 redis:7

# Or install locally on Ubuntu/Debian
sudo apt update
sudo apt install mongodb redis-server
```

## Implementation Phases

### Phase 1: Foundation (Week 1-2)
```javascript
// Day 1-3: Basic server setup
const express = require('express');
const mongoose = require('mongoose');
const app = express();

// Basic middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Database connection
mongoose.connect(process.env.MONGODB_URI);

// Day 4-7: Authentication system
const passport = require('passport');
const JwtStrategy = require('passport-jwt').Strategy;

// Day 8-14: Basic CRUD operations
```

### Phase 2: Core Features (Week 3-4)
- Rich text editor integration (TinyMCE or CKEditor)
- File upload system with image handling
- Basic search functionality
- Page linking and cross-references

### Phase 3: Advanced Features (Week 5-6)
- Version control system
- User collaboration features
- Advanced search with filters
- Admin dashboard

### Phase 4: Production Ready (Week 7)
- Error handling and logging
- Performance optimization
- Security hardening
- Deployment setup

## Testing Strategy

### Unit Tests
```javascript
// Example test for page creation
describe('Page Controller', () => {
  test('should create new page', async () => {
    const pageData = {
      title: 'Test Page',
      content: 'Test content'
    };
    
    const response = await request(app)
      .post('/api/pages')
      .set('Authorization', `Bearer ${userToken}`)
      .send(pageData)
      .expect(201);
      
    expect(response.body.title).toBe(pageData.title);
  });
});
```

### Integration Tests
- API endpoint testing
- Database integration testing
- Authentication flow testing
- File upload testing

## Performance Considerations

### Database Optimization
```javascript
// Indexes for common queries
pageSchema.index({ title: 'text', content: 'text' }); // Full-text search
pageSchema.index({ tags: 1 }); // Tag filtering
pageSchema.index({ createdAt: -1 }); // Recent pages
pageSchema.index({ author: 1, createdAt: -1 }); // User pages
```

### Caching Strategy
```javascript
const redis = require('redis');
const client = redis.createClient();

// Cache frequently accessed pages
const getCachedPage = async (pageId) => {
  const cached = await client.get(`page:${pageId}`);
  if (cached) return JSON.parse(cached);
  
  const page = await Page.findById(pageId);
  await client.setex(`page:${pageId}`, 300, JSON.stringify(page));
  return page;
};
```

## Security Implementation

### Input Validation
```javascript
const Joi = require('joi');

const pageValidation = Joi.object({
  title: Joi.string().min(1).max(200).required(),
  content: Joi.string().min(1).required(),
  tags: Joi.array().items(Joi.string().max(50)).max(20),
  category: Joi.string().max(100)
});
```

### Authentication Middleware
```javascript
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) {
    return res.sendStatus(401);
  }
  
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
};
```

## Deployment Checklist

### Pre-deployment
- [ ] All tests passing
- [ ] Environment variables configured
- [ ] Database migrations completed
- [ ] Security headers implemented
- [ ] Error logging configured
- [ ] Performance testing completed

### Production Environment
- [ ] SSL certificate installed
- [ ] Database backups configured
- [ ] Monitoring tools setup
- [ ] Rate limiting implemented
- [ ] CORS properly configured
- [ ] File upload limits set

## Monitoring & Maintenance

### Key Metrics to Track
- API response times
- Database query performance
- Memory usage
- Error rates
- User activity

### Log Management
```javascript
const winston = require('winston');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});
```

## Frontend Integration

### API Client Setup
```javascript
// Frontend API service
class WikiAPI {
  constructor(baseURL = '/api') {
    this.baseURL = baseURL;
    this.token = localStorage.getItem('authToken');
  }
  
  async getPages() {
    const response = await fetch(`${this.baseURL}/pages`, {
      headers: { 'Authorization': `Bearer ${this.token}` }
    });
    return response.json();
  }
  
  async createPage(pageData) {
    const response = await fetch(`${this.baseURL}/pages`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.token}`
      },
      body: JSON.stringify(pageData)
    });
    return response.json();
  }
}
```

## Quick Commands Reference

```bash
# Development
npm run dev          # Start development server
npm test             # Run tests
npm run test:watch   # Run tests in watch mode

# Database
npm run db:seed      # Seed initial data
npm run db:migrate   # Run migrations
npm run db:backup    # Backup database

# Production
npm run build        # Build for production
npm start            # Start production server
npm run logs         # View application logs
```

---

This guide provides the technical foundation for implementing the wiki backend. Refer to the main Server_Architecture_Proposal.md for complete architectural details and business context.