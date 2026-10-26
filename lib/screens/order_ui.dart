import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'order_models.dart' show OrderEntry, OrderStatus;

const Color kInk = Color(0xFF1E293B);
const Color kLine = Color(0xFFE2E8F0);

String rp(int value) {
  final str = value.toString();
  final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  final formatted = str.replaceAllMapped(reg, (m) => '${m[1]}.');
  return 'Rp $formatted';
}

class OrderOverrides {
  static final ValueNotifier<Map<String, OrderStatus>> status =
      ValueNotifier<Map<String, OrderStatus>>({});
  static final Map<String, String> cancelReasons = {};

  static void setStatus(String id, OrderStatus s) {
    status.value = {...status.value, id: s};
  }

  static OrderStatus of(OrderEntry o) {
    return status.value[o.id] ?? o.status;
  }
}

enum TlState { done, active, idle }

class TimelineEntry {
  final String title;
  final String? subtitle;
  final String? detail;
  final String? time;
  final TlState state;

  const TimelineEntry({
    required this.title,
    this.subtitle,
    this.detail,
    this.time,
    this.state = TlState.done,
  });

  String? get resolvedSubtitle => detail ?? subtitle;
}

class TimelineList extends StatelessWidget {
  final List<TimelineEntry> entries;

  const TimelineList({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(entries.length, (index) {
        final e = entries[index];
        final isLast = index == entries.length - 1;
        final isDone = e.state == TlState.done;
        final isActive = e.state == TlState.active;
        final sub = e.resolvedSubtitle;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? AppColors.green
                        : (isActive ? AppColors.greenLight : const Color(0xFFCBD5E1)),
                    border: isActive
                        ? Border.all(color: AppColors.green, width: 2)
                        : null,
                  ),
                  child: Icon(
                    isDone ? Icons.check : Icons.circle,
                    size: 10,
                    color: isDone ? Colors.white : AppColors.green,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 38,
                    color: isDone ? AppColors.green : const Color(0xFFE2E8F0),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          e.title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDone || isActive ? kInk : AppColors.muted,
                          ),
                        ),
                        if (e.time != null)
                          Text(
                            e.time!,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.muted,
                            ),
                          ),
                      ],
                    ),
                    if (sub != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class KV extends StatelessWidget {
  final String k;
  final String v;
  final bool bold;
  final Color? vColor;
  final Color? valueColor;

  const KV(
    this.k,
    this.v, {
    super.key,
    this.bold = false,
    this.vColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            k,
            style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
          ),
          Text(
            v,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: valueColor ?? vColor ?? kInk,
            ),
          ),
        ],
      ),
    );
  }
}

class GuaranteeCard extends StatelessWidget {
  final String title;
  final String? description;
  final String? body;

  const GuaranteeCard({
    super.key,
    this.title = 'Amanah Kas BUMDes Sukorejo',
    this.description,
    this.body,
  });

  @override
  Widget build(BuildContext context) {
    final text = body ?? description ?? 'Dana pembayaran diteruskan ke mitra kelompok tani setelah barang sampai dengan aman.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            color: AppColors.green,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.green,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: AppColors.muted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderPageScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? bottomBar;
  final List<Widget>? children;
  final Widget? body;
  final List<Widget>? actions;

  const OrderPageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.bottomBar,
    this.children,
    this.body,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: kInk),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: kInk,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 1),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        actions: actions,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: kLine),
        ),
      ),
      body: body ??
          ListView(
            padding: const EdgeInsets.all(16),
            children: children ?? const [],
          ),
      bottomNavigationBar: bottomBar,
    );
  }
}

class OCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const OCard({
    super.key,
    required this.child,
    this.color,
    this.borderColor,
    this.padding = const EdgeInsets.all(14),
    this.margin = const EdgeInsets.only(bottom: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor ?? kLine),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class OButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final bool outline;
  final bool filled;

  const OButton(
    this.label, {
    super.key,
    this.onTap,
    this.icon,
    this.color,
    this.textColor,
    this.outline = false,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isOutline = outline || !filled;
    final bg = isOutline ? Colors.transparent : (color ?? AppColors.green);
    final fg = isOutline ? (color ?? AppColors.green) : (textColor ?? Colors.white);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isOutline ? Border.all(color: color ?? AppColors.green) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? textColor;
  final Color? bg;
  final Color? fg;
  final IconData? icon;

  const Pill(
    this.text, {
    super.key,
    this.color,
    this.textColor,
    this.bg,
    this.fg,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = bg ?? color ?? AppColors.greenLight;
    final fgColor = fg ?? textColor ?? AppColors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fgColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: fgColor,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final IconData? icon;

  const SectionHeading(
    this.title, {
    super.key,
    this.trailing,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.green),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: kInk,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
