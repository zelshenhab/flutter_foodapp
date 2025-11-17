class AdminPromo {
  final int id;
  final String code;
  final String title;
  final String? description;
  final String type; // "percent" | "fixed"
  final num value;
  final DateTime? validFrom;
  final DateTime? validTo;
  final num? minSubtotal;
  final bool active;

  AdminPromo({
  required this.id,
  required this.code,
  required this.title,
  required this.description,
  required this.type,
  required this.value,
  required this.validFrom,
  required this.validTo,
  required this.minSubtotal,
  required this.active,
});

  factory AdminPromo.fromJson(Map<String, dynamic> j) {
    return AdminPromo(
      id: j["id"] as int,
      code: j["code"] ?? "",
      title: j["title"] ?? "",
      description: j["description"],
      type: j["type"] ?? "percent",
      value: j["value"] ?? 0,
      validFrom: j["validFrom"] != null ? DateTime.parse(j["validFrom"]) : null,
      validTo: j["validTo"] != null ? DateTime.parse(j["validTo"]) : null,
      minSubtotal: j["minSubtotal"],
      active: j["active"] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "code": code,
      "title": title,
      "description": description,
      "type": type,
      "value": value,
      "validFrom": validFrom?.toIso8601String(),
      "validTo": validTo?.toIso8601String(),
      "minSubtotal": minSubtotal,
      "active": active,
    };
  }

  AdminPromo copyWith({
    int? id,
    String? code,
    String? title,
    String? description,
    String? type,
    num? value,
    DateTime? validFrom,
    DateTime? validTo,
    num? minSubtotal,
    bool? active,
  }) {
    return AdminPromo(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      value: value ?? this.value,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      minSubtotal: minSubtotal ?? this.minSubtotal,
      active: active ?? this.active,
    );
  }
}
