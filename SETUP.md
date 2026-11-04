# Wendy's Goals — setup guide

A small web app for Wendy's daily goals. It runs on **GitHub Pages** (free hosting) and saves everything in **Supabase** (free database with sign-in). Only Wendy has an account.

## What's in this folder

| File | What it is |
|---|---|
| `index.html` | The whole app |
| `config.js` | Where you paste the Supabase address and key (step 4) |
| `schema.sql` | Creates the database tables (step 2) |
| `manifest.json`, `icon-180.png`, `icon-512.png` | Home-screen icon and name for the iPhone/iPad |

Supabase occasionally renames menu items. If a label below doesn't match exactly, look for the closest one.

---

## Part 1 — Set up Supabase (about 10 minutes)

### 1. Create the project
1. Go to **supabase.com**, sign up (free), and click **New project**.
2. Name it `wendys-goals`, make up a **database password** (save it somewhere; you won't need it day to day), and pick the **region** closest to Wendy.
3. Click **Create new project** and wait a minute or two while it starts.

### 2. Create the tables
1. In the left sidebar, open **SQL Editor** and click **New query**.
2. Open `schema.sql`, copy **everything**, paste it into the editor, and click **Run**.
3. You should see "Success. No rows returned." In **Table Editor** you'll now see five tables: `goals`, `logs`, `people`, `contacts`, `reflections`.

### 3. Create Wendy's login (and lock out everyone else)
1. Go to **Authentication → Users** and click **Add user → Create new user**.
2. Enter Wendy's **email** and a **password**, tick **Auto Confirm User**, and click **Create user**.
3. Go to **Authentication → Sign In / Providers** (on some dashboards: **Authentication → Settings**) and turn **off** "Allow new users to sign up." Click **Save**. Now nobody else can create an account.
4. Make sure the **Email** provider is enabled. It is on by default.

### 4. Copy the address and key into `config.js`
1. Go to **Project Settings → API** (on newer dashboards, **Project Settings → API Keys** and **Data API**).
2. Copy the **Project URL**, which looks like `https://abcdxyz.supabase.co`.
3. Copy the **anon public** key. Newer projects call it the **publishable** key; it starts with `sb_publishable_`. Either one works.
   **Do not** use the `service_role` / **secret** key.
4. Open `config.js` and paste them in:
   ```js
   SUPABASE_URL: 'https://abcdxyz.supabase.co',
   SUPABASE_ANON_KEY: 'paste-the-key-here',
   ```
   The anon/publishable key is designed to be public. The security rules in `schema.sql` make sure only Wendy, once signed in, can read or change her data.

---

## Part 2 — Put the app on GitHub Pages (about 10 minutes)

### 5. Upload the files
1. Sign in at **github.com** and click **New repository**. Name it `wendys-goals` and make it **Public**. (Free GitHub Pages needs a public repo; her data stays private in Supabase.) Click **Create repository**.
2. Click **uploading an existing file**, drag in all the files from this folder (`index.html`, `config.js`, `manifest.json`, both icons; `schema.sql` and this README are optional), then click **Commit changes**.

### 6. Turn on GitHub Pages
1. In the repository, go to **Settings → Pages**.
2. Under **Build and deployment**, set **Source: Deploy from a branch**, **Branch: main**, folder **/ (root)**, and click **Save**.
3. After a minute or two the page shows the address, for example `https://your-username.github.io/wendys-goals/`.

### 7. Tell Supabase the app's address (for "Forgot password?")
1. Back in Supabase, go to **Authentication → URL Configuration**.
2. Set **Site URL** to the GitHub Pages address from step 6, including the final `/`.
3. Add the same address under **Redirect URLs** and click **Save**.

---

## Part 3 — Wendy's iPhone and iPad

1. Open the GitHub Pages address in **Safari**.
2. Sign in with her email and password, keeping **Keep me signed in** ticked.
3. Tap the **Share** button, then **Add to Home Screen**, then **Add**. She now has a "Wendy's Goals" icon that opens like an app.
4. Do the same on the iPad.

The first time she signs in, the app creates starter goals: water (8 glasses), steps (8,000), bike ride, weightlifting, stretching, flexibility, reading (1 book a week), Spanish (20 min a day), declutter, Book of Mormon reading, piano, harp, and photos with Dad. She can change or stop any of them with **Change**, and add new ones (supplements, a second study subject, preparedness goals, ministering people) with the **+ Add** buttons.

---

## Good to know

- **Changing things later:** edit the file on GitHub (open it and click the pencil icon), then commit. The site updates within a minute or two.
- **Free Supabase projects pause after about a week with no use.** If Wendy uses the app most days, this won't happen. If it does, sign in to supabase.com and click **Restore project**; her data is kept.
- **Forgot password:** she types her email on the sign-in screen and taps **Forgot password?**. The email link opens the app, where she picks a new password. You can also reset it yourself under **Authentication → Users**.
- **Backups:** in Supabase **Table Editor**, any table can be exported to CSV.
- **Weeks** run Sunday through Saturday. **Months** are calendar months.
