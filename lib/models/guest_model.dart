enum RSVPStatus { pending, accepted, declined, maybe }

class GuestModel {
  final String id;
  final String eventId;
  final String name;
  final String email;
  final String? phone;
  final RSVPStatus rsvpStatus;
  final int? plusOnes;
  final String? notes;

  GuestModel({
    required this.id,
    required this.eventId,
    required this.name,
    required this.email,
    this.phone,
    this.rsvpStatus = RSVPStatus.pending,
    this.plusOnes,
    this.notes,
  });

  GuestModel copyWith({
    String? id,
    String? eventId,
    String? name,
    String? email,
    String? phone,
    RSVPStatus? rsvpStatus,
    int? plusOnes,
    String? notes,
  }) {
    return GuestModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      rsvpStatus: rsvpStatus ?? this.rsvpStatus,
      plusOnes: plusOnes ?? this.plusOnes,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'name': name,
      'email': email,
      'phone': phone,
      'rsvpStatus': rsvpStatus.toString(),
      'plusOnes': plusOnes,
      'notes': notes,
    };
  }

  factory GuestModel.fromJson(Map<String, dynamic> json) {
    return GuestModel(
      id: json['id'],
      eventId: json['eventId'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      rsvpStatus: RSVPStatus.values.firstWhere(
        (e) => e.toString() == json['rsvpStatus'],
        orElse: () => RSVPStatus.pending,
      ),
      plusOnes: json['plusOnes'],
      notes: json['notes'],
    );
  }
}