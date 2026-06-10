import 'package:flutter/material.dart';

class SearchablePickerField<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T? selectedItem;
  final List<T> items;
  final String hint;
  final String Function(T item) titleBuilder;
  final String Function(T item)? subtitleBuilder;
  final String Function(T item) searchTextBuilder;
  final ValueChanged<T> onSelected;

  const SearchablePickerField({
    super.key,
    required this.label,
    required this.icon,
    required this.selectedItem,
    required this.items,
    required this.hint,
    required this.titleBuilder,
    required this.searchTextBuilder,
    required this.onSelected,
    this.subtitleBuilder,
  });

  void _openPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _SearchablePickerSheet<T>(
          label: label,
          items: items,
          titleBuilder: titleBuilder,
          subtitleBuilder: subtitleBuilder,
          searchTextBuilder: searchTextBuilder,
          onSelected: (item) {
            Navigator.pop(context);
            onSelected(item);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSelected = selectedItem != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF253B56),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _openPicker(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 62,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EBEF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF7B8794), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: hasSelected
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        titleBuilder(selectedItem as T),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF0B2E59),
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                      if (subtitleBuilder != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitleBuilder!(selectedItem as T),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF667085),
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  )
                      : Text(
                    hint,
                    style: const TextStyle(
                      color: Color(0xFF667085),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF667085),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchablePickerSheet<T> extends StatefulWidget {
  final String label;
  final List<T> items;
  final String Function(T item) titleBuilder;
  final String Function(T item)? subtitleBuilder;
  final String Function(T item) searchTextBuilder;
  final ValueChanged<T> onSelected;

  const _SearchablePickerSheet({
    required this.label,
    required this.items,
    required this.titleBuilder,
    required this.searchTextBuilder,
    required this.onSelected,
    this.subtitleBuilder,
  });

  @override
  State<_SearchablePickerSheet<T>> createState() =>
      _SearchablePickerSheetState<T>();
}

class _SearchablePickerSheetState<T> extends State<_SearchablePickerSheet<T>> {
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<T> get filteredItems {
    final query = searchController.text.trim().toLowerCase();

    if (query.isEmpty) return widget.items;

    return widget.items.where((item) {
      return widget.searchTextBuilder(item).toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = filteredItems;

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 18,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F7FA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6EEF8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Color(0xFF0B2E59),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Select ${widget.label}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0B2E59),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6EEF8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.items.length}',
                      style: const TextStyle(
                        color: Color(0xFF0B2E59),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFE8EBEF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                '${results.length} result(s)',
                style: const TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: results.isEmpty
                    ? const Center(
                  child: Text(
                    'No results found',
                    style: TextStyle(
                      color: Color(0xFF667085),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
                    : ListView.separated(
                  controller: scrollController,
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = results[index];

                    return InkWell(
                      onTap: () => widget.onSelected(item),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE9EEF5),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.titleBuilder(item),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF0B2E59),
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                            if (widget.subtitleBuilder != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.subtitleBuilder!(item),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF667085),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}