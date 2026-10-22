/// A favourite contact shown on the EasyDial home screen.
///
/// Only what the app needs is stored: a display name, the number to dial,
/// an optional locally-saved photo, and an optional reference to the phone's
/// address-book entry. Tile position is the item's index in the saved list.
class Favourite {
  final String id;
  final String name;
  final String phone;
  final String? photoPath;
  final String? contactId;
  final bool isSample;

  const Favourite({
    required this.id,
    required this.name,
    required this.phone,
    this.photoPath,
    this.contactId,
    this.isSample = false,
  });

  Favourite copyWith({
    String? name,
    String? phone,
    String? photoPath,
    bool clearPhoto = false,
    String? contactId,
    bool? isSample,
  }) {
    return Favourite(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      contactId: contactId ?? this.contactId,
      isSample: isSample ?? this.isSample,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'photoPath': photoPath,
        'contactId': contactId,
        'isSample': isSample,
      };

  factory Favourite.fromJson(Map<String, dynamic> json) => Favourite(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        photoPath: json['photoPath'] as String?,
        contactId: json['contactId'] as String?,
        isSample: json['isSample'] as bool? ?? false,
      );
}
