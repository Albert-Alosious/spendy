import 'package:flutter/material.dart';

class AppDropdownItem<T> {
  final T? value;
  final String text;

  const AppDropdownItem({required this.value, required this.text});
}

class AppDropdown<T> extends StatelessWidget {
  final T? value;
  final List<AppDropdownItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final String? labelText;

  const AppDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedItem = items.firstWhere(
      (item) => item.value == value,
      orElse: () => AppDropdownItem(value: null, text: hint ?? 'Select'),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
        ],
        InkWell(
          onTap: () => _showSelectionSheet(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: theme.inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.inputDecorationTheme.border?.borderSide.color ?? Colors.grey,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value != null ? selectedItem.text : (hint ?? 'Select'),
                  style: value != null
                      ? theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.titleMedium?.color)
                      : theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: theme.iconTheme.color?.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              if (labelText != null || hint != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    labelText ?? hint!,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item.value == value;
                    return ListTile(
                      title: Text(
                        item.text,
                        style: isSelected
                            ? const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)
                            : null,
                      ),
                      trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
                      onTap: () {
                        onChanged(item.value);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
