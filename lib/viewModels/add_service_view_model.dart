// add_service_view_model.dart
import 'package:wefix_shop/data/models/new_service_model.dart';

class AddServiceViewModel {
  NewService service = NewService(
    name: '',
    description: '',
    category: '',
    pricingType: 'Fixed',
    amount: 0.0,
  );

  void setServiceName(String name) => service.name = name;
  void setDescription(String desc) => service.description = desc;
  void setCategory(String cat) => service.category = cat;
  void setPricingType(String type) => service.pricingType = type;
  void setAmount(double amt) => service.amount = amt;

  bool validate() {
    return service.name.isNotEmpty &&
        service.category.isNotEmpty &&
        service.amount > 0;
  }

  // Add your save service logic here if needed
}
