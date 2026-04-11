import 'package:flutter/material.dart';

class PharmacySearchScreen extends StatefulWidget {
  const PharmacySearchScreen({super.key});

  @override
  State<PharmacySearchScreen> createState() => _PharmacySearchScreenState();
}

class _PharmacySearchScreenState extends State<PharmacySearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool _isLocationLoading = false;
  
  // MVP Hardcoded Mock Data structure array
  List<Map<String, dynamic>> _pharmacies = [];

  void _getMockCurrentLocation() async {
    setState(() {
      _isLocationLoading = true;
    });
    
    // Simulate fetching geolocation
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLocationLoading = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location securely updated: 28.61° N, 77.20° E')),
    );
  }

  void _searchPharmacies() async {
    if (_searchController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a medicine name to search')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
      _pharmacies = []; // Clear previous search results before searching
    });
    
    // Simulate HTTP Request delay to /api/v1/pharmacy/search
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isLoading = false;
      _pharmacies = [
        {
          "id": "pharm_001",
          "name": "Apollo Pharmacy",
          "distance_km": 2.3,
          "availability": {
            "status": "in_stock", // Green status
            "confidence": 95,
            "verified_by": "Ram S."
          }
        },
        {
          "id": "pharm_002",
          "name": "MedPlus",
          "distance_km": 3.8,
          "availability": {
            "status": "out_of_stock", // Red status
            "confidence": 80,
            "verified_by": "Priya M."
          }
        },
        {
          "id": "pharm_003",
          "name": "Local Chemist",
          "distance_km": 4.1,
          "availability": {
            "status": "limited_stock", // Yellow status
            "confidence": 65,
            "verified_by": "Guardian Raj"
          }
        }
      ];
    });
  }

  void _openDirections(String pharmacyName) {
    // Stub for url_launcher invoking Google maps/Apple Maps
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening maps route navigation to $pharmacyName...')),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'in_stock') return const Color(0xFF00C853);
    if (status == 'out_of_stock') return Colors.red;
    return Colors.orange; // limited_stock
  }
  
  String _getStatusText(String status) {
    if (status == 'in_stock') return "In Stock";
    if (status == 'out_of_stock') return "Out of Stock";
    return "Limited Stock";
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacy Relay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary, 
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Search Bar & Location Controls Container
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                ]
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for medicine (e.g., Cardivas 25mg)',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF1565C0)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300)
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300)
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    onSubmitted: (_) => _searchPharmacies(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _getMockCurrentLocation,
                          icon: _isLocationLoading 
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.my_location, size: 20),
                          label: const Text('Use Current Location', style: TextStyle(fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1565C0),
                            side: const BorderSide(color: Color(0xFF1565C0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _searchPharmacies,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Search', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // 2. Mock Search Results Body
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00C853)))
                : _pharmacies.isEmpty 
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.storefront_outlined, size: 60, color: Colors.grey),
                          SizedBox(height: 16),
                          Text("Search for a medicine to see local availability", 
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _pharmacies.length,
                      itemBuilder: (context, index) {
                        final pharmacy = _pharmacies[index];
                        final availability = pharmacy['availability'];
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.shade200)
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Pharmacy Name and Distance Tracker
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        pharmacy['name'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(6)
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${pharmacy['distance_km']} km",
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                // Availability Status Dot
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _getStatusColor(availability['status']),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _getStatusText(availability['status']),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _getStatusColor(availability['status']),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      "Verified by: ${availability['verified_by']}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontStyle: FontStyle.italic
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                // Routing Navigation Button Hook
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _openDirections(pharmacy['name']),
                                    icon: const Icon(Icons.directions, size: 20),
                                    label: const Text('Get Directions', style: TextStyle(fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF1565C0),
                                      side: BorderSide(color: Colors.grey.shade300),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
            )
          ],
        ),
      ),
    );
  }
}
