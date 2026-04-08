import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/customer_controller.dart';
import '/core/constants/app_colors.dart';
import '/core/widgets/common_text_field.dart';

import 'package:p_v_j/features/vendor/dashboard/presentation/widgets/setup_progress_widget.dart';

class CustomersScreen extends StatelessWidget {
  CustomersScreen({super.key});

  final CustomerManagementController controller =
      Get.put(CustomerManagementController());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SetupProgressWidget(),
        Expanded(
          child: Obx(() {
            if (controller.customers.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline,
                          size: 80,
                          color: AppColors.primary.withValues(alpha: 0.2)),
                      const SizedBox(height: 24),
                      const Text(
                        "No Customers Yet",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Once you've added products, add the people you'll be delivering to.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => _showCustomerDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.person_add, color: Colors.white),
                        label: const Text("Add My First Customer",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Stack(
              children: [
                ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.customers.length,
                  itemBuilder: (context, index) {
                    final customer = controller.customers[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                            backgroundColor: AppColors.primaryLight,
                            child:
                                Icon(Icons.person, color: AppColors.primary)),
                        title: Text(customer.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(customer.phone),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.error),
                          onPressed: () =>
                              controller.deleteCustomer(customer.id),
                        ),
                        onTap: () => _showCustomerDialog(context, customer),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    backgroundColor: AppColors.primary,
                    onPressed: () => _showCustomerDialog(context),
                    child: const Icon(Icons.person_add, color: Colors.white),
                  ),
                )
              ],
            );
          }),
        ),
      ],
    );
  }

  void _showCustomerDialog(BuildContext context, [customer]) {
    controller.openForm(customer);
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24),
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer == null ? 'Add Customer' : 'Edit Customer',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  CommonTextField(
                    controller: controller.nameController,
                    hint: 'Full Name',
                    icon: Icons.person_outline,
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  CommonTextField(
                    controller: controller.phoneController,
                    hint: 'Phone Number',
                    icon: Icons.phone_outlined,
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  CommonTextField(
                    controller: controller.addressController,
                    hint: 'Address',
                    icon: Icons.location_on_outlined,
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  CommonTextField(
                    controller: controller.emailController,
                    hint: 'Email Address (for login access)',
                    icon: Icons.email_outlined,
                    validator: (val) {
                      if (val != null &&
                          val.isNotEmpty &&
                          !GetUtils.isEmail(val)) {
                        return 'Invalid Email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      onPressed: controller.saveCustomer,
                      child: const Text('Save',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        });
  }
}
