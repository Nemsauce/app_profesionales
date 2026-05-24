# app_profesionales

## Project summary

Flutter Android app for a Colombian marketplace of local service professionals.

The app connects clients with professionals such as plumbers, carpenters, electricians, painters, locksmiths, cleaners, gardeners, movers, remodeling workers, and air conditioning technicians.

The MVP is Android-first.

## Current development priority

Build the core authentication and registration flow first.

Current priority order:
1. Clean data models.
2. Firebase Auth service.
3. Register screen connected to AuthService.
4. Login screen connected to AuthService.
5. Role-based routing using users/{uid}.role.
6. Basic marketplace listing.
7. Professional profile detail.
8. Reviews.
9. Photos and payments later.

Do not prioritize visual polish over functional correctness.

## Stack

- Flutter / Dart
- Firebase Auth
- Cloud Firestore
- Android-first
- Firebase Storage is deferred
- Wompi payments are deferred
- Google login is deferred

## User roles

### Client

Clients can:
- Register for free.
- Browse professionals by category and city.
- View professional profiles.
- Contact professionals outside the app by WhatsApp or phone.
- Leave reviews later.

Current client model:
- id
- name
- photoUrl
- email
- city

### Professional

Professionals can:
- Register with email and password.
- Get a 3-month free trial.
- Appear in the marketplace while subscriptionActive is true.
- Later pay 49,900 COP/month to stay visible.

Current professional model:
- id
- name
- email
- photoUrl
- description
- category
- city
- phoneNumber
- whatsappNumber
- portfolioPhotos
- rating
- reviewCount
- registrationDate
- freeTrialStartDate
- freeTrialEndDate
- subscriptionStatus
- subscriptionActive

subscriptionStatus expected values:
- trial
- active
- expired

### Review

Reviews live separately, not embedded inside clients.

Current review model:
- id
- clientId
- clientName
- clientPhotoUrl
- professionalId
- rating
- comment
- date

## Firestore structure

Use this structure:

```text
users/{uid}
clients/{uid}
professionals/{uid}
reviews/{reviewId}
