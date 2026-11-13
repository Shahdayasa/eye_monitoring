# Wave 2: Core UI Framework & Navigation

> **Status**: ✅ Complete  
> **Duration**: 5-7 days  
> **Dependencies**: Wave 1 must be complete

---

## Objectives

- Build main app shell with navigation
- Create theme system
- Implement shared UI components
- Set up routing

---

## Tasks

- [x] Create app theme (`lib/core/theme/app_theme.dart`)
- [x] Define color palette (`lib/core/theme/colors.dart`)
- [x] Define typography system (`lib/core/theme/typography.dart`)
- [x] Build main app shell with bottom navigation
- [x] Create navigation router configuration
- [x] Build shared loading indicator widget
- [x] Build shared error message widget
- [x] Build shared status badge widget
- [x] Create responsive layout utilities
- [x] Add app configuration management
- [x] Implement navigation guards for authentication
- [x] Test navigation flows

---

## Deliverables

- ✅ App theme system
- ✅ Navigation framework
- ✅ Shared UI component library
- ✅ Main app shell

---

## Dependencies

- Wave 1 must be complete (need authentication for navigation guards)

---

## Success Criteria

Wave is considered complete when:
- [x] All tasks are checked off
- [x] Theme system is implemented and consistent
- [x] Navigation works across all screens
- [x] Shared components are reusable
- [x] Authentication guards prevent unauthorized access
- [x] UI is responsive and accessible

---

## Implementation Notes

### Theme System

The theme system is established with:

```
lib/core/theme/
├── app_theme.dart      # Material 3 theme configuration, spacing/radius/shadows
├── app_colors.dart     # Color palette with light/dark variants
├── typography.dart     # Manrope typography system (design.md section 2)
```

**Features:**
- ✅ Material Design 3 compliance
- ✅ Light and dark theme support
- ✅ Consistent spacing system (AppSpacing)
- ✅ Typography system with Google Fonts (Manrope)
- ✅ Component themes (buttons, cards, inputs, etc.)
- ✅ Shadow system

### Navigation

**Router Configuration** (`lib/core/router/app_router.dart`):
- ✅ go_router for declarative routing
- ✅ Authentication/profile guards (splash, login, onboarding, authenticated shell)
- ✅ Design-compliant floating pill bottom navigation with 6 tabs
- ✅ Error handling for unknown routes
- ✅ Shell route for main navigation

**Routes:**
```dart
/splash      - Splash/loading gate
/login       - Authentication page
/onboarding  - Profile setup
/dashboard   - Home dashboard
/device      - Device connection (Wave 3)
/monitoring  - Live monitoring (Wave 4)
/predictions - Fatigue results (Wave 7)
/history     - Session history (Wave 8)
/settings    - Settings page (Wave 9)
```

### Shared Components

**Navigation / Shell** (`lib/shared/widgets/app_bottom_nav_bar.dart`):
- ✅ `AppBottomNavBar` - Floating dark pill navigation (64px, 16px margin)
- ✅ Active destination shown as green pill with icon + label; inactive icon-only
- ✅ Used by `MainNavigationShell` with extend-to-bar-safe layout

**Scroll Reveal & Lists** (`lib/shared/widgets/scroll_reveal.dart`, `lib/shared/widgets/skeleton.dart`, `lib/shared/widgets/paginated_list.dart`):
- ✅ `RevealOnScroll` / `RevealGroup` - Viewport-triggered fade+slide, staggered (80ms), once-only, reduced-motion aware
- ✅ `SkeletonBox` / `SkeletonCard` / `SkeletonList` - Grey shimmer placeholders for loading states
- ✅ `PaginatedListView` - Load-more trigger (~200px from bottom) with skeletons and optional reveal

**Search** (`lib/shared/widgets/app_search_bar.dart`):
- ✅ `AppSearchBar` - Pill-shaped 48px search bar with leading icon, placeholder, and clear action

**Loading Indicators** (`lib/shared/widgets/loading_indicator.dart`):
- ✅ `LoadingIndicator` - Centered loading with optional message
- ✅ `FullScreenLoading` - Full screen scaffold with loading
- ✅ `InlineLoading` - Small inline loading indicator

**Error Messages** (`lib/shared/widgets/error_message.dart`):
- ✅ `ErrorMessage` - Styled error/warning/info banner (design tokens)
- ✅ `FullScreenError` - Full screen error display
- ✅ Multiple error types (error, warning, info, connection, auth, validation)
- ✅ Optional retry button

