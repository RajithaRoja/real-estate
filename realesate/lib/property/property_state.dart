import 'package:equatable/equatable.dart';

import '../models/property.dart';

abstract class PropertyState extends Equatable {
  const PropertyState();

  @override
  List<Object?> get props => [];
}

class PropertyInitial extends PropertyState {}

class PropertyLoading extends PropertyState {}

class PropertyLoaded extends PropertyState {
  final List<Property> properties;

  const PropertyLoaded(this.properties);

  @override
  List<Object?> get props => [properties];
}

class PropertyError extends PropertyState {
  final String message;

  const PropertyError(this.message);

  @override
  List<Object?> get props => [message];
}

class PropertyAdded extends PropertyState {}

class PropertyUpdated extends PropertyState {}

class PropertyDeleted extends PropertyState {} 