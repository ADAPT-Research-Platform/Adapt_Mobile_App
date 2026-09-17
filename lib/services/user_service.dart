import 'dart:convert';

import 'package:adapt/services/session_manager.dart';
import 'package:logging/logging.dart';

import '../utils/app_config.dart';
import '../utils/app_keys.dart';
import '../utils/app_routes.dart';
import '../widgets/snack_bar_shower.dart';

class UserService {
  final log = Logger('UserService');

  void updateUser(String userName, String currentPassword, String newPassword, String confirmNewPassword) async {
    if(userName.isEmpty){
      SnackBarShower.warn(mainPageScaffold, 'username_empty');
      return;
    }

    final sessionUser = await SessionManager().getSessionUser();
    if(userName == sessionUser!.userName && newPassword.isEmpty){
      SnackBarShower.warn(mainPageScaffold, 'nothing_to_update');
      return;
    }

    if(newPassword.isNotEmpty){ //Which means user has given a new password

      if(currentPassword.isEmpty){
        SnackBarShower.warn(mainPageScaffold, 'current_password_required');
        return;
      }

      // Validate passwords
      if (newPassword != confirmNewPassword) {
        SnackBarShower.warn(mainPageScaffold, 'confirm_password_mismatch');
        return;
      }
    }

    try {
      final response = await SessionManager().client.put(
        Uri.parse('${AppConfig.baseUrl}/users'),
        headers: SessionManager().getHeaders(),
        body: jsonEncode({
          'userName': userName,
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      log.info('User Update Response: ${response.body}');
      if (response.statusCode == 200) {
        //Update username on current session!
        sessionUser.userName = userName;
        await SessionManager().setSessionInfo(
          user: sessionUser,
        ); // Extract the cookie value

        SnackBarShower.info(mainPageScaffold, 'user_update_success');
      } else {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        SnackBarShower.error(mainPageScaffold, jsonResponse['message']);
      }
    } catch (e) {
      log.severe('Error in User Update', e);
      SnackBarShower.error(mainPageScaffold, 'internal_app_error');
    }
  }

  void deleteUser(String currentPassword) async {
    if(currentPassword.isEmpty){
      SnackBarShower.warn(mainPageScaffold, 'password_missing');
      return;
    }

    try {
      final response = await SessionManager().client.delete(
        Uri.parse('${AppConfig.baseUrl}/users'),
        headers: SessionManager().getHeaders(),
        body: jsonEncode({
          'currentPassword': currentPassword,
        }),
      );

      log.info('User Delete Response: ${response.body}');
      if (response.statusCode == 200) {
        SessionManager().clearSessionInfo();

        // Navigate to the login page
        mainNavigator.currentState!.pushReplacementNamed(Routes.routeLogin);

        Future.delayed(const Duration(milliseconds: 1000), () {
          SnackBarShower.info(loginPageScaffold, 'user_delete_success');
        });
      } else {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        SnackBarShower.error(mainPageScaffold, jsonResponse['message']);
      }
    } catch (e) {
      log.severe('Error in User Delete', e);
      SnackBarShower.error(mainPageScaffold, 'internal_app_error');
    }
  }
}
