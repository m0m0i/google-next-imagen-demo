class GeminiResponse {
  final List<Candidate> candidates;
  final UsageMetadata usageMetadata;

  GeminiResponse({
    required this.candidates,
    required this.usageMetadata,
  });

  factory GeminiResponse.fromJson(Map<String, dynamic> json) {
    return GeminiResponse(
      candidates: (json['candidates'] as List)
          .map((e) => Candidate.fromJson(e))
          .toList(),
      usageMetadata: UsageMetadata.fromJson(json['usageMetadata']),
    );
  }
}

class Candidate {
  final Content content;

  Candidate({
    required this.content,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      content: Content.fromJson(json['content']),
    );
  }
}

class Content {
  final List<Part> parts;

  Content({
    required this.parts,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      parts: (json['parts'] as List)
          .map((e) => Part.fromJson(e))
          .toList(),
    );
  }
}

class Part {
  final String text;

  Part({
    required this.text,
  });

  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(
      text: json['text'],
    );
  }
}

class UsageMetadata {
  final int promptTokenCount;
  final int candidatesTokenCount;
  final int totalTokenCount;

  UsageMetadata({
    required this.promptTokenCount,
    required this.candidatesTokenCount,
    required this.totalTokenCount,
  });

  factory UsageMetadata.fromJson(Map<String, dynamic> json) {
    return UsageMetadata(
      promptTokenCount: json['promptTokenCount'],
      candidatesTokenCount: json['candidatesTokenCount'],
      totalTokenCount: json['totalTokenCount'],
    );
  }
}