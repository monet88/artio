-- Create templates table for AI art generation presets

CREATE TABLE IF NOT EXISTS templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  thumbnail_url TEXT,
  category TEXT NOT NULL,
  prompt_template TEXT NOT NULL,
  input_fields JSONB NOT NULL DEFAULT '[]'::jsonb,
  default_aspect_ratio TEXT DEFAULT '1:1',
  is_premium BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  "order" INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_templates_category ON templates(category);
CREATE INDEX IF NOT EXISTS idx_templates_is_active ON templates(is_active);
CREATE INDEX IF NOT EXISTS idx_templates_order ON templates("order");
CREATE INDEX IF NOT EXISTS idx_templates_is_premium ON templates(is_premium);

ALTER TABLE templates ENABLE ROW LEVEL SECURITY;

-- Public users can view active templates
CREATE POLICY "Public can view active templates"
ON templates FOR SELECT
USING (is_active = true);

-- Admins can manage all templates (created in admin migration)
CREATE POLICY "Admins can manage templates"
ON templates FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid()
    AND profiles.role = 'admin'
  )
);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_templates_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for updated_at
DROP TRIGGER IF EXISTS update_templates_updated_at ON templates;
CREATE TRIGGER update_templates_updated_at
BEFORE UPDATE ON templates
FOR EACH ROW EXECUTE FUNCTION update_templates_updated_at();
