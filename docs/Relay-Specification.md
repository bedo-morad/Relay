# Relay — Requirements Specification Pack

**Version:** 1.0.1
**Date:** 2026-08-20
**Status:** Signed

---

## 1. Document Control

### 1.1 Document Information

| Field | Value |
|---|---|
| Product name | Relay |
| Document type | Requirements specification pack (PRD + functional requirements + acceptance criteria + technical requirements) |

### 1.2 Revision History

| Version | Date | Author | Change |
|---|---|---|---|
| 1.0 | 2026-08-20 | PM | Initial draft |
| 1.0.1 | 2026-08-23 | Owner | Amendments D-18…D-22: Boot/Java pins, Resend email delivery, social-login scope reduction, admin-client versioning |

### 1.3 Sign-off

Approval of this document constitutes agreement to the scope, functional requirements, acceptance criteria, and deliverables defined herein.

---

## 2. Executive Summary

Relay is a hosted web application for creating, storing, and sharing notes via unique links. It is positioned as a simplified alternative to Pastebin aimed at **general, non-technical users**. It deliberately excludes code-specific features (syntax highlighting, diffs, raw endpoints, public gallery).

The product is monetized through a **free tier** and a **Pro subscription at 250 EGP/month**:

- **Free tier:** up to 5 notes, 1KB of text per note, 10MB attachment per note.
- **Pro tier:** unlimited notes, 1MB of text per note, 50MB attachment per note, and short-link creation.

The application is a **web app only**, responsive for desktop and mobile browsers. Delivery must include a fully localized experience (Arabic/English human quality, French/Spanish/German AI quality), a strong marketing/landing presence, brand media deliverables, dark/light themes, and a set of batch analytics.

The build is fully prescribed by technology stack (Section 6) and includes deployment hosting, CI/CD, and design deliverables (Section 13).

---

## 3. Business Objectives & Success Criteria

| Objective | Success measure |
|---|---|
| Launch a simple, reliable note-sharing service | Service live on a public domain, usable by the public |
| Monetize via Pro subscription (250 EGP/month) | Subscriptions accepted through required payment providers (Section 12) |
| Convert free users to Pro | Free-limit enforcement and Pro upsell flows work correctly; conversion funnel measurable via analytics |
| Support an Egyptian-first and international audience | Localization (AR/EN full, FR/ES/DE AI) and Egyptian + western payment methods |
| Support large concurrent usage at low latency | Load balancer, Redis caching, and performance NFRs (Section 10) |

---

## 4. Scope

### 4.1 In Scope

- All functional requirements in Section 8.
- All non-functional requirements in Section 10.
- All deliverables in Section 13 (code, media, docs, hosting, CI/CD).
- All prescribed technology (Section 6).

### 4.2 Out of Scope

- Mobile native applications (iOS/Android) — web app only.
- Public gallery or browse/search of other users' notes.
- Code-specific features (syntax highlighting, diffs, raw API endpoints).
- Automatic malware/antivirus scanning of uploads — users may upload any file type.
- Real-time analytics.
- Managing previously created short links (list/update/delete) — short links are create-only by design (FR-09).

### 4.3 Deferred (explicitly not required now)

- Additional Pro-plan perks beyond those listed in Section 8.8.
- Additional languages beyond the five specified.
- API access for third parties.

---

## 5. Roles & Permissions

| Role | Description | Key permissions |
|---|---|---|
| Guest (unauthenticated) | Any visitor | View public notes via link; prompted for password on protected notes; informed that private notes are private. Cannot create notes. |
| Free user | Registered user, no subscription | Create/update/delete own notes (max 5), see own private notes, hit Pro upsell at limit. |
| Pro user | Registered user with active 250 EGP/mo subscription | All free-user permissions, unlimited notes, larger limits, short links. |
| Admin | Internal client/company staff | Note takedown, report queue, user lookup, content page management (changelog/news), analytics access. |

---

## 6. Prescribed Technology Stack

The following stack is mandatory. No substitution without written client approval.

| Layer | Technology | Version / Notes |
|---|---|---|
| Backend | Spring Boot | 4.0.8 (pinned — springdoc-openapi compatibility, see D-18; upgrade path to 4.1.x tracked) |
| Frontend | Angular | 22 (TypeScript), Bootstrap |
| Database | PostgreSQL | Pin a fixed major (e.g., 18.x) at latest patch — not "latest LTS" |
| Identity / Auth | Keycloak | Handles registration, login, email verification, password reset, and social login (Facebook, X, Google, Apple) |
| API documentation | OpenAPI / Swagger | OpenAPI spec generated from all backend endpoints; serves as the integration contract. Swagger UI is exposed in dev/staging only; in production it is disabled or restricted (Section 14, D-11). |
| Background/batch jobs | Spring Batch | Expiration handling, attachment processing, analytics aggregation |
| Caching | Redis | Session/cache layer; Redis key TTL is set to match each note's expiry (lazy expiration, FR-06) |
| Load balancing | Load balancer | Distribute traffic across backend instances |
| Containerization | Docker | Backend and frontend |
| Version control | GitHub | Single monorepo (backend + frontend) |
| CI/CD | GitHub Actions | Automated build, test, and deploy pipelines |

### 6.1 Architecture Requirements

