class Post{
  final String id;
  final String title;
  final String content;
  bool isFavorited;

  Post({
    required this.id,
    required this.title,
    required this.content,
    this.isFavorited = false,
    
  });


}