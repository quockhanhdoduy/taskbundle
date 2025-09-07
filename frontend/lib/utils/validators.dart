class Validators {
  static String? email(String? value) {
    if (value?.isEmpty ?? true) return 'Email không được để trống';

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value!)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  static String? password(String? value) {
    if (value?.isEmpty ?? true) return 'Mật khẩu không được để trống';

    if (value!.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất 1 chữ thường';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất 1 chữ hoa';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất 1 số';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất 1 ký tự đặc biệt';
    }

    return null;
  }

  // Simple password for login (no strong password when login)
  static String? loginPassword(String? value) {
    if (value?.isEmpty ?? true) return 'Mật khẩu không được để trống';
    if (value!.length < 8) return 'Mật khẩu phải có ít nhất 8 ký tự';
    return null;
  }


  static String? name(String? value) {
    if (value?.isEmpty ?? true) return 'Tên không được để trống';
    if (value!.trim().isEmpty) return 'Tên không được để trống';
    if (value.length > 150) return 'Tên không được vượt quá 150 ký tự';
    return null;
  }

  // Generic required field
  static String? required(String? value, String fieldName) {
    if (value?.isEmpty ?? true) return '$fieldName không được để trống';
    if (value!.trim().isEmpty) return '$fieldName không được để trống';
    return null;
  }

  static String? confirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword?.isEmpty ?? true) return 'Xác nhận mật khẩu không được để trống';
    if (password != confirmPassword) return 'Mật khẩu xác nhận không khớp';
    return null;
  }

  static String? title(String? value, {int maxLength = 200}) {
    if (value?.isEmpty ?? true) return 'Tiêu đề không được để trống';
    if (value!.trim().isEmpty) return 'Tiêu đề không được để trống';
    if (value.length > maxLength) return 'Tiêu đề không được vượt quá $maxLength ký tự';
    return null;
  }

  // Board name validation (max: 150)
  static String? boardName(String? value) {
    return title(value, maxLength: 150);
  }

  // Card title validation (max: 200)
  static String? cardTitle(String? value) {
    return title(value, maxLength: 200);
  }


  // Comment content validation (min: 1, max: 2000)
  static String? comment(String? value) {
    if (value?.isEmpty ?? true) return 'Nội dung bình luận không được để trống';
    if (value!.trim().isEmpty) return 'Nội dung bình luận không được để trống';
    if (value.length > 2000) return 'Bình luận không được vượt quá 2000 ký tự';
    return null;
  }

  // URL validation for background images
  static String? url(String? value) {
    if (value?.isEmpty ?? true) return null; // Optional field

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
    );

    if (!urlRegex.hasMatch(value!)) {
      return 'URL không hợp lệ';
    }
    return null;
  }

  // Date validation (ISO 8601 format)
  static String? date(String? value) {
    if (value?.isEmpty ?? true) return null; // Optional field

    try {
      DateTime.parse(value!);
      return null;
    } catch (e) {
      return 'Ngày không hợp lệ';
    }
  }

  // OTP validation (usually 6 digits)
  static String? otp(String? value) {
    if (value?.isEmpty ?? true) return 'Mã OTP không được để trống';
    if (value!.length != 6) return 'Mã OTP phải có 6 số';
    if (!RegExp(r'^\d{6}$').hasMatch(value)) return 'Mã OTP chỉ được chứa số';
    return null;
  }
}