- The entire codebase lives in a single **monorepo** (one repository, one CI/CD pipeline). Backend and frontend remain separate, independently deployable units.
- Keycloak is used for all authentication flows (local email/password, email verification, password reset, and the four social logins: Facebook, X, Google, Apple).
- A load balancer sits in front of the backend.
- Redis is used for caching (e.g., hot note reads, session data, rate limiting metadata). Cached note data carries a Redis TTL matching the note's expiry, and caches are invalidated on note update and deletion, so stale data is never served. Redis is Relay-owned (cache/rate-limit storage); Keycloak manages its own sessions.
- Caching rules: cache canonical data only — never cache authorization results or rendered responses; the access decision (owner/privacy/password/expiry/takedown) is re-evaluated after every cache or DB load. No negative caching initially.
- Redis topology: single node with AOF persistence at launch; clustering/HA only if scale demands (Section 14, D-15).
- Expiration is **lazy**: access validity is checked at read time; no background job is required for a note to become expired, and expiration never deletes a note directly (expired notes are purged after 90 days, D-17). After expiry the note is inaccessible to everyone, including its creator (FR-06).
- OpenAPI/Swagger must document all backend endpoints.
- Docker Compose or equivalent must allow local reproduction of the full stack.
- **Version matrix:** pin mutually compatible versions for Java (**17, pinned** — D-21), Node, TypeScript, springdoc-openapi (verify Spring Boot 4.x compatibility explicitly — springdoc 3.x targets Boot 4.0.x, which drove D-18), Keycloak (26.x), Redis, and the build tool; lockfiles/toolchain files are deliverables (Section 13.1).

---

## 7. Terminology

| Term | Definition |
|---|---|
| Note | The core content unit: title, text, category, expiry, privacy, optional password, optional attachment. |
| Note URL | `https://<domain>/<note-id>` where note-id is the note's UUID. |
| Short link | A Pro-only, create-only redirect for an external URL (Bit.ly-style). Users cannot list, update, or delete created short links. |
| Expiry | Time at which a note becomes inaccessible to everyone, including its creator (lazy expiration). The note is never deleted by expiry itself; expired notes are purged after 90 days (D-17). |
| Attachment | A single optional file attached to a note, of any type. |
| TOS | Terms of Service. |

---

## 8. Functional Requirements

Each functional requirement has an ID (FR-xx), a description, user stories, acceptance criteria (AC), and a phase.

**Phase definitions:**
- **P1 — Core (must build):** everything required for the product to function.
- **P2 — Monetization:** subscription, billing, and Pro features.
- **P3 — Support & content:** marketing pages, localization, media, analytics.

Phases are a scheduling guide; all phases are in contract scope. See Section 16 for the phase breakdown.

### 8.1 FR-01 — Account Creation & Authentication (Phase P1)

**Description:** Users register, log in, and manage identity. Authentication is handled by Keycloak. Email verification and password reset are required. Social login at launch supports Google and Facebook (Apple/X deferred — D-20). Every account has a display name. Email acts as the username/login. A user can delete their own account.

**User stories:**
- As a visitor, I can create an account with a display name, email, and password.
- As a new user, I must verify my email before I can log in.
- As a user, I can reset my password by email if I forget it.
- As a user, I can register and log in with Facebook, X, Google, or Apple.
- As a user, I can log out.
- As a user, I can permanently delete my account.

**Acceptance criteria:**
- AC-01-01 Registration requires a display name (max 50 chars), email, and password. Email is the username/login. Duplicate email is rejected with a clear message.
- AC-01-02 A verification email is sent upon registration; a resend option exists. The account **cannot log in until the email is verified**.
- AC-01-03 Password reset flow: request → email link → set new password. Reset links are single-use and expire after 1 hour.
- AC-01-04 Social login works with all delivered providers. **Amended by D-20:** launch scope is Google + Facebook; Apple and X are deferred (paid developer accounts required) — the Keycloak realm is designed so their generic OIDC/OAuth2 broker configs can be added later without code changes. A display name is taken from the provider (fallback: "User") and can be changed later. Where a social login email matches an existing account, the accounts are linked after user confirmation; the definition of duplicate-account handling is a Keycloak first-broker-login policy. The immutable Relay owner ID is the Keycloak `sub` claim.
- AC-01-05 A password strength policy is enforced; weak passwords (e.g., "12345678") are rejected with a localized message.
- AC-01-06 An unverified account is blocked at the login page — it cannot sign in. As a guest (not logged in), a visitor can still view public notes.
- AC-01-07 A user can permanently delete their account. Deletion is orchestrated by the application: it removes all the user's notes and attachments and invalidates all their cached data first, then deletes the Keycloak account (with the `DELETE_ACCOUNT` required action enabled and the delete-account role assigned). The flow is idempotent and safe on partial failure. A confirmation step is required. (Right-to-erasure, FR-01.)
- AC-01-08 All auth errors (wrong password, unverified email, expired reset link) show clear, localized messages.

### 8.2 FR-02 — Note Creation (Phase P1)

**Description:** An authenticated user creates a note with the following fields: title, text, category, expiry, privacy, optional password, and optional attachment.

**User stories:**
- As a user, I can create a note with a title, text, and category.
- As a user, I can choose an expiry from the fixed list (Section 8.6).
- As a user, I can choose privacy: public / protected / private.
- As a user, I can set a password when privacy is "protected".
- As a user, I can attach one file of any type.

**Acceptance criteria:**
- AC-02-01 Title is optional; if left empty, the note is saved with the title "Untitled" (localized). Max title length: 256 characters.
- AC-02-02 Text is required; empty text with no attachment cannot be saved.
- AC-02-03 Category is selected from the fixed list (Section 9.3); it is required and has a default of "General".
- AC-02-04 Expiry is required and chosen from the fixed list; default is "never".
- AC-02-05 Privacy is required; default is "public".
- AC-02-06 A password is required if and only if privacy is "protected". If privacy is not "protected", no password is requested.
- AC-02-07 Exactly one attachment per note, chosen at creation time; selecting a file before saving replaces the previous selection. An attachment on an existing note cannot be changed (see D-05).
- AC-02-08 Text length and attachment size limits are enforced per tier (Section 9.1). Enforcement is mandatory **server-side**; client-side checks are optional UX only.
- AC-02-09 On success, the user is shown the note URL and can copy it. The URL format is `https://<domain>/<note-id>`.
- AC-02-10 Free users at their 5-note limit are blocked from creating (see FR-07).

### 8.3 FR-03 — Note URL & Access Rules (Phase P1)

**Description:** Every note is accessible at `https://<domain>/<note-id>`. Access behavior depends on privacy. For protected and private notes, **no note data is returned at all** unless access is authorized.

