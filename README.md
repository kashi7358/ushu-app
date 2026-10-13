# USHU — E-Commerce Marketplace (Buyer & Seller Center)

**USHU (`uhsu_buy`)** is a full-featured, production-grade Flutter e-commerce application built with **Clean Architecture** and **GetX**. It combines a complete **Buyer Shopping Experience** and a dedicated **Seller Center** within a unified mobile application connected to the USHU Backend (`https://ecombackend.ushu.pk`).

---

## Key Features

### 1. Buyer Module
- **Authentication & Security:** Buyer registration, email OTP verification, login, forgot/reset password, and persistent session management.
- **Home & Discovery:** Dynamic homepage banners, categories with images, trending products, active flash sales, and keyword search.
- **Product & Store Experience:** Detailed product view with image gallery, variants, store profile page, and verified buyer reviews (create & vote).
- **Cart & Checkout:** Add to cart, quantity updates, item selection, multi-address management, and order placement.
- **Orders, Wishlist & Returns:** Order tracking, order cancellation, wishlist management, and buyer return request submission/tracking.
- **Support & Info:** In-app chat messaging, Contact Us, Privacy Policy, and About Us screens.

### 2. Seller Center Module
- **Seller Onboarding & Auth:** Multi-step seller registration (personal info, CNIC, bank details & cheque image upload), OTP verification, login, and password recovery.
- **Store Setup & Verification:**
  - Automatic store ownership verification (`GET /store/my-store`) on login and session restore.
  - Multi-step store creation (`POST /store/create`) with store logo, banner, shipping configuration, return/warranty policies, and warehouse details.
- **Seller Dashboard:**
  - Real-time earnings & KPI metrics (`GET /api/dashboard/stats`) including Total Earnings, Total Products, Total Orders, Pending/Completed/Cancelled Orders, and Stock alerts.
  - Interactive Store Profile BottomSheet displaying store banner, logo, contact info, shipping coverage, and store policies.
  - Navigation Drawer for quick access to catalog, flash sales, orders, and verified logout.
- **Product Catalog Management:**
  - Create & Edit products (`POST /api/product/create/:storeId`, `PATCH /api/product/update-product/:productId`) with multi-image upload, dynamic variants (`color`, `size`), pricing, stock, and status (`Active`, `Inactive`, `Draft`).
  - Manage store products (`GET /api/product/all/:storeId`) with status filter tabs, search, and product deletion (`DELETE /api/product/delete/:productId`).
- **Flash Sales & Promotions:**
  - Launch time-bound Flash Sale campaigns (`POST /api/flashSale/create`) with percentage/fixed discounts, stock limits, per-user limits, and free shipping toggles.
  - View & filter all Flash Sale campaigns (`GET /api/flashSale/all`) across `All`, `Ongoing`, `Upcoming`, and `Expired` states.
  - Update existing Flash Sale campaigns (`PUT /api/flashSale/update/:id`) and delete campaigns (`DELETE /api/flashSale/delete/:id`).

---

## Tech Stack & Architecture

- **Framework:** Flutter (Dart SDK `^3.11.0`)
- **State Management & Routing:** [`get`](https://pub.dev/packages/get) (GetX)
- **Networking:** [`dio`](https://pub.dev/packages/dio) with custom interceptors, token injection, and automatic timeout retry
- **Local Storage:** [`shared_preferences`](https://pub.dev/packages/shared_preferences) via [`SessionManager`](lib/core/utils/session_manager.dart)
- **UI & Media:** [`shimmer`](https://pub.dev/packages/shimmer), [`image_picker`](https://pub.dev/packages/image_picker), [`google_fonts`](https://pub.dev/packages/google_fonts), [`flutter_svg`](https://pub.dev/packages/flutter_svg)

### Project Structure (`lib/`)
```text
lib/
├── app/
│   ├── routes/          # Centralized GetX route definitions & initial route guard
│   └── theme/           # AppColors, AppTextStyles, and theme configuration
├── core/
│   ├── errors/          # Centralized ExceptionHandler & custom error models
│   ├── network/         # ApiClient (Dio singleton) & ApiEndpoints
│   ├── utils/           # SessionManager, CustomPopup, validators & helpers
│   └── widgets/         # Reusable shared UI components
├── features/
│   ├── authentication/  # Buyer login, signup, OTP, forgot password
│   ├── home/            # Homepage, banners, categories, product details
│   ├── cart/            # Shopping cart management
│   ├── checkout/        # Address management & order placement
│   ├── order/           # Buyer order history & cancellation
│   ├── returns/         # Buyer return requests
│   ├── review/          # Product reviews & ratings
│   ├── store/           # Public store view for buyers
│   ├── wishlist/        # Saved products
│   ├── profile/         # Buyer profile, Contact Us, Privacy Policy, About Us
│   └── seller/          # Complete Seller Center (Data, Domain, Presentation)
└── main.dart            # Application entry point
```

---

## API Overview

Base Domain: `https://ecombackend.ushu.pk`

| Module | Method | Endpoint | Description |
| :--- | :--- | :--- | :--- |
| **Seller Auth** | `POST` | `/api/seller/create` | Register new seller account (multipart) |
| **Seller Auth** | `POST` | `/api/seller/verify-email` | Verify seller email OTP |
| **Seller Auth** | `POST` | `/api/seller/login` | Seller login & token generation |
| **Seller Store** | `POST` | `/store/create` | Create seller store (multipart) |
| **Seller Store** | `GET` | `/store/my-store` | Fetch authenticated seller's store profile |
| **Seller Dashboard** | `GET` | `/api/dashboard/stats` | Fetch seller earnings, order & inventory stats |
| **Seller Products** | `POST` | `/api/product/create/:storeId` | Create new product (multipart) |
| **Seller Products** | `GET` | `/api/product/all/:storeId` | Get all products for a store |
| **Seller Products** | `PATCH` | `/api/product/update-product/:id` | Update product details (multipart) |
| **Seller Products** | `DELETE` | `/api/product/delete/:id` | Delete a store product |
| **Flash Sales** | `POST` | `/api/flashSale/create` | Create a new flash sale campaign |
| **Flash Sales** | `GET` | `/api/flashSale/all` | Get all flash sale campaigns |
| **Flash Sales** | `PUT` | `/api/flashSale/update/:id` | Update an existing flash sale campaign |
| **Flash Sales** | `DELETE` | `/api/flashSale/delete/:id` | Delete a flash sale campaign |

---

## Getting Started

### Prerequisites
- Flutter SDK `>=3.11.0`
- Android Studio / VS Code with Flutter & Dart plugins

### Installation & Run
1. Install dependencies:
   ```bash
   flutter pub get
   ```
2. Run static analysis:
   ```bash
   dart analyze
   ```
3. Launch the application on a connected device or emulator:
   ```bash
   flutter run
   ```
