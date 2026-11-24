-- ==============================================================================
-- Influencer Pulse Database Architecture (PostgreSQL on Supabase)
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. Table: users_brand
CREATE TABLE IF NOT EXISTS public.users_brand (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL UNIQUE,
    company_name TEXT DEFAULT '',
    city TEXT DEFAULT 'Pune',
    subscription_status BOOLEAN DEFAULT FALSE,
    subscription_expiry TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Table: users_influencer
CREATE TABLE IF NOT EXISTS public.users_influencer (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    age INT DEFAULT 24,
    address TEXT DEFAULT '',
    city TEXT NOT NULL DEFAULT 'Pune',
    state TEXT NOT NULL DEFAULT 'Maharashtra',
    contact_primary TEXT NOT NULL,
    contact_secondary TEXT DEFAULT '',
    email_personal TEXT NOT NULL,
    email_work TEXT NOT NULL,
    social_links JSONB DEFAULT '{}'::jsonb,
    collabs TEXT[] DEFAULT ARRAY[]::TEXT[],
    category TEXT NOT NULL,
    price_per_reel NUMERIC(10, 2) NOT NULL,
    portfolio_images TEXT[] DEFAULT ARRAY[]::TEXT[],
    membership_tier TEXT DEFAULT 'gold' CHECK (membership_tier IN ('free', 'gold', 'burgundy')),
    membership_expiry TIMESTAMPTZ,
    bio TEXT DEFAULT '',
    followers_count TEXT DEFAULT '45K',
    rating NUMERIC(3, 2) DEFAULT 4.9,
    impressions_count INT DEFAULT 0,
    views_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Table: profile_views (Real-Time Lead Alerts)
CREATE TABLE IF NOT EXISTS public.profile_views (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    influencer_id UUID NOT NULL,
    brand_id UUID,
    brand_name TEXT DEFAULT 'Verified Brand',
    brand_email TEXT DEFAULT '',
    brand_category TEXT DEFAULT '',
    brand_location TEXT DEFAULT 'Pune',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    notified_via_email BOOLEAN DEFAULT TRUE
);

-- Indexes for lightning-fast multi-filter discovery queries
CREATE INDEX IF NOT EXISTS idx_influencer_category ON public.users_influencer(category);
CREATE INDEX IF NOT EXISTS idx_influencer_city ON public.users_influencer(city);
CREATE INDEX IF NOT EXISTS idx_influencer_price ON public.users_influencer(price_per_reel);
CREATE INDEX IF NOT EXISTS idx_influencer_tier ON public.users_influencer(membership_tier);
CREATE INDEX IF NOT EXISTS idx_profile_views_inf ON public.profile_views(influencer_id);

-- Enable Row Level Security (RLS)
ALTER TABLE public.users_brand ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users_influencer ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profile_views ENABLE ROW LEVEL SECURITY;

-- Permissive public policies for API access
DROP POLICY IF EXISTS "Public Read Influencers" ON public.users_influencer;
CREATE POLICY "Public Read Influencers" ON public.users_influencer FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public Upsert Influencers" ON public.users_influencer;
CREATE POLICY "Public Upsert Influencers" ON public.users_influencer FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public Read Brands" ON public.users_brand;
CREATE POLICY "Public Read Brands" ON public.users_brand FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public Upsert Brands" ON public.users_brand;
CREATE POLICY "Public Upsert Brands" ON public.users_brand FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public Read Views" ON public.profile_views;
CREATE POLICY "Public Read Views" ON public.profile_views FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public Insert Views" ON public.profile_views;
CREATE POLICY "Public Insert Views" ON public.profile_views FOR INSERT WITH CHECK (true);

-- Insert initial regional creator seed data
INSERT INTO public.users_influencer (
    id, name, age, address, city, state, contact_primary, contact_secondary,
    email_personal, email_work, social_links, collabs, category, price_per_reel,
    portfolio_images, membership_tier, bio, followers_count, rating, impressions_count, views_count
) VALUES
(
    'a1000000-0000-0000-0000-000000000001',
    'Aanya Deshmukh', 24, 'FC Road, Deccan', 'Pune', 'Maharashtra',
    '+91 98231 44521', '+91 88050 99214', 'aanya.personal@gmail.com', 'shiftlogiciq@gmail.com',
    '{"ig":"https://instagram.com/aanyabites","yt":"https://youtube.com/@AanyaBitesPune","tg":"https://t.me/pune_food_insider"}'::jsonb,
    ARRAY['Zomato Gold', 'Starbucks India', 'Chitale Bandhu', 'Burger King'],
    'Food Blogger', 1800.00,
    ARRAY['https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80', 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=800&q=80'],
    'gold', 'Uncovering Pune legend street flavors & artisanal cafes. 12M+ monthly video impressions.', '68K', 4.90, 1420, 184
),
(
    'a1000000-0000-0000-0000-000000000002',
    'Rohan Kulkarni', 26, 'Baner Highway', 'Pune', 'Maharashtra',
    '+91 99220 81132', '+91 91580 44211', 'rohan.tech@gmail.com', 'shiftlogiciq@gmail.com',
    '{"ig":"https://instagram.com/rohan_techtalks","yt":"https://youtube.com/@RohanTechPune"}'::jsonb,
    ARRAY['OnePlus India', 'Nothing India', 'Keychron', 'Boat Audio'],
    'Tech Blogger', 3500.00,
    ARRAY['https://images.unsplash.com/photo-1526738549149-8e07eca6c147?auto=format&fit=crop&w=800&q=80', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80'],
    'burgundy', 'Sleek mechanical keyboards, Apple ecosystem setups, and honest gadget tear-downs.', '125K', 4.95, 3100, 420
),
(
    'a1000000-0000-0000-0000-000000000003',
    'Tanya Sen', 23, 'Bandra West, Pali Hill', 'Mumbai', 'Maharashtra',
    '+91 98199 12345', '', 'tanya.sen@gmail.com', 'tanya.mgmt@pulseagency.in',
    '{"ig":"https://instagram.com/tanyasen_style","yt":"https://youtube.com/@TanyaSenVlogs"}'::jsonb,
    ARRAY['Zara', 'H&M India', 'Nykaa', 'Urbanic'],
    'Fashion & Lifestyle', 4200.00,
    ARRAY['https://images.unsplash.com/photo-1490481651871-ab68de25d43d?auto=format&fit=crop&w=800&q=80', 'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=800&q=80'],
    'gold', 'Capsule wardrobe styling, conscious fashion curation & Bombay vintage aesthetic.', '94K', 4.85, 890, 92
),
(
    'a1000000-0000-0000-0000-000000000004',
    'Kabir Joshi', 27, 'Koregaon Park, Lane 7', 'Pune', 'Maharashtra',
    '+91 97641 55990', '', 'kabir.travels@gmail.com', 'shiftlogiciq@gmail.com',
    '{"ig":"https://instagram.com/kabir_wanderlust","yt":"https://youtube.com/@KabirSahyadri"}'::jsonb,
    ARRAY['Decathlon India', 'Wildcraft', 'GoPro India', 'MakeMyTrip'],
    'Travel', 2800.00,
    ARRAY['https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80', 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?auto=format&fit=crop&w=800&q=80'],
    'gold', 'Sahyadri monsoon trails, hidden heritage stays, and offbeat Western Ghat expeditions.', '82K', 4.92, 2200, 310
),
(
    'a1000000-0000-0000-0000-000000000005',
    'Dr. Vikram Sethi', 29, 'Indiranagar 100ft Rd', 'Bengaluru', 'Karnataka',
    '+91 98450 77123', '', 'vikram.sethi.fit@gmail.com', 'vikram@fitscience.in',
    '{"ig":"https://instagram.com/dr_vikram_fitness","yt":"https://youtube.com/@FitScienceIndia"}'::jsonb,
    ARRAY['Cult.fit', 'Fast&Up', 'MuscleBlaze', 'Under Armour'],
    'Health & Fitness', 5000.00,
    ARRAY['https://images.unsplash.com/photo-1517838277536-f5f99be501cd?auto=format&fit=crop&w=800&q=80', 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?auto=format&fit=crop&w=800&q=80'],
    'burgundy', 'Evidence-based strength training, hypertrophy science, and metabolic health.', '210K', 4.98, 4600, 680
)
ON CONFLICT (id) DO NOTHING;
