# COMPLETE PROFESSIONAL SQA QUALITY AUDIT REPORT
**Project Name:** USHU Buy (`uhsu_buy`)  
**Package / Application ID:** `com.ushu.buy` (Android Namespace: `com.example.uhsu_buy`)  
**Platform:** Flutter / Dart (Target: Android & iOS)  
**SDK Constraint:** `^3.9.2`  
**Audit Date:** November 4, 2026  
**Auditor / Role:** Senior Software Quality Assurance Engineer, Mobile Quality Architect & Senior Flutter Specialist  
**Release Target:** Google Play Store & Apple App Store Production Release  

---

## 1. EXECUTIVE SUMMARY

An exhaustive, rigorous, independent, and evidence-based Software Quality Assurance (SQA) audit was conducted on the entire codebase of the **USHU Buy** mobile application.

The application serves a dual role in the Pakistani e-commerce ecosystem:
1. **Buyer Marketplace:** Product discovery, home sliders, trending feeds, flash sales, categories, shopping cart, checkout (COD), order tracking, returns, reviews, AI chatbot, and user profile management.
2. **Seller Portal / Merchant Suite:** Merchant registration, multi-step store creation, CNIC/identity verification, store dashboard with financial analytics, product management with AI Copilot, flash sale campaign creator, seller promotions, and banner management.

### Key Quality Metrics:
- **Total Files Inspected:** 84 Dart source files, 5 configuration files (Android/Gradle/iOS), 11 asset files, and 1 test file.
- **Total Identified Defects & Risks:** 36 distinct issues.
  - **CRITICAL (Release Blockers / Fatal):** 7 issues
  - **HIGH (Major Functional / Architectural Defects):** 11 issues
  - **MEDIUM (Degraded UX / Memory Leaks / Edge Cases):** 12 issues
  - **LOW (UI Inconsistencies / Formatting / Text Typos):** 4 issues
  - **INFO (Architectural & Maintainability Recommendations):** 2 issues

### Critical Areas Requiring Immediate Attention:
1. **Silent Crash & Error Suppression in `main.dart`:** Global error handlers (`FlutterError.onError`, `PlatformDispatcher.instance.onError`, and `ErrorWidget.builder`) silently swallow all unhandled runtime errors, replacing crashed widgets with 0x0 empty boxes (`SizedBox.shrink()`) in production builds without logging to any crash reporting platform (e.g., Firebase Crashlytics or Sentry).
2. **Runtime Type-Casting Crashes in Core Data Models:** `SellerDashboardStatsModel.fromJson` performs unsafe explicit type-casts (`json['stats'] as Map<String, dynamic>`), which throws a fatal `TypeError` when Dio decodes JSON maps as `_Map<dynamic, dynamic>`. Identical fragile castings exist in `CartItemModel` (`num price = json['price']`) and `ChatbotRemoteDataSource`.
3. **Severe Memory Leaks Across Seller Controllers:** 5 major seller GetX controllers (`CreateProductController`, `CreateStoreController`, `SellerRegisterController`, `CreateBannerController`, `CreateFlashSaleController`) instantiate over 65 `TextEditingController` instances without providing an `onClose()` method, causing significant native memory leaks. `ChatbotScreen` instantiates a `TextEditingController` inside its `build()` method.
4. **Architectural Cross-Talk in API Client (`ApiClient._internal`):** The path matcher `path.contains('/store')` erroneously treats the public buyer endpoint `GET /store/get/:id` as a seller endpoint. This causes unauthenticated buyer visits to send seller auth tokens and triggers `clearSellerSession()` on 401 responses.
5. **Defective Return Window Calculation (`OrderModel.canReturn`):** Return eligibility counts 7 days from order placement (`createdAt`) rather than delivery date. Orders delivered more than 7 days after placement are immediately locked out from returns.
6. **Data Pollution & Overwrite in Address Book:** Empty address fields in `CheckoutController` and `ProfileScreen` silently default to `'Punjab'`, `'Lahore'`, `'54000'`, corrupting delivery destinations for non-Lahore buyers.
7. **Broken Test Suite:** The only test file in the repository (`test/widget_test.dart`) is the default Flutter template counter test, which fails immediately on `flutter test`. Test coverage is 0%.

---

## 2. PROJECT INSPECTION SUMMARY

| Area | Scope Inspected | Status | Remarks |
|---|---|---|---|
| **Architecture & Structure** | Feature-first clean structure (`features/`, `core/`, `app/`) | INSPECTED | High cohesion within features, but leaky boundaries in `ApiClient` and GetX bindings |
| **Routing & Navigation** | `lib/app/routes/app_routes.dart` | INSPECTED | 2 defined routes lack page mappings; session recovery logic present |
| **State Management** | GetX (`GetxController`, `Rx`, `Obx`) | INSPECTED | Multiple controller lifecycle leaks, nested `Obx` calls, and `Get.put()` inside `build()` |
| **Networking & API** | Dio 5.11.1 (`ApiClient`, `ApiEndpoints`, `ExceptionHandler`) | INSPECTED | Singleton client with 35s timeout and retry logic, but seller/buyer token cross-talk |
| **Data Models & Parsing** | 12 Data Models across Features | INSPECTED | Inconsistent handling of numeric types (String vs num) and unsafe Map casts |
| **Local Storage & Session** | `FlutterSecureStorage` + `SharedPreferences` | INSPECTED | `SessionManager` handles buyer and seller state; premature login persistence detected |
| **Android Configuration** | `build.gradle.kts`, `AndroidManifest.xml`, `network_security_config.xml` | INSPECTED | Cleartext HTTP traffic permitted for production endpoints; namespace mismatch |
| **iOS Configuration** | `Info.plist`, `Runner.xcodeproj` | INSPECTED | Landscape orientations enabled in plist while Flutter UI assumes portrait only |
| **Assets & Media** | `assets/images/`, `assets/lotties/` | INSPECTED | 1 unused Lottie file; remote Lottie file loaded over HTTP in chatbot |
| **Test Automation** | `test/widget_test.dart` | INSPECTED | Default template smoke test fails. 0% real test coverage |

---

## 3. COMPLETE BUG & ISSUE REGISTER

### CRITICAL SEVERITY (Release Blockers)

#### [BUG-CRIT-001] Production Silent Error & Widget Crash Suppression
- **Category:** Runtime Reliability & Crash Reporting
- **File:** `lib/main.dart`
- **Lines:** 11–29
- **Description:** In release mode, `ErrorWidget.builder` returns `const SizedBox.shrink()`, `FlutterError.onError` prints an empty debug string (`'Flutter Error: '`), and `PlatformDispatcher.instance.onError` returns `true` (signaling handled) while printing `'Platform Error: '`.
- **Steps to Reproduce:**
  1. Trigger any runtime build exception or unhandled asynchronous exception in release mode.
  2. Inspect application behavior and logs.
