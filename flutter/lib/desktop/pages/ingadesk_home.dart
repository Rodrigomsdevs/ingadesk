import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/common/widgets/animated_rotation_widget.dart';
import 'package:flutter_hbb/desktop/pages/connection_page.dart';
import 'package:flutter_hbb/desktop/pages/desktop_tab_page.dart';
import 'package:flutter_hbb/models/platform_model.dart';
import 'package:flutter_hbb/models/server_model.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class IngaDeskHome extends StatelessWidget {
  const IngaDeskHome({Key? key}) : super(key: key);

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    showToast(translate("Copied"));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: gFFI.serverModel,
      child: Consumer<ServerModel>(
        builder: (context, model, _) => Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: translate('Settings'),
                  onPressed: DesktopTabPage.onAddSetting,
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        loadLogo(),
                        const SizedBox(height: 24),
                        _buildId(context, model),
                        const SizedBox(height: 32),
                        _buildPassword(context, model),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              OnlineStatusWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildId(BuildContext context, ServerModel model) {
    final labelColor =
        Theme.of(context).textTheme.titleLarge?.color?.withOpacity(0.5);
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: model.serverId,
      builder: (context, value, _) => Column(
        children: [
          Text(translate("ID"),
              style: TextStyle(fontSize: 18, color: labelColor)),
          InkWell(
            onTap: () => _copy(value.text),
            borderRadius: BorderRadius.circular(8),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value.text,
                style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2),
              ).paddingSymmetric(horizontal: 12),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _copy(value.text),
            icon: const Icon(Icons.copy),
            label: Text(translate("Copy to clipboard")),
          ),
        ],
      ),
    );
  }

  Widget _buildPassword(BuildContext context, ServerModel model) {
    final showOneTime = model.approveMode != 'click' &&
        model.verificationMethod != kUsePermanentPassword;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: model.serverPasswd,
      builder: (context, value, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("${translate("Password")}: ",
              style: const TextStyle(fontSize: 18)),
          SelectableText(value.text,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          if (showOneTime) ...[
            const SizedBox(width: 8),
            AnimatedRotationWidget(
              onPressed: () => bind.mainUpdateTemporaryPassword(),
              child: Tooltip(
                message: translate('Refresh Password'),
                child: const RotatedBox(
                    quarterTurns: 2, child: Icon(Icons.refresh, size: 22)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              tooltip: translate("Copy to clipboard"),
              onPressed: () => _copy(value.text),
            ),
          ],
        ],
      ),
    );
  }
}
