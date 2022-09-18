import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/spells.dart';

final spellProvider = StateProvider<Spell>((ref) {
  return Spell(slug: '', name: '', description: '', level: 0, classes: []);
});
