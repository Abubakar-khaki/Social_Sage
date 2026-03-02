# Social Sage - PRD, MVP, ERD & Wireframes

---

## 1. PRODUCT REQUIREMENTS DOCUMENT (PRD)

### 1.1 Product Overview
**App Name:** Social Sage (Open Source Version)  
**Purpose:** Create one post and automatically send it to 13 social media platforms in the correct way. Safe, easy, automatic.  
**Target Users:** Content creators, small businesses, social media managers, influencers.  
**Platform:** Mobile App (iOS & Android)

### 1.2 Core Functionality
- One-click multi-platform posting to 13 platforms
- Automatic content adaptation per platform
- Post scheduling with calendar drag-and-drop
- AI-powered suggestions (titles, descriptions, hashtags)
- Centralized inbox for all comments, messages, and mentions
- Local data storage with encryption
- Analytics aggregation across platforms
- Library management for photos, videos, and music

### 1.3 Key Features

#### Feature 1: Dashboard
- 13 platform icons in grid layout
- Live feed preview for each platform
- Notification bell (top right)
- Large + button for creating posts

#### Feature 2: Post Creator
- Title box with AI suggestions
- Description/text box (unlimited)
- Hashtag box with AI suggestions
- Photo/video upload
- Music selection (from library)
- Post Now / Schedule Later buttons
- 5-minute cooldown after posting

#### Feature 3: Scheduler
- Calendar view
- Drag-and-drop to reschedule posts
- View all scheduled posts

#### Feature 4: Analytics
- View metrics per platform (views, likes, comments)
- Best time to post recommendations
- First post statistics
- Historical performance data

#### Feature 5: Library
- Store photos, videos, text posts
- Upload music (MP3 files)
- Tag items (Reuse/Delete)
- Minimal UI, clean design

#### Feature 6: Inbox
- Unified comments, messages, mentions from all 13 platforms
- Reply directly from inbox
- Replies route back to original platform

#### Feature 7: Settings
- User profile (name, security)
- Biometric/password authentication
- Toggle platforms on/off
- Platform-specific options (accordion list)
- Clear All Data button
- AI Suggestions toggle

### 1.4 Technical Requirements

#### Data Storage
- All data saved locally on device
- User login tokens
- Scheduled posts
- User library (photos, videos, music)
- Analytics data
- No cloud storage; self-hosted

#### APIs Required
- Facebook Graph API
- Instagram Graph API
- Twitter/X API
- TikTok API
- YouTube Data API
- LinkedIn API
- Pinterest API
- Telegram Bot API
- WhatsApp Business API (limited)
- Snapchat API
- Reddit API
- Discord Bot API
- WeChat API

#### Authentication
- OAuth2 for all 13 platforms
- One-time secure login
- Access tokens saved locally

#### Security
- AES-256 encryption for sensitive data
- Android Keystore / iOS Keychain for key storage
- Biometric authentication (fingerprint, face)
- Auto-lock after phone lock
- Password protection
- Clear All Data option

#### Push Notifications
- Notify user when posts go live
- Notify on comments/mentions

#### Special Rules
- 5-minute cooldown after posting
- User-uploaded music only (no copyrighted content)
- Platform-specific content formatting
- Error handling for limited APIs

---

## 2. MINIMUM VIABLE PRODUCT (MVP)

### 2.1 MVP Scope
The MVP includes the core functionality to make the app usable and valuable on day one.

### 2.2 MVP Features (Phase 1)

#### Must Have:
1. **Dashboard** - View 13 platform icons, open + button for new post
2. **Post Creator** - Create basic post (title, description, photo)
3. **Posting** - Post to at least 5 platforms (Facebook, Twitter, Instagram, LinkedIn, TikTok)
4. **Settings** - Add platform accounts, set username, basic security (password only, no biometric yet)
5. **Local Storage** - Save posts locally
6. **OAuth Login** - Connect to 5 main platforms

#### Nice to Have (Phase 2):
- Scheduling feature
- Analytics dashboard
- Library / Media management
- Inbox / Comments aggregation
- AI suggestions
- Biometric authentication
- All 13 platforms
- Hashtag auto-generation

### 2.3 MVP Tech Stack

**Frontend:**
- React Native (cross-platform iOS/Android)
- Redux for state management
- SQLite for local storage
- Encryption library (libsodium or similar)

**Backend (Local/Device):**
- Node.js runtime on device (or equivalent)
- SQLite database
- OAuth2 flow management

