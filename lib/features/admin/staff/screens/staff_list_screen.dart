import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/staff_provider.dart';
import '../widgets/staff_tile.dart';
import 'create_staff_screen.dart';
import 'edit_staff_screen.dart';

class StaffListScreen extends StatelessWidget {
  const StaffListScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Staff Management',
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateStaffScreen(),
            ),
          );
        },
        child: const Icon(
          Icons.person_add_outlined,
        ),
      ),

      body: Consumer<StaffProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          if (provider.isLoading && provider.staff.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final totalStaff = provider.staff.length;
          final activeStaff = provider.staff.where((staff) => staff.isActive).length;
          final inactiveStaff = totalStaff - activeStaff;
          final managers = provider.staff.where((staff) => staff.role == 'Manager').length;

          if (provider.staff.isEmpty) {
            return const Center(
              child: Text(
                'No staff found.',
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.0,
                  children: [
                    _StaffStatCard(
                      title: 'Total Staff',
                      value: totalStaff.toString(),
                      icon: Icons.people_outline,
                    ),

                    _StaffStatCard(
                      title: 'Active',
                      value: activeStaff.toString(),
                      icon: Icons.check_circle_outline,
                    ),

                    _StaffStatCard(
                      title: 'Inactive',
                      value: inactiveStaff.toString(),
                      icon: Icons.person_off_outlined,
                    ),

                    _StaffStatCard(
                      title: 'Managers',
                      value: managers.toString(),
                      icon: Icons.manage_accounts_outlined,
                    ),
                  ],
                ),
              ),

              const Divider(
                height: 1,
              ),

              Expanded(
                child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: provider.staff.length,
                    itemBuilder: (context, index) {
                      final staff = provider.staff[index];

                      return StaffTile(
                        staff: staff,

                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditStaffScreen(
                                staff: staff,
                              ),
                            ),
                          );
                        },

                        onToggleStatus: () {
                          provider.toggleStaffStatus(staff.uid);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                staff.isActive
                                    ? '${staff.name} deactivated'
                                    : '${staff.name} activated',
                              ),
                            ),
                          );
                        },

                        onDelete: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) {
                              return AlertDialog(
                                title: const Text(
                                  'Delete Staff?',
                                ),

                                content: Text(
                                  'Are you sure you want to delete ${staff.name}? '
                                  'This action cannot be undone.',
                                ),

                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                        dialogContext,
                                        false,
                                      );
                                    },

                                    child: const Text(
                                      'Cancel',
                                    ),
                                  ),

                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(
                                        dialogContext,
                                        true,
                                      );
                                    },

                                    child: const Text(
                                      'Delete',
                                    ),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmed != true) {
                            return;
                          }

                          await provider.deleteStaff(staff.uid);

                          if (!context.mounted) {
                            return;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${staff.name} deleted'),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StaffStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StaffStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            blurRadius: 6,
            color: Colors.black12,
          ),
        ],
      ),

      child: Row(
        children: [
          Icon(
            icon,
            size: 26,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
