import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../data/models/client_model.dart';

class ClientsController extends GetxController {
  final clientBox = Hive.box<ClientModel>('clients');

  // Observables
  final searchQuery = ''.obs;
  final sortBy = 'Name'.obs;
  final sortAscending = true.obs;
  final showAdvancedFilters = false.obs;
  final selectedCity = 'All'.obs;
  final selectedState = 'All'.obs;

  // Controllers
  final searchController = TextEditingController();

  // Options
  final sortOptions = ['Name', 'Email', 'Phone', 'City', 'State'].obs;

  // Computed filtered clients
  RxList<ClientModel> get filteredClients {
    final allClients = clientBox.values.toList().cast<ClientModel>();
    return _filterAndSortClients(allClients).obs;
  }

  List<String> get cityOptions {
    final cities = clientBox.values
        .map((client) => client.city.trim())
        .where((city) => city.isNotEmpty)
        .toSet()
        .toList();
    cities.sort();
    return ['All', ...cities];
  }

  List<String> get stateOptions {
    final states = clientBox.values
        .map((client) => client.state.trim())
        .where((state) => state.isNotEmpty)
        .toSet()
        .toList();
    states.sort();
    return ['All', ...states];
  }

  // Stats
  int get totalClients => clientBox.length;
  int get filteredCount => filteredClients.length;

  Map<String, int> get clientsByCity {
    final allClients = clientBox.values.toList().cast<ClientModel>();
    final cityCount = <String, int>{};

    for (final city in cityOptions) {
      if (city == 'All') continue;
      cityCount[city] = allClients.where((c) => c.city == city).length;
    }

    return cityCount;
  }

  Map<String, int> get clientsByState {
    final allClients = clientBox.values.toList().cast<ClientModel>();
    final stateCount = <String, int>{};

    for (final state in stateOptions) {
      if (state == 'All') continue;
      stateCount[state] = allClients.where((c) => c.state == state).length;
    }

    return stateCount;
  }

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text.toLowerCase();
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  List<ClientModel> _filterAndSortClients(List<ClientModel> clients) {
    List<ClientModel> filtered = clients.where((client) {
      final query = searchQuery.value;

      bool matchesSearch = query.isEmpty ||
          client.name.toLowerCase().contains(query) ||
          client.email.toLowerCase().contains(query) ||
          client.contactNumber.toLowerCase().contains(query) ||
          client.city.toLowerCase().contains(query) ||
          client.state.toLowerCase().contains(query);

      bool matchesCity = selectedCity.value == 'All' || client.city == selectedCity.value;
      bool matchesState = selectedState.value == 'All' || client.state == selectedState.value;

      return matchesSearch && matchesCity && matchesState;
    }).toList();

    filtered.sort((a, b) {
      int comparison = 0;
      switch (sortBy.value) {
        case 'Name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'Email':
          comparison = a.email.compareTo(b.email);
          break;
        case 'Phone':
          comparison = a.contactNumber.compareTo(b.contactNumber);
          break;
        case 'City':
          comparison = a.city.compareTo(b.city);
          break;
        case 'State':
          comparison = a.state.compareTo(b.state);
          break;
      }
      return sortAscending.value ? comparison : -comparison;
    });

    return filtered;
  }

  // Actions
  void updateSearchQuery(String query) {
    searchQuery.value = query.toLowerCase();
  }

  void updateCityFilter(String city) {
    selectedCity.value = city;
  }

  void updateStateFilter(String state) {
    selectedState.value = state;
  }

  void updateSortBy(String sort) {
    if (sortBy.value == sort) {
      sortAscending.value = !sortAscending.value;
    } else {
      sortBy.value = sort;
      sortAscending.value = true;
    }
  }

  void toggleAdvancedFilters() {
    showAdvancedFilters.value = !showAdvancedFilters.value;
  }

  void clearFilters() {
    searchController.clear();
    searchQuery.value = '';
    selectedCity.value = 'All';
    selectedState.value = 'All';
    sortBy.value = 'Name';
    sortAscending.value = true;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  List<ClientModel> getClientsByCity(String city) {
    return clientBox.values
        .where((c) => c.city == city)
        .toList()
        .cast<ClientModel>();
  }

  List<ClientModel> getClientsByState(String state) {
    return clientBox.values
        .where((c) => c.state == state)
        .toList()
        .cast<ClientModel>();
  }

  List<ClientModel> getRecentClients() {
    final allClients = clientBox.values.toList().cast<ClientModel>();
    allClients.sort((a, b) => b.key.compareTo(a.key));
    return allClients.take(10).toList();
  }

  List<String> getSearchSuggestions(String query) {
    if (query.isEmpty) return [];

    final suggestions = <String>{};
    final lowerQuery = query.toLowerCase();

    for (final client in clientBox.values) {
      if (client.name.toLowerCase().contains(lowerQuery)) {
        suggestions.add(client.name);
      }
      if (client.email.toLowerCase().contains(lowerQuery)) {
        suggestions.add(client.email);
      }
    }

    return suggestions.take(5).toList();
  }

  Future<void> deleteClient(ClientModel client) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Client'),
        content: Text('Are you sure you want to delete ${client.name}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await client.delete();
      Get.snackbar(
        'Deleted',
        'Client removed successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String exportClientsToCSV() {
    final clients = filteredClients;
    final csv = StringBuffer();

    csv.writeln('Name,Email,Phone,City,State');

    for (final client in clients) {
      csv.writeln(
        '${client.name},${client.email},${client.contactNumber},'
        '${client.city},${client.state}'
      );
    }

    return csv.toString();
  }
}
