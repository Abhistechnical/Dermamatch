-- DermaMatch AI — Complete Foundation Products Database
-- Run this in Supabase SQL Editor to populate ALL skin tone combinations

-- Create foundation_products table (if not exists)
CREATE TABLE IF NOT EXISTS public.foundation_products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand TEXT NOT NULL,
    shade_name TEXT NOT NULL,
    undertone TEXT NOT NULL,
    depth TEXT NOT NULL,
    hex_reference TEXT NOT NULL,
    amazon_affiliate_url TEXT NOT NULL,
    price_range TEXT CHECK (price_range IN ('Budget', 'Mid-Range', 'Premium')),
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Create affiliate_clicks table (if not exists)
CREATE TABLE IF NOT EXISTS public.affiliate_clicks (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    product_id UUID REFERENCES public.foundation_products(id) ON DELETE CASCADE,
    clicked_at TIMESTAMPTZ DEFAULT now()
);

-- Add missing column to scans table
ALTER TABLE public.scans ADD COLUMN IF NOT EXISTS recommended_products_json JSONB;

-- Clear old placeholder data
DELETE FROM public.foundation_products;

-- ═══════════════════════════════════════════════════════
-- FAIR SKIN TONES
-- ═══════════════════════════════════════════════════════

-- Fair / Warm
INSERT INTO public.foundation_products (brand, shade_name, undertone, depth, hex_reference, amazon_affiliate_url, price_range) VALUES
('Maybelline', 'Fit Me - 110 Porcelain', 'Warm', 'Fair', '#F5D5C0', 'https://amzn.to/40EoVOe', 'Budget'),
('L''Oréal Paris', 'True Match - W1 Golden Ivory', 'Warm', 'Fair', '#F2D0B5', 'https://amzn.to/40EoVOe', 'Mid-Range'),
('Estée Lauder', 'Double Wear - 1W1 Bone', 'Warm', 'Fair', '#F0CCB0', 'https://amzn.to/40EoVOe', 'Premium');

-- Fair / Cool
INSERT INTO public.foundation_products (brand, shade_name, undertone, depth, hex_reference, amazon_affiliate_url, price_range) VALUES
('Maybelline', 'Fit Me - 105 Fair Ivory', 'Cool', 'Fair', '#F5D4C5', 'https://amzn.to/40EoVOe', 'Budget'),
('NYX', 'Can''t Stop Won''t Stop - Pale', 'Cool', 'Fair', '#F0CBBC', 'https://amzn.to/40EoVOe', 'Budget'),
('MAC', 'Studio Fix - NC10', 'Cool', 'Fair', '#EFC8B1', 'https://amzn.to/40EoVOe', 'Premium');

-- Fair / Neutral
INSERT INTO public.foundation_products (brand, shade_name, undertone, depth, hex_reference, amazon_affiliate_url, price_range) VALUES
('NYX', 'Can''t Stop Won''t Stop - Light', 'Neutral', 'Fair', '#EFC8B1', 'https://amzn.to/40EoVOe', 'Budget'),
('MAC', 'Studio Fix Fluid - N18', 'Neutral', 'Fair', '#E9C1AA', 'https://amzn.to/40EoVOe', 'Premium');

-- Fair / Olive
INSERT INTO public.foundation_products (brand, shade_name, undertone, depth, hex_reference, amazon_affiliate_url, price_range) VALUES
('Fenty Beauty', 'Pro Filt''r - 145', 'Olive', 'Fair', '#E8C9A8', 'https://amzn.to/40EoVOe', 'Premium'),
('L''Oréal Paris', 'True Match - W2 Light Ivory', 'Olive', 'Fair', '#E5C4A0', 'https://amzn.to/40EoVOe', 'Mid-Range');

-- ═══════════════════════════════════════════════════════
-- MEDIUM SKIN TONES
-- ═══════════════════════════════════════════════════════

-- Medium / Warm
INSERT INTO public.foundation_products (brand, shade_name, undertone, depth, hex_reference, amazon_affiliate_url, price_range) VALUES
('Maybelline', 'Fit Me - 220 Natural Beige', 'Warm', 'Medium', '#D4A78A', 'https://amzn.to/40EoVOe', 'Budget'),
('Estée Lauder', 'Double Wear - 3W1 Tawny', 'Warm', 'Medium', '#CF9F81', 'https://amzn.to/40EoVOe', 'Premium'),
('L''Oréal Paris', 'True Match - G3 Gold Linen', 'Warm', 'Medium', '#D9AD91', 'https://amzn.to/40EoVOe', 'Mid-Range'),
('Fenty Beauty', 'Pro Filt''r - 240', 'Warm', 'Medium', '#C59576', 'https://amzn.to/40EoVOe', 'Premium');

-- Medium / Cool
INSERT INTO public.foundation_products (brand, shade_name, undertone, depth, hex_reference, amazon_affiliate_url, price_range) VALUES
('Maybelline', 'Fit Me - 230 Natural Buff', 'Cool', 'Medium', '#D5A88E', 'https://amzn.to/40EoVOe', 'Budget'),
('MAC', 'Studio Fix - NW25', 'Cool', 'Medium', '#CFA085', 'https://amzn.to/40EoVOe', 'Premium'),
('L''Oréal Paris', 'True Match - C5 Classic Beige', 'Cool', 'Medium', '#D0A28A', 'https://amzn.to/40EoVOe', 'Mid-Range');