**Rules:**
- **Public:** anyone with the link can view the full note (title, text, category, attachment download).
- **Protected:** the visitor sees only a password prompt. No note data (including title and category) is revealed until the correct password is provided. On success, the visitor can view and download like a public note.
- **Private:** visitors who are not the owner see only a localized notice that this note is private. No note data is returned. The owner, when logged in, can view it.

**Acceptance criteria:**
- AC-03-01 GET on `/note-id` for a public note returns full content.
- AC-03-02 GET on `/note-id` for a protected note returns a password prompt only; the response contains no note title, text, category, or attachment.
- AC-03-03 Submitting the correct password returns full content; an incorrect password returns an error without revealing data. Rate-limiting on password attempts is required.
- AC-03-04 GET on `/note-id` for a private note returns a "private note" notice only, with no note data, for anyone who is not the owner.
- AC-03-05 The owner, logged in, can view their own private note.
- AC-03-06 The note-id is a UUID v4 (RFC 4122, random) and is not predictable or enumerable.
- AC-03-07 After expiry, everyone (including the creator) sees the "This note has expired" message; no note data is returned (FR-06).
- AC-03-08 Access resolution order (applies to text and attachments): deleted/not found > removed (takedown) > expired > privacy/password. Admin moderation access is the single authorized exception (FR-10).

### 8.4 FR-04 — Note Viewing & Sharing (Phase P1)

**Description:** A visitor can read a note, copy its link, and download the attachment.

**User stories:**
- As a visitor, I can read the note text.
- As a visitor, I can copy the note link.
- As a visitor, I can download the attached file.
- As a visitor, I can report a note (FR-10).

**Acceptance criteria:**
- AC-04-01 Text renders with preserved line breaks; plain-text presentation. Content is served as text/plain or escaped HTML — no markdown/HTML rendering.
- AC-04-02 The shareable URL is `https://<domain>/<note-id>` and is copyable with one click.
- AC-04-03 Attachment download works and preserves the original filename; download respects the visibility rules of FR-03.
- AC-04-04 A report action is available to any visitor (FR-10).
- AC-04-05 Guest visitors can use all viewer features without an account.

### 8.5 FR-05 — Note Management (Phase P1)

**Description:** A user can list the notes they created, delete any of them, and update a restricted set of fields.

**Updateable fields (only these):**
- Title
- Text
- Category
- Privacy
- Password (only when privacy is "protected")

**Not updateable:** expiry and attachment. Changing these requires deleting and recreating the note.

**Acceptance criteria:**
- AC-05-01 "My notes" page lists the user's own notes with title, category, privacy, expiry, and creation date.
- AC-05-02 The user can delete any of their notes; deletion is permanent after confirmation.
- AC-05-03 The user can update Title, Text, Category, Privacy, and Password (when privacy is "protected").
- AC-05-04 The UI does not offer editing for expiry or attachment on existing notes (fields shown read-only).
- AC-05-05 Updating privacy to "protected" prompts for and sets a password; updating from "protected" to "public" clears the password requirement. The password can be set or changed while the note is "protected".
- AC-05-06 All updates take effect on the same note URL; caches are invalidated so the new content is served immediately.
- AC-05-07 A free user can delete notes to free space in their 5-note limit (FR-07).

### 8.6 FR-06 — Expiration (Phase P1)

**Description:** Each note has an expiry chosen from the fixed list. Expiration is **lazy**: access is validated at read time, so a note becomes inaccessible to **everyone — including its creator** exactly at its expiry time — never before, never after — with no dependency on a background job. After expiry the note is dead for everyone: the URL shows "This note has expired" and no one can view or edit it; the creator can still delete it from "My notes". Expiry cannot be changed after creation. Expiration never deletes a note directly; expired notes are purged with their attachments 90 days after expiry (D-17). All expiry times are evaluated in **UTC** (server time).

**Fixed expiry options (exact list):**
- never
- 5 minutes
- 10 minutes
- 30 minutes
- 1 hour
- 6 hours
- 12 hours
- 1 day
- 1 week
- 1 month

**Acceptance criteria:**
- AC-06-01 The expiry options are exactly the list above, in this order.
- AC-06-02 Exactly at its expiry time, the note stops being accessible to everyone, including the creator — never before, never after. Authorization is evaluated at the moment of the request; bytes already transmitted to a viewer are exempt.
- AC-06-03 The creator cannot view or edit an expired note (same "expired" message as everyone else), but the note remains visible in "My notes" as expired and can be deleted from there until the 90-day purge (D-17).
- AC-06-04 Anyone (including the creator) visiting an expired note sees a localized "This note has expired" message; no note content is returned.
- AC-06-05 Expiry cannot be modified after creation.
- AC-06-06 Expired notes still count toward the free user's 5-note limit (FR-07) until they are purged. Owner lists and free-tier counts are sourced from persistent rows, never from expiry-evicted cache entries.
- AC-06-07 **Lazy expiration:** access is validated at read time. The authority is the persisted `expires_at` timestamp compared against the server clock; Redis TTL is eviction-only, never the authority. On Redis failure, access falls back to the database — no stale cache is served.
- AC-06-08 **Redis TTL:** cached note data uses a Redis TTL set to the note's absolute expiry (PEXPIREAT / remaining milliseconds) so a later cache fill can never extend access; "never" notes have no TTL. TTL mismatch tolerance is small (±1s).
- AC-06-09 A batched background job (Spring Batch) runs every 10 minutes for **derived cleanup and retention** — e.g., analytics rollups, short-link purge, and purging notes (with their attachments) 90 days after expiry (D-17). It never drives access decisions; exactness is guaranteed by the lazy read-time check (AC-06-07).
- AC-06-10 Expiration never deletes a note directly — it only becomes "expired" for everyone. Expired notes are purged (with their attachments) 90 days after expiry by the retention job (D-17); until then the creator can delete them from "My notes".
- AC-06-11 Attachment access follows the same rules as the note.
- AC-06-12 `expires_at` is set from the authoritative database transaction timestamp at successful note creation (after attachment processing), and is returned to clients. "1 month" means one UTC calendar month.

