/// Future-ready pagination primitives (offset/limit or cursor).
///
/// Repositories can evolve from `Future<List<T>>` to
/// `Future<PaginatedPage<T>>` without changing presentation patterns.
final class PageRequest {
  const PageRequest({
    this.page = 1,
    this.pageSize = 20,
    this.cursor,
  }) : assert(page >= 1),
       assert(pageSize >= 1);

  /// 1-based page index (offset style).
  final int page;
  final int pageSize;

  /// Optional opaque cursor when the backend prefers cursor pagination.
  final String? cursor;

  int get offset => (page - 1) * pageSize;
}

final class PaginatedPage<T> {
  const PaginatedPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.hasMore,
    this.nextCursor,
  });

  final List<T> items;
  final int page;
  final int pageSize;
  final bool hasMore;
  final String? nextCursor;

  /// Wrap a full list as a single non-paginated page (until the API splits).
  factory PaginatedPage.single(List<T> items, {int pageSize = 20}) {
    return PaginatedPage<T>(
      items: items,
      page: 1,
      pageSize: pageSize,
      hasMore: false,
      nextCursor: null,
    );
  }
}
