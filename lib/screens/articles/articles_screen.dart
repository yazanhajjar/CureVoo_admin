import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/articles/articles_cubit.dart';
import '../../cubits/articles/articles_state.dart';
import '../../models/articles/article_requests.dart';
import '../../models/articles/article_source.dart';
import '../../models/articles/knowledge_article.dart';
import '../../widgets/admin_style.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  String? _selectedCategory;
  String? _selectedLanguage;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArticlesCubit, ArticlesState>(
      listener: (context, state) {
        if (state.status == ArticlesStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        final cubit = context.read<ArticlesCubit>();
        final items = state.articles;
        final cs = Theme.of(context).colorScheme;

        return AdminPageScaffold(
          child: ListView(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [cs.primary, cs.secondary.withValues(alpha: 0.85)],
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.article_outlined, color: Colors.white, size: 30),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Knowledge Articles',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _openArticleDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('New Article'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: cs.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TopMetricCard(
                      icon: Icons.library_books_outlined,
                      label: 'Total Articles',
                      value: '${items.length}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TopMetricCard(
                      icon: Icons.translate_outlined,
                      label: 'Language Filter',
                      value: _selectedLanguage?.toUpperCase() ?? 'ALL',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TopMetricCard(
                      icon: Icons.category_outlined,
                      label: 'Category Filter',
                      value: _selectedCategory ?? 'all',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AdminSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const AdminSectionTitle('Articles List'),
                          OutlinedButton.icon(
                            onPressed: state.status == ArticlesStatus.loading
                                ? null
                                : () => cubit.loadArticles(
                                      category: _selectedCategory,
                                      language: _selectedLanguage,
                                    ),
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withValues(alpha: 0.32),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final wide = constraints.maxWidth > 760;
                            return Flex(
                              direction: wide ? Axis.horizontal : Axis.vertical,
                              crossAxisAlignment: wide ? CrossAxisAlignment.end : CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  width: wide ? 220 : null,
                                  child: DropdownButtonFormField<String?>(
                                    isExpanded: true,
                                    value: _selectedCategory,
                                    decoration: const InputDecoration(labelText: 'Category'),
                                    items: const [
                                      DropdownMenuItem<String?>(value: null, child: Text('All')),
                                      DropdownMenuItem<String?>(value: 'cancer', child: Text('cancer')),
                                      DropdownMenuItem<String?>(value: 'wellbeing', child: Text('wellbeing')),
                                      DropdownMenuItem<String?>(value: 'curevoo', child: Text('curevoo')),
                                    ],
                                    onChanged: (value) => setState(() => _selectedCategory = value),
                                  ),
                                ),
                                SizedBox(width: wide ? 10 : 0, height: wide ? 0 : 10),
                                SizedBox(
                                  width: wide ? 190 : null,
                                  child: DropdownButtonFormField<String?>(
                                    isExpanded: true,
                                    value: _selectedLanguage,
                                    decoration: const InputDecoration(labelText: 'Language'),
                                    items: const [
                                      DropdownMenuItem<String?>(value: null, child: Text('All')),
                                      DropdownMenuItem<String?>(value: 'en', child: Text('en')),
                                      DropdownMenuItem<String?>(value: 'ar', child: Text('ar')),
                                    ],
                                    onChanged: (value) => setState(() => _selectedLanguage = value),
                                  ),
                                ),
                                SizedBox(width: wide ? 10 : 0, height: wide ? 0 : 10),
                                FilledButton.icon(
                                  onPressed: state.status == ArticlesStatus.loading
                                      ? null
                                      : () => cubit.loadArticles(
                                            category: _selectedCategory,
                                            language: _selectedLanguage,
                                          ),
                                  icon: const Icon(Icons.search, size: 16),
                                  label: const Text('Apply Filters'),
                                ),
                                const SizedBox(width: 8, height: 8),
                                OutlinedButton(
                                  onPressed: state.status == ArticlesStatus.loading
                                      ? null
                                      : () {
                                          setState(() {
                                            _selectedCategory = null;
                                            _selectedLanguage = null;
                                          });
                                          cubit.loadArticles();
                                        },
                                  child: const Text('Reset'),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: cs.surfaceContainerHighest.withValues(alpha: 0.2),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: cs.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tap Edit to update article details, or Delete to remove an article permanently.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    if (state.status == ArticlesStatus.loading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(child: Text('No articles available.')),
                      )
                    else
                      ListView.separated(
                        itemCount: items.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final article = items[index];
                          return _ArticleCard(
                            article: article,
                            onEdit: () => _openArticleDialog(context, article: article),
                            onDelete: () => _confirmDelete(context, article),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openArticleDialog(BuildContext context, {KnowledgeArticle? article}) async {
    final cubit = context.read<ArticlesCubit>();
    final result = await showDialog<_ArticleFormValue>(
      context: context,
      builder: (_) => _ArticleFormDialog(article: article),
    );

    if (result == null || !context.mounted) return;

    if (article == null) {
      await cubit.createArticle(
        CreateArticleRequest(
          title: result.title,
          category: result.category,
          summary: result.summary,
          content: result.content,
          slug: result.slug,
          sources: result.sources,
          language: result.language,
          readingTimeMinutes: result.readingTimeMinutes,
          isPublished: true,
        ),
      );
    } else {
      await cubit.updateArticle(
        article.id,
        UpdateArticleRequest(
          title: result.title,
          category: result.category,
          summary: result.summary,
          content: result.content,
          slug: result.slug,
          sources: result.sources,
          language: result.language,
          readingTimeMinutes: result.readingTimeMinutes,
        ),
      );
      if (!context.mounted) return;
      await cubit.loadArticles(
        category: _selectedCategory,
        language: _selectedLanguage,
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, KnowledgeArticle article) async {
    final cubit = context.read<ArticlesCubit>();
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete article'),
        content: Text('Delete "${article.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      await cubit.deleteArticle(article.id);
    }
  }

}

class _TopMetricCard extends StatelessWidget {
  const _TopMetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: cs.surface,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: cs.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({
    required this.article,
    required this.onEdit,
    required this.onDelete,
  });

  final KnowledgeArticle article;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  article.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  article.category,
                  style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            article.summary,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(icon: Icons.translate_rounded, label: article.language.toUpperCase()),
              if (article.sources.isNotEmpty) _MetaChip(icon: Icons.link, label: '${article.sources.length} source(s)'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton.tonalIcon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Delete'),
                style: OutlinedButton.styleFrom(foregroundColor: cs.error),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _ArticleFormDialog extends StatefulWidget {
  const _ArticleFormDialog({this.article});

  final KnowledgeArticle? article;

  @override
  State<_ArticleFormDialog> createState() => _ArticleFormDialogState();
}

class _ArticleFormDialogState extends State<_ArticleFormDialog> {
  static const _allowedCategories = <String>['cancer', 'wellbeing', 'curevoo'];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _summary;
  late final TextEditingController _content;
  late final TextEditingController _slug;
  late final TextEditingController _sourceTitle;
  late final TextEditingController _sourceUrl;
  late final TextEditingController _language;
  late final TextEditingController _readingTimeMinutes;
  late String _category;

  @override
  void initState() {
    super.initState();
    final article = widget.article;
    final firstSource = (article != null && article.sources.isNotEmpty) ? article.sources.first : null;

    _title = TextEditingController(text: article?.title ?? '');
    _summary = TextEditingController(text: article?.summary ?? '');
    _content = TextEditingController(text: article?.content ?? '');
    _slug = TextEditingController();
    _sourceTitle = TextEditingController(text: firstSource?.title ?? '');
    _sourceUrl = TextEditingController(text: firstSource?.url ?? '');
    _language = TextEditingController(text: article?.language ?? 'en');
    _readingTimeMinutes = TextEditingController();
    _category = _allowedCategories.contains(article?.category) ? article!.category : 'cancer';

    _title.addListener(_onFormChanged);
    _summary.addListener(_onFormChanged);
    _content.addListener(_onFormChanged);
    _slug.addListener(_onFormChanged);
    _sourceTitle.addListener(_onFormChanged);
    _sourceUrl.addListener(_onFormChanged);
    _language.addListener(_onFormChanged);
    _readingTimeMinutes.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _title.removeListener(_onFormChanged);
    _summary.removeListener(_onFormChanged);
    _content.removeListener(_onFormChanged);
    _slug.removeListener(_onFormChanged);
    _sourceTitle.removeListener(_onFormChanged);
    _sourceUrl.removeListener(_onFormChanged);
    _language.removeListener(_onFormChanged);
    _readingTimeMinutes.removeListener(_onFormChanged);

    _title.dispose();
    _summary.dispose();
    _content.dispose();
    _slug.dispose();
    _sourceTitle.dispose();
    _sourceUrl.dispose();
    _language.dispose();
    _readingTimeMinutes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _canSubmit();

    return AlertDialog(
      title: Text(widget.article == null ? 'Create Article' : 'Edit Article'),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: _titleValidator,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'cancer', child: Text('cancer')),
                    DropdownMenuItem(value: 'wellbeing', child: Text('wellbeing')),
                    DropdownMenuItem(value: 'curevoo', child: Text('curevoo')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _category = value);
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _summary,
                  decoration: const InputDecoration(labelText: 'Summary'),
                  validator: _summaryValidator,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _content,
                  minLines: 4,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: 'Content'),
                  validator: _contentValidator,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _slug,
                  decoration: const InputDecoration(labelText: 'Slug (optional)'),
                  validator: _slugValidator,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _language,
                  decoration: const InputDecoration(labelText: 'Language (optional)'),
                  validator: _languageValidator,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _readingTimeMinutes,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Reading Time Minutes (optional)'),
                  validator: _readingTimeValidator,
                ),
                const SizedBox(height: 10),
                TextFormField(controller: _sourceTitle, decoration: const InputDecoration(labelText: 'Source title')),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _sourceUrl,
                  decoration: const InputDecoration(labelText: 'Source URL'),
                  validator: _sourceUrlValidator,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: canSubmit
              ? () {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  final sources = <ArticleSource>[];
                  if (_sourceTitle.text.trim().isNotEmpty && _sourceUrl.text.trim().isNotEmpty) {
                    sources.add(ArticleSource(title: _sourceTitle.text.trim(), url: _sourceUrl.text.trim()));
                  }
                  Navigator.pop(
                    context,
                    _ArticleFormValue(
                      title: _title.text.trim(),
                      category: _category,
                      summary: _summary.text.trim(),
                      content: _content.text.trim(),
                      slug: _slug.text.trim().isEmpty ? null : _slug.text.trim(),
                      sources: sources,
                      language: _language.text.trim().isEmpty ? null : _language.text.trim(),
                      readingTimeMinutes: int.tryParse(_readingTimeMinutes.text.trim()),
                    ),
                  );
                }
              : null,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _onFormChanged() => setState(() {});

  bool _canSubmit() {
    final title = _title.text.trim();
    final summary = _summary.text.trim();
    final content = _content.text.trim();
    final slug = _slug.text.trim();
    final language = _language.text.trim();
    final readingTimeText = _readingTimeMinutes.text.trim();

    if (title.length < 2 || title.length > 300) return false;
    if (!_allowedCategories.contains(_category)) return false;
    if (summary.length < 10 || summary.length > 3000) return false;
    if (content.length < 20 || content.length > 50000) return false;
    if (slug.isNotEmpty && (slug.length < 2 || slug.length > 300)) return false;
    if (language.isNotEmpty && (language.length < 2 || language.length > 10)) return false;

    if (readingTimeText.isNotEmpty) {
      final readingTime = int.tryParse(readingTimeText);
      if (readingTime == null || readingTime < 1 || readingTime > 120) return false;
    }

    final sourceTitle = _sourceTitle.text.trim();
    final sourceUrl = _sourceUrl.text.trim();
    if (sourceTitle.isEmpty && sourceUrl.isEmpty) return true;
    if (sourceTitle.isEmpty || sourceUrl.isEmpty) return false;
    final uri = Uri.tryParse(sourceUrl);
    return uri != null && (uri.isScheme('http') || uri.isScheme('https'));
  }

  String? _titleValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Title is required';
    if (v.length < 2) return 'Title must be at least 2 characters';
    if (v.length > 300) return 'Title must be at most 300 characters';
    return null;
  }

  String? _summaryValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Summary is required';
    if (v.length < 10) return 'Summary must be at least 10 characters';
    if (v.length > 3000) return 'Summary must be at most 3000 characters';
    return null;
  }

  String? _contentValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Content is required';
    if (v.length < 20) return 'Content must be at least 20 characters';
    if (v.length > 50000) return 'Content must be at most 50000 characters';
    return null;
  }

  String? _slugValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (v.length < 2) return 'Slug must be at least 2 characters';
    if (v.length > 300) return 'Slug must be at most 300 characters';
    return null;
  }

  String? _languageValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (v.length < 2) return 'Language must be at least 2 characters';
    if (v.length > 10) return 'Language must be at most 10 characters';
    return null;
  }

  String? _readingTimeValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    final parsed = int.tryParse(v);
    if (parsed == null) return 'Reading time must be an integer';
    if (parsed < 1 || parsed > 120) return 'Reading time must be between 1 and 120';
    return null;
  }

  String? _sourceUrlValidator(String? value) {
    final title = _sourceTitle.text.trim();
    final url = value?.trim() ?? '';
    if (title.isEmpty && url.isEmpty) return null;
    if (title.isEmpty || url.isEmpty) return 'Both source title and URL are required';
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return 'Enter a valid URL';
    }
    return null;
  }
}

class _ArticleFormValue {
  const _ArticleFormValue({
    required this.title,
    required this.category,
    required this.summary,
    required this.content,
    required this.sources,
    this.slug,
    this.language,
    this.readingTimeMinutes,
  });

  final String title;
  final String category;
  final String summary;
  final String content;
  final List<ArticleSource> sources;
  final String? slug;
  final String? language;
  final int? readingTimeMinutes;
}