### 8.7 FR-07 — Free-Tier Limit & Pro Upsell (Phase P1 + P2)

**Description:** Free users are limited to 5 notes. Reaching the limit blocks creation of new notes and shows a Pro upsell. Deleting an old note frees a slot, but this option is **not advertised** in the upsell.

**Acceptance criteria:**
- AC-07-01 A free user with 5 existing notes cannot create a new note; a clear, localized message explains the limit.
- AC-07-02 The blocking message includes a Pro upsell (price 250 EGP/month and Pro benefits).
- AC-07-03 The upsell does not mention deleting old notes as an option. Deletion stays available in "My notes"; the upsell screen must not link to it.
- AC-07-04 If the user deletes one of their notes (via My Notes), they can create a new note normally. No special "you may now create" messaging is required.
- AC-07-05 Counts include all the user's notes regardless of privacy or expiry state — **including expired notes** (FR-06). Only deleted notes are excluded.
- AC-07-06 The limit check is enforced server-side (not just hidden in the UI).
- AC-07-07 Subscribing to Pro removes the limit (FR-08).

### 8.8 FR-08 — Pro Plan & Subscription (Phase P2)

**Description:** Pro costs **250 EGP/month** and provides: unlimited notes, 1MB text per note, 50MB attachment per note, and short links (FR-09). Billing supports the required payment providers (Stripe, Fawry, and at least one of Paymob/Opay; all four as bonus).

**Payment provider contract requirements:**
- **Required:** Stripe, Fawry, and **at least one of** Paymob or Opay.
- **Bonus:** all four (Stripe, Fawry, Paymob, Opay) delivered.

**Acceptance criteria:**
- AC-08-01 Users can subscribe to Pro at 250 EGP/month (recurring) and cancel anytime.
- AC-08-02 Subscription works through all delivered payment providers.
- AC-08-03 Pro benefits activate immediately on successful payment: unlimited notes, 1MB text, 50MB attachment, short links.
- AC-08-04 If a subscription lapses or is cancelled, the user returns to free-tier limits (5 notes, 1KB text, 10MB attachment). Notes they already created are not deleted, but they cannot create more until they are within limits (matching FR-07).
- AC-08-05 Payment errors, retries, and webhook failures are handled with clear localized messages; no double-charging.
- AC-08-06 For Egyptian providers without native recurring payments, the subscription follows a defined renewal flow with clear UI states: active → past_due/grace → cancelled. Grace period is 7 days, with reminder emails at day 7/3/1 before the deadline. The user keeps Pro benefits during grace; on cancel they return to free-tier limits (AC-08-04).
- AC-08-07 An invoice/receipt is available to Pro users as a PDF delivered by email and in-app, including the required Egyptian tax fields (tax ID, sequential number, VAT).
- AC-08-08 Subscription status is reflected in the UI (badge, My Notes, and upsell states).

### 8.9 FR-09 — Short Links (Phase P1)

**Description:** A simple Bit.ly-style URL shortener, available to **Pro users only**. A Pro user pastes an external URL and receives a short link that redirects to it. Short links are **create-only**: users cannot list, retrieve, update, or delete their previously created short links.

**User stories:**
- As a Pro user, I can paste an external URL and receive a short link that redirects to it.
- As a Pro user, I understand I cannot later list, edit, or delete the short links I have created.

**Acceptance criteria:**
- AC-09-01 Only Pro users can create short links.
- AC-09-02 A Pro user can paste any external URL and receive a short, random code that redirects to that URL. Only http/https URLs are accepted; private/internal network ranges are rejected (SSRF protection) — the blocklist includes RFC1918 (10/8, 172.16/12, 192.168/16), loopback (127/8, ::1/128), link-local (169.254/16, fe80::/10), and cloud metadata (169.254.169.254).
- AC-09-03 Following a short link redirects to the target URL correctly; works for guests too.
- AC-09-04 There is no listing, updating, or deleting of previously created short links (create-only by design).
- AC-09-05 Short codes are unpredictable and not enumerable (e.g., 8-character base62 — 62^8 space). Collisions are handled by generating a new code with a unique DB constraint enforcing no duplicates.
- AC-09-06 The created short link is shown once after creation with a copy button (it cannot be retrieved later).
- AC-09-07 Pro entitlement gating is implemented in P1; short links become usable once Pro subscriptions exist (P2). Until then the feature is built and gated but inactive.
- AC-09-08 Short links expire after 2 years from creation; expired links are removed by the batch cleanup job (FR-06 AC-06-09). There is no limit on the number of short links a Pro user can create.

### 8.10 FR-10 — Moderation & Abuse Control (Phase P3)

**Description:** Basic abuse controls: a report action on every note, a Terms of Service page, and an admin takedown tool. **No automatic content or malware scanning.**

**Acceptance criteria:**
- AC-10-01 Any visitor can report a note; reporting requires no account. A reported note enters the admin report queue. Report submissions are rate-limited per IP.
- AC-10-02 Admins can review reports, view the reported note and its attachment, and take it down. Admin access to reported content is an explicitly authorized, purpose-limited bypass of privacy/expiry, and is logged (audit trail). Target: respond to reports within 24 hours, sooner for clearly illegal content.
- AC-10-03 Takedown makes the note URL return the "removed" page immediately (caches invalidated).
- AC-10-04 Admins can also take down a note directly by note-id or URL, without a report.
- AC-10-05 TOS is published and linked (FR-12).
- AC-10-06 The report flow does not reveal the reporter's identity to the note author.
- AC-10-07 No automatic scanning of attachments or text is performed (uploads of any type are accepted).
- AC-10-08 Admins authenticate through Keycloak with an admin role; the standard login flow applies.

### 8.11 FR-11 — Content & Static Pages (Phase P3)

**Description:** A high-quality landing page plus support pages.

