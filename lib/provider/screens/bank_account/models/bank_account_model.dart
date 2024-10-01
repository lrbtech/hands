class BankAccountModel {
  int? id;
  int? providerId;
  String? bankName;
  String? branchName;
  String? accountNo;
  String? accountName;
  String? iban;
  String? swift;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  BankAccountModel({
    this.id,
    this.providerId,
    this.bankName,
    this.branchName,
    this.accountNo,
    this.accountName,
    this.iban,
    this.swift,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  BankAccountModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    providerId = json['provider_id'] ?? 0;
    bankName = json['bank_name'] ?? '';
    branchName = json['branch_name'] ?? '';
    accountNo = json['account_no'] ?? '';
    accountName = json['account_name'] ?? '';
    iban = json['iban'] ?? '';
    swift = json['swift'] ?? '';
    status = json['status'] ?? 0;
    createdAt = json['created_at'] ?? '';
    updatedAt = json['updated_at'] ?? '';
    deletedAt = json['deleted_at'] ?? '';
  }
}
