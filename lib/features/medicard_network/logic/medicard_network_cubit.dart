import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mediconsult/core/constants/api_result.dart';
import 'package:mediconsult/features/network/data/city_response_model.dart';
import 'package:mediconsult/features/network/data/government_response_model.dart';
import 'package:mediconsult/features/network/data/network_category_response_model.dart';
import 'package:mediconsult/features/network/data/network_provider_response_model.dart';
import 'package:mediconsult/features/medicard_network/repository/medicard_network_repository.dart';

abstract class MedicardNetworkState {}

class MedicardNetworkInitial extends MedicardNetworkState {}

class MedicardNetworkLoading extends MedicardNetworkState {}

class MedicardNetworkLoaded extends MedicardNetworkState {
  final List<NetworkCategory> categories;
  final List<NetworkProvider> providers;
  final List<Government> governments;
  final List<City> cities;
  final int? selectedCategoryId;
  final int? selectedGovernmentId;
  final int? selectedCityId;
  final String? searchKey;
  final bool hasMore;

  MedicardNetworkLoaded({
    required this.categories,
    required this.providers,
    required this.governments,
    required this.cities,
    this.selectedCategoryId,
    this.selectedGovernmentId,
    this.selectedCityId,
    this.searchKey,
    this.hasMore = false,
  });

  MedicardNetworkLoaded copyWith({
    List<NetworkCategory>? categories,
    List<NetworkProvider>? providers,
    List<Government>? governments,
    List<City>? cities,
    int? selectedCategoryId,
    bool resetCategory = false,
    int? selectedGovernmentId,
    bool resetGovernment = false,
    int? selectedCityId,
    bool resetCity = false,
    String? searchKey,
    bool resetSearch = false,
    bool? hasMore,
  }) {
    return MedicardNetworkLoaded(
      categories: categories ?? this.categories,
      providers: providers ?? this.providers,
      governments: governments ?? this.governments,
      cities: cities ?? this.cities,
      selectedCategoryId: resetCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      selectedGovernmentId: resetGovernment ? null : (selectedGovernmentId ?? this.selectedGovernmentId),
      selectedCityId: resetCity ? null : (selectedCityId ?? this.selectedCityId),
      searchKey: resetSearch ? null : (searchKey ?? this.searchKey),
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class MedicardNetworkError extends MedicardNetworkState {
  final String message;

  MedicardNetworkError(this.message);
}

class MedicardNetworkCubit extends Cubit<MedicardNetworkState> {
  final MedicardNetworkRepository _repository;
  int _currentPage = 1;
  static const int _pageSize = 20;

  MedicardNetworkCubit(this._repository) : super(MedicardNetworkInitial());

  Future<void> loadInitialData(String lang) async {
    emit(MedicardNetworkLoading());

    List<NetworkCategory> categories = [];
    List<Government> governments = [];

    final categoriesResult = await _repository.getCategories(lang);
    final governmentsResult = await _repository.getGovernments(lang);

    categoriesResult.when(
      success: (response) {
        categories = response.data.categories;
      },
      failure: (_) {},
    );

    governmentsResult.when(
      success: (response) {
        governments = response.data.governments;
      },
      failure: (_) {},
    );

    // First emit state with categories and governments
    emit(MedicardNetworkLoaded(
      categories: categories,
      providers: [],
      governments: governments,
      cities: [],
    ));

    // Then search providers
    _searchProviders(lang);
  }

  Future<void> _searchProviders(String lang) async {
    final currentState = state;
    int? categoryId;
    int? governmentId;
    int? cityId;
    String? searchKey;

    if (currentState is MedicardNetworkLoaded) {
      categoryId = currentState.selectedCategoryId;
      governmentId = currentState.selectedGovernmentId;
      cityId = currentState.selectedCityId;
      searchKey = currentState.searchKey;
    }

    final result = await _repository.searchProviders(
      lang: lang,
      searchKey: searchKey,
      categoryId: categoryId,
      governmentId: governmentId,
      cityId: cityId,
      page: _currentPage,
      pageSize: _pageSize,
    );

    result.when(
      success: (response) {
        final currentState = state;
        List<NetworkProvider> allProviders = [];
        bool hasMore = false;

        if (response.data != null) {
          if (currentState is MedicardNetworkLoaded && _currentPage > 1) {
            allProviders = [...currentState.providers, ...response.data!.providers];
          } else {
            allProviders = response.data!.providers;
          }
          hasMore = response.data!.pagination.hasNextPage;
        }

        emit(MedicardNetworkLoaded(
          categories: currentState is MedicardNetworkLoaded ? currentState.categories : [],
          providers: allProviders,
          governments: currentState is MedicardNetworkLoaded ? currentState.governments : [],
          cities: currentState is MedicardNetworkLoaded ? currentState.cities : [],
          selectedCategoryId: categoryId,
          selectedGovernmentId: governmentId,
          selectedCityId: cityId,
          searchKey: searchKey,
          hasMore: hasMore,
        ));
      },
      failure: (message) {
        emit(MedicardNetworkError(message));
      },
    );
  }

  void selectCategory(int? categoryId, String lang) {
    final currentState = state;
    if (currentState is MedicardNetworkLoaded) {
      _currentPage = 1;
      emit(currentState.copyWith(
        selectedCategoryId: categoryId,
        resetGovernment: true,
        resetCity: true,
        cities: [],
      ));
      _searchProviders(lang);
    }
  }

  Future<void> selectGovernment(int? governmentId, String lang) async {
    final currentState = state;
    if (currentState is MedicardNetworkLoaded) {
      _currentPage = 1;

      List<City> cities = [];
      if (governmentId != null) {
        final citiesResult = await _repository.getCitiesByGovernment(lang, governmentId);
        citiesResult.when(
          success: (response) => cities = response.data?.cities ?? [],
          failure: (_) {},
        );
      }

      emit(currentState.copyWith(
        selectedGovernmentId: governmentId,
        resetGovernment: governmentId == null,
        resetCity: true,
        cities: cities,
      ));
      _searchProviders(lang);
    }
  }

  void selectCity(int? cityId, String lang) {
    final currentState = state;
    if (currentState is MedicardNetworkLoaded) {
      _currentPage = 1;
      emit(currentState.copyWith(
        selectedCityId: cityId,
        resetCity: cityId == null,
      ));
      _searchProviders(lang);
    }
  }

  void search(String? searchKey, String lang) {
    final currentState = state;
    if (currentState is MedicardNetworkLoaded) {
      _currentPage = 1;
      emit(currentState.copyWith(searchKey: searchKey));
      _searchProviders(lang);
    }
  }

  void loadMore(String lang) {
    final currentState = state;
    if (currentState is MedicardNetworkLoaded && currentState.hasMore) {
      _currentPage++;
      _searchProviders(lang);
    }
  }

  void clearFilters(String lang) {
    final currentState = state;
    if (currentState is MedicardNetworkLoaded) {
      _currentPage = 1;
      emit(MedicardNetworkLoaded(
        categories: currentState.categories,
        providers: currentState.providers,
        governments: currentState.governments,
        cities: [],
        hasMore: false,
      ));
      _searchProviders(lang);
    }
  }
}