**Required pages:**
- Landing page (must be high quality; the primary marketing surface)
- FAQ
- Privacy Policy
- Terms of Service
- Change log / Site news
- Contact
- About

**Acceptance criteria:**
- AC-11-01 The landing page explains the product, shows the free vs Pro comparison, and has clear call-to-actions (sign up, go Pro).
- AC-11-02 All pages are localized (FR-12) and theme-aware (FR-13).
- AC-11-03 FAQ content covers limits, privacy modes, expiry, payments, and account issues.
- AC-11-04 The change log / site news page is editable by admins from the admin UI (content management).
- AC-11-05 Contact page provides a contact form and a support email address; submissions reach the client's inbox.
- AC-11-06 Privacy Policy and TOS are supplied as editable content pages (client provides final copy at launch); the required content of all four pages is specified in FR-16.
- AC-11-07 Every page footer links to Privacy, TOS, FAQ, Contact, and About.

### 8.12 FR-12 — Localization (i18n) (Phase P3)

**Description:** Five languages with different quality bars.

| Language | Translation quality |
|---|---|
| Arabic | Human translation — very good |
| English | Human translation — very good |
| French | AI translation |
| Spanish | AI translation |
| German | AI translation |

**Acceptance criteria:**
- AC-12-01 All UI strings, error messages, validation messages, static page content, and transactional emails (verification, password reset, payment receipts) are localizable. This includes the Keycloak authentication screens (login, verification, password reset, social login errors) — localized Keycloak login/account themes are a software deliverable.
- AC-12-02 English and Arabic are human-quality; FR/ES/DE are AI-translated. The client reviews/approves 100% of AI-translated strings before launch; changes after launch go through change request.
- AC-12-03 Language selection is available (browser default + manual switcher), persisted per user.
- AC-12-04 Arabic renders with correct RTL layout and full bidirectional text handling.
- AC-12-05 No hardcoded user-facing strings in code; strings are externalized.

### 8.13 FR-13 — Theming (Phase P3)

**Description:** Light and dark themes.

**Acceptance criteria:**
- AC-13-01 The app has light and dark themes following the delivered color palette (Section 13).
- AC-13-02 Theme follows system preference by default and is manually switchable; the choice persists per user.
- AC-13-03 All pages and components render correctly in both themes (contrast and readability requirements in Section 10).

### 8.14 FR-14 — Analytics (Phase P3)

**Description:** Five non-real-time, batch-aggregated analytics. A scheduled job (e.g., nightly) computes aggregates. Results are shown to admins in a dashboard/report.

**Required metrics:**
1. Monthly visits (page views per month)
2. Number of registered users and percentage free vs subscribed
3. Category usage (count of notes per category)
4. Active users (weekly and monthly active)
5. Top countries and devices

**Acceptance criteria:**
- AC-14-01 All five metrics are computed and viewable by admins.
- AC-14-02 Data is non-real-time; nightly (or otherwise scheduled) batch aggregation is acceptable.
- AC-14-03 Monthly visits covers note views and site page views.
- AC-14-04 User metric shows total registered users and free/subscribed percentages.
- AC-14-05 Category usage shows note counts per category (current and/or over time).
- AC-14-06 Active users reports WAU (weekly) and MAU (monthly).
- AC-14-07 Top countries and devices report is available (monthly).
- AC-14-08 Metrics are computed from anonymized/aggregated data: user identity is hashed with HMAC-SHA256 and a per-user salt (rotated annually), IP addresses are truncated (IPv4 → /24, IPv6 → /48), and no note content is stored in analytics.

### 8.15 FR-15 — Attachments & File Handling (Phase P1)

**Description:** Notes support a single attachment of any file type. Spring Batch is used for file read/processing pipeline. Limits: 10MB (free), 50MB (Pro). No scanning (FR-10).

**Acceptance criteria:**
- AC-15-01 Exactly one attachment per note; any file type accepted.
- AC-15-02 Free tier max attachment size: 10MB. Pro tier: 50MB. Exceeding shows a localized error before upload.
- AC-15-03 Spring Batch processes uploaded files with defined steps: metadata extraction, MIME detection, safe-filename generation, storage write, and DB row completion. It is not used for scanning (D-03) and never drives access decisions.
- AC-15-04 The original filename is preserved on download (AC-04-03).
- AC-15-05 Uploaded files are stored on an S3-compatible object store (or equivalent) separate from application data (D-14), and are only accessible through the note's access rules (FR-03). Downloads are authorized by the backend on every request: either proxied with a full access check and `Content-Disposition: attachment`, `X-Content-Type-Options: nosniff`, and a security policy header; or served via short-lived signed URLs whose lifetime never exceeds the note's remaining lifetime.
- AC-15-06 Attachments are deleted when the note is deleted by its creator, or when the note is purged 90 days after expiry (D-17); attachment access follows the note's access rules (FR-06).

### 8.16 FR-16 — Content Page Specifications (Phase P3)

**Description:** Exact content requirements for the About, FAQ, Privacy Policy, and Terms of Service pages (pages themselves are FR-11). **Legally binding versions:** English and Arabic. French, Spanish, and German versions of legal pages are provided for convenience only and are **not** legally binding; in case of conflict, the English version prevails. Legal pages must be present (even as client-supplied copy) before user registration is enabled.

**8.16.1 About page — must contain:**
- What Relay is: a simple service for creating and sharing notes via links.
- What it does: store notes (text + optional attachment), share via a private link, three privacy levels, optional expiry, and short links (Pro).
- How it works in one or two sentences (paste → get link → share).
- Free vs Pro summary (one line each).
- Contact: support email and link to the Contact page.

