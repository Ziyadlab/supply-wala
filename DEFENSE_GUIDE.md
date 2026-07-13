# SupplyWala — 30% FYP Milestone Presentation & Defense Guide

> **How to use this guide:** Memorize the bold opening answer under each topic. Then use the technical details only when the panel asks a follow-up. Always distinguish between **what is implemented now** and **what is planned for production**. Never claim that Cloud Firestore, server-side authorization, automatic email verification, persistent marketplace data, image upload, or explicit request timeouts are already implemented.

## 1. THE ELEVATOR PITCH (Simple Words)

**SupplyWala is a B2B wholesale food marketplace that connects local restaurants directly with bulk suppliers.** Restaurants can discover suppliers, compare products, place wholesale orders, and communicate with sellers from one application. Suppliers can manage inventory, receive orders, update order progress, and build relationships with restaurant customers. The goal is to replace slow, fragmented phone-and-paper purchasing with a faster and more transparent digital workflow.

## 2. ARCHITECTURAL APPROACH & PATTERNS

### The accurate one-line answer

**The current 30% prototype uses a lightweight layered, reactive architecture: Flutter screens form the presentation layer, `AppState` acts as a centralized application-state/controller layer, model classes represent domain entities, and `SampleData` supplies the prototype data source.** It is inspired by MVVM principles, but it is **not a strict MVVM or repository architecture yet**, because there are no separate ViewModel and repository classes.

### Current layers

- **Presentation/UI layer:** `lib/screens/**` and `lib/widgets/app_widgets.dart` render widgets, collect input, and call state methods. Screens do not directly call Firebase Authentication.
- **Application state/controller layer:** `lib/state/app_state.dart` owns the active user, loading/error state, filters, cart, inventory, orders, chats, and mutations such as login, checkout, and status updates.
- **Domain model layer:** `lib/models/app_models.dart` defines `AppUser`, `Supplier`, `Product`, `CartItem`, `AppOrder`, `OrderItem`, `ChatThread`, and `ChatMessage`, plus the `UserRole` and `OrderStatus` enums.
- **Prototype data layer:** `lib/data/sample_data.dart` supplies in-memory suppliers, products, orders, and conversations. These marketplace records are not currently stored in a remote database.
- **Service integration:** Firebase Auth and Google Sign-In are currently called inside `AppState`. A later milestone should move them behind authentication and profile repositories.

### State-management mechanism

`AppState` extends Flutter's `ChangeNotifier`. `SupplyWalaApp` creates one `AppState` instance, and `AppScope` exposes it throughout the widget tree using `InheritedNotifier<AppState>`.

The execution pattern is:

1. A screen obtains the shared state with `AppScope.of(context)`.
2. The screen calls a state method such as `login`, `signup`, `addToCart`, or `updateOrderStatus`.
3. `AppState` changes its data and calls `notifyListeners()`.
4. Widgets that depend on `AppScope` rebuild with the new values.

This is **unidirectional enough for the current scale**: UI triggers an action, centralized state changes, and the UI reacts.

### How the application remembers Restaurant versus Supplier

The role is represented by the typed enum `UserRole { restaurant, supplier }` and stored on `AppUser.role`. The convenience getters `isRestaurant` and `isSupplier` drive navigation and role-dependent views.

For a custom email/password signup, the application currently records role/profile information in two places:

- It calls Firebase Auth `updateDisplayName` with the format `role|name|businessName`, for example `supplier|Ali Khan|Fresh Foods`.
- It stores role, name, and business name in device-local `SharedPreferences`, keyed by normalized email:
  - `role:<email>`
  - `profile:<email>:name`
  - `profile:<email>:business`

It also maintains in-memory maps as a same-process cache. On app startup, `_restoreSession()` reads Firebase Auth's `currentUser`; `_appUserFromFirebase()` resolves the locally stored profile first, then the encoded display name, and finally the selected/default role. `MainShell` then opens `SupplierShell` or `RestaurantShell` based on `currentUser.role`.

### Why this approach was selected

- **Fast and appropriate for a 30% prototype:** it avoids unnecessary framework complexity while the team validates workflows.
- **Separation of concerns:** screens primarily render; models describe data; state owns application behavior.
- **Consistent shared state:** cart count, active user, orders, inventory, and chats update across screens from one source.
- **Easy migration path:** `AppState` methods can later delegate to `AuthRepository`, `OrderRepository`, and `InventoryRepository` without redesigning every screen.
- **Testability:** domain calculations and state transitions can be unit-tested independently of most widget rendering, although direct Firebase/static singleton calls should first be dependency-injected for stronger tests.
- **Scalability caveat:** a single large `AppState` will become difficult to maintain. The production evolution is feature-specific controllers/ViewModels plus repository interfaces and remote/local data sources.

