import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/customer_controller.dart';
import '/core/constants/app_colors.dart';
import '/core/constants/app_styles.dart';
import '/core/widgets/common_text_field.dart';

class CustomersScreen extends StatelessWidget {
  CustomersScreen({super.key});

  final CustomerManagementController controller =
      Get.put(CustomerManagementController());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                          color: AppColors.indigoPrimary.withOpacity(0.1)),
                      const SizedBox(height: 24),
                      Text(
                        "No Customers Yet",
                        style: AppStyles.dashboardHeading(context),
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
                          backgroundColor: AppColors.indigoPrimary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.person_add, color: Colors.white),
                        label: Text("Add My First Customer",
                            style: AppStyles.premiumButton(context)),
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
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cardShadow,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                            backgroundColor: AppColors.indigoPrimary.withOpacity(0.1),
                            child:
                                const Icon(Icons.person, color: AppColors.indigoPrimary)),
                        title: Text(customer.name,
                            style: AppStyles.premiumCardTitle(context)),
                        subtitle: Text(customer.phone, style: AppStyles.premiumCardBody(context)),
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
                    heroTag: 'add_customer_fab',
                    backgroundColor: AppColors.indigoPrimary,
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
                          backgroundColor: AppColors.indigoPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      onPressed: controller.saveCustomer,
                      child: Text('Save',
                          style: AppStyles.premiumButton(context)),
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