**8.16.2 FAQ page — must answer at least these questions:**
- What is Relay?
- Do I need an account to create or view notes? (create: yes; view shared public links: no)
- What are the free limits? (5 notes, 1KB text, 10MB attachment per note)
- What does Pro include and what does it cost? (unlimited notes, 1MB text, 50MB attachment, short links; 250 EGP/month)
- What do public / protected / private notes mean?
- What happens when a note expires? (everyone — including the creator — sees "This note has expired"; expired notes are purged after 90 days)
- Can I edit or delete my notes? (edit: title, text, category, privacy, password; delete: any time)
- What file types can I attach and what is the size limit?
- Which payment methods are accepted?
- How do I cancel my subscription? (anytime; access continues to end of paid period)
- Which languages are supported?
- How do I report a note or contact support?
- How do I delete my account?

**8.16.3 Privacy Policy — minimum required clauses:**
- Data controller: Relay's operating company, with a contact/support email.
- Data collected: display name, email, note content, attachments, anonymized usage analytics (no note content in analytics), IP addresses (truncated; used for rate limiting and abuse protection), payment data (handled by the payment providers, not stored by Relay).
- Purposes and lawful bases: providing the service (contract), security and abuse prevention (legitimate interest), legal obligations.
- Retention: notes kept until deleted by the user or on account deletion; analytics aggregates kept as long as needed for reporting; contact-form emails kept for a reasonable period.
- Sharing: no selling of personal data. Data is shared only with service providers needed to run the service (hosting, payment providers, email delivery).
- User rights: access, correction, deletion (account deletion), and the right to request an export (fulfilled manually).
- Security: technical measures described in general terms.
- Cookies/tracking: analytics are anonymized and non-real-time; a consent choice is offered where legally required.
- Changes to this policy and an effective date.
- Applicable law: Egypt (Personal Data Protection Law No. 151/2020) and, for EU users, the GDPR.

**8.16.4 Terms of Service — minimum required clauses:**
- Acceptance of terms; user must be at least 18 years old.
- Description of the service.
- Accounts: user responsible for keeping credentials secure and for accuracy of their display name.
- Pro subscription: 250 EGP/month, recurring, cancel anytime; access continues to the end of the paid period; disclosed refund policy.
- Free-tier limits: 5 notes, 1KB text, 10MB attachment.
- User content and license: user retains ownership of their content and grants Relay a license to store and display it solely to provide the service.
- Acceptable use / prohibited content: illegal content, malware, malicious files, copyright-infringing material, CSAM, harassment, phishing or deceptive short links, and other prohibited categories.
- Reporting and takedown: how to report a note; Relay's right to remove content and suspend/terminate accounts for violations.
- No-scanning notice: content is not proactively scanned; prohibited-content rules still apply.
- Disclaimer of warranties: service provided "as is".
- Limitation of liability.
- Changes to these terms.
- Governing law and jurisdiction: Egypt.
- Contact information.

**Acceptance criteria:**
- AC-16-01 All four pages contain the content listed above, in the appropriate language versions.
- AC-16-02 English and Arabic are the legally binding versions; FR/ES/DE legal pages are clearly marked as non-binding references, with the English version prevailing on conflict.
- AC-16-03 Legal pages are present and linked before user registration is enabled (placeholder copy acceptable pre-launch).
- AC-16-04 All pages are localized (FR-12) and theme-aware (FR-13).

---

## 9. Business Rules Summary

### 9.1 Plan Limits

| Capability | Free | Pro (250 EGP/month) |
|---|---|---|
| Notes | 5 max | Unlimited |
| Text per note | 1KB | 1MB |
| Attachment per note | 10MB | 50MB |
| Short links | — | Yes |
| Price | — | 250 EGP/month |

### 9.2 Note Fields

| Field | Required | Updateable? | Notes |
|---|---|---|---|
| Title | No | Yes | "Untitled" fallback; max 256 chars |
| Text | Yes | Yes | |
| Category | Yes | Yes | Fixed list below; default General |
| Expiry | Yes | No | Fixed list in FR-06 |
| Privacy | Yes | Yes | public / protected / private |
| Password | Only if protected | Yes | Set or changed while "protected"; cleared on "public" |
| Attachment | No | No | One file, any type |

### 9.3 Categories (fixed list — exact)

1. General
2. Work
3. Study
4. Personal
5. Ideas
6. Tech
7. Recipes
8. Finance
9. Health
10. Travel
11. Other

### 9.4 Expiry Options (exact list)

never / 5m / 10m / 30m / 1h / 6h / 12h / 1d / 1w / 1 month

### 9.5 Privacy Rules

- **Public:** any visitor with the link can view.
- **Protected:** password required; no data revealed before password.
- **Private:** only the owner can view.

### 9.6 Free-Limit Rule

At 5 notes, creation is blocked with a Pro upsell. Deleting a note frees a slot, but deletion is not mentioned in the upsell.

---

## 10. Non-Functional Requirements

### 10.1 Performance & Scalability

- NFR-01 The app must be fast and designed to handle a large number of concurrent users.
- NFR-02 A load balancer distributes traffic across backend instances; the architecture must scale horizontally.
- NFR-03 Redis caching reduces hot-path load; cache invalidation must be correct on update/delete/expiry/takedown/account-deletion. Protocol: cache keys carry the DB row version (invalidated by that version after commit), invalidation happens after the DB commit with durable retry, and no negative caching is used initially (D-15). HTTP-layer caching respects access rules: private/protected/owner responses are served with `Cache-Control: no-store`; public notes and attachments use expiry-capped caching.
- NFR-04 Note viewing and creation should feel instant (target < 500ms server response on cached note reads). Capacity floor at launch: at least 1,000 concurrent note views without degradation (D-15).
- NFR-05 Static assets (front-end) are served efficiently (CDN or equivalent recommended).

### 10.2 Reliability

- NFR-06 Expiration must be exact: a note becomes inaccessible to everyone, including the creator, exactly at its expiry time — never before, never after (FR-06). Enforced lazily at read time, with Redis TTL aligned to the note's expiry; a batched background job handles deferred cleanup and retention. Expiration never deletes a note directly; expired notes are purged 90 days after expiry (D-17).
- NFR-07 Background jobs (expiration handling, analytics) are idempotent and safe to re-run.
- NFR-08 Webhook processing (payments) is idempotent to prevent double-charging.
- NFR-09 The system degrades gracefully (clear localized messages) on upstream failures (e.g., Redis, payment provider).
- NFR-25 Daily database backups are performed; uploaded attachments are stored separately from application data.
- NFR-26 A health-check endpoint exists for the load balancer.

