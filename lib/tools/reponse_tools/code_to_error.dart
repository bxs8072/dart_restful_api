class CodeToError {
  static String authErrorMessage(int code) {
    if (code == 11000) {
      return "User with email address already existed";
    }

    return "";
  }
}
