import 'package:flutter/foundation.dart';

class StaffNotificationSettingsProvider extends ChangeNotifier {
  bool _newOrderAlertsEnabled = true;
  bool _lowStockAlertsEnabled = true;
  bool _criticalStockAlertsEnabled = true;

  bool get newOrderAlertsEnabled => _newOrderAlertsEnabled;
  bool get lowStockAlertsEnabled => _lowStockAlertsEnabled;
  bool get criticalStockAlertsEnabled => _criticalStockAlertsEnabled;

  void setNewOrderAlertsEnabled(bool value) {
    _update(_newOrderAlertsEnabled, value, () {
      _newOrderAlertsEnabled = value;
    });
  }

  void setLowStockAlertsEnabled(bool value) {
    _update(_lowStockAlertsEnabled, value, () {
      _lowStockAlertsEnabled = value;
    });
  }

  void setCriticalStockAlertsEnabled(bool value) {
    _update(_criticalStockAlertsEnabled, value, () {
      _criticalStockAlertsEnabled = value;
    });
  }

  void _update(bool currentValue, bool nextValue, VoidCallback update) {
    if (currentValue == nextValue) {
      return;
    }

    update();
    notifyListeners();
  }
}
