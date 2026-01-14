# QuoteVault

**QuoteVault** - Your daily dose of inspiration

A complete Flutter mobile application for managing, organizing, and discovering inspirational quotes. Built with Flutter 3+, Supabase (Auth + Database), and clean architecture principles.

## Features

### 🔐 Authentication
- Email/password signup and login
- Password reset functionality
- Session persistence
- Secure authentication using Supabase Auth

### 📝 Quotes
- Browse quotes by categories (Motivation, Love, Success, Wisdom, Humor)
- Search quotes by text or author
- Pull-to-refresh functionality
- Daily quote feature
- Beautiful quote cards with color variations

### ❤️ Favorites
- Favorite/unfavorite quotes with a single tap
- View all your favorite quotes in one place
- Synced with Supabase

### 📚 Collections
- Create custom collections to organize quotes
- Add quotes to collections
- Manage multiple collections
- View collection details with quote count

### 🔔 Notifications
- Daily quote notifications
- Customizable notification time
- Local notifications support

### ⚙️ Settings
- Dark mode toggle
- Accent color customization (Purple, Blue, Green, Red, Orange)
- Font size adjustment
- Daily quote notification time settings
- User profile management

## Tech Stack

- **Flutter 3+** - UI Framework
- **Supabase** - Backend (Authentication & Database)
- **Material 3** - Design System
- **Google Fonts** - Typography
- **SharedPreferences** - Local Storage
- **flutter_local_notifications** - Notifications
- **Clean Architecture** - Code Organization

## Project Structure

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── supabase_client.dart    # Supabase client initialization
│   ├── theme.dart              # Theme configuration
│   └── constants.dart          # App constants
│
├── auth/
│   ├── login_screen.dart       # Login screen
│   ├── signup_screen.dart      # Signup screen
│   ├── reset_password_screen.dart  # Password reset
│   └── auth_gate.dart          # Auth routing
│
├── profile/
│   └── profile_screen.dart     # User profile & settings
│
├── quotes/
│   ├── quote_model.dart        # Quote data model
│   ├── quote_service.dart      # Quote business logic
│   ├── home_screen.dart        # Home feed
│   └── quote_tile.dart         # Quote card widget
│
├── favorites/
│   └── favorites_screen.dart   # Favorites list
│
├── collections/
│   ├── collection_model.dart   # Collection data model
│   ├── collection_service.dart # Collection business logic
│   ├── collections_screen.dart # Collections list
│   └── collection_detail_screen.dart  # Collection details
│
├── notifications/
│   └── daily_quote_service.dart  # Daily quote & notifications
│
└── widgets/
    ├── loading.dart            # Loading indicator
    └── empty_state.dart        # Empty state widget
```

## Setup Instructions

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Supabase account and project
- Android Studio / Xcode (for mobile development)

### 1. Clone the Repository

```bash
git clone <repository-url>
cd QuoteVault
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Supabase Setup

1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Get your project URL and anon key from the project settings
3. Update `lib/main.dart` with your Supabase credentials:

```dart
await SupabaseService.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

### 4. Database Schema

Create the following tables in your Supabase database:

#### Profiles Table
```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  name TEXT,
  email TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Quotes Table
```sql
CREATE TABLE quotes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  text TEXT NOT NULL,
  author TEXT NOT NULL,
  category TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Favorites Table
```sql
CREATE TABLE favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  quote_id UUID REFERENCES quotes(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, quote_id)
);
```

#### Collections Table
```sql
CREATE TABLE collections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Collection Quotes Table
```sql
CREATE TABLE collection_quotes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  collection_id UUID REFERENCES collections(id) ON DELETE CASCADE,
  quote_id UUID REFERENCES quotes(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(collection_id, quote_id)
);
```

### 5. Row Level Security (RLS) Policies

Enable RLS on all tables and create policies:

#### Profiles
```sql
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all profiles"
  ON profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can update their own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);
```

#### Quotes
```sql
ALTER TABLE quotes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view quotes"
  ON quotes FOR SELECT
  USING (true);
```

