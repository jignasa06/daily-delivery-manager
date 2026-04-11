# Project Architectural Guidelines

To ensure the long-term scalability and maintainability of the Daily Delivery Manager, following rules MUST be followed by all contributors.

## 1. Backend Agnosticity (Repository Pattern)

The UI layer must **NEVER** interact directly with Firebase, Supabase, or any other specific backend service.

- **Interfaces**: All data operations must be defined in an interface (e.g., `ICustomerRepository`) in the `domain/repositories` folder.
- **Implementations**: Concrete implementations (e.g., `FirebaseCustomerRepository`, `MockCustomerRepository`) must reside in the `data/repositories` folder.
- **Dependency Injection**: Use `service_locator.dart` to bind the implementation to the interface. Always check the `useMockData` flag.

## 2. Standardized Imports

To prevent "Target of URI doesn't exist" errors during refactoring, **Always use absolute package imports** for feature-to-feature or layer-to-layer communication.

- **Correct**: `import 'package:p_v_j/features/vendor/customers/data/models/customer_model.dart';`
- **Incorrect**: `import '../../models/customer_model.dart';` (Avoid relative paths except for strictly local sibling files).

## 3. Demo-First Development

Every new feature must include a `Mock` version of its repository with realistic dummy data. This allows:
- Testing without internet or Firebase configuration.
- High-speed UI development.
- Safe demoing for potential clients/users.

## 4. Controller Dependencies

Controllers should only depend on **Repository Interfaces**.
- **Correct**: `final ICustomerRepository _repo = Get.find<ICustomerRepository>();`
- **Incorrect**: `final CustomerService _service = Get.find<CustomerService>();`

---
*Last Updated: 2026-04-11*
