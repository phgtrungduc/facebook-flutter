class RegisterEntity {
  String name;
  DateTime birthday;
  String phone;
  String password;

  RegisterEntity(this.name, this.birthday, this.phone, this.password);
  @override
  String toString() {
    return this.name.toString() +
        "-" +
        this.birthday.toString() +
        "-" +
        this.phone.toString() +
        "-" +
        this.password.toString();
  }
}
