import 'package:flutter/foundation.dart';


/// Simple notifier that fires whenever the user saves their profile.
/// UserHeaderWidget listens to this to refresh name and image.
class ProfileNotifier extends ChangeNotifier {
  static final ProfileNotifier instance = ProfileNotifier._();
  ProfileNotifier._();

  void notifyProfileUpdated() {
    notifyListeners();
  }
}
