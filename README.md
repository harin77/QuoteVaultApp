# QuoteVault

**QuoteVault** – Your daily dose of inspiration ✨

QuoteVault is a full-featured Flutter mobile application for discovering, saving, and organizing inspirational quotes.  
Built with **Flutter 3+**, **Supabase (Auth + Database)**, and **Clean Architecture** principles.

---

## 🚀 Overview

QuoteVault allows users to:
- Discover motivational quotes
- Save favorite quotes
- Organize quotes into collections
- Receive daily quote notifications
- Customize theme, font size, and accent colors

---

## ✨ Features

### 🔐 Authentication
- Email & password signup/login
- Password reset
- Session persistence
- Secure authentication with Supabase Auth

### 📝 Quotes
- Browse quotes by category:
  - Motivation
  - Love
  - Success
  - Wisdom
  - Humor
- Search by quote text or author
- Pull-to-refresh
- Daily featured quote
- Material 3 quote cards

### ❤️ Favorites
- One-tap favorite/unfavorite
- View all favorite quotes
- Synced with Supabase

### 📚 Collections
- Create unlimited collections
- Add/remove quotes
- View quote count per collection
- Delete collections with confirmation

### 🔔 Notifications
- Daily quote notifications
- Custom notification time
- Enable/disable notifications
- Local notifications support

### ⚙️ Settings
- Light / Dark mode
- Accent color selection
- Font size control (12px – 24px)
- Notification time settings
- User profile management

---

## 🛠 Tech Stack

- **Flutter 3+**
- **Supabase** (Authentication & Database)
- **Material 3**
- **Google Fonts**
- **SharedPreferences**
- **flutter_local_notifications**
- **Clean Architecture**

---

## 📁 Project Structure

lib/
├── main.dart
├── app.dart
│
├── core/
│ ├── supabase_client.dart
│ ├── theme.dart
│ └── constants.dart
│
├── auth/
│ ├── login_screen.dart
│ ├── signup_screen.dart
│ ├── reset_password_screen.dart
│ └── auth_gate.dart
│
├── profile/
│ └── profile_screen.dart
│
├── quotes/
│ ├── quote_model.dart
│ ├── quote_service.dart
│ ├── home_screen.dart
│ └── quote_tile.dart
│
├── favorites/
│ └── favorites_screen.dart
│
├── collections/
│ ├── collection_model.dart
│ ├── collection_service.dart
│ ├── collections_screen.dart
│ └── collection_detail_screen.dart
│
├── notifications/
│ └── daily_quote_service.dart
│
└── widgets/
├── loading.dart
└── empty_state.dart



---

## ⚙️ Setup Instructions

### Prerequisites
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Supabase account
- Android Studio / Xcode

---

### 1️⃣ Clone Repository
```bash
git clone <repository-url>
cd QuoteVault

## 🗄 Database Schema (SQL)

> Backend: **Supabase (PostgreSQL)**  
> Note: This schema uses PostgreSQL (recommended for Supabase)

```sql
-- =========================
-- PROFILES TABLE
-- =========================
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  name TEXT,
  email TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =========================
-- QUOTES TABLE
-- =========================
CREATE TABLE quotes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  text TEXT NOT NULL,
  author TEXT NOT NULL,
  category TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =========================
-- FAVORITES TABLE
-- =========================
CREATE TABLE favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  quote_id UUID REFERENCES quotes(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id, quote_id)
);

-- =========================
-- COLLECTIONS TABLE
-- =========================
CREATE TABLE collections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =========================
-- COLLECTION QUOTES TABLE
-- =========================
CREATE TABLE collection_quotes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  collection_id UUID REFERENCES collections(id) ON DELETE CASCADE,
  quote_id UUID REFERENCES quotes(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (collection_id, quote_id)
);

-- =========================
-- ENABLE ROW LEVEL SECURITY
-- =========================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE quotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE collection_quotes ENABLE ROW LEVEL SECURITY;

-- =========================
-- PROFILES POLICIES
-- =========================
CREATE POLICY "Read profiles"
ON profiles FOR SELECT
USING (true);

CREATE POLICY "Insert own profile"
ON profiles FOR INSERT
WITH CHECK (auth.uid() = id);

CREATE POLICY "Update own profile"
ON profiles FOR UPDATE
USING (auth.uid() = id);

-- =========================
-- QUOTES POLICIES
-- =========================
CREATE POLICY "Public read quotes"
ON quotes FOR SELECT
USING (true);

-- =========================
-- FAVORITES POLICIES
-- =========================
CREATE POLICY "Read own favorites"
ON favorites FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Insert own favorites"
ON favorites FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Delete own favorites"
ON favorites FOR DELETE
USING (auth.uid() = user_id);

-- =========================
-- COLLECTIONS POLICIES
-- =========================
CREATE POLICY "Read own collections"
ON collections FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Insert own collections"
ON collections FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Update own collections"
ON collections FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Delete own collections"
ON collections FOR DELETE
USING (auth.uid() = user_id);

-- =========================
-- COLLECTION QUOTES POLICIES
-- =========================
CREATE POLICY "Read collection quotes"
ON collection_quotes FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM collections
    WHERE collections.id = collection_quotes.collection_id
      AND collections.user_id = auth.uid()
  )
);

CREATE POLICY "Insert collection quotes"
ON collection_quotes FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM collections
    WHERE collections.id = collection_quotes.collection_id
      AND collections.user_id = auth.uid()
  )
);

CREATE POLICY "Delete collection quotes"
ON collection_quotes FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM collections
    WHERE collections.id = collection_quotes.collection_id
      AND collections.user_id = auth.uid()
  )
);


