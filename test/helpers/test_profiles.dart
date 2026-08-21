import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';

class TestProfiles extends Profiles {
  final List<Profile> initial;

  TestProfiles([this.initial = const []]);

  @override
  List<Profile> build() => initial;

  @override
  void put(Profile profile) {
    final next = List<Profile>.from(state);
    final index = next.indexWhere((item) => item.id == profile.id);
    if (index == -1) {
      next.add(profile);
    } else {
      next[index] = profile;
    }
    state = next;
  }

  @override
  Future<void> del(int id) async {
    state = state.where((profile) => profile.id != id).toList();
  }

  @override
  void reorder(List<Profile> profiles) {
    state = List.of(profiles);
  }

  void replace(List<Profile> profiles) {
    state = profiles;
  }
}
