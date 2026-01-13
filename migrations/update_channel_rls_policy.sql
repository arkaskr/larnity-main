-- Migration: Update Channel RLS Policy to Allow Group Owners and Members
-- Description: This migration updates the RLS policy for the Channel table to allow
-- both group members (from Members table) and group owners (from Group.userId) to create channels.
-- 
-- To apply this migration in Supabase:
-- 1. Go to Supabase Dashboard > SQL Editor
-- 2. Paste and run this SQL script
-- 3. Verify the policy is active

-- Drop existing INSERT policy for Channel if it exists
DROP POLICY IF EXISTS "Allow members to create channels" ON "Channel";
DROP POLICY IF EXISTS "Allow group members to create channels" ON "Channel";
DROP POLICY IF EXISTS "Channel insert policy" ON "Channel";

-- Create new RLS policy that allows both members and group owners to create channels
CREATE POLICY "Allow members and group owners to create channels"
ON "Channel"
FOR INSERT
WITH CHECK (
  -- User is a member of the group (from Members table)
  EXISTS (
    SELECT 1
    FROM "Members"
    WHERE "Members"."groupId" = "Channel"."groupId"
      AND "Members"."userId" = auth.uid()
      AND "Members"."isActive" = true
  )
  OR
  -- User is the group owner (from Group.userId)
  EXISTS (
    SELECT 1
    FROM "Group"
    WHERE "Group"."id" = "Channel"."groupId"
      AND "Group"."userId" = auth.uid()
  )
);

-- Verify the policy was created
-- You can check this by running: SELECT * FROM pg_policies WHERE tablename = 'Channel';