## 3. DEEP-DIVE: AUTHENTICATION & IDENTITY MANAGEMENT

### Email/password signup flow

1. The user chooses **Restaurant** or **Supplier** in `SignupScreen`.
2. Flutter form validators require a name, business name, valid-looking email, and password of at least six characters.
3. The screen calls `AppState.signup(...)` with the selected `UserRole`.
4. `_withLoading()` sets `isLoading`, notifies the UI, and disables/shows progress on authentication controls.
5. The state verifies that Firebase has been initialized.
6. Firebase Auth `createUserWithEmailAndPassword()` creates the identity and securely handles the password; the application does not store the plaintext password.
7. The Firebase Auth display name is updated to `role|name|businessName`.
8. `_saveLocalProfile()` writes role, name, and business name to the in-memory cache and `SharedPreferences`.
9. `_appUserFromFirebase()` creates the application's typed `AppUser`.
10. The screen replaces the navigation stack with `MainShell`, which selects the correct role shell.
11. Firebase exceptions such as duplicate email, weak password, disabled provider, or network failure are translated into user-friendly messages.

### Email/password login flow

1. The user chooses a role and submits email/password.
2. `AppState.login()` validates basic format and calls Firebase Auth `signInWithEmailAndPassword()`.
3. `_appUserFromFirebase()` tries the locally stored role/profile, then parses Firebase Auth display-name metadata, then uses the role selected on the login screen as a fallback.
4. The resulting `AppUser.role` determines the shell and visible workflow.

**Important limitation:** selecting a role at login is not server-side authorization. For an account with no stored role metadata, it can become the fallback role. Production authorization must load the role from a server-controlled user document or custom claim and must never trust a client selection.

### Google Sign-In flow

1. The user selects Restaurant or Supplier and taps the Google button.
2. On web, Firebase Auth uses `signInWithPopup(GoogleAuthProvider)`.
3. On Android/iOS, `GoogleSignIn.instance.authenticate()` obtains a Google identity token; the app converts it into a Firebase Google credential and calls `signInWithCredential()`.
4. Other supported platforms use Firebase's provider sign-in flow.
5. Firebase validates the provider credential and returns a Firebase user.
6. `_ensureProfileForProviderUser()` creates a local profile only when no local role exists. It uses the Google display name and a placeholder business name.
7. `_appUserFromFirebase()` creates the active `AppUser`, and `MainShell` routes by role.
8. Cancellation, Firebase provider errors, and general Google Sign-In errors are caught and displayed.

### Where the role is stored—answer this precisely

**At this milestone, clicking “Create Account” does not create or update any Cloud Firestore collection.** The project has `firebase_core` and `firebase_auth`, but no `cloud_firestore` dependency. Firebase stores the authentication identity; role/profile metadata is encoded in the Auth user's `displayName` and persisted locally in `SharedPreferences`.

Do **not** tell the panel that a `users` collection already exists. State the production design instead:

```text
users/{firebaseUid}
  uid: string
  email: string
  role: "supplier" | "restaurant"
  name: string
  businessName: string
  createdAt: server timestamp
```

The production signup should create this document after Auth succeeds, load it by immutable Firebase `uid`, and enforce role/ownership through Firestore Security Rules or privileged custom claims. Using an email as the local prototype key and putting structured metadata in `displayName` are transitional choices, not the final database design.

### Panel trap: email verification versus Google security prompts

**Firebase does not automatically send a verification email merely because `createUserWithEmailAndPassword()` was called.** The application must explicitly call `user.sendEmailVerification()` and usually gate protected features using `user.emailVerified`. The current code does neither, so custom email accounts are created without an app-triggered verification link. Password-reset email is different and is implemented through `sendPasswordResetEmail()`.

**Google Sign-In is an OAuth/federated identity flow, not the application's email-verification flow.** Google's native UI may show account selection, consent, device-lock, two-step verification, or phone-based security challenges according to Google's own risk policies. SupplyWala does not invoke or control a “native OAuth phone prompt,” and such a prompt is not guaranteed. Firebase trusts the validated Google credential and marks provider-verified identity information accordingly.

### Failure and recovery behavior

