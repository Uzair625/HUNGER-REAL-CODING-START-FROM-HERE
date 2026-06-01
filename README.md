# Hunger Point Flutter App — Complete 3-Day Build

## App Flow
Splash (wavy yellow) → Auth (Phone OTP or Guest) → Home → Explore/Cart → Profile

## What's Built
- ✅ Splash screen with yellow wavy animation + brand logo
- ✅ Auth screen: Continue with Phone + Continue as Guest only
- ✅ Phone OTP: 6-box input, 60s countdown, auto-advance
- ✅ Home: Side drawer, Deliver to bar, promo banner, 3-col category grid, popular items
- ✅ Side drawer: Order History, Favorites, Explore Menu, Ratings, Logout, Contact Us
- ✅ Explore Menu: Full menu with search + category filter tabs
- ✅ Item Detail: HD image, size selector (pizza), quantity picker, Add to Cart
- ✅ Cart: Items list, order summary, payment method selector, place order
- ✅ Profile: Full name, email, date of birth, verified phone number, edit mode
- ✅ Order History: placeholder screen
- ✅ 95 PNG images generated for all menu items and deals
- ✅ All 65+ Hunger Point menu items from brochure

## File Structure
```
hunger_point/
├── pubspec.yaml
├── FIREBASE_SETUP.md          ← READ THIS FIRST
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── firebase_options.dart  ← REPLACE with: flutterfire configure
│   ├── models/
│   │   ├── menu_item_model.dart
│   │   ├── user_model.dart
│   │   └── cart_item_model.dart
│   ├── controllers/
│   │   ├── auth_controller.dart
│   │   ├── menu_controller.dart
│   │   └── cart_controller.dart
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── auth_screen.dart
│   │   ├── phone_otp_screen.dart
│   │   ├── home_screen.dart
│   │   ├── explore_screen.dart
│   │   ├── item_detail_screen.dart
│   │   ├── cart_screen.dart
│   │   ├── profile_screen.dart
│   │   └── order_history_screen.dart
│   ├── widgets/
│   │   ├── common/app_drawer.dart
│   │   └── home/menu_item_card.dart
│   └── utils/
│       ├── colors.dart
│       ├── theme.dart
│       ├── constants.dart
│       └── routes.dart
├── assets/
│   ├── images/  (95 PNG files — all menu items)
│   └── fonts/   (add Poppins .ttf files here)
```

## Setup Steps
1. Run `flutter pub get`
2. Follow `FIREBASE_SETUP.md` to connect Firebase
3. Run `flutterfire configure` to generate real `firebase_options.dart`
4. Add Poppins fonts to `assets/fonts/` (download from fonts.google.com)
5. Run `flutter run`

## Poppins Fonts Needed
Download from https://fonts.google.com/specimen/Poppins:
- Poppins-Regular.ttf
- Poppins-Medium.ttf  
- Poppins-SemiBold.ttf
- Poppins-Bold.ttf
Place all 4 in `assets/fonts/`
