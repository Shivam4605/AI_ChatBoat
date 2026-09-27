import 'dart:convert';

class UserModel({
  required this.text,
  required this.isUser,
  required this.timeStamp,
  required this.isLoading,
}) {
  String text;
  bool isUser;
  String timeStamp;
  bool isLoading;

  UserModel copyWith({
    String? text,
    bool? isUser,
    String? timeStamp,
    bool? isLoading,
  }) {
    return UserModel(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timeStamp: timeStamp ?? this.timeStamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'text': text,
      'isUser': isUser,
      'timeStamp': timeStamp,
      'isLoading': isLoading,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      text: map['text'] ?? '',
      isUser: map['isUser'] ?? false,
      timeStamp: map['timeStamp'] ?? '',
      isLoading: map['isLoading'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
