# Database Migration Instructions

## Issue: Channel Creation RLS Policy Violation

### Problem
When a group is created, the creator cannot create the "general" channel because:
1. The RLS policy only allows members (from `Members` table) to create channels
2. The group creator is not automatically added to the `Members` table
3. Even after adding the creator as a member, the RLS policy doesn't allow group owners

### Solution Applied

#### 1. Code Changes (Already Applied)
- Modified `createGroup` in `group_datasource.dart` to automatically add the creator as ADMIN to the `Members` table
- Improved error handling and logging for member insertion

#### 2. Database Migration (REQUIRED - Not Yet Applied)
You need to run the SQL migration in Supabase to update the RLS policy.

### Steps to Apply Migration

1. **Go to Supabase Dashboard**
   - Open your Supabase project
   - Navigate to **SQL Editor**

2. **Run the Migration**
   - Open the file: `migrations/update_channel_rls_policy.sql`
   - Copy the entire SQL script
   - Paste it into the SQL Editor
   - Click **Run** or press `Ctrl+Enter`

3. **Verify the Policy**
   - Run this query to verify the policy was created:
   ```sql
   SELECT * FROM pg_policies WHERE tablename = 'Channel';
   ```
   - You should see a policy named "Allow members and group owners to create channels"

### What the Migration Does

The migration:
- Drops any existing INSERT policies for the Channel table
- Creates a new policy that allows BOTH:
  - **Members**: Users in the `Members` table for that group
  - **Group Owners**: Users where `Group.userId` matches the authenticated user

### Testing

After applying the migration:
1. Create a new group
2. The creator should automatically be added as ADMIN member
3. The "general" channel should be created successfully without RLS errors

### Current Status

✅ Code changes applied  
⏳ **SQL migration needs to be applied in Supabase**
