import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/task_provider.dart';
import '../../../theme/app_theme.dart';
import '../../members/add_family_member_screen.dart';

class FamilyTab extends StatefulWidget {
  const FamilyTab({super.key});

  @override
  FamilyTabState createState() => FamilyTabState();
}

class FamilyTabState extends State<FamilyTab> with SingleTickerProviderStateMixin {
  List<User> _familyMembers = [];
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _animationController.forward();
    _loadFamilyMembers();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadFamilyMembers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final members = await authProvider.getFamilyMembers();
      setState(() {
        _familyMembers = members;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading family members: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isParent = authProvider.isParent;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFamilyMembers,
              child: FadeTransition(
                opacity: _fadeInAnimation,
                child: _familyMembers.isEmpty
                    ? _buildEmptyState(isParent)
                    : _buildFamilyMembersList(isParent),
              ),
            ),
      floatingActionButton: isParent
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddFamilyMemberScreen()),
                ).then((_) => _loadFamilyMembers());
              },
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.person_add),
            )
          : null,
    );
  }

  Widget _buildFamilyMembersList(bool isParent) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    final currentFamily = authProvider.currentFamily;

    // Group members by role
    final parents = _familyMembers.where((member) => member.role == UserRole.parent).toList();
    final children = _familyMembers.where((member) => member.role == UserRole.child).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Family info card
        if (currentFamily != null) _buildFamilyInfoCard(currentFamily.name, _familyMembers.length),
        
        const SizedBox(height: 24),
        
        // Parents section
        if (parents.isNotEmpty) ...[  
          Text(
            'Parents',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...parents.map((parent) => _buildMemberCard(
                parent,
                isCurrentUser: currentUser?.id == parent.id,
                isCreator: currentFamily?.createdBy == parent.id,
              )),
          const SizedBox(height: 24),
        ],
        
        // Children section
        if (children.isNotEmpty) ...[  
          Text(
            'Children',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...children.map((child) => _buildMemberCard(
                child,
                isCurrentUser: currentUser?.id == child.id,
              )),
        ],
      ],
    );
  }

  Widget _buildFamilyInfoCard(String familyName, int memberCount) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.family_restroom,
                    size: 32,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        familyName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '$memberCount ${memberCount == 1 ? 'member' : 'members'}',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(User member, {bool isCurrentUser = false, bool isCreator = false}) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: isCurrentUser ? 3 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isCurrentUser
              ? BorderSide(color: AppTheme.primaryColor, width: 2)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar placeholder
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isCurrentUser
                      ? AppTheme.primaryColor
                      : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    member.role == UserRole.parent ? Icons.person : Icons.child_care,
                    color: isCurrentUser ? Colors.white : Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          member.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isCurrentUser
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                        if (isCurrentUser) ...[  
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'YOU',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                        if (isCreator) ...[  
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'ADMIN',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.role == UserRole.parent ? 'Parent' : 'Child',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Future task count - this would need to be implemented to count tasks per user
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    FutureBuilder<List<int>>(
                      // This would be replaced with actual task counts
                      future: Future.value([0, 0]),
                      builder: (context, snapshot) {
                        final total = snapshot.data?[0] ?? 0;
                        final completed = snapshot.data?[1] ?? 0;
                        return Text(
                          '$completed/$total',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isParent) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline,
              size: 64,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Family Members',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              isParent
                  ? 'You haven\'t added any family members yet. Add your family members to get started.'
                  : 'There are no family members in your family yet.',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (isParent) ...[  
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddFamilyMemberScreen()),
                ).then((_) => _loadFamilyMembers());
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Add Family Member'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}