**Status Badges** (`lib/shared/widgets/status_badge.dart`):
- ✅ `StatusBadge` - Colored badge with dot or icon
- ✅ Multiple status types (success, warning, error, info, connected, disconnected)
- ✅ Customizable with icons

### Responsive Utilities

**Responsive Layout** (`lib/shared/utils/responsive_layout.dart`):
- ✅ `ResponsiveLayout` - Adaptive widget based on screen size
- ✅ `ResponsiveBuilder` - Build function with screen size
- ✅ `AdaptiveContainer` - Responsive padding and max width
- ✅ `ResponsiveText` - Responsive font sizes
- ✅ `ResponsiveGrid` - Adaptive grid columns
- ✅ `ResponsiveSpacing` - Responsive spacing

**Screen Size Breakpoints:**
- Small: < 600px (mobile)
- Medium: 600-900px (tablet)
- Large: 900-1200px (desktop)
- Extra Large: > 1200px (large desktop)

### Configuration & Utilities

**App Config** (`lib/core/config/app_config.dart`):
- ✅ Environment selection and compile-time overrides (`--dart-define`)
- ✅ AI API base URL, BLE mock flag, signal/window defaults, collection names

**Validators** (`lib/shared/utils/validators.dart`): email, password, required, min/max length, numeric

**Formatters** (`lib/shared/utils/formatters.dart`): date/time, relative time, duration, number, file size

**Navigation Features:**
- ✅ Auth + profile-completion guards with splash/loading gate
- ✅ Auto-redirect for authenticated users away from auth/onboarding
- ✅ Error page for unknown routes
- ✅ Deep linking support via go_router

---

## File Structure

```
lib/
├── main.dart
├── core/
│   ├── config/
│   │   └── app_config.dart                     # App configuration & env flags
│   ├── router/
│   │   ├── app_router.dart                     # Router + main shell + guards
│   │   └── app_routes.dart
│   └── theme/
│       ├── app_theme.dart                      # Material 3 theme, spacing/radius/shadows
│       ├── app_colors.dart                     # Color palette (light/dark)
│       └── typography.dart                     # Manrope typography system
├── features/
│   ├── authentication/presentation/...         # Splash/login/onboarding/auth state
│   ├── dashboard/presentation/dashboard_page.dart
│   ├── device|monitoring|predictions|history|settings/presentation/...
└── shared/
    ├── widgets/
    │   ├── app_bottom_nav_bar.dart             # Floating pill bottom navigation
    │   ├── app_search_bar.dart                 # Pill search bar
    │   ├── scroll_reveal.dart                  # Viewport reveal + stagger
    │   ├── skeleton.dart                       # Skeleton placeholders/shimmer
    │   ├── paginated_list.dart                 # Lazy list + load-more + skeletons
    │   ├── loading_indicator.dart
    │   ├── error_message.dart
    │   └── status_badge.dart
    └── utils/
        ├── responsive_layout.dart
        ├── validators.dart
        └── formatters.dart
```

---

## Dependencies Added

- `go_router: ^14.2.0` - Declarative routing
- `intl: ^0.19.0` - Internationalization and formatting
- `google_fonts: ^6.2.1` - Manrope typography
- `provider: ^6.1.2` - State management
- `shared_preferences: ^2.5.6` - Local persistence support

---

## Testing

**Widget Tests Created/Updated:**
- ✅ `test/widget/loading_indicator_test.dart`
- ✅ `test/widget/error_message_test.dart`
- ✅ `test/widget/status_badge_test.dart`
- ✅ `test/widget/app_bottom_nav_bar_test.dart`
- ✅ `test/widget/app_search_bar_test.dart`
- ✅ `test/widget/scroll_reveal_test.dart`
- ✅ `test/widget/skeleton_test.dart`

> Note: `flutter analyze` / `flutter test` could not be executed in this environment because the Windows Flutter/Dart toolchain on `/mnt/c/src/flutter` is not runnable from Linux WSL here; run verification on a configured Flutter environment.

---

## Previous & Next

**Previous**: [Wave 1: Firebase Authentication & User Management](./WAVE_01_AUTHENTICATION.md)  
**Next**: [Wave 3: BLE Device Connection](./WAVE_03_BLE_CONNECTION.md)
