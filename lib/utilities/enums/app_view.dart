enum AppView {
  splash,
  signUp,
  logIn,
  dashboard,
  workspace;

  String get path => name == "splash" ? "/" : "/$name";
}
