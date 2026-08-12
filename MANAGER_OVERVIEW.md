# MediConsult Manager Overview

## 1. Executive Summary

MediConsult is a mobile health insurance and medical services app for members in Egypt. It helps users access their insurance information, find medical providers, submit approval and refund requests, manage family members, and receive service updates from one place.

The app is designed for insured members who need quick self-service access to healthcare support without calling or visiting an office for every request.

## 2. Key Features

### Account Access

- User login and account registration.
- Password recovery through OTP-based reset screens.
- Onboarding flow for first-time users.
- Language selection for Arabic and English.

### Member Dashboard

- Home dashboard with plan/member information.
- Quick access to approval history and refund history.
- Ongoing request cards and health-related content areas.
- Notifications entry point for member updates.

### Medical Requests

- Submit approval requests with provider selection, family member selection, notes, and attachments.
- View approval request history.
- Submit refund requests with refund type, reason, amount, date, provider name, notes, family member selection, and attachments.
- View refund history and request PDFs.

### Provider and Policy Access

- Search and filter medical provider networks.
- Browse network categories, governments, cities, and providers.
- Use location to find nearby providers where available.
- View policy coverage categories and details.
- Access a separate Medicard provider network area [TO CONFIRM].

### Member Profile and Support

- View personal information.
- View and manage family members.
- View insurance plan information.
- Change password.
- Contact support through the contact screen.
- View FAQs.
- View terms, conditions, and privacy policy.
- Open a live chat-style support screen.

### Digital Card and Notifications

- View an electronic insurance card.
- Receive push notifications through Firebase.
- View notifications and mark notifications as read.

## 3. Tech Stack

- Flutter: supports one shared app experience across Android, iOS, web, and desktop targets.
- Firebase: supports push notifications, crash reporting, analytics, and app distribution workflows.
- Secure local storage and caching: keeps key member data available and improves repeat-use performance.
- Location services: enables provider search based on the member's location.
- Localization: supports Arabic and English users in the same app.
- Automated tests: provides coverage for repositories, cubits, routing, caching, connectivity, and performance checks.

## 4. Current Status

### Built

- Main app navigation and core screens are present.
- Login, signup, password reset, home, profile, provider network, policy, approval, refund, family member, e-card, support, notifications, and terms/privacy flows are implemented in the codebase.
- Firebase initialization, push notifications, Crashlytics, analytics, app update checks, offline banner, and local caching are present.
- Android Fastlane distribution setup exists for Firebase App Distribution.

### In Progress / To Confirm

- Chronic medicines has a screen, but the home quick-access button currently shows a "coming soon" dialog.
- Chat is currently a local simulated conversation, not an integrated support backend.
- Signup OTP verification logic has a TODO in a commented-out screen.
- Medicard provider details navigation has a TODO.
- Some README/config text appears corrupted due to character encoding, so business wording from those files should be confirmed.

## 5. Architecture at a Glance

MediConsult mobile app <-> MediConsult backend API <-> member, policy, provider, approval, refund, notification, and support services.

The app also connects to Firebase for notifications, analytics, crash reporting, and distribution support. A separate provider network connection exists for Medicard data, and the app stores selected data locally so screens can load faster and remain more resilient when connectivity changes.

## 6. Next Steps / Roadmap

- [TO CONFIRM] Roadmap item 1.
- [TO CONFIRM] Roadmap item 2.
- [TO CONFIRM] Roadmap item 3.
- [TO CONFIRM] Release or rollout priorities.