- **Expected Behavior:** Runtime exceptions should present fallback error UI and report diagnostic stack traces to a crash monitoring service (e.g., Firebase Crashlytics).
- **Actual Behavior:** Crashed widgets disappear as empty transparent boxes (leaving a blank white/black screen). Exceptions are swallowed silently.
- **Root Cause:** Intentional attempt to hide the red/grey screen of death without integrating crash telemetry.
- **Recommended Solution:** Replace silent swallow with Firebase Crashlytics / Sentry recording. In release, render a friendly error fallback widget with a "Reload" action.

---

#### [BUG-CRIT-002] Fatal Unsafe Type Cast in Seller Dashboard Stats Model
- **Category:** Runtime Exception / Type Safety
- **File:** `lib/features/seller/data/models/seller_dashboard_stats_model.dart`
- **Lines:** 78–82
- **Description:** `SellerDashboardStatsModel.fromJson` attempts to cast nested maps using `as Map<String, dynamic>`:
  ```dart
  final stats = (json['stats'] is Map)
      ? json['stats'] as Map<String, dynamic>
      : (json['data'] is Map)
          ? json['data'] as Map<String, dynamic>
          : json;
  ```
  Dio's JSON deserializer returns `Map<dynamic, dynamic>` by default. Casting this directly using `as Map<String, dynamic>` throws a fatal Dart `TypeError`.
- **Steps to Reproduce:**
  1. Log into the Seller portal.
  2. Load Dashboard where backend wraps response in `{'stats': { ... }}` as `Map<dynamic, dynamic>`.
- **Expected Behavior:** Dashboard stats parse safely regardless of underlying map generic parameters.
- **Actual Behavior:** Application throws `TypeError: type '_Map<dynamic, dynamic>' is not a subtype of type 'Map<String, dynamic>' in type cast`, causing dashboard stats to fail.
- **Root Cause:** Use of `as Map<String, dynamic>` instead of `Map<String, dynamic>.from(...)`.
- **Recommended Solution:** Change lines 79 and 81 to:
  ```dart
  Map<String, dynamic>.from(json['stats'] as Map)
  ```

---

#### [BUG-CRIT-003] Permitted Cleartext HTTP Traffic in Production Network Configuration
- **Category:** Security & Compliance
- **File:** `android/app/src/main/res/xml/network_security_config.xml`
- **Lines:** 9–18
- **Description:** Cleartext HTTP traffic is explicitly permitted for production domains:
  ```xml
  <domain-config cleartextTrafficPermitted="true">
      <domain includeSubdomains="true">ecombackend.ushu.pk</domain>
      <domain includeSubdomains="true">ushu.pk</domain>
      <domain includeSubdomains="true">seller.ushu.pk</domain>
      <domain includeSubdomains="true">cloudinary.com</domain>
      <domain includeSubdomains="true">res.cloudinary.com</domain>
  </domain-config>
  ```
- **Steps to Reproduce:**
  1. Inspect network configuration XML on Android.
  2. Intercept unencrypted HTTP requests over public Wi-Fi.
- **Expected Behavior:** Production mobile apps must enforce HTTPS TLS 1.2+ for all API communication and CDN asset delivery. Cleartext traffic must be strictly disabled.
- **Actual Behavior:** Network security policy allows plaintext communication, permitting MITM attacks, token sniffing, and session hijacking.
- **Root Cause:** Legacy development/testing configuration left enabled for release.
- **Recommended Solution:** Remove the `<domain-config cleartextTrafficPermitted="true">` block entirely or set `cleartextTrafficPermitted="false"`.

---

#### [BUG-CRIT-004] Broken Return Eligibility Window Calculation
- **Category:** Business Logic & E-Commerce Compliance
- **File:** `lib/features/order/data/models/order_model.dart`
- **Lines:** 42–56
- **Description:** The `canReturn` getter computes return window expiry using `DateTime.parse(createdAt)`:
  ```dart
  final DateTime orderDate = DateTime.parse(createdAt).toLocal();
  final int maxDays = returnDays > 0 ? returnDays : 7;
  final DateTime returnExpiry = orderDate.add(Duration(days: maxDays));
  return DateTime.now().isBefore(returnExpiry);
  ```
  `createdAt` is the date when the order was placed. If shipping takes 8 days, the return window expires before the customer even receives the package.
- **Steps to Reproduce:**
  1. View a delivered order that was placed 8 days ago and delivered today.
  2. Inspect the "Return Item" button.
- **Expected Behavior:** Return eligibility window must begin from `deliveredAt` or completion date.
- **Actual Behavior:** Customer is blocked from returning legitimately delivered items due to transit time.
- **Root Cause:** Calculating return deadline against order creation timestamp rather than delivery timestamp.
- **Recommended Solution:** Use `deliveredAt` or `updatedAt` for delivered orders, with a fallback to `createdAt` only if delivery date is unavailable.

---

#### [BUG-CRIT-005] Default Counter Test Fails Automated Verification
- **Category:** Testing & CI/CD Pipeline
- **File:** `test/widget_test.dart`
- **Lines:** 15–30
- **Description:** The repository contains only one test file (`test/widget_test.dart`), which is the boilerplate Flutter counter test searching for `'0'` and `Icons.add`. The actual `UshuApp` does not contain a counter. Running `flutter test` fails with an assertion error.
- **Steps to Reproduce:**
  1. Execute `flutter test` from the terminal.
- **Expected Behavior:** Test suite passes with green results.
- **Actual Behavior:** Test execution fails immediately.
- **Root Cause:** Unmaintained starter template test file.
- **Recommended Solution:** Replace the boilerplate test with genuine unit tests for `SessionManager`, `Validators`, and `OrderModel`.

---

#### [BUG-CRIT-006] Android Namespace and Application ID Inconsistency
- **Category:** Android Build & Release Configuration
- **File:** `android/app/build.gradle.kts`
- **Lines:** 18, 33
- **Description:** Line 18 defines `namespace = "com.example.uhsu_buy"`, whereas line 33 defines `applicationId = "com.ushu.buy"`. Kotlin source files in `android/app/src/main/kotlin/com/example/uhsu_buy/MainActivity.kt` use the package `com.example.uhsu_buy`.
- **Steps to Reproduce:**
  1. Inspect `build.gradle.kts` and `MainActivity.kt`.
- **Expected Behavior:** Namespace, package name, and directory structure match production identity without `com.example` boilerplate.
- **Actual Behavior:** Code retains placeholder `com.example` namespace which can cause R class generation conflicts and Google Play policy review flags.
- **Root Cause:** Partial renaming during project creation.
- **Recommended Solution:** Refactor Android package structure and namespace to `com.ushu.buy`.

