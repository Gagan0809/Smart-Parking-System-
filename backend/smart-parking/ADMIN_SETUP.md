# Smart Parking Backend - Admin Setup

## Admin login
POST /api/admin/login

Default credentials:
- Email: admin@smartparking.com
- Password: admin123

Optional Render environment variables:
- ADMIN_EMAIL
- ADMIN_PASSWORD

Required existing environment variables:
- MONGODB_URI
- JWT_SECRET

## Build locally
Windows PowerShell:
.\mvnw.cmd clean package

## Admin endpoints
- POST /api/admin/login
- GET/POST/PUT/DELETE /api/admin/parking-locations
- GET/POST/PUT/DELETE /api/admin/parking-slots
- GET/DELETE /api/admin/users
- GET/DELETE /api/admin/bookings
