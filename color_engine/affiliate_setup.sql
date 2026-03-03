-- Create foundation_products table
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

-- Enable RLS
ALTER TABLE public.foundation_products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public read access" ON public.foundation_products FOR SELECT USING (true);

-- Create affiliate_clicks table
CREATE TABLE IF NOT EXISTS public.affiliate_clicks (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    product_id UUID REFERENCES public.foundation_products(id) ON DELETE CASCADE,
    clicked_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS for clicks
ALTER TABLE public.affiliate_clicks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow authenticated insert" ON public.affiliate_clicks FOR INSERT WITH CHECK (true);

-- Insert sample data (Warm/Medium example)
INSERT INTO public.foundation_products (brand, shade_name, undertone, depth, hex_reference, amazon_affiliate_url, price_range)
VALUES 
('Maybelline', 'Fit Me Matte + Poreless - 220 Natural Beige', 'Warm', 'Medium', '#D4A78A', 'https://amzn.to/example-maybelline', 'Budget'),
('Estée Lauder', 'Double Wear - 3W1 Tawny', 'Warm', 'Medium', '#CF9F81', 'https://amzn.to/example-esteelauder', 'Premium'),
('L''Oréal Paris', 'True Match - G3 Gold Linen', 'Warm', 'Medium', '#D9AD91', 'https://amzn.to/example-loreal', 'Mid-Range'),
('Fenty Beauty', 'Pro Filt''r - 240', 'Warm', 'Medium', '#C59576', 'https://amzn.to/example-fenty', 'Premium');

-- Neutral/Light example
INSERT INTO public.foundation_products (brand, shade_name, undertone, depth, hex_reference, amazon_affiliate_url, price_range)
VALUES 
('NYX', 'Can''t Stop Won''t Stop - Light', 'Neutral', 'Light', '#EFC8B1', 'https://amzn.to/example-nyx', 'Budget'),
('MAC', 'Studio Fix Fluid - N18', 'Neutral', 'Light', '#E9C1AA', 'https://amzn.to/example-mac', 'Premium');
