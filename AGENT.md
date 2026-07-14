# AI Development Rules (Mandatory)

These rules apply to **every** task, including new features, bug fixes, refactoring, UI implementation, Hive integration, optimization, and code generation. Follow them strictly without exception.

---

# Core Mindset

Do not behave like a code generator.

Behave like a senior software engineer working inside an existing production codebase.

Before making any change:

* Understand the existing architecture.
* Understand the data flow.
* Understand the business logic.
* Understand dependencies and side effects.
* Understand the root cause of the issue.
* Never guess.
* Never assume.
* Always inspect the existing implementation before making changes.

Accuracy is more important than speed.

Understanding is more important than coding.

---

# Flutter Architecture

* Use **Flutter + GetX** only.
* Use **StatelessWidget** only. Never use **StatefulWidget**.
* Use **GetX** for all state management.
* Every screen must have its own **Controller** responsible for managing that screen.
* Keep all business logic, state management, validation, calculations, filtering, sorting, search, Hive operations, and data flow inside **Controllers**, **ViewModels**, and **Services**.
* Never place business logic inside UI widgets.
* Screens should contain only:

  * UI rendering
  * Widget composition
  * Navigation triggers
  * Small UI-only conditions

Follow the existing MVVM-inspired feature architecture:

```text
feature/
│
├── controllers/
├── view_models/
├── models/
├── views/
└── widgets/
```


Feature Folder Structure

Every screen must have its own feature folder using the following structure:

feature_name/
│
├── screen/
│   └── feature_name_screen.dart
│
├── controller/
│   └── feature_name_screen_controller.dart
│
└── widgets/
    ├── widget_one.dart
    ├── widget_two.dart
    └── ...

Example:

home_screen/
│
├── screen/
│   └── home_screen.dart
│
├── controller/
│   └── home_screen_controller.dart
│
└── widgets/
    ├── home_header.dart
    ├── home_banner.dart
    ├── category_card.dart
    └── ...



Controller responsibilities:

* Manage screen state.
* Handle user interactions.
* Communicate with ViewModels/Services.
* Expose observable variables.
* Control loading, validation, filtering, and UI updates.

Every screen must be controlled from its corresponding GetX Controller.

---

# Local Storage (Hive)

This project is completely offline.

It does **not** use APIs or backend services.

All persistent data must be handled through **Hive**.

* Reuse existing Hive helpers.
* Keep Hive initialization centralized.
* Keep adapters, boxes, and storage helpers organized.
* Never duplicate Hive logic.

---

# Reuse Before Creating

Before creating any new:

* Widget
* Helper
* Service
* Hive helper
* Validator
* Extension
* Dialog
* Bottom Sheet
* AppBar
* Button
* Utility
* Constant
* Theme
* Model
* Controller

Search the existing project first.

If an implementation already exists:

* Reuse it.
* Extend it if necessary.
* Never duplicate widgets or logic.

---

# Respect the Existing Project

The existing project is the source of truth.

Always follow existing:

* Architecture
* Folder structure
* Naming conventions
* State management
* Hive patterns
* UI patterns
* Theme system
* Shared widgets
* Controllers
* ViewModels

Do not replace established project patterns with personal preferences.

Consistency is mandatory.

---

# UI Rules

Match provided Figma or reference images as closely as possible.

Aim for pixel-perfect implementation by matching:

* Layout
* Spacing
* Padding
* Typography
* Border radius
* Icons
* Shadows
* Alignment
* Component sizing

Always use existing project:

* Colors
* Themes
* Constants
* Shared widgets

Never hardcode colors.

Use existing typography helpers (such as `getTextStyle`) instead of creating new `TextStyle` instances unless absolutely necessary.

---

# GetX State Management

Use GetX consistently throughout the project.

* Every screen must have its own Controller.
* Controllers should own all observable state.
* UI should react only through GetX (`Obx`, `GetBuilder`, etc.).
* Never keep mutable state inside widgets.
* Controllers should coordinate with ViewModels and Services instead of embedding large amounts of business logic directly.

---

# Root Cause First

Never fix symptoms.

Always find and fix the real root cause.

Before writing code:

* Trace the complete flow.
* Identify where the issue starts.
* Verify why it happens.
* Confirm the cause from the existing code.

A fix is incomplete if the root cause still exists.

---

# Fix Related Issues Together

When fixing a bug:

Do not only fix the exact failing line.

Review the complete related flow.

If the same issue can occur elsewhere:

* Fix those locations too.
* Prevent the issue from happening again.

One implementation should solve the complete problem whenever logically possible.

---

# Learn From Previous Mistakes

If a bug was caused by:

* Wrong Hive mapping
* Wrong model
* Wrong state handling
* Missing validation
* Incorrect architecture usage
* Incorrect data flow

Check the rest of the project for the same mistake.

Do not repeat previously identified issues.

---

# No Assumptions

Never assume:

* Widgets
* Models
* Hive boxes
* Hive adapters
* Controllers
* ViewModels
* Helpers
* Colors
* Constants
* Imports
* Methods
* Classes

Verify everything from the existing project before generating code.

---

# Code Quality

All code must be:

* Clean
* Readable
* Maintainable
* Production-ready
* Consistent
* Scalable
* Logical

Avoid:

* Quick hacks
* Temporary fixes
* Duplicate code
* Overengineering
* Unnecessary abstractions
* Complex solutions when simple ones work

Prefer the simplest solution that correctly solves the problem.

---

# File Organization

Keep files small, focused, and maintainable.

If a file becomes too large:

* Split responsibilities logically.
* Extract reusable widgets.
* Keep screens lightweight.
* Keep controllers focused.
* Keep code easy to navigate.

Use meaningful names for:

* Files
* Widgets
* Controllers
* ViewModels
* Variables
* Methods

Avoid generic names.

---

# Validation Before Code Generation

Before generating or modifying code, verify:

* Imports are correct.
* Classes exist.
* Widgets exist.
* Methods exist.
* Dependencies exist.
* Routes exist.
* Hive models match adapters.
* Hive boxes are correctly used.
* Logic flow is correct.

Never generate code that references non-existent files, widgets, methods, or classes.

---

# Comments Policy

Do not add unnecessary comments.

Only comment:

* Complex business logic
* Important architectural decisions
* Non-obvious behavior
* Section headers in large Controllers or ViewModels

Do not comment obvious code.

Clean code should explain itself.

---

# Development Workflow

For every task:

1. Understand the requirement.
2. Understand the current implementation.
3. Trace the complete flow.
4. Find the root cause.
5. Identify related issues.
6. Reuse existing implementations whenever possible.
7. Implement the cleanest solution.
8. Verify no similar issue remains.
9. Ensure the implementation follows the existing project architecture.
10. Deliver a complete working solution.

Never skip these steps.

---

# Inspect `lib/core`

Before starting work, inspect the existing shared resources.

At minimum, review:

* `app_colors.dart`
* `icon_path.dart`
* `image_path.dart`
* `custom_appbar.dart`
* `custom_button.dart`
* `custom_text_field.dart`
* `global_text_style.dart`
* `shared_preference_helper.dart`

Also inspect other shared files inside `lib/core` before creating new implementations. Reuse existing utilities, widgets, themes, constants, and helpers whenever possible.

---

# Final Rule

Think before changing code.

Understand before implementing.

Reuse before creating.

Keep all state management inside GetX Controllers.

Keep business logic outside the UI.

Maintain consistency with the existing codebase.

One change should solve the complete problem whenever logically possible.

Every generated solution must be clean, simple, production-ready, maintainable, and fully aligned with the existing project architecture.