- Firebase initialization is wrapped in `try/catch`; unsupported targets/tests can still render the prototype, but auth methods then return a clear “Firebase is not initialized” error.
- Auth operations catch `FirebaseAuthException`; Google flow also handles cancellation and `GoogleSignInException`.
- Network errors are converted to “Check your internet connection,” the user remains on the auth screen, and retry is possible.
- Loading state prevents repeated taps during an in-flight request.
- Firebase Auth persists its authenticated session; splash startup waits for `AppState.ready` and routes an existing user to `MainShell`.
- **There is currently no explicit application-level timeout, retry policy, exponential backoff, offline login, or rollback of a newly created Auth user if local-profile saving fails.** These are production hardening items.

## 4. CODEBASE TOPOGRAPHY & CLASS RELATIONSHIPS

### Directory map

```text
lib/
├── main.dart                 Firebase initialization and runApp
├── app.dart                  MaterialApp and root AppState/AppScope
├── firebase_options.dart     Generated Firebase platform configuration
├── core/
│   └── app_theme.dart        Colors and visual theme
├── data/
│   └── sample_data.dart      In-memory prototype marketplace records
├── models/
│   └── app_models.dart       Domain entities and enums
├── state/
│   └── app_state.dart        Central state, auth integration, business actions
├── widgets/
│   └── app_widgets.dart      Reusable cards, buttons, thumbnails, banners
└── screens/
    ├── auth/                 Splash, onboarding, login, signup, reset password
    ├── shared/               Orders, chats, profile, details, role router
    ├── restaurant/           Discovery, supplier detail, cart, checkout, shell
    └── supplier/             Dashboard, inventory, customers, item form, shell
```

### What each requested folder means

- **`lib/data`:** currently a mock data source. It allows UI/business-flow demonstration without claiming backend persistence.
- **`lib/models`:** shared domain vocabulary. Both roles use the same `AppOrder` and `ChatThread` types, avoiding duplicated or incompatible entity definitions.
- **`lib/screens/shared`:** reusable workflows that both roles need, including orders, order details, chats, profile, and `MainShell` role routing.
- **`lib/screens/restaurant`:** buyer-specific supplier discovery, product browsing, cart, checkout, and restaurant navigation.
- **`lib/screens/supplier`:** seller-specific dashboard, customers, inventory CRUD UI, and supplier navigation.

### Key class relationships

```text
SupplyWalaApp
  └─ owns AppState
      └─ exposed by AppScope (InheritedNotifier)
          ├─ Auth screens call login/signup/Google methods
          ├─ MainShell reads AppUser.role
          │   ├─ SupplierShell
          │   └─ RestaurantShell
          ├─ Shared screens read role-aware selectors
          └─ Feature screens call cart/order/inventory/chat mutations

AppState owns collections of Supplier, Product, AppOrder, and ChatThread
AppOrder contains OrderItem objects
CartItem references a Product
ChatThread contains ChatMessage objects
```

### How shared order views adapt

`OrdersScreen` does not duplicate supplier and restaurant implementations. It asks `AppState` for role-aware values:

- `visibleOrders`: for a supplier, filters orders where `order.supplierId == activeSupplierId`; for a restaurant, it currently returns all prototype orders.
- `orderDisplayName(order)`: supplier sees the restaurant name; restaurant sees the supplier name.
- The title and empty-state copy change based on `isSupplier`.
- `OrderDetailScreen` only renders supplier status controls when `isSupplier` is true.

**Truthful limitation:** restaurant orders are not currently filtered by a restaurant UID because `AppOrder` has no `restaurantId`; returning all sample orders is a demo-data shortcut. Production records need both `restaurantId` and `supplierId`, and database queries/rules must enforce membership.

### How shared chat views adapt

`ChatListScreen` reads `state.visibleChats`. Suppliers receive the `chats` list containing restaurant conversations; restaurants receive the separate `restaurantChats` list containing supplier conversations. The same reusable `ChatTile` and `ChatDetailScreen` render either type.

This is UI adaptation, not production isolation. The lists are currently in memory. Production chat documents require participant UIDs and server-side security rules such as “read/write only if `request.auth.uid` is a participant.”

## 5. RAPID-FIRE PANEL Q&A (Defense Matrix)

### 1. Why did you choose Flutter instead of native Android/iOS?

**Flutter gives us one strongly typed Dart codebase for Android, iOS, web, and desktop while retaining a responsive, compiled UI.** For an FYP team, this reduces duplicate development and keeps business rules consistent. Native code is still available through plugins or platform channels where necessary. The trade-off is plugin/platform testing, but it is more economical for this marketplace's shared workflows.

