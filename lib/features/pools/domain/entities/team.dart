/// Entidad de dominio: equipo del mundial (sembrado en la base de datos).
class Team {
  const Team({
    required this.id,
    required this.name,
    required this.fifaCode,
    required this.iso2,
    required this.flagUrl,
    this.group,
  });

  final int id;
  final String name;
  final String fifaCode;
  final String iso2;
  final String flagUrl;
  final String? group;
}

/// Estadio sede de un partido.
class Stadium {
  const Stadium({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.capacity,
  });

  final int id;
  final String name;
  final String city;
  final String country;
  final int capacity;
}