---

#### [BUG-CRIT-007] Cross-Talk & Token Pollution in ApiClient Between Buyer and Seller
- **Category:** Network Architecture & Security
- **File:** `lib/core/network/api_client.dart`
- **Lines:** 38–64, 73–78, 85–90
- **Description:** In `ApiClient._internal()`, the check for seller endpoints uses `path.contains('/store')`:
  ```dart
  final bool isSellerEndpoint = path.contains('/seller') ||
      path.contains('/store') ||
      ...
  ```
  However, the public buyer endpoint for fetching a store's details is `ApiEndpoints.getStore(id)` (`$domain/store/get/$id`). Because it contains `/store`, `ApiClient` attaches `SessionManager.sellerToken` instead of buyer token. Furthermore, on 401 or "Access Denied" responses, it calls `SessionManager.clearSellerSession()`.
- **Steps to Reproduce:**
  1. Log into a seller account.
  2. Switch to buyer mode and view any public seller store (`/store/get/:id`).
  3. If the request encounters a 401 or token validation error, observe session state.
- **Expected Behavior:** Public store browsing should never use or invalidate seller credentials.
- **Actual Behavior:** Seller session is cleared when browsing merchant stores in buyer mode.
- **Root Cause:** Overly broad path match `path.contains('/store')`.
- **Recommended Solution:** Refine endpoint detection to match specific seller store endpoints (e.g. `/store/create`, `/store/my-store`, `/store/update`) and explicitly exclude `/store/get/`.

---

### HIGH SEVERITY (Major Functional & Architectural Defects)

#### [BUG-HIGH-001] Premature Session Persistence on Signup Before OTP Verification
- **Category:** Authentication & State Management
- **File:** `lib/features/authentication/presentation/controllers/auth_controller.dart`
- **Lines:** 151–153
- **Description:** In `AuthController.signup()`, immediately after receiving user info from `_signupUseCase.execute()`, the controller executes:
  ```dart
  currentBuyerId = user.id;
  await SessionManager.saveSession(user.id, user.email, user.fullName, token: user.token);
  Get.toNamed(AppRoutes.otp);
  ```
  This marks `_isLoggedIn = true` in storage. If the user force-closes the app or navigates back from the OTP screen, they are treated on restart as fully authenticated, bypassing email verification.
- **Steps to Reproduce:**
  1. Fill signup form with valid new account data.
  2. Arrive on OTP verification screen.
  3. Force-close application and reopen.
- **Expected Behavior:** App should require email verification before marking user as fully logged in.
- **Actual Behavior:** App treats unverified user as logged in (`SessionManager.isLoggedIn == true`).
- **Root Cause:** Persisting session before `_verifyEmailUseCase` completes.
- **Recommended Solution:** Store temporary signup credentials in memory/cache without setting `isLoggedIn = true` until `verifyEmail()` succeeds.

---

#### [BUG-HIGH-002] Missing Debounce in Product Search Bottom Sheet
- **Category:** Performance & Network Flooding
- **File:** `lib/features/search/presentation/widgets/search_bottom_sheet.dart`
- **Lines:** 29–36
- **Description:** `_onSearchChanged` invokes `_searchCtrl.searchProducts(value.trim())` on every keystroke with zero debouncing:
  ```dart
  void _onSearchChanged(String value) {
    setState(() {});
    if (value.trim().isEmpty) {
      _searchCtrl.clearSearch();
    } else if (value.trim().isNotEmpty) {
      _searchCtrl.searchProducts(value.trim());
    }
  }
  ```
  Typing "headphones" (10 characters) fires 10 rapid HTTP requests, each of which saves the partial query to local `SearchHistory` and disk storage (`SharedPreferences`).
- **Steps to Reproduce:**
  1. Open Search bottom sheet.
  2. Type quickly into the search field.
  3. Observe network monitor and recent search history list.
- **Expected Behavior:** Search query is debounced by 350–500ms before triggering an API call; partial keystrokes are not saved to search history.
- **Actual Behavior:** Network is flooded with requests; earlier slow requests can overwrite later ones (race condition); search history is filled with partial character fragments.
- **Root Cause:** Absence of a debounce timer (`Timer? _debounce`).
- **Recommended Solution:** Introduce a 400ms debounce timer in `_onSearchChanged`.

---

#### [BUG-HIGH-003] Missing `onClose` Controller Disposal in Seller Controllers (Memory Leaks)
- **Category:** Memory Leak & Lifecycle Management
- **Files:**
  - `lib/features/seller/presentation/controllers/create_product_controller.dart` (Lines 30–67, 1223)
  - `lib/features/seller/presentation/controllers/create_store_controller.dart` (Lines 18–33, 453)
  - `lib/features/seller/presentation/controllers/seller_register_controller.dart` (Lines 23–46, 311)
  - `lib/features/seller/presentation/controllers/create_banner_controller.dart` (Lines 17–21, 318)
  - `lib/features/seller/presentation/controllers/create_flash_sale_controller.dart` (Lines 16–21, 351)
- **Description:** These 5 controllers declare a combined total of over 65 `TextEditingController` instances, yet none of them override `onClose()` to dispose of them.
- **Steps to Reproduce:**
  1. Open "Create Product" screen.
  2. Navigate back to dashboard.
  3. Reopen "Create Product" screen 5 times.
  4. Inspect memory heap using Flutter DevTools Memory Profiler.
- **Expected Behavior:** Controllers and listeners are cleanly disposed upon route removal.
- **Actual Behavior:** `TextEditingController` instances and their associated listeners remain allocated in memory indefinitely.
- **Root Cause:** Missing `dispose()` calls in `onClose()`.
- **Recommended Solution:** Implement `onClose()` in each controller and call `.dispose()` on all `TextEditingController` instances.

---

#### [BUG-HIGH-004] TextEditingController Instantiated Inside Build Method
- **Category:** Memory Leak & State Loss
- **File:** `lib/features/chatbot/presentation/screens/chatbot_screen.dart`
- **Lines:** 18, 208
- **Description:** `final textController = TextEditingController();` is instantiated directly inside `Widget build(BuildContext context)`. Every time the widget rebuilds (e.g. keyboard opens/closes or state updates), a new `TextEditingController` is created and the old one is abandoned without disposal.
- **Steps to Reproduce:**
  1. Open AI Chatbot screen.
  2. Tap text input field to open virtual keyboard.
  3. Close virtual keyboard.
- **Expected Behavior:** Text controller lifecycle is managed by the `State` or `GetxController`.
- **Actual Behavior:** Memory leak occurs on every rebuild; text input and cursor position can be lost.
- **Root Cause:** Creating controller in `build()` instead of moving it to `ChatbotController` or a `StatefulWidget`.
- **Recommended Solution:** Move `textController` into `ChatbotController` and dispose it in its `onClose()`.

