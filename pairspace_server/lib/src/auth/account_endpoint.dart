import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

class AccountEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// The signed-in user's own email, or null if their profile has none.
  Future<String?> myEmail(Session session) async {
    final profile = await AuthServices.instance.userProfiles
        .maybeFindUserProfileByUserId(
          session,
          session.authenticated!.authUserId,
        );
    return profile?.email;
  }
}
