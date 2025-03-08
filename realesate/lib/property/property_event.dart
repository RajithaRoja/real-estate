import '../models/property.dart';

abstract class PropertyEvent {
  const PropertyEvent();

  @override
  List<Object?> get props => [];
}

class LoadProperties extends PropertyEvent {}

class AddNewProperty extends PropertyEvent {
  final Property property;

  const AddNewProperty(this.property);

  @override
  List<Object?> get props => [property];
}

class UpdatePropertyEvent extends PropertyEvent {
  final Property property;

  const UpdatePropertyEvent(this.property);

  @override
  List<Object?> get props => [property];
}

class DeletePropertyEvent extends PropertyEvent {
  final String propertyId;

  const DeletePropertyEvent(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
} 