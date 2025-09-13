# Lives App Authentication System

## Overview
I have successfully implemented a comprehensive authentication system for the Lives app following the exact specifications provided. The system handles both User and Contributor registration flows with email verification.

## Features Implemented

### 1. Authentication Models
- **User Model**: Handles user registration data with proper JSON serialization
- **Contributor Model**: Supports both Individual and Association types
- **Verification Models**: Email verification and API response handling
- All models use manual JSON serialization (no external dependencies)

### 2. Authentication Service (`AuthService`)
- User registration: `POST /users`
- Contributor registration: `POST /contributors`
- Email verification: `POST /users/validate-email`  
- Resend verification: `POST /users/resend-verification-email`
- Proper error handling with custom `AuthException`
- Helper methods for creating registration requests

### 3. BLoC State Management (`AuthBloc`)
- Complete state management for authentication flow
- Events for all user actions (registration, verification, navigation)
- States for each step of the authentication process
- Proper error handling and loading states

### 4. UI Components
- **User Type Selection**: Initial choice between "User" or "Contributor"
- **Contributor Type Selection**: Choose between "Individual" or "Association"
- **User Registration Form**: Email, first name, last name, phone number
- **Individual Contributor Form**: Personal details + ID card and selfie upload
- **Association Contributor Form**: Organization details + registration certificate
- **Email Verification**: 6-digit code input with resend functionality
- **Auth Status**: Success screens with appropriate messaging

### 5. Integration
- **Account Page**: Fully integrated with authentication flow
- **Navigation**: Seamless flow between different authentication steps
- **Error Handling**: User-friendly error messages and recovery options

## API Endpoints Used

### User Registration
```
POST /users
{
  "user_type": "registered",
  "email": "user@example.com",
  "first_name": "Ahmed",
  "last_name": "Al-Rashid", 
  "phone_number": "+970-123-456789",
  "is_email_verified": false,
  "registration_date": "2025-08-24T10:00:00Z"
}
```

### Contributor Registration
```
POST /contributors
{
  "user_id": 1,
  "contributor_type": "individual", // or "association"
  "verification_status": "pending",
  "verified": false,
  "email": "",
  "first_name": "", // individual only
  "last_name": "", // individual only
  "phone_number": "",
  "id_card_picture": "", // individual only
  "selfie_picture": "", // individual only
  "organization_name": "", // association only
  "organization_address": "", // association only
  "registration_certificate_picture": "" // association only
}
```

### Email Verification
```
POST /users/validate-email
{
  "user_id": 1,
  "verification_code": "123456"
}
```

### Resend Verification
```
POST /users/resend-verification-email
{
  "user_id": 1
}
```

## Authentication Flow

1. **Initial Access**: User clicks account button in navigation
2. **Type Selection**: Choose between "User" or "Contributor"
3. **User Flow**:
   - Fill registration form (email, name, phone)
   - Submit registration → receive user_id and token
   - Verify email with 6-digit code
   - Account activated
4. **Contributor Flow**:
   - Complete user registration first
   - Verify email
   - Choose contributor type (Individual/Association)
   - Fill appropriate contributor form
   - Submit contributor registration
   - Account remains in "pending" status until admin approval

## Key Features

✅ **Complete Form Validation**: All forms have proper validation with user-friendly error messages

✅ **Document Upload Simulation**: File upload UI is ready (currently simulated - can be connected to actual file picker)

✅ **Responsive Design**: All screens adapt to different screen sizes

✅ **Error Handling**: Comprehensive error handling with retry mechanisms

✅ **Loading States**: Proper loading indicators during API calls

✅ **Navigation Flow**: Intuitive back/forward navigation between steps

✅ **Email Verification**: 6-digit code input with countdown timer and resend functionality

✅ **Status Management**: Clear indication of account status (verified, pending, etc.)

## File Structure

```
lib/
├── models/
│   ├── user.dart                    # User model and registration requests
│   ├── contributor.dart            # Contributor models
│   └── verification.dart           # Verification models
├── services/
│   └── auth_service.dart           # HTTP service for API calls
├── bloc/auth/
│   ├── auth_bloc.dart              # Main authentication BLoC
│   ├── auth_event.dart             # Authentication events
│   ├── auth_state.dart             # Authentication states
│   └── auth.dart                   # Barrel export file
├── widgets/
│   ├── user_type_selection.dart        # Initial type selection
│   ├── contributor_type_selection.dart  # Contributor type choice
│   ├── user_registration_form.dart      # User registration form
│   ├── individual_contributor_form.dart # Individual contributor form
│   ├── association_contributor_form.dart # Association contributor form
│   ├── email_verification.dart          # Email verification UI
│   └── auth_status.dart                # Success/status screens
└── pages/
    └── account.dart                # Updated account page with auth flow
```

## Configuration

### API Base URL
Update the base URL in `AuthService`:
```dart
static const String _baseUrl = 'https://your-api-base-url.com';
```

### Dependencies Added
- `http: ^1.1.0` for API calls

## Usage

The authentication system is fully integrated into the account page. When users click the account button in the navigation drawer, they will be guided through the appropriate registration flow based on their selections.

### For Testing
- The document upload functionality is currently simulated
- API calls will need a real backend endpoint
- All forms are fully functional and validated

### Next Steps for Production
1. Connect to real API endpoints
2. Implement actual file/image picker for document uploads
3. Add persistent storage for user sessions
4. Implement logout functionality
5. Add admin dashboard for contributor verification (separate project)

The authentication system is now complete and ready for integration with your backend API!