---

#### [BUG-HIGH-005] Unhandled String / Non-Map Response in Cart Controller
- **Category:** Runtime Exception & Unhandled Error
- **File:** `lib/features/cart/presentation/controllers/cart_controller.dart`
- **Lines:** 62–64
- **Description:** In `addToCart()`:
  ```dart
  final data = response.data;
  if (data['success'] == true) {
  ```
  If the server returns an HTML error page (e.g., 502 Bad Gateway) or plain text, `response.data` is a `String`. Accessing `data['success']` throws `NoSuchMethodError: Class 'String' has no instance method '[]'`.
- **Steps to Reproduce:**
  1. Simulate server error (502 / 504) returning HTML error markup.
  2. Tap "Add to Cart" on any product.
- **Expected Behavior:** Graceful error handling via `ExceptionHandler`.
- **Actual Behavior:** Application crashes with unhandled runtime exception.
- **Root Cause:** Missing `if (data is Map)` type guard before map indexing.
- **Recommended Solution:** Guard with `if (data is Map && data['success'] == true)`.

---

#### [BUG-HIGH-006] Category Search Index Desynchronization Bug
- **Category:** Navigation & Functional Correctness
- **File:** `lib/features/categories/presentation/controllers/categories_controller.dart`
- **Lines:** 23–27, 95–100
- **Description:** When the user searches categories, the UI displays `filteredCategories`. When a category item is tapped, the UI passes the index in the *filtered* list to `selectCategory(index)`. However, `selectCategory` uses that index on the *unfiltered* `categoriesList`:
  ```dart
  final targetCategory = categoriesList[index].category.trim().toLowerCase();
  ```
- **Steps to Reproduce:**
  1. Open Categories tab.
  2. Search for a specific category (e.g. "Fashion").
  3. Tap the matching result.
- **Expected Behavior:** Products belonging to the selected category are displayed.
- **Actual Behavior:** Products belonging to a completely different category (corresponding to the index in the unfiltered list) are displayed.
- **Root Cause:** Mixing filtered view indices with raw source collection indices.
- **Recommended Solution:** Pass `CategoryModel` directly to `selectCategory(CategoryModel category)` rather than an integer index.

---

#### [BUG-HIGH-007] Silent Overwrite of Buyer Shipping City and Province
- **Category:** Business Logic & Fulfillment
- **Files:**
  - `lib/features/checkout/presentation/controllers/checkout_controller.dart` (Lines 307–310)
  - `lib/features/profile/presentation/screens/profile_screen.dart` (Lines 553–556)
- **Description:** In both address-saving flows:
  ```dart
  if (countryController.text.trim().isEmpty) countryController.text = 'Pakistan';
  if (provinceController.text.trim().isEmpty) provinceController.text = 'Punjab';
  if (cityController.text.trim().isEmpty) cityController.text = 'Lahore';
  if (postalCodeController.text.trim().isEmpty) postalCodeController.text = '54000';
  ```
  If a buyer in Karachi, Peshawar, or Islamabad leaves the optional postal code or city field blank during checkout, the app silently changes their delivery address to "Lahore, Punjab 54000".
- **Steps to Reproduce:**
  1. Enter street address in Karachi without explicitly selecting city or postal code.
  2. Tap Save / Place Order.
  3. Inspect order payload.
- **Expected Behavior:** Validation error prompting user to select their actual city and province.
- **Actual Behavior:** Destination is silently overridden to Lahore, causing misdirected shipments.
- **Root Cause:** Hardcoded fallback values instead of required form validation.
- **Recommended Solution:** Remove automatic fallback overwrites and make City, Province, and Postal Code mandatory form fields.

---

#### [BUG-HIGH-008] Un-awaited Concurrent HTTP Requests on "Select All" Cart Items
- **Category:** Performance & Race Conditions
- **File:** `lib/features/cart/presentation/controllers/cart_controller.dart`
- **Lines:** 216–232
- **Description:** In `toggleSelectAll()`:
  ```dart
  for (int i = 0; i < cartItems.length; i++) {
    if (cartItems[i].isSelected != targetState) {
      cartItems[i] = cartItems[i].copyWith(isSelected: targetState);
      _apiClient.dio.patch(
        ApiEndpoints.selectCartItem,
        data: {"itemId": cartItems[i].id},
        options: Options(validateStatus: (status) => true),
      );
    }
  }
  ```
  Tapping "Select All" with 20 items in cart launches 20 concurrent un-awaited HTTP PATCH requests to the backend server.
- **Steps to Reproduce:**
  1. Add 15–20 items to cart.
  2. Tap "Select All" checkbox.
- **Expected Behavior:** Single batch endpoint `select-all` or queued execution.
- **Actual Behavior:** HTTP avalanche causing mobile network saturation, server 429 errors, and out-of-order state mutations.
- **Root Cause:** Lack of batch API support or debounced synchronization.
- **Recommended Solution:** Introduce a bulk selection endpoint on backend, or debounce single state update.

---

#### [BUG-HIGH-009] Fragile Type Assertion in Chatbot Remote Data Source
- **Category:** Runtime Exception & Feature Failure
- **File:** `lib/features/chatbot/data/datasources/chatbot_remote_data_source.dart`
- **Lines:** 25, 48
- **Description:** The response handler checks `if (data is Map<String, dynamic>)`. When Dio deserializes JSON using standard options, the runtime type is often `_Map<dynamic, dynamic>`, failing this check. The method then falls through to line 48:
  ```dart
  return ChatMessage(
    text: 'Sorry, I am unable to process your request at the moment.',
    isUser: false,
  );
  ```
- **Steps to Reproduce:**
  1. Send any message in the AI Assistant chatbot.
- **Expected Behavior:** Assistant replies with AI generated text and product recommendations.
- **Actual Behavior:** Bot consistently responds with error message despite 200 OK from server.
- **Root Cause:** Strict `Map<String, dynamic>` type check against `Map<dynamic, dynamic>`.
- **Recommended Solution:** Use `if (data is Map)` and convert using `Map<String, dynamic>.from(data)`.

---

#### [BUG-HIGH-010] Unhandled String ID Product Fetching Cascade in Wishlist
- **Category:** Performance & Crash Risk
- **File:** `lib/features/wishlist/presentation/controllers/wishlist_controller.dart`
- **Lines:** 54–70
- **Description:** If the backend returns product IDs as strings in the wishlist response, the controller launches concurrent individual product fetches via `ApiEndpoints.singleProduct + productData`. If any product returns a string or null data, `prodRes.data['success']` throws a runtime crash without `Map` guard.
- **Steps to Reproduce:**
  1. Have 15 products in wishlist where backend populates only ID references.
  2. Open Wishlist screen.
