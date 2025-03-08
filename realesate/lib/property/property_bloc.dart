import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/property_repository.dart';
import 'property_event.dart';
import 'property_state.dart';

class PropertyBloc extends Bloc<PropertyEvent, PropertyState> {
  final PropertyRepository _propertyRepository;

  PropertyBloc(this._propertyRepository) : super(PropertyInitial()) {
    on<LoadProperties>(_onLoadProperties);
    on<AddNewProperty>(_onAddNewProperty);
    on<UpdatePropertyEvent>(_onUpdateProperty);
    on<DeletePropertyEvent>(_onDeleteProperty);
  }

  Future<void> _onLoadProperties(
    LoadProperties event,
    Emitter<PropertyState> emit,
  ) async {
    emit(PropertyLoading());
    try {
      final properties = await _propertyRepository.getProperties();
      emit(PropertyLoaded(properties));
    } catch (e) {
      emit(PropertyError(e.toString()));
    }
  }

  Future<void> _onAddNewProperty(
    AddNewProperty event,
    Emitter<PropertyState> emit,
  ) async {
    emit(PropertyLoading());
    try {
      await _propertyRepository.addProperty(event.property);
      emit(PropertyAdded());
      add(LoadProperties());
    } catch (e) {
      emit(PropertyError(e.toString()));
    }
  }

  Future<void> _onUpdateProperty(
    UpdatePropertyEvent event,
    Emitter<PropertyState> emit,
  ) async {
    emit(PropertyLoading());
    try {
      await _propertyRepository.updateProperty(event.property);
      emit(PropertyUpdated());
      add(LoadProperties());
    } catch (e) {
      emit(PropertyError(e.toString()));
    }
  }

  Future<void> _onDeleteProperty(
    DeletePropertyEvent event,
    Emitter<PropertyState> emit,
  ) async {
    emit(PropertyLoading());
    try {
      await _propertyRepository.deleteProperty(event.propertyId);
      emit(PropertyDeleted());
      add(LoadProperties());
    } catch (e) {
      emit(PropertyError(e.toString()));
    }
  }
} 