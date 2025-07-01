final RegExp _usernamePattern = RegExp(
  r'^[a-zA-Z][a-zA-Z0-9_.]{2,19}$',
); // Username: starts with letter, 3-20 chars

final RegExp _emailPattern = RegExp(
  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  caseSensitive: false,
);

String? validateUserName(String? value) {
  if (value == null || value.isEmpty) {
    return "Username is required.";
  }
  
  if (value.length < 3) {
    return "Username must be at least 3 characters";
  }
  
  if (value.length > 20) {
    return "Username cannot exceed 20 characters";
  }

  if (!_usernamePattern.hasMatch(value)) {
    return 'Username must:\n'
           '• Start with a letter (a-z, A-Z)\n'
           '• Contain only letters, numbers, _ or .\n'
           '• Be 3-20 characters long';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return "Password is required.";
  }
  
  if (value.length < 8) {
    return 'Password must be at least 8 characters';
  }

  if (!value.contains(RegExp(r'[A-Z]'))) {
    return 'Password must contain at least one uppercase letter';
  }

  if (!value.contains(RegExp(r'[a-z]'))) {
    return 'Password must contain at least one lowercase letter';
  }

  if (!value.contains(RegExp(r'[0-9]'))) {
    return 'Password must contain at least one number (0-9)';
  }

  if (!value.contains(RegExp(r'[._#]'))) {
    return 'Password must contain at least one special character (., _, or #)';
  }
  
  // Optional: Check for common weak passwords
  if (value.contains(RegExp(r'(123456|password|qwerty|abc123)'))) {
    return 'Password is too common or weak';
  }
  
  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  
  if (!_emailPattern.hasMatch(value)) {
    return 'Please enter a valid email address\n'
           'Example: yourname@example.com';
  }
  
  // Optional: Disallow disposable emails
  if (value.endsWith('@tempmail.com') || 
      value.endsWith('@mailinator.com')) {
    return 'Disposable email addresses are not allowed';
  }
  
  return null;
}