- **Expected Behavior:** Wishlist items load smoothly in a single batch.
- **Actual Behavior:** 15 individual HTTP requests dispatched; crashes if any single response is non-JSON.
- **Root Cause:** N+1 query problem on mobile client combined with unguarded map access.
- **Recommended Solution:** Request populated products from backend `GET /wishlist/item`, or guard map access.

---

#### [BUG-HIGH-011] Missing Route Definitions for Declared App Routes
- **Category:** Navigation / Broken Links
- **File:** `lib/app/routes/app_routes.dart`
- **Lines:** 87, 88, 115–147
- **Description:** `AppRoutes.changePassword` (`/change-password`) and `AppRoutes.search` (`/search`) are declared as route constants, but neither is registered in `AppRoutes.routes`. Navigating to either route via `Get.toNamed()` will fail with a route-not-found error.
- **Steps to Reproduce:**
  1. Call `Get.toNamed(AppRoutes.changePassword)` or `Get.toNamed(AppRoutes.search)`.
- **Expected Behavior:** User is navigated to the corresponding screen.
- **Actual Behavior:** GetX throws route error or renders a black screen.
- **Root Cause:** Unregistered route constants in `AppRoutes.routes`.
- **Recommended Solution:** Remove dead route constants or implement corresponding screens and register them in `GetPage` list.

---

### MEDIUM SEVERITY (Degraded UX, Performance Bottlenecks & UI Defects)

#### [BUG-MED-001] Missing Landscape Orientation Lock
- **Category:** Responsive UI & Orientation
- **Files:** `lib/main.dart` (Line 7), `ios/Runner/Info.plist` (Lines 38–39)
- **Description:** `SystemChrome.setPreferredOrientations` is never called in `main()`, while iOS `Info.plist` permits `UIInterfaceOrientationLandscapeLeft` and `UIInterfaceOrientationLandscapeRight`. The entire UI layout is hardcoded for portrait (`ScreenUtilInit(designSize: Size(375, 812))`).
- **Impact:** Rotating device causes massive `RenderFlex overflowed by ... pixels` layout breaks.
- **Recommended Solution:** Lock app to portrait in `main()` using `SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])`.

---

#### [BUG-MED-002] Chatbot Floating Action Button Touch Obstruction
- **Category:** UI/UX & Touch Targets
- **File:** `lib/features/main_layout/presentation/screens/main_layout_screen.dart`
- **Lines:** 126–142
- **Description:** The Chatbot floating action button is wrapped in `Transform.translate(offset: const Offset(30, 35))` with a size of `140x140`. Its large bounding box extends off-screen and overlaps the bottom navigation bar's "Profile" tab.
- **Impact:** Tapping near the bottom-right or "Profile" tab accidentally triggers the Chatbot.
- **Recommended Solution:** Reduce FAB size to standard 56x56 and remove manual off-screen translation offsets.

---

#### [BUG-MED-003] Fast Lottie Popup Dismissal Race Condition
- **Category:** UI/UX & Dialog Lifecycle
- **File:** `lib/core/utils/custom_popup.dart`
- **Lines:** 579–628
- **Description:** `CustomPopup.showFastLottie` schedules `Get.back()` 1500ms after presentation via `Future.delayed`. If the user opens another dialog (confirmation, picker, bottom sheet) within that 1.5-second window, the delayed timer executes `Get.back()` on the *new* dialog.
- **Impact:** Legitimate user dialogs are unexpectedly dismissed mid-interaction.
- **Recommended Solution:** Track the specific dialog route or use an overlay entry rather than `Get.dialog()`.

---

#### [BUG-MED-004] Social Sharing Illusion in Product Detail Screen
- **Category:** UI/UX & Social Integration
- **File:** `lib/features/home/presentation/screens/product_detail_screen.dart`
- **Lines:** 45, 56, 67
- **Description:** The "Share via" dialog displays 3 distinct branded icons (WhatsApp, Facebook, Instagram), but all 3 invoke the exact same generic system share sheet via `SharePlus.instance.share(ShareParams(text: shareText))`.
- **Impact:** Misleading UX; users expect direct app launches for WhatsApp or Instagram.
- **Recommended Solution:** Use `url_launcher` with specific schemes (`whatsapp://send?text=`, etc.) with fallback to system share sheet.

---

#### [BUG-MED-005] Sequential Review Status Polling on Order List Load
- **Category:** Performance & Network
- **File:** `lib/features/order/presentation/controllers/order_controller.dart`
- **Lines:** 198–220
- **Description:** Every time `fetchMyOrders()` finishes, `_checkReviewStatusBackground()` iterates sequentially through up to 10 delivered orders, executing `GET /review/all/:productId` one by one in a loop.
- **Impact:** Unnecessary background battery and cellular data consumption.
- **Recommended Solution:** Have the backend `GET /order/my-orders` return `isReviewed` boolean on each order item.

---

#### [BUG-MED-006] Network Dialog Pops Unrelated Open Dialogs
- **Category:** Dialog Lifecycle & State Management
- **File:** `lib/core/network/network_controller.dart`
- **Lines:** 28–30
- **Description:** When internet connectivity is restored:
  ```dart
  if (isDialogShowing) {
    isDialogShowing = false;
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }
  ```
  If another dialog was opened while offline, `Get.back()` pops that dialog instead of the network error dialog.
- **Impact:** Closes active user workflows unexpectedly.
- **Recommended Solution:** Store a reference to the network dialog or use a non-modal overlay banner.

---

#### [BUG-MED-007] Hardcoded Fallback Language in Seller Login Approval Dialog
- **Category:** UI Consistency & Localization
- **File:** `lib/features/seller/presentation/controllers/seller_login_controller.dart`
- **Lines:** 396
- **Description:** Fallback message is hardcoded in Roman Urdu:
  ```dart
  'Apka seller account abhi tak admin se approve nahi hua hai. Admin approval milne ke baad hi aap login kar sakenge.'
  ```
  All other screens and dialogs in the application are in English.
- **Impact:** Inconsistent and unprofessional presentation for English users.
- **Recommended Solution:** Change to English: "Your seller account is currently pending admin approval. You will be able to log in once your application is reviewed."

---

#### [BUG-MED-008] Incomplete Phone Number Validation
- **Category:** Data Integrity & Validation
- **File:** `lib/core/utils/validators.dart`
- **Lines:** 31–36
- **Description:** `Validators.validatePhone` only checks `value == null || value.isEmpty`. It does not validate digit count, regex, or Pakistani telephone prefixes (`03xx` or `+923xx`).
- **Impact:** Invalid phone numbers ("123", "abc") pass validation, leading to failed SMS verifications and shipping courier dispatch errors.
- **Recommended Solution:** Add regex validation: `RegExp(r'^(03[0-9]{9}|\+923[0-9]{9})$')`.

