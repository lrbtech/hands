class RatingsModel {
  ProviderRating? providerRating;
  ProviderReviews? providerReviews;

  RatingsModel({this.providerRating, this.providerReviews});

  RatingsModel.fromJson(Map<String, dynamic> json) {
    providerRating = json['provider_rating'] != null ? new ProviderRating.fromJson(json['provider_rating']) : null;
    providerReviews = json['provider_reviews'] != null ? new ProviderReviews.fromJson(json['provider_reviews']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.providerRating != null) {
      data['provider_rating'] = this.providerRating!.toJson();
    }
    if (this.providerReviews != null) {
      data['provider_reviews'] = this.providerReviews!.toJson();
    }
    return data;
  }
}

class ProviderRating {
  int? ratingCount;
  double? rate;

  ProviderRating({this.ratingCount, this.rate});

  ProviderRating.fromJson(Map<String, dynamic> json) {
    ratingCount = json['rating_count'];
    rate = json['rate'].toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rating_count'] = this.ratingCount;
    data['rate'] = this.rate;
    return data;
  }
}

class ProviderReviews {
  int? currentPage;
  List<Rating>? ratings;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Links>? links;
  String? path;
  int? perPage;
  int? to;
  int? total;

  ProviderReviews({this.currentPage, this.ratings, this.firstPageUrl, this.from, this.lastPage, this.lastPageUrl, this.links, this.path, this.perPage, this.to, this.total});

  ProviderReviews.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      ratings = <Rating>[];
      json['data'].forEach((v) {
        ratings!.add(new Rating.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(new Links.fromJson(v));
      });
    }
    path = json['path'];
    perPage = json['per_page'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_page'] = this.currentPage;
    if (this.ratings != null) {
      data['data'] = this.ratings!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = this.firstPageUrl;
    data['from'] = this.from;
    data['last_page'] = this.lastPage;
    data['last_page_url'] = this.lastPageUrl;
    if (this.links != null) {
      data['links'] = this.links!.map((v) => v.toJson()).toList();
    }
    data['path'] = this.path;
    data['per_page'] = this.perPage;
    data['to'] = this.to;
    data['total'] = this.total;
    return data;
  }
}

class Rating {
  String? review;
  String? username;
  String? date;
  int? rating;
  int? isUrgent;

  Rating({
    this.review,
    this.rating,
    this.isUrgent,
    this.username,
    this.date,
  });

  Rating.fromJson(Map<String, dynamic> json) {
    review = json['review'];
    rating = json['rating'];
    isUrgent = json['is_urgent'];
    username = json['user_name'];
    date = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['review'] = this.review;
    data['created_at'] = this.date;
    data['rating'] = this.rating;
    data['is_urgent'] = this.isUrgent;
    data['user_name'] = this.username;
    return data;
  }
}

class Links {
  String? url;
  String? label;
  bool? active;

  Links({this.url, this.label, this.active});

  Links.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['label'] = this.label;
    data['active'] = this.active;
    return data;
  }
}
