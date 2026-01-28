# Artio - AI Art Generation App

<div align="center">

**A Flutter cross-platform AI image generation SaaS**

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.6+-AFB5C8?logo=flutter)](https://riverpod.dev)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

</div>

---

## 🎯 Overview

**Artio** ("Art Made Simple") is a cross-platform AI image generation SaaS delivering enterprise-grade image creation through two distinct modes:

- **Template Engine** (Home tab): Guided image-to-image transformation with curated presets
- **Text-to-Image** (Create tab): Freeform prompt-based generation

### Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.10+ (Android, iOS, Web) |
| **State Management** | Riverpod 2.6+ with code generation |
| **Navigation** | go_router 14.8+ with auth guards |
| **Data Models** | Freezed + JSON Serializable |
| **Backend** | Supabase (Auth, PostgreSQL, Storage, Edge Functions, Realtime) |
| **Payments** | RevenueCat (mobile) + Stripe (web) |
| **Ads** | AdMob (rewarded ads) |
| **AI Provider** | KIE API (Nano Banana, Imagen 4) |

---

## 🏗️ Architecture

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
└── main.dart              # Entry point
```

### 3-Layer Pattern per Feature

Each feature follows Clean Architecture:
- **Domain**: Entities, Repository interfaces
- **Data**: Repository implementations, Supabase integration
- **Presentation**: Providers (Riverpod), Screens, Widgets

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.10+ ([Install](https://docs.flutter.dev/get-started/install))
- Dart SDK 3.10+
- Supabase project ([Create free](https://supabase.com))

### Installation

```bash
# Clone repository
git clone <repo-url>
cd aiart

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
# Flutter (iOS/Android)
flutter run

# Web
flutter run -d chrome

# Release build
flutter build apk    # Android
flutter build ios    # iOS
flutter build web    # Web
```

---

## 📦 Features

### ✅ Implemented

| Feature | Description | Status |
|---------|-------------|--------|
| **Authentication** | Email/password, Google OAuth, Apple Sign-In, password reset | ✅ Complete |
| **Template Engine** | Browse templates, dynamic inputs, generation tracking | ✅ Complete |
| **Gallery** | Masonry grid, image viewer, download/share/delete | ✅ Complete |
| **Settings** | Theme switcher (light/dark/system) | ✅ Complete |
| **Realtime Updates** | Job status streaming via Supabase Realtime | ✅ Complete |
| **Error Handling** | Centralized AppException hierarchy | ✅ Complete |

### 🚧 Planned

| Feature | Description | Status |
|---------|-------------|--------|
| **Subscription & Credits** | Free/Pro tiers, RevenueCat integration | 🚧 Planned |
| **Rate Limiting** | Daily generation limits, cooldown | 🚧 Planned |
| **Text-to-Image** | Custom prompt generation | 🚧 Planned |

---

## 🛠️ Development

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

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [ROADMAP.md](ROADMAP.md) | Project phases and progress tracking |
| [CLAUDE.md](CLAUDE.md) | AI assistant guidelines |
| [AGENTS.md](AGENTS.md) | Agent orchestration protocols |
| [docs/code-standards.md](docs/code-standards.md) | Coding conventions |
| [docs/system-architecture.md](docs/system-architecture.md) | Architecture documentation |
| [docs/project-overview-pdr.md](docs/project-overview-pdr.md) | Product requirements |
| [docs/codebase-summary.md](docs/codebase-summary.md) | Detailed code analysis |
| [docs/development-roadmap.md](docs/development-roadmap.md) | Development phases |

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/auth/auth_repository_test.dart
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📞 Support

For issues, questions, or contributions, please [open an issue](https://github.com/your-repo/issues).

---

<div align="center">

**Built with ❤️ using Flutter**

</div>