### 10.3 Security

- NFR-10 Authentication and session management are handled by Keycloak; passwords are never stored by the app itself.
- NFR-11 Note IDs (UUIDs) and short codes are unpredictable and not enumerable.
- NFR-12 Protected-note password attempts are rate-limited.
- NFR-13 Access rules are enforced server-side, never relied on via the UI.
- NFR-14 Uploads are not scanned, but are served with safe content headers/disposition to avoid stored-XSS/active-content issues.
- NFR-15 All endpoints are documented (OpenAPI 3.1) and validated with zero errors; the OpenAPI artifact is generated and validated in CI and covers every endpoint/response with stable operation IDs and the shared error schema; no sensitive data in logs.
- NFR-16 Admin endpoints are restricted to admin role.
- NFR-24 Rate limiting is applied per IP/user on abuse-prone endpoints: note creation, short-link creation, report submission, and protected-note password attempts.

### 10.4 Exception Handling

- NFR-17 Backend exposes a consistent, structured error format (error code + localized message + HTTP status).
- NFR-18 Frontend catches all error cases and shows friendly, localized messages; no raw stack traces to users.
- NFR-19 Client-side and server-side validation messages are consistent.
- NFR-20 Payment and upload failures are handled gracefully with retry guidance.

### 10.5 Accessibility & Quality

- NFR-21 Contrast and readability are WCAG AA-compliant in both themes.
- NFR-22 All interactive elements are keyboard-accessible and have accessible labels.
- NFR-23 Responsive layout: desktop and mobile browsers fully supported.

---

## 11. Analytics Specification

Computed by a scheduled batch job (non-realtime). Admin dashboard/report output.

| # | Metric | Definition |
|---|---|---|
| 1 | Monthly visits | Total page views (note views + site pages) per calendar month |
| 2 | Users free vs subscribed | Total registered users; percentage free vs Pro |
| 3 | Category usage | Number of notes per category |
| 4 | Active users | Weekly active (WAU) and monthly active (MAU) counts |
| 5 | Top countries & devices | Monthly report of visitor countries and device types |

---

## 12. Payment Providers

| Provider | Requirement |
|---|---|
| Stripe | Required |
| Fawry | Required |
| Paymob **or** Opay | Required (at least one) |
| Paymob + Opay (all four) | Bonus (deliver all four if possible) |

See FR-08 for subscription acceptance criteria and PM decisions (Section 14) for recurring-billing handling on non-recurring providers.

---

## 13. Deliverables

### 13.1 Software

- The full codebase is delivered as a single **monorepo** (backend + frontend together).
- Backend source code (Spring Boot 4.1) with OpenAPI/Swagger documentation.
- Frontend source code (Angular 22 + TypeScript + Bootstrap).
- Docker files for backend and frontend.
- Database schema/migration scripts (PostgreSQL).
- Keycloak realm/configuration for identity (registration, verification, reset, social logins).
- Spring Batch job definitions (expiration handling, attachment processing, analytics aggregation).
- Version matrix and lockfiles/toolchain files pinning Java, Node, TypeScript, springdoc-openapi, Keycloak, Redis, and the build tool (§6.1).

### 13.2 DevOps & Hosting

