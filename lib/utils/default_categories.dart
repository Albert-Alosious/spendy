import '../models/category.dart';

final defaultCategories = <Category>[
  Category(id: 'food', name: 'Food & Dining', colorHex: '#F59E0B', icon: 'restaurant', isExpense: true),
  Category(id: 'transport', name: 'Transport', colorHex: '#0EA5E9', icon: 'directions_bus', isExpense: true),
  Category(id: 'groceries', name: 'Groceries', colorHex: '#10B981', icon: 'shopping_basket', isExpense: true),
  Category(id: 'rent', name: 'Rent', colorHex: '#6366F1', icon: 'home', isExpense: true),
  Category(id: 'utilities', name: 'Utilities', colorHex: '#F97316', icon: 'bolt', isExpense: true),
  Category(id: 'entertainment', name: 'Entertainment', colorHex: '#EC4899', icon: 'theaters', isExpense: true),
  Category(id: 'shopping', name: 'Shopping', colorHex: '#E11D48', icon: 'shopping_bag', isExpense: true),
  Category(id: 'health', name: 'Health', colorHex: '#22D3EE', icon: 'health_and_safety', isExpense: true),
  Category(id: 'saving', name: 'Saving', colorHex: '#8B5E3C', icon: 'savings', isExpense: true),
  Category(id: 'income', name: 'Income', colorHex: '#10B981', icon: 'payments', isExpense: false),
];