### 2. What architecture or design pattern does the project use?

**It uses a lightweight layered reactive architecture with MVVM-like separation.** Widgets are views, `AppState` is a centralized `ChangeNotifier` controller/state holder, models define domain data, and `SampleData` is the current prototype source. I call it MVVM-inspired rather than strict MVVM because dedicated ViewModels and repositories have not yet been extracted.

### 3. What design pattern does your database or state management follow?

**State follows the Observer pattern:** `ChangeNotifier` publishes changes and `InheritedNotifier` rebuilds dependent widgets. There is no application database yet—Firebase Auth stores identities while marketplace data is in memory. The planned database layer follows the Repository pattern, with repositories hiding Firestore queries from state controllers.

### 4. Why did you not use Provider, Riverpod, or BLoC?

**At 30%, native Flutter primitives keep dependencies and boilerplate low while providing reactive shared state.** The decision is proportional to current complexity, not a claim that one pattern is universally best. As features grow, splitting `AppState` into feature controllers—potentially using Riverpod/BLoC for dependency injection and event/state discipline—is a planned refactor.

### 5. How does the app remember whether someone is a supplier or restaurant?

**`AppUser.role` is a typed enum and is reconstructed from local per-email preferences or Auth display-name metadata when Firebase restores the session.** `MainShell` uses that role to select the correct shell. In production, the authoritative role will come from `users/{uid}` or a custom claim, not client-selectable/local storage.

### 6. Where exactly is the role stored in Firebase?

**There is no Firestore role document in this milestone.** The role is encoded into the Firebase Auth display name and copied into local `SharedPreferences`. That is sufficient to demonstrate role-aware flows but not secure authorization; the next backend milestone will store it in a UID-keyed user profile with Security Rules.

### 7. If screens are shared, how do you prevent data leaks between supplier and restaurant?

**A shared widget does not imply shared data: it receives role-filtered selectors such as `visibleOrders` and `visibleChats`, and supplier-only controls are conditionally rendered.** However, client filtering is not a security boundary. The current sample data cannot leak server data because it is bundled/in-memory; production isolation must be enforced again at query and Firestore Security Rule level using authenticated UID and participant/owner IDs.

### 8. Is the restaurant order filter production-ready?

**No. Supplier sample orders are filtered by `supplierId`, but restaurant mode currently returns all sample orders because the model lacks `restaurantId`.** This is transparent prototype debt. The production model will store both party UIDs and query only records where the current UID is the buyer or seller.

### 9. How are passwords secured?

**Passwords are passed directly to Firebase Auth over its SDK flow and are never stored by SupplyWala in models, sample data, or `SharedPreferences`.** Firebase handles credential storage and authentication. We still need production measures such as verification, stronger password policy, abuse controls, and secure backend rules.

### 10. Why are verification emails not being received?

**Because account creation does not automatically send one, and the current code does not call `sendEmailVerification()`.** This milestone supports identity creation and password reset; the next step is to send verification, refresh the user, check `emailVerified`, and gate sensitive marketplace actions.

### 11. Does Google Sign-In verify the user's phone number?

**Not as an application feature.** Google may independently request two-step verification, device unlock, or a phone challenge based on account security risk. SupplyWala receives an OAuth identity token and Firebase validates it; we neither force nor guarantee a phone prompt. Separate phone verification would require a deliberate Firebase Phone Auth flow.

### 12. What is your fallback if Firebase Authentication fails or times out?

**The implemented fallback is a safe failure:** exceptions are caught, a friendly error is shown, state remains unauthenticated, controls are re-enabled, and the user can retry. If Firebase is not initialized, auth is blocked with an explicit message. There is currently no explicit timeout/backoff or offline authentication; adding bounded timeouts, connectivity-aware retry, logging, and idempotent profile creation is planned hardening.

### 13. How do you handle image loading and assets securely?

**Bundled UI assets are declared in `pubspec.yaml`, while product/supplier thumbnails use HTTPS URLs and `Image.network`.** `NetworkThumb` clips images and uses `errorBuilder` to show a safe placeholder if loading fails. At this milestone URLs are trusted sample values; production should use Firebase Storage, validated MIME/type and size, generated object paths, authorization rules, allow-listed HTTPS sources, caching, and no user-supplied executable content. The current inventory form does not upload an image; it assigns a fixed Unsplash placeholder.