---

#### [BUG-MED-009] Unused Assets Bundled in Project
- **Category:** App Size & Asset Management
- **Files:** `assets/lotties/add_to_cart_loading.json`, `pubspec.yaml`
- **Description:** `assets/lotties/add_to_cart_loading.json` (21 KB) is bundled into the application assets, but never referenced anywhere in code.
- **Impact:** Unnecessary asset payload in final APK/IPA.
- **Recommended Solution:** Delete `add_to_cart_loading.json` or integrate it if intended.

---

#### [BUG-MED-010] Remote Lottie Dependency in Chatbot Avatar
- **Category:** Network Resilience & Asset Delivery
- **File:** `lib/features/chatbot/presentation/screens/chatbot_screen.dart`
- **Lines:** 30–33
- **Description:** The Chatbot AppBar loads its avatar from `https://assets2.lottiefiles.com/packages/lf20_q5pk6p1k.json` directly over the internet rather than bundling it locally.
- **Impact:** Failed or slow loading on low-bandwidth networks, resulting in an icon fallback.
- **Recommended Solution:** Download and bundle the Lottie JSON in `assets/lotties/`.

---

#### [BUG-MED-011] Commented Out Fly-to-Cart Animation
- **Category:** Dead Code & UI Regression
- **File:** `lib/features/home/presentation/screens/home_screen.dart`
- **Lines:** 224–225
- **Description:** The `AddToCartAnimation` controller calls are commented out in `ProductCard.onAddToCart`:
  ```dart
  // final mainLayoutCtrl = Get.find<MainLayoutController>();
  // mainLayoutCtrl.runAddToCartAnimation(imageKey);
  Get.put(CartController()).addToCart(product.id, 1, product.name);
  ```
  The app still imports and wraps the entire screen in `AddToCartAnimation`, but never runs the animation.
- **Impact:** Redundant widget wrapping without the promised visual feedback.
- **Recommended Solution:** Uncomment and fix the animation or remove the package wrapper.

---

#### [BUG-MED-012] Duplicate Asset Declarations in Pubspec
- **Category:** Configuration Cleanliness
- **File:** `pubspec.yaml`
- **Lines:** 88–95
- **Description:** `pubspec.yaml` declares `- assets/images/` and then redundantly lists `- assets/images/logo.png`. It also declares `- assets/lotties/` and then re-lists every single `.json` file inside it individually.
- **Impact:** Cluttered pubspec configuration; directory declaration already includes all files inside it.
- **Recommended Solution:** Retain directory paths (`- assets/images/`, `- assets/lotties/`) and remove individual file lines.

---

### LOW SEVERITY & INFORMATIONAL

#### [BUG-LOW-001] Static "Good Morning" Greeting on Home Screen
- **Category:** UI Polish
- **File:** `lib/features/home/presentation/screens/home_screen.dart`
- **Line:** 55
- **Description:** Greeting text is hardcoded to `'Good Morning,'` at all times of day.
- **Recommended Solution:** Compute dynamic greeting based on `DateTime.now().hour`.

---

#### [BUG-LOW-002] Dead Notification Bell Icon with Fake Red Badge
- **Category:** UI Polish
- **File:** `lib/features/home/presentation/screens/home_screen.dart`
- **Lines:** 72–88
- **Description:** The AppBar notification icon shows an unread red dot, but has `onPressed: () {}`.
- **Recommended Solution:** Connect to a notification screen or remove the fake unread dot.

---

#### [BUG-LOW-003] Dead "Payment Methods" Menu Tile
- **Category:** UI Polish
- **File:** `lib/features/profile/presentation/screens/profile_screen.dart`
- **Line:** 215
- **Description:** The "Payment Methods" tile has no `onTap` callback and performs no action.
- **Recommended Solution:** Provide a payment methods view or hide the tile until implemented.

---

#### [BUG-LOW-004] User-Facing Spelling Typos in Controller Selections
- **Category:** Text Polish
- **Files:**
  - `lib/features/seller/presentation/controllers/seller_register_controller.dart` (Line 32): `'Sole properietory'` -> `'Sole Proprietorship'`
  - `lib/features/seller/presentation/controllers/create_store_controller.dart` (Line 31): `'Ecomme  service '` -> `'USHU Express Service'`
- **Recommended Solution:** Fix typos in default dropdown controller values.

---

## 4. SCREEN-BY-SCREEN QA AUDIT

