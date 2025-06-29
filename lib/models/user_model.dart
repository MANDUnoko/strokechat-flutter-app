import 'package:uuid/uuid.dart';

// 사용자 정보를 담는 모델
class UserModel {
  final String employeeId; // 사원번호 (로그인 ID)
  final String name; // 사용자 이름
  final String department; // 부서
  final String role; // 역할 (doctor, nurse, patient 등)
  final String? uuid; // 웹 토큰에서 받는 UUID (기존 openmrsUuid 대신)

  // 생성자
  UserModel({
    required this.employeeId,
    required this.name,
    required this.department,
    required this.role,
    this.uuid, // nullable
  });

  // JSON 데이터로부터 UserModel 객체를 생성하는 팩토리 메서드
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      employeeId: json['employee_id'] as String,
      name: json['name'] as String,
      department: json['department'] as String,
      role: json['role'] as String,
      // 'uuid' 필드를 사용하도록 수정
      uuid: json['uuid'] as String?, // 'uuid'는 nullable이므로 null 체크
    );
  }

  // UserModel 객체를 JSON 데이터로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'name': name,
      'department': department,
      'role': role,
      'uuid': uuid, // 'uuid' 필드를 사용하도록 수정
    };
  }

  @override
  String toString() {
    return 'UserModel(employeeId: $employeeId, name: $name, role: $role, uuid: $uuid)'; // toString()도 수정
  }
}
