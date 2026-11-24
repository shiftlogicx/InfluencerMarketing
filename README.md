# CreatorPulse — Regional Micro-Influencer Marketplace

A two-sided lead-generation platform connecting regional micro-influencers with local brands, engineered with a hybrid **Firebase + Supabase** architecture and zero cold-start hosting on **Firebase Hosting**.

🌐 **Live Deployed Platform**: [https://creatorpulse-app.web.app](https://creatorpulse-app.web.app)  
📧 **Master Administrator / Contact**: `shiftlogiciq@gmail.com`  
🎨 **Design Philosophy**: Minimalist Apple Studio aesthetic (Space Black, frosted glass cards, SF Pro/Inter typography, zero AI-slop).

---

## 1. Architectural Highlights

| Service | Technology | Role in Architecture |
|---|---|---|
| **Frontend** | Flutter Web (Web for Brands, App/Web for Influencers) | Single codebase responsive cross-platform client |
| **Hosting** | Firebase Hosting (Global CDN) | Zero cold starts, instant static delivery (strictly avoiding Render sleep delays) |
| **Authentication** | Firebase Authentication | Google SSO (`shiftlogiciq@gmail.com`) |
| **Database** | Supabase (PostgreSQL) | Relational multi-filter queries (Category, City, Price Range slider) |
| **Storage** | Supabase Storage (`influencer-portfolios`) | High-res portfolio imagery storage |
| **Payments** | Razorpay API | Brand ₹49/mo pass, Gold ₹149/3mo, Burgundy ₹399/6mo memberships |
| **Email Engine** | Resend / Supabase Edge Functions | Automated background LinkedIn-style lead dispatch |

---

## 2. Core Modules Implemented

### Module 1: Influencer Onboarding & Profile Management
- **Picture-Ready Onboarding**: Multi-step wizard with real-time portfolio photo preview.
- **Early-Access Marketing Hook**: Strikethrough pricing hook:
  ```
  Gold Membership: ~₹149~ FREE for early access
  ```
- **Data Collection**:
  - Personal details: Full Name, Age, Neighborhood/Studio Address, City, State.
  - Paywalled contact coordinates: Primary Phone, Secondary Phone, Personal Email, Work Email (`shiftlogiciq@gmail.com`).
  - Social Links: Instagram, Telegram, Snapchat, X (Twitter), YouTube.
  - Professional Commercials: Category dropdown (10 niches), Price per Reel slider, Past brand collaborations interactive tag chips.
  - Portfolio Showcase: 3 to 5 images saved to Supabase Storage.

### Module 2: Brand Search & Discovery Engine
- **Geo-Location Lock**: Prompts for location services on entry; auto-filters regional creators based on current city (e.g. Pune, Maharashtra).
- **Relational Filters (PostgreSQL Powered)**:
  - 10 Categories: Food Blogger, Tech Blogger, Fashion & Lifestyle, Travel, Health & Fitness, Journalist, News Reporter, Finance, Gaming, Beauty.
  - Price Range Slider: `₹500` to `₹20,000+`.
  - Location Dropdown: Pune, Mumbai, Bengaluru, Delhi NCR, Hyderabad, Chennai, etc.
- **Teaser Cards with Critical Limitation**:
  - Displays high-resolution portfolio, Name, Category, Reel Price, Past Collabs.
  - **Paywalled Blur**: Phone numbers, emails, and handles are obscured with frosted glass blur until unlocked.

### Module 3: Monetization & The Paywall (Razorpay)
- **For Brands**: `₹49 / month` to unblur all creator contact details across the platform.
- **For Influencers**:
  - **Free Tier**: Listed on marketplace, generic teaser notifications.
  - **Gold Membership**: `₹149 / 3 months` (Unlocks exact names & direct emails of brands who view their profile).
  - **Burgundy VIP Membership**: `₹399 / 6 months` (Includes Gold perks + Top-Rank Priority placement in Brand searches).

### Module 4: The "LinkedIn-Style" Notification Engine
- **Background Impression & View Tracking**:
  - When a brand searches for creators and clicks a profile, the platform logs 1 impression for remaining creators and 1 profile view for the clicked creator.
- **Email Dispatch Logic**:
  - **Free Tier Influencer**:
    - Subject: `Someone viewed your profile!`
    - Body: `A brand looking for [Category] in [Location] viewed your profile. Upgrade to Gold to see who they are and contact them directly.`
  - **Gold / Burgundy Tier Influencer**:
    - Subject: `[Brand Name] viewed your profile!`
    - Body: Includes the brand's verified contact email, company name, and direct reach-out coordinates.

---

## 3. Database Schema (Supabase PostgreSQL)

The schema maps the Firebase Auth `uid` as the primary key (`id UUID`) in the Supabase tables:

```sql
-- See supabase/schema.sql for the complete DDL script
CREATE TABLE public.users_brand (
    id UUID PRIMARY KEY, -- References Firebase Auth UID
    email TEXT NOT NULL,
    company_name TEXT,
    city TEXT,
    subscription_status BOOLEAN DEFAULT FALSE,
    subscription_expiry TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.users_influencer (
    id UUID PRIMARY KEY, -- References Firebase Auth UID
    name TEXT NOT NULL,
    age INT,
    address TEXT,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    contact_primary TEXT NOT NULL,
    contact_secondary TEXT,
    email_personal TEXT NOT NULL,
    email_work TEXT NOT NULL,
    social_links JSONB DEFAULT '{}'::jsonb,
    collabs TEXT[] DEFAULT ARRAY[]::TEXT[],
    category TEXT NOT NULL,
    price_per_reel NUMERIC(10, 2) NOT NULL,
    portfolio_images TEXT[] DEFAULT ARRAY[]::TEXT[],
    membership_tier TEXT DEFAULT 'free' CHECK (membership_tier IN ('free', 'gold', 'burgundy')),
    membership_expiry TIMESTAMPTZ,
    impressions_count INT DEFAULT 0,
    views_count INT DEFAULT 0
);

CREATE TABLE public.profile_views (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    influencer_id UUID NOT NULL REFERENCES public.users_influencer(id) ON DELETE CASCADE,
    brand_id UUID NOT NULL REFERENCES public.users_brand(id) ON DELETE CASCADE,
    brand_name TEXT,
    brand_email TEXT,
    brand_category TEXT,
    brand_location TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    notified_via_email BOOLEAN DEFAULT FALSE
);
```

---

## 4. Local Development & Deployment

### Build & Deploy
```bash
# 1. Get dependencies
flutter pub get

# 2. Build for production web
flutter build web --release

# 3. Deploy to Firebase Hosting (Instant, zero cold starts)
npx firebase-tools deploy --only hosting --project creatorpulse-app
```