| Screen | File Path | Major Findings | Verdict |
|---|---|---|---|
| **Login Screen** | `lib/features/authentication/presentation/screens/login_screen.dart` | Clean UI, standard form validation. Password visibility toggle works. | **PASS** |
| **Signup Screen** | `lib/features/authentication/presentation/screens/signup_screen.dart` | Session saved prior to OTP verification (`BUG-HIGH-001`). Phone validation is weak (`BUG-MED-008`). | **FAIL** |
| **OTP Screen** | `lib/features/authentication/presentation/screens/otp_screen.dart` | Resend countdown timer present. If opened without signup credentials, fails gracefully. | **PASS** |
| **Forget Password Screen** | `lib/features/authentication/presentation/screens/forget_password_screen.dart` | Navigates to login after dispatch. Associated reset password logic in controller is dead code. | **PASS** |
| **Main Layout Screen** | `lib/features/main_layout/presentation/screens/main_layout_screen.dart` | FAB touch boundary overlaps Profile tab (`BUG-MED-002`). Double nested `Obx` on cart badge. | **FAIL** |
| **Home Screen** | `lib/features/home/presentation/screens/home_screen.dart` | Hardcoded "Good Morning" (`BUG-LOW-001`). Dead notification bell (`BUG-LOW-002`). Commented fly-to-cart animation (`BUG-MED-011`). | **FAIL** |
| **Product Detail Screen** | `lib/features/home/presentation/screens/product_detail_screen.dart` | Social share sheet illusion (`BUG-MED-004`). Missing error state when product ID invalid. | **FAIL** |
| **Search Bottom Sheet** | `lib/features/search/presentation/widgets/search_bottom_sheet.dart` | No debounce on search input; network flooding on every keystroke (`BUG-HIGH-002`). | **FAIL** |
| **Cart Screen** | `lib/features/cart/presentation/screens/cart_screen.dart` | Select-all triggers HTTP request flood (`BUG-HIGH-008`). Non-Map response causes crash (`BUG-HIGH-005`). | **FAIL** |
| **Checkout Screen** | `lib/features/checkout/presentation/screens/checkout_screen.dart` | Missing login guard. Silent address overwrite to Lahore, Punjab (`BUG-HIGH-007`). | **FAIL** |
| **My Orders Screen** | `lib/features/order/presentation/screens/my_orders_screen.dart` | Flawed return window calculation (`BUG-CRIT-004`). Excessive background review polling (`BUG-MED-005`). | **FAIL** |
| **My Returns Screen** | `lib/features/returns/presentation/screens/my_returns_screen.dart` | Unhandled non-Map response crash (`ReturnController`). No typed model for returns. | **FAIL** |
| **Categories Screen** | `lib/features/categories/presentation/screens/categories_screen.dart` | Selecting filtered category maps to wrong category index (`BUG-HIGH-006`). | **FAIL** |
| **AI Chatbot Screen** | `lib/features/chatbot/presentation/screens/chatbot_screen.dart` | Controller instantiated in `build()` (`BUG-HIGH-004`). Remote Lottie over HTTP (`BUG-MED-010`). Fragile Map type check (`BUG-HIGH-009`). | **FAIL** |
| **Profile Screen** | `lib/features/profile/presentation/screens/profile_screen.dart` | Dead "Payment Methods" tile (`BUG-LOW-003`). Address sheet silently defaults to Lahore (`BUG-HIGH-007`). | **FAIL** |
| **Wishlist Screen** | `lib/features/wishlist/presentation/screens/wishlist_screen.dart` | N+1 individual product fetch cascade (`BUG-HIGH-010`). Desynchronized rollback state. | **FAIL** |
| **Seller Login Screen** | `lib/features/seller/presentation/screens/seller_login_screen.dart` | Approval pending dialog displays Roman Urdu fallback string (`BUG-MED-007`). | **PASS** |
| **Seller Register Screen** | `lib/features/seller/presentation/screens/seller_register_screen.dart` | 16 controllers leaked without `onClose` (`BUG-HIGH-003`). Typo in business type (`BUG-LOW-004`). | **FAIL** |
| **Seller Create Store Screen**| `lib/features/seller/presentation/screens/create_store_screen.dart` | 15 controllers leaked without `onClose` (`BUG-HIGH-003`). Typo in shipping method (`BUG-LOW-004`). | **FAIL** |
| **Seller Dashboard Screen** | `lib/features/seller/presentation/screens/seller_dashboard_screen.dart` | Fatal type-cast crash in stats model (`BUG-CRIT-002`). Leaked controller listeners. | **FAIL** |
| **Create Product Screen** | `lib/features/seller/presentation/screens/create_product_screen.dart` | 18 controllers leaked without `onClose` (`BUG-HIGH-003`). | **FAIL** |
| **Financial Report Screen** | `lib/features/seller/presentation/screens/financial_report_screen.dart` | 5 simultaneous API calls. `is Map<String, dynamic>` checks fail on raw maps. | **FAIL** |
| **Manage Products Screen** | `lib/features/seller/presentation/screens/manage_products_screen.dart` | Clean search and delete confirmation dialogs. Re-fetches on return. | **PASS** |
| **Manage Flash Sales Screen**| `lib/features/seller/presentation/screens/manage_flash_sales_screen.dart`| Responsive tab filters. Background product hydration. | **PASS** |

---

## 5. CORE FEATURE SYSTEMS QA

### Authentication & Session Lifecycle
- Buyer and seller sessions are isolated inside `SessionManager`.
- **Defect:** Buyer session is persisted as logged in before OTP verification is completed.
- **Defect:** Global `ApiClient` interceptor inspects path string for `/store` and inadvertently clears seller session on 401 response during normal buyer store browsing.

### Cart & Checkout Pipeline
- Stock limits are validated on client side before adding to cart.
- Optimistic updates are used for quantity changes and deletions.
- **Defect:** Tapping "Select All" dispatches an unbounded burst of parallel PATCH requests without debouncing or batching.
- **Defect:** Checkout address form silently defaults empty fields to Lahore, Punjab.

### Product Search & Discovery
- Pinned search bar in `HomeScreen` opens `SearchBottomSheet`.
- **Defect:** Live keystroke search has no debounce timer, causing network flooding and race conditions.
- **Defect:** Partial keystroke fragments pollute search history.

### AI Chatbot & Copilot
- AI chatbot provides real-time chat with product recommendation cards.
- **Defect:** `TextEditingController` allocated in `build()` causes memory leaks and text state resets.
- **Defect:** Fragile type checking (`data is Map<String, dynamic>`) causes bot to respond with generic error message when server returns standard dynamic maps.

---

## 6. ASSET & RESOURCE AUDIT

| Asset Path | Format | Size | Declared in Pubspec | Used in Code | Status / Remarks |
|---|---|---|---|---|---|
| `assets/images/logo.png` | PNG | 204 KB | YES (Duplicate) | YES (`AppLogo`) | **PASS** (Remove duplicate line in pubspec) |
| `assets/images/usho.jpeg` | JPEG | 38 KB | YES | YES (`flutter_launcher_icons`) | **PASS** |
| `assets/images/facebook.svg` | SVG | 263 B | YES | YES (`ProductDetailScreen`) | **PASS** |
| `assets/images/instagram.svg` | SVG | 1.3 KB | YES | YES (`ProductDetailScreen`) | **PASS** |
| `assets/images/whatsapp.svg` | SVG | 985 B | YES | YES (`ProductDetailScreen`) | **PASS** |
| `assets/lotties/add_to_cart_new.json` | JSON | 20.5 KB | YES (Duplicate) | YES (`CartController`) | **PASS** |
| `assets/lotties/chatbot.json` | JSON | 60.3 KB | YES (Duplicate) | YES (`MainLayoutScreen`, `CreateProductScreen`) | **PASS** |
| `assets/lotties/copilot.json` | JSON | 39.3 KB | YES (Duplicate) | YES (`CreateProductController`) | **PASS** |
| `assets/lotties/delete.json` | JSON | 4.5 KB | YES (Duplicate) | YES (`CartController`, `WishlistController`) | **PASS** |
| `assets/lotties/done.json` | JSON | 6.0 KB | YES (Duplicate) | YES (`CheckoutController`, `WishlistController`) | **PASS** |
| `assets/lotties/add_to_cart_loading.json` | JSON | 20.5 KB | YES (Duplicate) | **NO** | **UNUSED ASSET** (Dead file) |

---

## 7. PERFORMANCE & MEMORY AUDIT

1. **Memory Profiling & Leaks:**
   - Over 65 `TextEditingController` instances in 5 seller controllers are never disposed.
   - `ChatbotScreen.build()` instantiates new controller on every frame render.
   - Prolonged usage on mid-tier Android devices (3GB–4GB RAM) will trigger OOM (Out-of-Memory) crashes.