**External APIs:**
- 5 platform APIs (Facebook, Twitter, Instagram, LinkedIn, TikTok)

### 2.4 MVP Timeline
- **Week 1-2:** Setup project, OAuth for 5 platforms
- **Week 3-4:** Create post creator UI, basic posting logic
- **Week 5-6:** Settings, security, local storage
- **Week 7-8:** Testing, bug fixes, launch

### 2.5 MVP Success Metrics
- Users can create and post to all 5 platforms from one interface
- 10MB or less app size
- <5 second launch time
- Zero crashes in first 1000 users

---

## 3. ENTITY-RELATIONSHIP DIAGRAM (ERD)

### 3.1 Database Schema

```
TABLES:

User
├─ user_id (PK)
├─ username
├─ email
├─ password_hash (encrypted)
├─ created_at
├─ biometric_enabled
└─ last_sync

PlatformAccount
├─ account_id (PK)
├─ user_id (FK)
├─ platform_name (Facebook, Instagram, etc.)
├─ platform_user_id
├─ access_token (encrypted)
├─ refresh_token (encrypted)
├─ is_enabled
├─ created_at
└─ expires_at

Post
├─ post_id (PK)
├─ user_id (FK)
├─ title
├─ description
├─ hashtags (JSON)
├─ media_ids (JSON)
├─ created_at
├─ updated_at
├─ is_draft

PublishedPost
├─ published_post_id (PK)
├─ post_id (FK)
├─ account_id (FK)
├─ platform_name
├─ platform_post_id
├─ posted_at
├─ status (success, failed, pending)

ScheduledPost
├─ scheduled_post_id (PK)
├─ post_id (FK)
├─ scheduled_time
├─ account_ids (JSON)
├─ is_posted
├─ created_at

Media
├─ media_id (PK)
├─ user_id (FK)
├─ file_path (local storage path)
├─ media_type (photo, video, music)
├─ file_size
├─ duration (for video/music)
├─ created_at
└─ tags (JSON)

Analytics
├─ analytics_id (PK)
├─ published_post_id (FK)
├─ account_id (FK)
├─ views
├─ likes
├─ comments
├─ shares
├─ updated_at

Comment
├─ comment_id (PK)
├─ published_post_id (FK)
├─ account_id (FK)
├─ platform_name
├─ commenter_name
├─ comment_text
├─ created_at

Notification
├─ notification_id (PK)
├─ user_id (FK)
├─ type (post_published, new_comment, mention)
├─ message
├─ is_read
├─ created_at

SecurityLog
├─ log_id (PK)
├─ user_id (FK)
├─ action (login, logout, post, delete)
├─ timestamp
└─ details (JSON)
```

### 3.2 ER Diagram (Text Representation)

```
User (1) ─── (Many) PlatformAccount
 │
 ├─ (1) ─── (Many) Post
 │
 ├─ (1) ─── (Many) Media
 │
 ├─ (1) ─── (Many) Analytics
 │
 ├─ (1) ─── (Many) Notification
 │
 └─ (1) ─── (Many) SecurityLog

Post (1) ─── (Many) PublishedPost
 │
 ├─ (1) ─── (Many) ScheduledPost
 │
 └─ (Many) ─── (Many) Media

PlatformAccount (1) ─── (Many) PublishedPost
 │
 ├─ (1) ─── (Many) Analytics
 │
 └─ (1) ─── (Many) Comment

PublishedPost (1) ─── (Many) Analytics
 │
 ├─ (1) ─── (Many) Comment
 │
 └─ (1) ─── (Many) Notification
```

---

## 4. WIREFRAMES

### 4.1 Design System

**Color Palette:**
- Background: #181A20 (very dark gray/black)
- Card Background: #23272F (lighter dark)
- Primary Accent: #00FFD0 (neon cyan)
- Secondary Accent: #FFD700 (gold/optional)
- Text Primary: #FFFFFF (white)
- Text Secondary: #B0B3B8 (light gray)
- Error: #FF4444 (red)
- Success: #00FF88 (neon green)

**Typography:**
- Font: Inter (modern) or JetBrains Mono (coder vibe)
- Sizes: H1 (24px), H2 (20px), Body (16px), Small (14px)

**UI Elements:**
- Border Radius: 8-12px
- Icon Style: Line icons with neon accent on hover
- Button Style: Large (48px height), rounded corners, neon glow on hover
- Animations: Smooth 200-300ms transitions

---

