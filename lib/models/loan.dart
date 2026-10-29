class Loan {
  final int id;
  final String loanCode;
  final int borrowerId;
  final String borrowerName;
  final String facilityName;
  final int quantity;
  final String startAt;
  final String endAt;
  final String purpose;
  final String status;
  final String note;
  final String qrPayload;

  const Loan({
    required this.id,
    required this.loanCode,
    required this.borrowerId,
    required this.borrowerName,
    required this.facilityName,
    required this.quantity,
    required this.startAt,
    required this.endAt,
    required this.purpose,
    required this.status,
    required this.note,
    required this.qrPayload,
  });

  factory Loan.fromMap(Map<String, Object?> map) => Loan(
        id: map['id'] as int,
        loanCode: map['loan_code'] as String,
        borrowerId: map['borrower_id'] as int,
        borrowerName: map['borrower_name'] as String? ?? '',
        facilityName: map['facility_name'] as String? ?? '',
        quantity: map['quantity'] as int,
        startAt: map['start_at'] as String,
        endAt: map['end_at'] as String,
        purpose: map['purpose'] as String,
        status: map['status'] as String,
        note: map['note'] as String? ?? '',
        qrPayload: map['qr_payload'] as String? ?? '',
      );
}
