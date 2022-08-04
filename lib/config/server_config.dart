class ServerConfig {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String? baseUrl;
  final String? appName;
  final String? username;
  final String? password;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const ServerConfig({
    this.baseUrl,
    this.appName,
    this.username,
    this.password,
  });

  const ServerConfig.empty() : this();

  ServerConfig.fromJson({required Map<String, dynamic> json})
      : this(
          baseUrl: json['baseUrl'],
          appName: json['appName'],
          username: json['username'],
          password: json['password'],
        );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'baseUrl': baseUrl,
        'appName': appName,
        'username': username,
        'password': password,
      };
}