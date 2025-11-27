class Roast {
  final String text;
  final String emote; // Filename for the emote image

  Roast({
    required this.text,
    required this.emote,
  });

  factory Roast.fromJson(Map<String, dynamic> json) {
    return Roast(
      text: json['text'] ?? '',
      emote: json['emote'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'emote': emote,
    };
  }
}