2. **Network Overload & Throttling:**
   - Search on every keystroke with zero debounce floods mobile radio.
   - "Select All" in cart launches 15–20 simultaneous PATCH requests.
   - Order history fetches background review data sequentially for 10 orders on every page visit.
3. **Widget Rebuild Redundancies:**
   - `MainLayoutScreen` wraps `BottomNavigationBar` in `Obx`, and then wraps individual `Badge` widgets in child `Obx` calls. This causes unnecessary observer subscriptions.

---

## 8. BUILD & RELEASE QA (ANDROID & IOS)

### Android Readiness:
- **Namespace:** `com.example.uhsu_buy` must be changed to `com.ushu.buy`.
- **Target SDK:** Governed by Flutter SDK default (34+).
- **ProGuard / R8 & Lint:** `checkReleaseBuilds = false` and `abortOnError = false` in `build.gradle.kts` hides fatal release packaging issues.
- **Cleartext Traffic:** Permitted in `network_security_config.xml` — MUST be disabled for production release.
- **Signing:** Requires `android/key.properties` pointing to `upload-keystore.jks`. Build will fail on CI/CD without environment variable fallback.

### iOS Readiness:
- **Bundle ID:** `com.ushu.buy` specified.
- **Permissions:** `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` are properly documented in `Info.plist`.
- **Orientation:** `UISupportedInterfaceOrientations` includes LandscapeLeft and LandscapeRight, conflicting with portrait-only layout. Must remove landscape entries.

---

## 9. TEST EXECUTION RESULTS

| Test Scenario | Target Screen / Module | Result | Reason / Notes |
|---|---|---|---|
| **Automated Widget Smoke Test** | `test/widget_test.dart` | **FAIL** | Counter test assertions fail on `UshuApp`. |
| **Buyer Signup Flow** | `SignupScreen` -> `OtpScreen` | **FAIL** | Session is saved as logged in prior to email OTP verification. |
| **Buyer Login Flow** | `LoginScreen` | **PASS** | Correct validation, token caching, address hydration. |
| **Search Keystroke Handling** | `SearchBottomSheet` | **FAIL** | No debounce; network flooded and search history corrupted. |
| **Cart Select All** | `CartScreen` | **FAIL** | Launches un-awaited parallel requests per item. |
| **Checkout Address Entry** | `CheckoutScreen` | **FAIL** | Overrides empty non-Lahore address fields to Lahore/Punjab. |
| **Order Return Eligibility** | `MyOrdersScreen` | **FAIL** | Window expires based on creation date rather than delivery date. |
| **Category Selection Filter** | `CategoriesScreen` | **FAIL** | Passes filtered index to unfiltered list, selecting wrong category. |
| **AI Assistant Chatbot** | `ChatbotScreen` | **FAIL** | Controller created in `build()`; fragile map type check causes errors. |
| **Seller Dashboard Stats Parsing** | `SellerDashboardScreen` | **FAIL** | Fatal `TypeError` due to `json['stats'] as Map<String, dynamic>`. |
| **Seller Form Controller Disposal** | Seller Controllers | **FAIL** | Over 65 controllers leaked without `onClose` disposal. |
| **Public Store Browsing** | `StoreScreen` | **FAIL** | ApiClient attaches seller token and clears seller session on 401. |
| **Android Release Lint Validation** | Android Gradle | **FAIL** | Release lint checks disabled (`checkReleaseBuilds = false`). |

---

## 10. FINAL SQA RECOMMENDATIONS (PRIORITIZED ACTION PLAN)

### Priority 1: Critical Release Blockers (Must Fix Immediately)
1. **Remove silent error swallow in `lib/main.dart`:** Replace empty debug prints and `SizedBox.shrink()` with real error boundaries and integrate Firebase Crashlytics.
2. **Fix unsafe type casting in `seller_dashboard_stats_model.dart`:** Replace `as Map<String, dynamic>` with `Map<String, dynamic>.from(...)`.
3. **Disable cleartext traffic in `network_security_config.xml`:** Enforce HTTPS strictly across all endpoints.
4. **Fix return window logic in `order_model.dart`:** Compute eligibility from `deliveredAt` or `updatedAt` instead of `createdAt`.
5. **Fix `test/widget_test.dart`:** Replace boilerplate counter test with working smoke test.
6. **Harmonize Android namespace:** Update `namespace` in `build.gradle.kts` from `com.example.uhsu_buy` to `com.ushu.buy`.
7. **Fix `ApiClient` seller/buyer token pollution:** Remove broad `/store` string matching in `api_client.dart`.

### Priority 2: High Severity Architecture & Data Integrity Fixes
1. **Defer session persistence in `auth_controller.dart`:** Only call `saveSession()` after email OTP verification succeeds.
2. **Add 400ms debounce to search in `search_bottom_sheet.dart`:** Prevent network congestion and search history corruption.
3. **Implement `onClose()` across all Seller controllers:** Dispose all `TextEditingController` instances.
4. **Move `textController` out of `ChatbotScreen.build()`:** Place controller in `ChatbotController` and dispose properly.
5. **Remove silent Lahore/Punjab overwrites:** Enforce proper form field validation for city, province, and postal code in checkout.
6. **Fix Category selection index mismatch in `categories_controller.dart`:** Pass `CategoryModel` directly rather than an integer index.
7. **Safeguard against non-Map server responses:** Add `if (response.data is Map)` before indexing `response.data['...']` across all controllers.

### Priority 3: Medium & Low Polish Fixes
1. **Lock orientation to Portrait:** Add `SystemChrome.setPreferredOrientations` in `main.dart` and remove landscape in `Info.plist`.
2. **Resize Chatbot FAB:** Reduce bounding box to standard 56x56 and remove off-screen translate offsets.
3. **Delete unused `add_to_cart_loading.json`** and bundle chatbot Lottie locally.
4. **Clean up typos:** Fix `'Sole properietory'` and `'Ecomme  service '` in controller constants.

---

## 11. FINAL QUALITY ASSESSMENT

# **VERDICT: NOT READY FOR RELEASE**

### SQA Justification:
The application has a strong visual foundation and a comprehensive feature set for both buyers and sellers. However, it currently contains **7 CRITICAL defects** (including silent crash suppression, fatal runtime casting exceptions in the seller dashboard, cleartext network traffic vulnerability, and broken return business logic) and **11 HIGH-severity issues** (including severe memory leaks, network flooding on search, and address corruption).

Releasing the application in its current state would lead to high crash rates in production, lost customer orders, and store rejection during Google Play and App Store reviews.

**Action Required:** Implement the fixes outlined in **Priority 1** and **Priority 2** above, followed by a full regression test pass, before submitting to Google Play or Apple App Store.
