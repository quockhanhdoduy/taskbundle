# Setup Guide

## Prerequisites
- Node.js (v16 or higher)
- MongoDB (v5 or higher)
- npm or yarn

## Installation
1. Clone the repository
2. Install dependencies: `npm install`
3. Copy `.env.example` to `.env` and configure
4. Start MongoDB service
5. Run migrations: `npm run migrate`
6. Start development server: `npm run dev`

## Environment Variables
- `PORT`: Server port (default: 3000)
- `MONGODB_URI`: MongoDB connection string
- `JWT_SECRET`: JWT secret key
- `NODE_ENV`: Environment (development/production)

## Scripts
- `npm run dev`: Start development server
- `npm run start`: Start production server
- `npm run test`: Run tests
- `npm run lint`: Run linter
- `npm run build`: Build for production