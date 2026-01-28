-- Create admin user for Artio Admin Dashboard
-- Email: minhthang4292@gmail.com
-- Password: Tonight123@
-- Note: User must be created FIRST via Supabase Dashboard or CLI

-- Add role column to profiles if not exists (already in profiles table migration)
-- This is kept here for reference but skipped by IF NOT EXISTS
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'role'
  ) THEN
    ALTER TABLE profiles ADD COLUMN role TEXT DEFAULT 'user' CHECK (role IN ('user', 'admin'));
    CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);
  END IF;
END $$;

-- Admin RLS Policies for templates
DROP POLICY IF EXISTS "Admins can manage templates" ON templates;
CREATE POLICY "Admins can manage templates"
ON templates FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid()
    AND profiles.role = 'admin'
  )
);

-- Admin RLS Policies for generation_jobs
DROP POLICY IF EXISTS "Admins can view all generation jobs" ON generation_jobs;
CREATE POLICY "Admins can view all generation jobs"
ON generation_jobs FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid()
    AND profiles.role = 'admin'
  )
);

-- Note: To set a user as admin, run after creating the user:
-- UPDATE profiles SET role = 'admin' WHERE email = 'minhthang4292@gmail.com';
