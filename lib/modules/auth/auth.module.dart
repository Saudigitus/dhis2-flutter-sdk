import 'package:d2_touch/core/models/d2_touch.model.dart';
import 'package:d2_touch/modules/auth/models/auth-token.model.dart';
import 'package:d2_touch/modules/auth/models/login-response.model.dart';
import 'package:d2_touch/shared/utilities/http_client.util.dart';
import 'package:dio/dio.dart';

import 'entities/user.entity.dart';

class AuthModule {
  D2TouchModel d2Instance;
  AuthModule({required this.d2Instance});

  Future<bool> isAuthenticated() async {
    if (d2Instance.database == null) {
      return false;
    }

    final User? user = await d2Instance.userModule2.user.getOne();
    return user?.isLoggedIn ?? false;
  }

  Future<LoginResponseStatus> logIn(
      {required String username,
      required String password,
      required String url,
      Dio? dioTestClient}) async {
    HttpResponse userResponse = await HttpClient.get(
        'me.json?fields=id,name,created,lastUpdated,birthday,gender,displayName,jobTitle,surname,employer,email,firstName,phoneNumber,nationality,userCredentials[code,id,name,lastLogin,displayName,username,userRoles[id,name,code]],organisationUnits[id,code,name],dataViewOrganisationUnits[id,code,name],userGroups[id,name],authorities,programs,dataSets',
        baseUrl: url,
        username: username,
        password: password,
        dioTestClient: dioTestClient);

    if (userResponse.statusCode == 401) {
      return LoginResponseStatus.WRONG_CREDENTIALS;
    }

    if (userResponse.statusCode == 500) {
      return LoginResponseStatus.SERVER_ERROR;
    }

    final uri = Uri.parse(url).host;
    final String databaseName = '${username}_$uri';

    d2Instance.database = await d2Instance.setDatabase(
        databaseName: databaseName,
        inMemory: d2Instance.inMemory,
        databaseFactory: d2Instance.databaseFactory,
        sharedPreferenceInstance: d2Instance.sharedPreferenceInstance);

    Map<String, dynamic> userData = userResponse.body;
    userData['password'] = password;
    userData['isLoggedIn'] = true;
    userData['username'] = username;
    userData['baseUrl'] = url;
    userData['authTye'] = 'basic';
    userData['dirty'] = true;

    final user = User.fromApi(userData);
    await d2Instance.userModule2.user.setData(user).save();

    await d2Instance.userModule2.userOrganisationUnit
        .setData(user.organisationUnits)
        .save();

    return LoginResponseStatus.ONLINE_LOGIN_SUCCESS;
  }

  Future<bool> logOut() async {
    bool logOutSuccess = false;
    try {
      User? currentUser = await d2Instance.userModule2.user.getOne();

      currentUser?.isLoggedIn = false;
      currentUser?.dirty = true;

      await d2Instance.userModule2.user.setData(currentUser).save();

      logOutSuccess = true;
    } catch (e) {}
    return logOutSuccess;
  }

  Future<LoginResponseStatus> setToken(
      {required String instanceUrl,
      required Map<String, dynamic> userObject,
      required Map<String, dynamic> tokenObject,
      Dio? dioTestClient}) async {
    final uri = Uri.parse(instanceUrl).host;
    final String databaseName = '$uri';

    d2Instance.database = await d2Instance.setDatabase(
        databaseName: databaseName,
        inMemory: d2Instance.inMemory,
        databaseFactory: d2Instance.databaseFactory,
        sharedPreferenceInstance: d2Instance.sharedPreferenceInstance);

    AuthToken token = AuthToken.fromJson(tokenObject);

    userObject['token'] = token.accessToken;
    userObject['tokenType'] = token.tokenType;
    userObject['tokenExpiry'] = token.expiresIn;
    userObject['refreshToken'] = token.refreshToken;
    userObject['isLoggedIn'] = true;
    userObject['dirty'] = true;
    userObject['baseUrl'] = instanceUrl;
    userObject['authType'] = "token";

    final user = User.fromApi(userObject);
    print("NEW:: ${(await d2Instance.userModule2.user.getOne())?.toJson()}");
    // print("DATA TO SAVE:: ${user.toJson()}");

    await d2Instance.userModule2.user.setData(user).save();

    await d2Instance.userModule2.userOrganisationUnit
        .setData(user.organisationUnits)
        .save();

    return LoginResponseStatus.ONLINE_LOGIN_SUCCESS;
  }
}
