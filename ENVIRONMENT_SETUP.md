# Environment Configuration

This app supports multiple environment configurations for the API base URL.

## Available Environments

1. **localhost** - For running backend on localhost
2. **emulator** - For Android emulator (default)
3. **production** - For production server

## How to Launch with Different Environments

### Using Flutter Run Command

#### For Emulator (Default):
```bash
flutter run
```

#### For Localhost:
```bash
flutter run --dart-define=ENV=localhost
```

#### For Production:
```bash
flutter run --dart-define=ENV=production
```

### Using VS Code Launch Configuration

Add this to your `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter (Emulator)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart"
    },
    {
      "name": "Flutter (Localhost)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": [
        "--dart-define=ENV=localhost"
      ]
    },
    {
      "name": "Flutter (Production)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": [
        "--dart-define=ENV=production"
      ]
    }
  ]
}
```

### Using Android Studio / IntelliJ

1. Go to **Run** > **Edit Configurations**
2. Add **Additional run args**: `--dart-define=ENV=localhost`
3. Save and run

## Environment URLs

- **localhost**: `http://localhost:3100/api`
- **emulator**: `http://10.0.2.2:3100/api`
- **production**: `https://your-production-url.com/api`

## Updating Production URL

Edit `lib/config/environment.dart` and change the production URL:

```dart
static const Map<String, String> _baseUrls = {
  'localhost': 'http://localhost:3100/api',
  'emulator': 'http://10.0.2.2:3100/api',
  'production': 'https://your-actual-production-url.com/api', // Update this
};
```

## Checking Current Environment

The app will automatically use the environment specified at launch time. All services (PromotionService, CatalogueService, etc.) will use the configured base URL.

