# TaskBundle Backend

Backend API cho ứng dụng quản lý dự án nhóm dựa trên Trello.

## Cấu trúc thư mục

```
backend/
├── src/
│   ├── config/          # Cấu hình ứng dụng
│   ├── controllers/     # Business logic
│   ├── models/          # Database models
│   ├── routes/          # API routes
│   ├── middleware/      # Custom middleware
│   ├── utils/           # Utility functions
│   ├── services/        # External services
│   └── app.js          # Entry point
├── tests/              # Test files
├── docs/               # Documentation
└── env.example         # Environment variables template
```

## Kiến trúc

- **MVC Pattern**: Model-View-Controller
- **Layered Architecture**: Separation of concerns
- **RESTful API**: Standard REST endpoints
- **JWT Authentication**: Token-based auth

## API Endpoints

Xem chi tiết trong `docs/api.md`

## Setup

Xem hướng dẫn trong `docs/setup.md`