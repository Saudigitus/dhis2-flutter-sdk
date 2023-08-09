import 'package:d2_touch/core/annotations/index.dart';
import 'package:d2_touch/shared/entities/identifiable.entity.dart';

import 'user.entity.dart';

@AnnotationReflectable
@Entity(
    tableName: 'userOrganisationUnit', apiResourceName: 'userOrganisationUnits')
class UserOrganisationUnit extends IdentifiableEntity {
  @Column()
  final String orgUnit;

  @Column(nullable: true)
  final String? parent;

  @Column()
  final String type;

  @ManyToOne(joinColumnName: 'user', table: User)
  dynamic user;

  UserOrganisationUnit(
      {required String id,
      required String name,
      required this.orgUnit,
      this.parent,
      required this.user,
      required this.type,
      required bool dirty})
      : super(id: id, name: name, dirty: dirty);

  factory UserOrganisationUnit.fromJson(Map<String, dynamic> json) {
    final parent = json['parent'].runtimeType is String
        ? json['parent']
        : json['parente']?['id'];

    return UserOrganisationUnit(
        id: json['id'],
        name: json['id'],
        orgUnit: json['orgUnit'],
        parent: parent,
        user: json['user'],
        type: json['type'],
        dirty: json['dirty'].runtimeType == "String"
            ? json["dirty"] == "true"
                ? true
                : false
            : json['dirty']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['orgUnit'] = this.orgUnit;
    data['parent'] = this.parent;
    data['type'] = this.type;
    data['user'] = this.user;
    data['dirty'] = this.dirty;
    return data;
  }
}
