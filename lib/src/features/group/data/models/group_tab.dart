enum GroupTab {
  discussion(1, 'discussion', 'Discussion Room'),
  classRoom(2, 'class', 'Class Room'),
  liveClass(3, 'live_class', 'Live Class Room'),
  events(4, 'events', 'Events Room'),
  members(5, 'members', 'Members Room'),
  doubt(6, 'doubt', 'Doubt Room'),
  challenges(7, 'challenges', 'Challenges Room'),
  treasure(8, 'treasure', 'Treasure Room'),
  product(9, 'product', 'Product Room'),
  service(10, 'service', 'Service Room'),
  job(11, 'job', 'Job Room');

  final int id;
  final String key;
  final String label;

  const GroupTab(this.id, this.key, this.label);

  static GroupTab? fromId(int? id) {
    if (id == null) return null;
    try {
      return values.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  static GroupTab? fromKey(String? key) {
    if (key == null) return null;
    try {
      return values.firstWhere((e) => e.key == key);
    } catch (_) {
      return null;
    }
  }
}
