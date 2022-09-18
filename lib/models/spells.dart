class Spell {
  final String slug;
  final String name;
  final String description;
  final String higherLevel;
  final String range;
  final String material;
  final String duration;
  final int level;
  final String school;
  final List<String> classes;

  Spell({
    required this.slug,
    required this.name,
    required this.description,
    required this.level,
    required this.classes,
    this.higherLevel = '',
    this.range = '',
    this.material = '',
    this.duration = '',
    this.school = '',
  });

  static Spell fromJson(dynamic rawJson) {
    List<String> classes =
        (rawJson['dnd_class'].replaceAll(' ', '')).split(',');
    return Spell(
        slug: rawJson['slug'],
        name: rawJson['name'],
        description: rawJson['desc'],
        higherLevel: rawJson['higher_level'],
        range: rawJson['range'],
        material: rawJson['material'],
        duration: rawJson['duration'],
        level: rawJson['level_int'],
        school: rawJson['school'],
        classes: classes);
  }
}

class SpellPreview {
  final String slug;
  final String name;
  final int level;
  List<String> classes;

  SpellPreview(
      {required this.slug,
      required this.name,
      required this.level,
      required this.classes});

  static SpellPreview fromJson(dynamic rawJson) {
    List<String> classes =
        (rawJson['dnd_class'].replaceAll(' ', '')).split(',');

    return SpellPreview(
        slug: rawJson['slug'],
        name: rawJson['name'],
        level: rawJson['level_int'],
        classes: classes);
  }
}
