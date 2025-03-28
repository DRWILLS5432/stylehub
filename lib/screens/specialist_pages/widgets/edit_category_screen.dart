import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:stylehub/constants/app/app_colors.dart';
import 'package:stylehub/constants/app/textstyle.dart';
import 'package:stylehub/constants/localization/locales.dart';
import 'package:stylehub/screens/specialist_pages/provider/edit_category_provider.dart';

class ServiceSelectionScreen extends StatefulWidget {
  const ServiceSelectionScreen({super.key});

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  @override
  void initState() {
    fetchCategories();
    super.initState();
  }

  void fetchCategories() {
    final provider = Provider.of<EditCategoryProvider>(context, listen: false);
    provider.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategorySection(context),
            const SizedBox(height: 24),
            _buildSelectedCategories(),
            const SizedBox(height: 32),
            _buildServicesSection(context),
            const SizedBox(height: 40),
            _buildAcceptButton(),
          ],
        ),
      ),
    );
  }

  // Widget _buildCategorySection(context) {
  Widget _buildCategorySection(context) {
    return Consumer<EditCategoryProvider>(
      builder: (context, provider, _) {
        if (provider.availableCategories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Row(
              children: [
                SizedBox(
                    width: 320.w,
                    child: Text(
                      LocaleData.serviceCategory.getString(context),
                      style: appTextStyle15(AppColors.mainBlackTextColor).copyWith(fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    )),
              ],
            ),
            const SizedBox(height: 23),
            Row(
              children: [
                SizedBox(
                  width: 320.w,
                  child: Text(
                    LocaleData.pickService.getString(context),
                    style: appTextStyle12500(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 23),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: provider.availableCategories.map((category) {
                    final isSelected = provider.selectedCategories.contains(category.id);
                    return ChoiceChip(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.dg),
                        side: BorderSide(
                          color: AppColors.appBGColor,
                          width: 1,
                        ),
                      ),
                      label: Text(
                        category.name,
                        style: appTextStyle12K(AppColors.mainBlackTextColor),
                      ),
                      selected: isSelected,
                      onSelected: (_) => provider.toggleCategory(
                        category.name,
                      ),
                      backgroundColor: Colors.white,
                      selectedColor: Theme.of(context).primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSelectedCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleData.selectedCategory.getString(context),
          style: appTextStyle15(AppColors.mainBlackTextColor).copyWith(fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        SizedBox(height: 27.h),
        Text(
          LocaleData.selectedService.getString(context),
          style: appTextStyle12K(AppColors.mainBlackTextColor),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        SizedBox(height: 16.h),
        Consumer<EditCategoryProvider>(
          builder: (context, provider, _) {
            if (provider.selectedCategories.isEmpty) return const SizedBox();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  children: provider.selectedCategories.map((category) {
                    return Chip(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.dg),
                        side: BorderSide(
                          color: AppColors.appBGColor,
                          width: 1,
                        ),
                      ),
                      label: Text(
                        category,
                        style: appTextStyle12K(AppColors.mainBlackTextColor),
                      ),
                      backgroundColor: Colors.white,
                      deleteIconColor: Colors.blue.shade800,
                      onDeleted: () => provider.toggleCategory(category),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildServicesSection(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Services & Price Range',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Consumer<EditCategoryProvider>(
          builder: (context, provider, _) {
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.services.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Service name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) => provider.updateService(index, value, provider.services[index].price),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => provider.updateService(index, provider.services[index].name, value),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: Icon(Icons.add_circle, color: Colors.black),
            onPressed: () => Provider.of<EditCategoryProvider>(context, listen: false).addService(),
          ),
        ),
      ],
    );
  }

  Widget _buildAcceptButton() {
    return SizedBox(
      width: double.infinity,
      child: Consumer<EditCategoryProvider>(builder: (context, provider, child) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            if (provider.services.any((s) => s.name.isEmpty || s.price.isEmpty)) {
              // Show error if any service is incomplete
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill all service fields')),
              );
              return;
            }

            provider.submitForm();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ResultsScreen(),
              ),
            );
          },
          child: const Text(
            'Accept',
            style: TextStyle(fontSize: 16),
          ),
        );
      }),
    );
  }
}

// / Updated ResultsScreen
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EditCategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selected Services'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () => provider.clearAll(),
            tooltip: 'Clear All Data',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Submitted Categories
            Text('Submitted Categories:', style: Theme.of(context).textTheme.titleLarge),
            Wrap(
              spacing: 8,
              children: provider.submittedCategories.map((category) => Chip(label: Text(category))).toList(),
            ),

            const SizedBox(height: 24),

            // Submitted Services with Selection
            Text('Submitted Services:', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...provider.submittedServices.asMap().entries.map((entry) {
              final index = entry.key;
              final service = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: CheckboxListTile(
                  title: Text(service.name),
                  subtitle: Text(service.price),
                  value: service.selected,
                  onChanged: (_) => provider.toggleSubmittedServiceSelection(index),
                ),
              );
            }),

            const SizedBox(height: 24),

            // Selected Services Summary
            if (provider.submittedServices.any((s) => s.selected))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Selected Services:', style: Theme.of(context).textTheme.titleMedium),
                  ...provider.submittedServices.where((s) => s.selected).map(
                        (service) => ListTile(
                          title: Text(service.name),
                          trailing: Text(service.price),
                        ),
                      ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
