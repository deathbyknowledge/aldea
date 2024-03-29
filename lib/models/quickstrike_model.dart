import 'package:cloud_firestore/cloud_firestore.dart';

class QuickStrikePost {
  final String profilePic;
  final String title;
  int amount;
  List<dynamic> imageUrl;
  final String userId;
  final double price;
  bool isRandom;
  bool isQuestion;
  bool isGame;
  String modelo;
  String description;
  Timestamp fechaQuickstrike;
  String id;
  String communityName;
  String cid;
  String question;
  String correctAnswer;
  List<dynamic> wrongAnswers;
  bool isActive = false;
  final bool isEmpty;
  final bool finished;
  QuickStrikePost(
      {this.userId,
      this.profilePic,
      this.title,
      this.price,
      this.isActive,
      this.modelo,
      this.description,
      this.fechaQuickstrike,
      this.isGame,
      this.communityName,
      this.isQuestion,
      this.isRandom,
      this.imageUrl,
      this.id,
      this.isEmpty,
      this.finished,
      this.amount,
      this.cid,
      this.question,
      this.correctAnswer,
      this.wrongAnswers});

  Map<String, dynamic> toMap() {
    return {
      'isActive': isActive,
      'userId': userId,
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'isRandom': isRandom,
      'isQuestion': isQuestion,
      'isGame': isGame,
      'modelo': modelo,
      'description': description,
      'fechaQuickstrike': fechaQuickstrike,
      'id': id,
      'communityName': communityName,
      'isEmpty': isEmpty,
      'finished': finished,
      'cid': cid,
      'amount': amount,
      'question': question,
      'correctAnswer': correctAnswer,
      'wrongAnswers': wrongAnswers,
      'profilePic':profilePic
    };
  }

  static QuickStrikePost fromMap(Map<String, dynamic> map) {
    return QuickStrikePost(
        isActive: map['isActive'],
        title: map['title'],
        imageUrl: map['imageUrl'],
        userId: map['userId'],
        price: map['price'],
        isGame: map['isGame'],
        isRandom: map['isRandom'],
        isQuestion: map['isQuestion'],
        description: map['description'],
        modelo: map['modelo'],
        fechaQuickstrike: map['fechaQuickstrike'],
        id: map['id'],
        communityName: map['communityName'],
        isEmpty: map['isEmpty'],
        amount: map['amount'],
        cid: map['cid'],
        finished: map['finished'],
        question: map['question'],
        correctAnswer: map['correctAnswer'],
        profilePic: map['profilePic'],
        wrongAnswers: map['wrongAnswers']);
  }
}
