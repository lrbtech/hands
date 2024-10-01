class ProviderReview {
  String? review;
  int? rating;
  String? userName;

  ProviderReview({this.review, this.rating, this.userName});

  ProviderReview.fromJson(Map<String, dynamic> json) {
    review = json['review'];
    rating = json['rating'];
    userName = json['user_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['review'] = this.review;
    data['rating'] = this.rating;
    data['user_name'] = this.userName;
    return data;
  }
}
