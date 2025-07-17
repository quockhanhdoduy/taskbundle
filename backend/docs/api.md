# API Documentation

## Authentication
- POST /api/auth/register
- POST /api/auth/login
- POST /api/auth/logout
- GET /api/auth/me

## Users
- GET /api/users
- GET /api/users/:id
- PUT /api/users/:id
- DELETE /api/users/:id

## Boards
- GET /api/boards
- POST /api/boards
- GET /api/boards/:id
- PUT /api/boards/:id
- DELETE /api/boards/:id
- POST /api/boards/:id/members
- DELETE /api/boards/:id/members/:userId

## Lists
- GET /api/boards/:boardId/lists
- POST /api/boards/:boardId/lists
- PUT /api/lists/:id
- DELETE /api/lists/:id

## Cards
- GET /api/lists/:listId/cards
- POST /api/lists/:listId/cards
- GET /api/cards/:id
- PUT /api/cards/:id
- DELETE /api/cards/:id

## Comments
- GET /api/cards/:cardId/comments
- POST /api/cards/:cardId/comments
- PUT /api/comments/:id
- DELETE /api/comments/:id