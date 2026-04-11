import 'package:flutter/material.dart';

class FamilyDashboardScreen extends StatefulWidget {
  const FamilyDashboardScreen({super.key});

  @override
  State<FamilyDashboardScreen> createState() => _FamilyDashboardScreenState();
}

class _FamilyDashboardScreenState extends State<FamilyDashboardScreen> {
  // Mock Data for MVP 
  final List<Map<String, dynamic>> _familyMembers = [
    {
      "id": "fam_001",
      "name": "Dad",
      "relation": "Parent",
      "status": "safe",
      "medications_taken": 2,
      "medications_total": 3,
      "location": "Home",
      "safety_status": "Safe",
      "avatar_url": null,
      "status_color": const Color(0xFF00C853), // Green for safe
    },
    {
      "id": "fam_002",
      "name": "Mom",
      "relation": "Parent",
      "status": "warning",
      "medications_taken": 1,
      "medications_total": 4,
      "location": "Apollo Clinic",
      "safety_status": "Action Required",
      "avatar_url": null,
      "status_color": Colors.orange, // Orange/warning status
    }
  ];

  void _addFamilyMember() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening "Add Family Member" dialogue...')),
    );
  }

  void _callMember(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Initiating direct call to $name...')),
    );
  }

  void _trackMember(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening live location tracking map for $name...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('My Family', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: _addFamilyMember,
            tooltip: 'Add Family Member',
          )
        ],
      ),
      body: SafeArea(
        child: _familyMembers.isEmpty
          ? const Center(
              child: Text(
                "No family members added yet.", 
                style: TextStyle(color: Colors.grey, fontSize: 16)
              )
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _familyMembers.length,
              itemBuilder: (context, index) {
                final member = _familyMembers[index];
                final bool isSafe = member['status'] == 'safe';
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200, width: 1.5),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Profile Header ---
                        Row(
                          children: [
                            // Dynamic Avatar with online/warning Status Indicator
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  child: Text(
                                    member['name'].substring(0, 1),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 2,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: member['status_color'],
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            // Name & Relation
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member['name'],
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    member['relation'],
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Divider(height: 1),
                        ),
                        
                        // --- Metric Details ---
                        Row(
                          children: [
                            const Icon(Icons.medication_liquid_rounded, size: 22, color: Colors.indigo),
                            const SizedBox(width: 12),
                            Text("Medications:", style: TextStyle(color: Colors.grey.shade700, fontSize: 15)),
                            const Spacer(),
                            Text(
                              "${member['medications_taken']}/${member['medications_total']} taken today",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 22, color: Colors.redAccent),
                            const SizedBox(width: 12),
                            Text("Location:", style: TextStyle(color: Colors.grey.shade700, fontSize: 15)),
                            const Spacer(),
                            Text(
                              member['location'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              isSafe ? Icons.gpp_good : Icons.warning_rounded, 
                              size: 22, 
                              color: isSafe ? const Color(0xFF00C853) : Colors.orange
                            ),
                            const SizedBox(width: 12),
                            Text("Safety Status:", style: TextStyle(color: Colors.grey.shade700, fontSize: 15)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSafe ? const Color(0xFF00C853).withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8)
                              ),
                              child: Text(
                                member['safety_status'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isSafe ? const Color(0xFF00C853) : Colors.orange.shade800,
                                ),
                              ),
                            )
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // --- Action Buttons ---
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _callMember(member['name']),
                                icon: const Icon(Icons.phone, size: 18),
                                label: const Text('Call', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1565C0),
                                  side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _trackMember(member['name']),
                                icon: const Icon(Icons.my_location, size: 18, color: Colors.white),
                                label: const Text('Track', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1565C0),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}