### 14. What happens when the app restarts?

**Firebase Auth restores its authenticated user, and the splash screen waits for `AppState.ready` before routing.** Local preferences rebuild the profile/role. Cart, inventory edits, orders, and chat mutations are in memory, so those prototype changes do not survive a full restart; remote persistence is a later milestone.

### 15. How do you test this architecture?

**We can widget-test role-based routing and rendering and unit-test model totals, filters, cart mutations, and status transitions.** Strong authentication unit tests require wrapping Firebase/Google calls behind injectable repository interfaces because the current state class calls SDK singletons directly. Integration tests should cover signup, restored sessions, logout, and provider cancellation on configured devices.

### 16. What prevents one user from selecting the wrong role at login?

**For profiles already stored locally, the saved role takes priority over the login selection.** But that is not tamper-resistant and a new device may fall back to the selected role/display metadata. The production answer is server-authoritative role retrieval and Security Rules; hiding a screen alone is never authorization.

### 17. How does the supplier identity map to inventory?

**`activeSupplierId` currently matches the user's business name to sample supplier names and otherwise falls back to the first sample supplier.** Products then filter by that supplier ID. This supports the demonstration but is not a durable identity mapping; production will store `ownerUid` on supplier and product documents.

### 18. What happens if profile saving fails after Firebase creates the account?

**The current method can leave a valid Auth account without a complete local profile because account creation and local storage are not transactional.** The production solution is idempotent profile creation keyed by UID, a recoverable “complete profile” state, retry logic, and a backend/Cloud Function if atomic business guarantees are required.

### 19. How are orders and chats kept consistent between users?

**At present they are local mutable prototype lists, so they demonstrate workflows but are not synchronized between devices.** Production will use persistent order/chat documents, server timestamps, real-time listeners, transaction/batch operations where required, and deterministic status-transition validation.

### 20. Can a restaurant order products from multiple suppliers in one checkout?

**The current checkout assigns the order to the supplier of the first cart item, so a mixed-supplier cart is not safely supported.** The correct production rule is either one supplier per cart or splitting checkout into one order per supplier, with totals and delivery terms calculated independently.

### 21. Why use enums for role and order status?

**Enums restrict the application to known valid states and remove fragile string comparisons from UI logic.** Extensions provide labels and colors in one place. At persistence boundaries, values still need schema validation and backward-compatible serialization.

### 22. How will the system scale beyond one large state class?

**We will split state by feature—authentication, catalog, cart, orders, and chat—and place repository interfaces between controllers and Firebase.** This reduces rebuild scope, improves ownership, enables mocks, and prevents a single class from becoming a maintenance bottleneck.

### 23. What is genuinely complete at the 30% milestone?

**The project demonstrates the end-to-end product structure and major role-aware user journeys:** onboarding, Firebase email/password and Google authentication, session restoration, supplier discovery, cart/checkout simulation, inventory management UI, orders, status workflow, chats, reusable components, and separate role shells. Remote marketplace persistence, server authorization, verification, synchronized chat/orders, payments, and production observability remain future work.

### 24. What is the biggest current security risk?

**The largest gap is treating client-side role/profile state and filtering as if they were authorization.** We do not present them as production security. The priority backend milestone is UID-based ownership, authoritative roles, Firestore/Storage Security Rules, and tests proving cross-role and cross-tenant access is denied.

### 25. What would you implement next?

**First, introduce repository interfaces and a Firestore schema keyed by Firebase UIDs; second, enforce Security Rules; third, add email verification and robust profile completion; fourth, persist and synchronize inventory, orders, and chats.** Then add storage uploads, notifications, payments, explicit timeout/retry behavior, analytics/crash reporting, and automated integration/security-rule tests.

## Final Defense Rules to Memorize

- **Say “implemented” only for code that exists now.** Say “planned production design” for Firestore, repositories, and server rules.
- **Authentication answers “who are you?” Authorization answers “what may you access?”** Firebase Auth is integrated; production-grade authorization is not yet complete.
- **UI hiding and client filtering are usability measures, not security controls.** Security must be enforced on the backend.
- **The current architecture is layered and MVVM-inspired, not strict MVVM.** This honest distinction is stronger than using an inaccurate label.
- **Sample data is intentional at 30%.** It lets the team validate workflows before committing the remote schema, but it does not provide persistence or multi-device synchronization.
- **When challenged about a limitation, give three parts:** acknowledge the exact limitation, explain why it is acceptable at this milestone, and state the concrete production remedy.