#### Favorites
```sql
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own favorites"
  ON favorites FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own favorites"
  ON favorites FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own favorites"
  ON favorites FOR DELETE
  USING (auth.uid() = user_id);
```

#### Collections
```sql
ALTER TABLE collections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own collections"
  ON collections FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own collections"
  ON collections FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own collections"
  ON collections FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own collections"
  ON collections FOR DELETE
  USING (auth.uid() = user_id);
```

#### Collection Quotes
```sql
ALTER TABLE collection_quotes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view collection quotes for their collections"
  ON collection_quotes FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM collections
      WHERE collections.id = collection_quotes.collection_id
      AND collections.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert collection quotes for their collections"
  ON collection_quotes FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM collections
      WHERE collections.id = collection_quotes.collection_id
      AND collections.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete collection quotes for their collections"
  ON collection_quotes FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM collections
      WHERE collections.id = collection_quotes.collection_id
      AND collections.user_id = auth.uid()
    )
  );
```

### 6. Seed Sample Data (Optional)

Insert some sample quotes:

```sql
INSERT INTO quotes (text, author, category) VALUES
  ('The only way to do great work is to love what you do.', 'Steve Jobs', 'Motivation'),
  ('The best way to predict the future is to create it.', 'Peter Drucker', 'Success'),
  ('Success is walking from failure to failure with no loss of enthusiasm.', 'Winston Churchill', 'Success'),
  ('The only impossible journey is the one you never begin.', 'Tony Robbins', 'Motivation'),
  ('In the end, we will remember not the words of our enemies, but the silence of our friends.', 'Martin Luther King Jr.', 'Wisdom');
```

### 7. Run the App

```bash
flutter run
```

## Configuration

### Android Notification Setup

For Android notifications to work properly, ensure your `android/app/src/main/AndroidManifest.xml` includes:

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
```

### iOS Notification Setup

For iOS, notification permissions are requested automatically. Ensure you have proper permissions configured in `ios/Runner/Info.plist`.

## Features in Detail

### Authentication Flow
1. Users can sign up with email and password
2. Profile is automatically created on signup
3. Sessions are persisted across app restarts
4. Password reset functionality available

### Quote Management
- Quotes are fetched from Supabase
- Categories: Motivation, Love, Success, Wisdom, Humor
- Real-time search functionality
- Daily quote displayed on home screen

### Collections
- Create unlimited collections
- Add quotes to multiple collections
- Delete collections with confirmation
- View quote count per collection

### Notifications
- Daily quote notifications
- Customizable time (default: 09:00)
- Can be enabled/disabled in settings

### Settings
- **Dark Mode**: Toggle between light and dark themes
- **Accent Color**: Choose from 5 color options
- **Font Size**: Adjustable from 12px to 24px
- **Notification Time**: Set daily quote notification time

## Development

### Code Structure
- **Clean Architecture**: Separation of concerns with models, services, and UI
- **Service Layer**: Business logic separated from UI
- **Reusable Widgets**: Common widgets in `widgets/` directory
- **Constants**: Centralized constants for easy configuration

### Best Practices
- Error handling with try-catch blocks
- Loading states for async operations
- Empty states for better UX
- Form validation
- User feedback with SnackBars

## Troubleshooting

### Common Issues

1. **Supabase Connection Errors**
   - Verify your Supabase URL and anon key
   - Check internet connection
   - Ensure Supabase project is active

2. **Authentication Issues**
   - Clear app data and try again
   - Check Supabase Auth settings
   - Verify email confirmation settings

3. **Notification Issues (Android)**
   - Check Android manifest permissions
   - Ensure device notifications are enabled
   - Try scheduling notifications manually

4. **Build Errors**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Check Flutter SDK version (3.0+)

## License

This project is created for educational purposes.

## Support

For issues and questions, please create an issue in the repository.

---

**Built with ❤️ using Flutter and Supabase**
#   Q u o t e V a u l t A p p 
 
 