- Backend and frontend hosted online on a real public domain (hosting provider at vendor's choice, client-approved).
- The monorepo is hosted on GitHub with a GitHub Actions CI/CD pipeline (build, test, deploy).
- Load balancer and Redis deployed as part of the hosted infrastructure.

### 13.3 Media & Brand Deliverables

- App icon
- Favicon
- Simple banner (site header/top)
- Full banner (social media / Open Graph)
- Color palette (delivered as a spec usable in code — light and dark variants)

### 13.4 Documentation

- Deployment and operations guide (how to run, deploy, configure CI/CD, Redis, load balancer, Keycloak).
- OpenAPI/Swagger API documentation.
- Admin user guide (moderation, changelog editing, analytics).
- Localization instructions (how strings are added in the 5 languages).

---

## 14. Assumptions & PM Decisions Log

These decisions were made by the client PM where the CEO delegated them. The dev company must follow them unless the client approves a change in writing.

| # | Decision | Value | Rationale |
|---|---|---|---|
| D-01 | Free-tier text limit | 1KB | Business decision to drive Pro adoption. Tight but intentional. |
| D-02 | 5-note upsell behavior | Block + upsell; deletion allowed but not advertised | Maximize conversion while avoiding data loss. |
| D-03 | No malware scanning | Uploads of any type accepted | CEO directive; keeps costs down. Legal exposure covered by TOS and takedown. |
| D-04 | Expiration mechanism | **Lazy expiration (CEO decision):** access is checked on read; Redis key TTL is set to match the note's expiry so expired notes are never served from cache; a batched background job (Spring Batch) runs every 10 minutes for derived cleanup/retention. Expiration **never deletes a note directly** — after expiry the note is inaccessible to everyone, including the creator ("This note has expired"), and remains deletable from "My notes" until purged 90 days after expiry (FR-06, D-17). | CEO directive; replaces the rejected "delete within 10 min" sweep. |
| D-05 | Attachment on update | Attachment and expiry are not updateable; recreate to change. Password is updateable while the note is "protected" (CEO decision). | Restricts update surface; aligns with FR-05. |
| D-06 | Contact page | Contact form + support email | Covers FR-11. |
| D-07 | Egyptian recurring billing | Use provider-native recurring where available (e.g., via Fawry/Paymob/Opay subscription APIs); where not supported, a monthly renewal flow with email reminder | Ensures 250 EGP/month is actually collectable. |
| D-08 | Analytics privacy | Aggregated, anonymized; no note content stored in analytics | FR-14. |
| D-09 | Changelog/news content | Admin-editable from admin UI | FR-11. |
| D-10 | Protected note data exposure | No note data (including title) returned before password | CEO directive: "don't return data of note at all." |
| D-11 | OpenAPI/Swagger exposure | Swagger UI enabled in dev/staging only. In production **both** the Swagger UI and the OpenAPI endpoint (`/v3/api-docs`) are disabled (`springdoc.swagger-ui.enabled=false` and `springdoc.api-docs.enabled=false`), or protected by exact network/role rules | Avoid public exposure of internal API docs (Section 6). |
| D-12 | Short links scope | Standalone Bit.ly-style shortener: Pro-only, create-only (no list/update/delete of created links). Short links expire after 2 years; unlimited per Pro user (FR-09 AC-09-08) | CEO's corrected definition (FR-09). |
| D-13 | Account deletion | Account deletion included in P1 (right-to-erasure). Data export is out of scope | CEO decision (O-05 resolved). |
| D-14 | Attachment storage backend | S3-compatible object storage (or equivalent), separate from application data (FR-15 AC-15-05) | Tech review: storage backend was unspecified. |
| D-15 | Caching & capacity baseline | Single Redis node with AOF persistence at launch; clustering/HA only if scale demands. Versioned cache keys + post-commit invalidation (NFR-03). Capacity floor: ≥1,000 concurrent note views at launch (NFR-04) | Tech review: Redis topology and capacity targets unspecified. |
| D-16 | Expiration authority | The persisted `expires_at` compared against the server clock is the authority; Redis TTL is eviction-only. On Redis failure, access falls back to the database (FR-06 AC-06-07/08) | Tech review: Redis TTL cannot guarantee exact expiry. |
| D-17 | Expired-note retention | Expired notes and their attachments are purged 90 days after expiry by the batch job. Until purge, the note shows as "expired" in "My notes", counts toward the 5-note limit, and can be deleted by the creator (FR-06 AC-06-09/10) | CEO decision: expiry applies to everyone including the creator; resolves O-06. |
| D-18 | Spring Boot version | Backend pinned to **Spring Boot 4.0.8**, not 4.1.x — springdoc-openapi does not yet support Boot 4.1. Upgrade to 4.1.x is tracked as future work once springdoc compatibility lands | Dev decision: working OpenAPI tooling (NFR-15) outranks the minor-version target in §6. |
| D-19 | Transactional email delivery | Email sent via **Resend** using its Java SDK (`resend-java`), replacing the generic SMTP assumption in §6/architecture diagrams. Provider swap later = code change, accepted trade-off | Owner decision: chose Resend over SMTP-agnostic JavaMail for simplicity. |
| D-20 | Social login launch scope | Launch with **Google + Facebook only**. Apple (paid developer account) and X (paid API tier) are deferred; realm designed for zero-code addition later. AC-01-04 amended accordingly | Owner decision: cost constraint ($0 budget at launch). |
| D-21 | Java version | Pinned to **Java 17** (spec minimum), not 21 LTS. Accepted: no virtual-threads/LTS gains until revisited | Owner decision: team standard settled on 17 before build start. |
| D-22 | Keycloak admin-client versioning | `keycloak-admin-client` may sit on a different 26.x patch/minor line than the Keycloak server (26.7.0); client kept on latest available 26.x release rather than force-matched | Dev finding: admin-client releases do not track server patches one-to-one; REST Admin API contract is stable within 26.x. |

---

## 15. Open Questions / Deferred Items

| # | Item | Status |
|---|---|---|
| O-01 | Additional Pro perks beyond current set | Deferred — CEO will advise later. Current Pro = unlimited notes, 1MB text, 50MB attachment, short links. |
| O-02 | Final TOS / Privacy / landing copy | Client provides final copy at launch; dev builds editable content pages. |
| O-03 | Hosting provider | Vendor's choice, must be client-approved, online on a real domain. |
| O-04 | Additional features CEO may request later | To be added via change request; this doc is version-controlled (Section 1.1). |
| O-05 | Account deletion / data-export flow | **Resolved:** account deletion included in P1 (FR-01, D-13). Data export is out of contract scope; portability requests are fulfilled manually by the client. |
| O-06 | Expired-note data retention | **Resolved:** expiry applies to everyone, including the creator (CEO decision). Expired notes and attachments are purged 90 days after expiry by the batch job (D-17). |

---

## 16. Delivery Phases (for estimation)

| Phase | Content | FRs |
|---|---|---|
| P1 — Core | Accounts/auth, note CRUD, access rules, expiration, free limits, attachments, short links | FR-01…FR-07, FR-09, FR-15 |
| P2 — Monetization | Pro plan, subscriptions, payments | FR-08 |
| P3 — Support & content | Landing & static pages, content-page specs, localization, theming, media, analytics, moderation | FR-10, FR-11…FR-16 |

All phases are in scope. Phase order is a build/estimation guide; the company may propose a different safe order with client approval.

---

## 17. Definition of Done (for the dev company)

A feature is "done" when:

1. All its acceptance criteria pass.
2. Error cases show localized, friendly messages (no raw errors).
3. Both light and dark themes render correctly.
4. Works in all five languages, including RTL for Arabic.
5. Works on desktop and mobile browsers.
6. Backend endpoints are documented in OpenAPI/Swagger (OpenAPI 3.1 artifact generated and validated in CI with zero errors, NFR-15).
7. CI/CD pipeline builds and deploys it without errors.
8. Relevant caches are invalidated correctly (update/delete/expiry/takedown).
9. No security regressions (access rules still server-enforced).

---

## 18. Glossary

| Term | Definition |
|---|---|
| Note | Core content unit (Section 7) |
| Short link | A Pro-only, create-only redirect for an external URL (Bit.ly-style); no list/update/delete of created links (FR-09) |
| TOS | Terms of Service |
| WAU / MAU | Weekly / Monthly Active Users |
| RTL | Right-to-left (Arabic layout) |
