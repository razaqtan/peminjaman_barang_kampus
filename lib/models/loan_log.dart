class LoanLog {
  final int id;
  final int loanId;
  final String action;
  final int actorId;
  final String actorName;
  final String note;
  final String createdAt;

  const LoanLog({
    required this.id,
    required this.loanId,
    required this.action,
    required this.actorId,
    required this.actorName,
    required this.note,
    required this.createdAt,
  });

  factory LoanLog.fromMap(Map<String, Object?> map) => LoanLog(
        id: map['id'] as int,
        loanId: map['loan_id'] as int,
        action: map['action'] as String,
        actorId: map['actor_id'] as int,
        actorName: map['actor_name'] as String? ?? '',
        note: map['note'] as String? ?? '',
        createdAt: map['created_at'] as String,
      );
}