### 4.2 Page 1: Home / Dashboard

```
┌─────────────────────────────────────┐
│  🔔  Notification Bell      Settings ⚙│
├─────────────────────────────────────┤
│                                     │
│  Welcome, [Username]!               │
│                                     │
│   [FB]  [IG]  [TW]                 │
│   [TK]  [YT]  [LI]                 │
│   [PT]  [TG]  [WA]                 │
│   [SC]  [RD]  [DC]  [WC]           │
│                                     │
│          ┌──────────┐               │
│          │    +     │  ← New Post   │
│          └──────────┘               │
│                                     │
│  Recent Posts:                      │
│  • "My new blog post..." 2h ago     │
│  • "Check this out!" 5h ago         │
│                                     │
└─────────────────────────────────────┘
```

**Elements:**
- Header: Logo, notification bell, settings
- Grid: 13 platform icons (tap to see feed)
- Large + button in center
- Recent posts list below
- Bottom navigation (hidden, swipe up)

---

### 4.3 Page 2: Post Creator

```
┌─────────────────────────────────────┐
│  ← Back         Post Creator        │
├─────────────────────────────────────┤
│                                     │
│  Title: [________________________] │
│         ✨ AI Suggestion            │
│                                     │
│  Description:                       │
│  [____________________________]     │
│  [____________________________]     │
│  [____________________________]     │
│         ✨ AI Suggestion            │
│                                     │
│  Hashtags:                          │
│  [__________] [__________]         │
│         ✨ AI Suggestion (3-5)      │
│                                     │
│  Media:  [📷 Add Photo/Video]       │
│                                     │
│  [ ] Add Music  (Only from Library) │
│                                     │
│  ┌──────────────┐  ┌─────────────┐ │
│  │  Post Now    │  │ Schedule    │ │
│  └──────────────┘  └─────────────┘ │
│                                     │
│  ⓘ Posting to: FB, IG, TW, TK, YT  │
│                                     │
└─────────────────────────────────────┘
```

**Elements:**
- Title input with AI suggestion button
- Long text description
- Hashtag input
- Media upload button
- Music switch (only from library)
- Two large buttons (Post Now / Schedule)
- Platform preview at bottom

---

### 4.4 Page 3: Scheduler

```
┌─────────────────────────────────────┐
│  ← Back          Scheduler          │
├─────────────────────────────────────┤
│                                     │
│  Feb 2026    < February >  >        │
│  ┌─────────────────────────┐        │
│  │ Su Mo Tu We Th Fr Sa    │        │
│  │    1  2  3  4  5  6     │        │
│  │  7  8  9 10 11 12 13    │        │
│  │ ... (calendar continues)│        │
│  └─────────────────────────┘        │
│                                     │
│  Scheduled Posts:                   │
│  • Feb 20 @ 9:00 AM                │
│    "New blog post launch"           │
│    [FB IG TW]  [Edit] [Delete]     │
│                                     │
│  • Feb 21 @ 2:00 PM                │
│    "Product announcement"           │
│    [YT TK]  [Edit] [Delete]        │
│                                     │
│  • Feb 25 @ 7:00 PM                │
│    "Weekend tips"                  │
│    [All 13]  [Edit] [Delete]       │
│                                     │
└─────────────────────────────────────┘
```

**Elements:**
- Calendar month view (drag-drop to reschedule)
- List of scheduled posts below
- Each post shows: date/time, text preview, platforms, edit/delete
- Swipe to delete option

---

### 4.5 Page 4: Analytics

```
┌─────────────────────────────────────┐
│  ← Back          Analytics          │
├─────────────────────────────────────┤
│                                     │
│  Last 7 Days:                       │
│                                     │
│  ┌──────────────────────────┐       │
│  │ Total Views: 2,450       │       │
│  │ Total Likes: 340         │       │
│  │ Total Comments: 85       │       │
│  └──────────────────────────┘       │
│                                     │
│  Best Time to Post:                 │
│  🕐 Friday 7:00 PM (Most Views)    │
│                                     │
│  Platform Breakdown:                │
│  ┌─────────────────────────────┐   │
│  │ Instagram: 👁️ 800  👍 150   │   │
│  │ Twitter:   👁️ 600  👍 120   │   │
│  │ TikTok:    👁️ 500  👍 60    │   │
│  │ LinkedIn:  👁️ 400  👍 10    │   │
│  │ Facebook:  👁️ 150  👍 0     │   │
│  └─────────────────────────────┘   │
│                                     │
│  Your First Post (Feb 1):           │
│  "Starting my journey..."           │
│  Views: 1,200  Likes: 95            │
│                                     │
└─────────────────────────────────────┘
```

