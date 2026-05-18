# PXLCensor Frontend

Vue 3 SPA for uploading images (single or batch), browsing the gallery, and monitoring the queue.

## Development
```bash
npm install
npm run dev
```

## Build
```bash
npm run build
npm run preview
```

## Testing
```bash
npm test
```

## Configuration
Set `VITE_API_BASE_URL` in `.env` to override the API base for production builds.
In development, Vite proxies `/api` and `/media` to the backend services.

## Structure
- `src/router/` - Vue Router routes
- `src/api/` - API client modules (Axios-based)
- `src/components/` - UI components and tests
- `src/utils/` - Utility helpers (byte formatting, etc.)
