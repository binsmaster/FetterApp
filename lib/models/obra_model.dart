class ObraModel {
  final int numero;
  final String cliente;
  final String endereco;
  final String descricao;
  final DateTime createdAt;
  final List<String> imageUrls;

  ObraModel({
    required this.numero,
    required this.cliente,
    required this.endereco,
    required this.descricao,
    required this.createdAt,
    this.imageUrls = const [],
  });

  factory ObraModel.fromJson(Map<String, dynamic> json) {
    return ObraModel(
      numero: int.parse(json['numero']?.toString() ?? '0'),
      cliente: json['cliente']?.toString() ?? '',
      endereco: json['endereco']?.toString() ?? '',
      descricao: json['descricao']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      imageUrls: (json['image_urls'] as List<dynamic>?)
              ?.map((url) => url.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numero': numero.toString(),
      'cliente': cliente,
      'endereco': endereco,
      'descricao': descricao,
      'created_at': createdAt.toIso8601String(),
      'image_urls': imageUrls,
    };
  }

  ObraModel copyWith({
    int? numero,
    String? cliente,
    String? endereco,
    String? descricao,
    DateTime? createdAt,
    List<String>? imageUrls,
  }) {
    return ObraModel(
      numero: numero ?? this.numero,
      cliente: cliente ?? this.cliente,
      endereco: endereco ?? this.endereco,
      descricao: descricao ?? this.descricao,
      createdAt: createdAt ?? this.createdAt,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
}