**Elements:**
- Summary cards (views, likes, comments)
- Best time to post recommendation
- Platform-by-platform breakdown
- First post statistics
- Chart/graph view (optional)

---

### 4.6 Page 5: Library

```
┌─────────────────────────────────────┐
│  ← Back           Library           │
├─────────────────────────────────────┤
│  [📷 Photos] [🎬 Videos] [🎵 Music] │
├─────────────────────────────────────┤
│                                     │
│  [Upload Photo/Video] [Upload Music]│
│                                     │
│  Photos:                            │
│  ┌──────┐ ┌──────┐ ┌──────┐       │
│  │ IMG1 │ │ IMG2 │ │ IMG3 │       │
│  └──────┘ └──────┘ └──────┘       │
│  ☆ Reuse  ☆ Reuse  ☆ Delete      │
│                                     │
│  Videos:                            │
│  ┌──────┐ ┌──────┐                 │
│  │ VID1 │ │ VID2 │                 │
│  ├──────┤ ├──────┤                 │
│  │ 45s  │ │ 1:20 │                 │
│  └──────┘ └──────┘                 │
│  ☆ Delete  ☆ Delete                │
│                                     │
│  Music:                             │
│  ┌──────────────────────────────┐  │
│  │ Song 1 - Artist A      [DEL] │  │
│  │ Song 2 - Artist B      [DEL] │  │
│  │ Song 3 - Artist C      [DEL] │  │
│  └──────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

**Elements:**
- Tabs for Photos, Videos, Music
- Upload buttons
- Grid layout for photos/videos
- List for music files
- Tag/delete buttons
- Clean, minimal design

---

### 4.7 Page 6: Inbox

```
┌─────────────────────────────────────┐
│  ← Back            Inbox            │
├─────────────────────────────────────┤
│  [All] [Comments] [Likes] [Mentions]│
│                                     │
│  NEW:                               │
│  👤 John Doe (Instagram)            │
│  "Great post! Love it 🔥"            │
│  [Reply] [Like] [Delete]            │
│                                     │
│  👤 Jane Smith (Twitter)            │
│  "Thanks for sharing"               │
│  [Reply] [Like] [Delete]            │
│                                     │
│  👤 Tech News (Facebook)            │
│  "Loved your insights!"             │
│  [Reply] [Like] [Delete]            │
│                                     │
│  EARLIER:                           │
│  👤 Alex Chen (LinkedIn)            │
│  "Adding to my reading list"        │
│  [Reply] [Like] [Delete]            │
│                                     │
│  ┌────────────────────────────────┐ │
│  │ Write reply...    [Send →]     │ │
│  └────────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

**Elements:**
- Tabs for filtering (all, comments, likes, mentions)
- List of interactions from all platforms
- User profile pic, name, platform, message
- Reply/like/delete action buttons
- Reply text box at bottom
- Timestamps

---

### 4.8 Page 7: Settings

```
┌─────────────────────────────────────┐
│  ← Back          Settings           │
├─────────────────────────────────────┤
│                                     │
│  👤 Profile                         │
│  Username: [_________________]      │
│  Email: [_________________]         │
│  [Save Change]                      │
│                                     │
│  🔐 Security                        │
│  [ ] Biometric (Fingerprint)  [ON]  │
│  [ ] Password Protection      [ON]  │
│  Change Password: [_______] [Update]│
│  Auto-lock after phone lock   [ON]  │
│                                     │
│  📱 Platforms                       │
│  Connected Accounts:                │
│  ▼ Facebook      ✓ Connected        │
│    [ ] Timeline  [ ] Story [+]      │
│    [ ] Group     [ ] Page           │
│                                     │
│  ▼ Instagram     ✓ Connected        │
│    [ ] Feed      [ ] Reels [+]      │
│    [ ] Story                        │
│                                     │
│  ▼ Twitter       ✗ Disconnected     │
│    [+ Connect]                      │
│                                     │
│  ⚙️  App Settings                   │
│  AI Suggestions: [ON] / [OFF]       │
│  Notifications:   [ON] / [OFF]      │
│  Dark Mode:       [ON] / [OFF]      │
│                                     │
│  ⚠️ Danger Zone                     │
│  [Clear All Data] [Logout]          │
│                                     │
└─────────────────────────────────────┘
```