-- Medium / Neutral
INSERT INTO public.foundation_products (brand, shade_name, undertone, depth, hex_reference, amazon_affiliate_url, price_range) VALUES
('NYX', 'Can''t Stop Won''t Stop - Medium Olive', 'Neutral', 'Medium', '#CCA080', 'https://amzn.to/40EoVOe', 'Budget'),
('Fenty Beauty', 'Pro Filt''r - 250', 'Neutral', 'Medium', '#C89B78', 'https://amzn.to/40EoVOe', 'Premium');

-- Medium / Olive
INSERT INTO public.foundation_products (brand, shade_name, undertone, depth, hex_reference, amazon_affiliate_url, price_range) VALUES
('Fenty Beauty', 'Pro Filt''r - 235', 'Olive', 'Medium', '#C8A080', 'https://amzn.to/40EoVOe', 'Premium'),
('MAC', 'Studio Fix - NC30', 'Olive', 'Medium', '#C49A78', 'https://amzn.to/40EoVOe', 'Premium');

-- ═══════════════════════════════════════════════════════
-- TAN SKIN TONES
-- ═══════════════════════════════════════════════════════

-- Tan / Warm
INSERT INTO public.foundation_products (brand, shade_name, undertone, depth, hex_reference, amazon_affiliate_url, price_range) VALUES
('Maybelline', 'Fit Me - 330 Toffee', 'Warm', 'Tan', '#B8845E', 'https://amzn.to/40EoVOe', 'Budget'),
('Fenty Beauty', 'Pro Filt''r - 330', 'Warm', 'Tan', '#B07E58', 'https://amzn.to/40EoVOe', 'Premium'),
('L''Oréal Paris', 'True Match - W7 Caramel Beige', 'Warm', 'Tan', '#BC8A65', 'https://amzn.to/40EoVOe', 'Mid-Range');

-- Tan / Cool
INSERT INTO public.foundation_products (brand, shade_name, undertone, depth, hex_reference, amazon_affiliate_url, price_range) VALUES
('MAC', 'Studio Fix - NW40', 'Cool', 'Tan', '#B58860', 'https://amzn.to/40EoVOe', 'Premium'),
('NYX', 'Can''t Stop Won''t Stop - Camel', 'Cool', 'Tan', '#AE8058', 'https://amzn.to/40EoVOe', 'Budget');

-- Tan / Neutral
INSERT INTO public.foundation_products (brand, shade_name, undertone, depth, hex_reference, amazon_affiliate_url, price_range) VALUES
('Estée Lauder', 'Double Wear - 4N2 Spiced Sand', 'Neutral', 'Tan', '#B38560', 'https://amzn.to/40EoVOe', 'Premium'),
('L''Oréal Paris', 'True Match - N7 Nude Amber', 'Neutral', 'Tan', '#B0825C', 'https://amzn.to/40EoVOe', 'Mid-Range');

-- ═══════════════════════════════════════════════════════
-- DEEP SKIN TONES
-- ═══════════════════════════════════════════════════════

-- Deep / Warm
INSERT INTO public.foundation_products (brand, shade_name, undertone, depth, hex_reference, amazon_affiliate_url, price_range) VALUES
('Fenty Beauty', 'Pro Filt''r - 420', 'Warm', 'Deep', '#8B6040', 'https://amzn.to/40EoVOe', 'Premium'),
('Maybelline', 'Fit Me - 360 Mocha', 'Warm', 'Deep', '#905E3A', 'https://amzn.to/40EoVOe', 'Budget'),
('MAC', 'Studio Fix - NC50', 'Warm', 'Deep', '#886038', 'https://amzn.to/40EoVOe', 'Premium');

-- Deep / Cool
INSERT INTO public.foundation_products (brand, shade_name, undertone, depth, hex_reference, amazon_affiliate_url, price_range) VALUES
('Fenty Beauty', 'Pro Filt''r - 450', 'Cool', 'Deep', '#7A5035', 'https://amzn.to/40EoVOe', 'Premium'),
('NYX', 'Can''t Stop Won''t Stop - Deep Walnut', 'Cool', 'Deep', '#785038', 'https://amzn.to/40EoVOe', 'Budget');

-- Deep / Neutral
INSERT INTO public.foundation_products (brand, shade_name, undertone, depth, hex_reference, amazon_affiliate_url, price_range) VALUES
('Estée Lauder', 'Double Wear - 7N1 Deep Amber', 'Neutral', 'Deep', '#805838', 'https://amzn.to/40EoVOe', 'Premium'),
('L''Oréal Paris', 'True Match - N10 Cocoa', 'Neutral', 'Deep', '#7D5535', 'https://amzn.to/40EoVOe', 'Mid-Range');

-- Notify PostgREST to reload schema cache
NOTIFY pgrst, 'reload schema';
