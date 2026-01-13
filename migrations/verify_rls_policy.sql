-- Verification Script: Check Channel RLS Policies
-- Run this in Supabase SQL Editor to verify the policy is correctly applied

-- 1. Check all existing policies on Channel table
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'Channel'
ORDER BY policyname;

-- 2. Check if the new policy exists
SELECT 
    policyname,
    cmd as operation,
    with_check as policy_condition
FROM pg_policies 
WHERE tablename = 'Channel' 
    AND policyname = 'Allow members and group owners to create channels';

-- 3. Test query to see if a user can create a channel (replace with actual user ID and group ID)
-- SELECT auth.uid() as current_user_id;
-- 
-- -- Check if user is member of a group (replace 'GROUP_ID' with actual group ID)
-- SELECT EXISTS (
--     SELECT 1
--     FROM "Members"
--     WHERE "Members"."groupId" = 'GROUP_ID'
--       AND "Members"."userId" = auth.uid()
--       AND "Members"."isActive" = true
-- ) as is_member;
--
-- -- Check if user is owner of a group (replace 'GROUP_ID' with actual group ID)
-- SELECT EXISTS (
--     SELECT 1
--     FROM "Group"
--     WHERE "Group"."id" = 'GROUP_ID'
--       AND "Group"."userId" = auth.uid()
-- ) as is_owner;