**Elements:**
- Profile section (username, email)
- Security toggle and password change
- Connected platforms with accordions
- Platform-specific options (checkboxes)
- App settings (AI, notifications, dark mode)
- Danger zone (clear all, logout)

---

### 4.9 First-Time Setup Screens

#### Screen 1: Welcome & Username
```
┌─────────────────────────────────────┐
│         Social Sage                 │
│                                     │
│   Welcome! Let's set you up.        │
│                                     │
│  Your Name/Username:                │
│  [_______________________]          │
│                                     │
│           [Next →]                  │
│                                     │
└─────────────────────────────────────┘
```

#### Screen 2: Security Setup
```
┌─────────────────────────────────────┐
│   Secure Your Account               │
│                                     │
│  Choose Security Method:            │
│                                     │
│  [ ] Fingerprint (Recommended)      │
│  [ ] Face Recognition               │
│  [ ] Password Only                  │
│                                     │
│  Set Password:                      │
│  [_______________________]          │
│  Confirm: [_______________________] │
│                                     │
│   [< Back]       [Done]             │
│                                     │
└─────────────────────────────────────┘
```

---

## 5. DESIGN SPECIFICATIONS

### 5.1 Component Specifications

**Buttons:**
- Size: 48px height, 16px padding horizontal
- Color: Neon cyan (#00FFD0) on dark background
- Hover: Glow effect, brightness increase
- Active: Darker shade (#00CCA0)

**Input Fields:**
- Background: #23272F
- Border: 1px #B0B3B8
- Active: 2px #00FFD0
- Padding: 12px
- Font: 16px

**Cards:**
- Background: #23272F
- Border: 1px #B0B3B8 (optional)
- Shadow: 0 4px 12px rgba(0,0,0,0.3)
- Border-radius: 8px

**Icons:**
- Style: Line icons (24x24px)
- Color: #B0B3B8 (default), #00FFD0 (active)

### 5.2 Spacing & Layout
- Margin: 16px, 24px, 32px
- Padding: 12px, 16px, 20px
- Gap between elements: 16px

### 5.3 Animations
- Transition time: 200-300ms
- Easing: ease-in-out
- Hover effects on all interactive elements
- Smooth page transitions

---

## 6. NAVIGATION FLOW

```
┌─────────────────┐
│  Splash/Onboard │ (First time only)
└────────┬────────┘
         │
         ↓
    ┌─────────────┐
    │   Login     │ (OAuth setup)
    └────┬────────┘
         │
         ↓
    ┌──────────────────┐
    │  Dashboard/Home  │
    │                  │
    ├→ [Platform Icon] → Live Feed
    ├→ [+ Button]      → Post Creator → Post Now → Success
    │                                 └→ Schedule Later → Scheduler
    ├→ [Bell] Notifications
    └→ [Settings] Icon
       │
       ├→ Scheduler    (View/Edit/Delete scheduled posts)
       ├→ Analytics    (View metrics)
       ├→ Library      (Photos/Videos/Music)
       ├→ Inbox        (Comments/Mentions/Messages)
       └→ Settings     (Profile/Security/Accounts)
```

---

## 7. SUCCESS METRICS & KPIs

### 7.1 User Engagement
- Daily Active Users (DAU)
- Posts published per user
- Average session duration
- Features used most

### 7.2 Technical Metrics
- App crash rate (target: <0.1%)
- Average response time: <2 seconds
- API success rate: >95%
- Storage usage: <100MB

### 7.3 User Satisfaction
- App Store rating: >4.5 stars
- User retention (Day 7, Day 30)
- Feature adoption rate
- Support tickets / feedback

---

## 8. FUTURE ROADMAP (Post-MVP)

### Phase 2: Extended Features
- [ ] All 13 platforms fully supported
- [ ] Advanced analytics (charts, graphs, trends)
- [ ] AI content generation
- [ ] Team collaboration
- [ ] White-label version

### Phase 3: Premium Features
- [ ] Advanced scheduling
- [ ] A/B testing for posts
- [ ] Competitor analysis
- [ ] Content calendar
- [ ] Auto-posting based on best times

### Phase 4: Enterprise
- [ ] Multi-account management
- [ ] Role-based access control
- [ ] Custom branding
- [ ] API for third-party integrations
- [ ] Analytics export

---

**Document Version:** 1.0  
**Last Updated:** February 19, 2026  
**Status:** Draft
