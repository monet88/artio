# Artio - AI Art Generation App

<div align="center">

**A Flutter cross-platform AI image generation SaaS**

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.6+-AFB5C8?logo=flutter)](https://riverpod.dev)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

</div>

---

## Overview

**Artio** ("Art Made Simple") is a cross-platform AI image generation SaaS delivering enterprise-grade image creation through two distinct modes:

- **Template Engine** (Home tab): Guided image-to-image transformation with curated presets
- **Text-to-Image** (Create tab): Freeform prompt-based generation

### Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.10+ (Android, iOS, Web, Windows) |
| **State Management** | Riverpod 2.6+ with code generation |
| **Navigation** | go_router 14.8+ with auth guards |
| **Data Models** | Freezed + JSON Serializable |
| **Backend** | Supabase (Auth, PostgreSQL, Storage, Edge Functions, Realtime) |
| **Payments** | RevenueCat (mobile) + Stripe (web) |
| **Ads** | AdMob (rewarded ads) |
| **AI Provider** | Kie API (primary), Gemini (fallback) |

---

## Architecture

### Feature-First Clean Architecture

```
lib/
├── core/                   # Cross-cutting concerns
│   ├── constants/         # App-wide constants
│   ├── exceptions/        # AppException hierarchy
│   ├── providers/         # Supabase client DI
│   └── utils/             # Error mapper, logger
│
├── features/              # Feature modules (3-layer each)
│   ├── auth/              # ✓ Authentication (login/register/OAuth)
│   ├── template_engine/   # ✓ CORE: AI template-based generation
│   ├── gallery/           # ✓ User's generated images
│   ├── settings/          # ✓ App settings (theme switcher)
│   └── create/            # ✓ Create screen
│
├── routing/               # GoRouter configuration
├── shared/                # Shared widgets (MainShell, ErrorPage)
├── theme/                 # Theme management
├── test/                  # Unit and widget tests
├── integration_test/      # E2E tests
└── main.dart              # Entry point
```

### 3-Layer Pattern per Feature

Each feature follows Clean Architecture:
- **Domain**: Entities, Repository interfaces
- **Data**: Repository implementations, Supabase integration
- **Presentation**: Providers (Riverpod), Screens, Widgets

---

## Getting Started

### Prerequisites

- Flutter SDK 3.10+ ([Install](https://docs.flutter.dev/get-started/install))
- Dart SDK 3.10+
- Supabase project ([Create free](https://supabase.com))

### Installation

```bash
# Clone repository
git clone <repo-url>
cd artio

# Install dependencies
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Configure environment
cp .env.example .env
# Edit .env with your Supabase credentials
```

### Configuration

Create `.env` file in project root:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### Run

```bash
# Flutter (iOS/Android/Windows)
flutter run

# Web
flutter run -d chrome

# Windows
flutter run -d windows

# Release build
flutter build apk      # Android
flutter build ios      # iOS
flutter build web      # Web
flutter build windows  # Windows
```

---

## Features

### Implemented

| Feature | Description | Status |
|---------|-------------|--------|
| **Authentication** | Email/password, Google OAuth, Apple Sign-In, password reset | Complete |
| **Template Engine** | Browse templates, dynamic inputs, generation tracking, realtime job updates | Complete |
| **Create (Text-to-Image)** | Prompt + parameter UI, backend integration, credit enforcement via Edge Function | Complete |
| **Gallery** | Masonry grid, image viewer, download/share/delete, soft delete | Complete |
| **Settings** | Theme switcher (light/dark/system), account management | Complete |
| **Realtime Updates** | Job status streaming via Supabase Realtime (template + create flows) | Complete |
| **Credits System** | Balance display, insufficient credit + premium model sheets, 402 handling, deduct/refund RPCs | Complete |

**Credit Guardrails:** Both Template-Based and Text-to-Image generation flows post to `supabase/functions/generate-image`, which enforces the user's credit balance via `deduct_credits` RPC. On insufficient balance, returns 402 and displays `insufficient_credits_sheet` or `premium_model_sheet` widgets from `features/credits/presentation/widgets`. On success, polls the selected Kie/Gemini model, mirrors outputs into `generated-images` bucket, and updates `generation_jobs` table. Model costs defined in Edge Function match `core/constants/ai_models.dart`.

### Planned / Pending

| Feature | Description | Status |
|---------|-------------|--------|
| **Subscription purchases** | RevenueCat + Stripe + rewarded ads | Pending (purchase flows + pricing) |
| **Rate Limiting** | Daily generation limits, cooldown, anti-abuse | Planned |

---

## Quick Start

### Run the App

```bash
flutter run              # Default device
flutter run -d chrome    # Web
flutter run -d windows   # Windows
```

### Basic Workflow

1. **Sign up** → Email/password or Google/Apple OAuth
2. **Home tab** → Browse templates
3. **Select template** → Fill inputs → Generate
4. **Create tab** → Enter prompt (text-to-image flow)
5. **Gallery** → View/download/share your creations

See [docs/](docs/) for detailed guides

---

## Development

### Code Generation

```bash
# One-time generation
dart run build_runner build --delete-conflicting-outputs

# Watch mode (development)
dart run build_runner watch
```

### Code Quality

```bash
# Analyze code
flutter analyze

# Run tests
flutter test

# Format code
dart format .
```

### Key Libraries

```yaml
# State Management
flutter_riverpod: ^2.6.1
riverpod_annotation: ^2.6.1

# Data Classes
freezed: ^2.5.8
json_serializable: ^6.9.2

# Backend
supabase_flutter: ^2.11.0

# Routing
go_router: ^14.8.1

# Payments
purchases_flutter: ^9.0.0

# Utils
cached_network_image: ^3.4.1
image_picker: ^1.1.2
share_plus: ^12.0.1
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [docs/development-roadmap.md](docs/development-roadmap.md) | Project phases and progress tracking |
| [CLAUDE.md](CLAUDE.md) | AI assistant guidelines |
| [docs/code-standards.md](docs/code-standards.md) | Coding conventions |
| [docs/system-architecture.md](docs/system-architecture.md) | Architecture documentation |
| [docs/project-overview-pdr.md](docs/project-overview-pdr.md) | Product requirements |
| [docs/codebase-summary.md](docs/codebase-summary.md) | Detailed code analysis |

---

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests (requires running app)
flutter test integration_test/template_e2e_test.dart

# Run specific test file
flutter test test/features/auth/data/repositories/auth_repository_test.dart
```

**Test Suite**: Coverage and test count need verification (run `flutter test --coverage`).

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## Support

For issues, questions, or contributions, please open an issue in the project repository.

---

<div align="center">

**Built with Flutter**

**Last Updated**: 2026-02-19

</div>
