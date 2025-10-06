class accounts {
  int? id;
  String? name;
  String? email;
  String? password;
  Null? resetToken;
  Null? tokenExpiry;
  String? phoneNumber;
  String? photo;
  Null? dateOfBirth;
  String? role;
  List<Null>? tokens;
  bool? active;
  bool? enabled;
  List<Authorities>? authorities;
  String? username;
  bool? accountNonExpired;
  bool? credentialsNonExpired;
  bool? lock;
  bool? accountNonLocked;

  accounts(
      {this.id,
        this.name,
        this.email,
        this.password,
        this.resetToken,
        this.tokenExpiry,
        this.phoneNumber,
        this.photo,
        this.dateOfBirth,
        this.role,
        this.tokens,
        this.active,
        this.enabled,
        this.authorities,
        this.username,
        this.accountNonExpired,
        this.credentialsNonExpired,
        this.lock,
        this.accountNonLocked});

  accounts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    password = json['password'];
    resetToken = json['resetToken'];
    tokenExpiry = json['tokenExpiry'];
    phoneNumber = json['phoneNumber'];
    photo = json['photo'];
    dateOfBirth = json['dateOfBirth'];
    role = json['role'];
    // if (json['tokens'] != null) {
    //   tokens = <Null>[];
    //   json['tokens'].forEach((v) {
    //     tokens!.add(new Null.fromJson(v));
    //   });
    // }
    active = json['active'];
    enabled = json['enabled'];
    if (json['authorities'] != null) {
      authorities = <Authorities>[];
      json['authorities'].forEach((v) {
        authorities!.add(new Authorities.fromJson(v));
      });
    }
    username = json['username'];
    accountNonExpired = json['accountNonExpired'];
    credentialsNonExpired = json['credentialsNonExpired'];
    lock = json['lock'];
    accountNonLocked = json['accountNonLocked'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['password'] = this.password;
    data['resetToken'] = this.resetToken;
    data['tokenExpiry'] = this.tokenExpiry;
    data['phoneNumber'] = this.phoneNumber;
    data['photo'] = this.photo;
    data['dateOfBirth'] = this.dateOfBirth;
    data['role'] = this.role;
    // if (this.tokens != null) {
    //   data['tokens'] = this.tokens!.map((v) => v.toJson()).toList();
    // }
    data['active'] = this.active;
    data['enabled'] = this.enabled;
    if (this.authorities != null) {
      data['authorities'] = this.authorities!.map((v) => v.toJson()).toList();
    }
    data['username'] = this.username;
    data['accountNonExpired'] = this.accountNonExpired;
    data['credentialsNonExpired'] = this.credentialsNonExpired;
    data['lock'] = this.lock;
    data['accountNonLocked'] = this.accountNonLocked;
    return data;
  }
}

class Authorities {
  String? authority;

  Authorities({this.authority});

  Authorities.fromJson(Map<String, dynamic> json) {
    authority = json['authority'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['authority'] = this.authority;
    return data;
  }
}
