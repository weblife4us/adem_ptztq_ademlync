import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/app_delegate.dart';
import '../../utils/custom_color_scheme.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/s_loading_animation.dart';
import '../../utils/widgets/svg_image.dart';
import 'export_bloc.dart';

class ExportIcon extends StatefulWidget {
  final void Function(void Function(ExportEvent)) onPressed;
  final void Function(String, String)? onSaved;

  const ExportIcon({super.key, required this.onPressed, this.onSaved});

  @override
  State<ExportIcon> createState() => _ExportIconState();
}

class _ExportIconState extends State<ExportIcon> {
  late ExportBloc _bloc;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _bloc = ExportBloc();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: (_, state) {
        if (state is FileExportedState) {
          final FileExportedState(:filePath, :filename) = state;
          _filePath = filePath;

          showExportSuccessToast(context);

          if (widget.onSaved != null) widget.onSaved!(filePath, filename);
        } else if (state is FileOpenedState) {
          showToast(context, text: state.toast);
        } else if (state is FileExportFailedState) {
          handleError(context, state.error);
        }
      },
      builder: (_, state) {
        late Widget content;

        if (state is NotReadyState || state is FileExportFailedState) {
          content = SvgImage('download', color: colorScheme.white(context));
        } else if (state is FileExportingState || state is FileOpeningState) {
          content = SLoadingAnimationStaggered(
            color: colorScheme.white(context),
          );
        } else if (state is FileExportedState || state is FileOpenedState) {
          content = SvgImage(
            AppDelegate().exportFmt.svg,
            color: colorScheme.connected(context),
          );
        }

        return InkWell(
          onTap: () => _onPressed(_filePath, state),
          child: Padding(padding: const EdgeInsets.all(12.0), child: content),
        );
      },
    );
  }

  void _onPressed(String? filePath, Object? state) {
    if (state is NotReadyState || state is FileExportFailedState) {
      widget.onPressed((event) => _bloc.add(event));
    } else if ((state is FileExportedState || state is FileOpenedState) &&
        filePath != null) {
      _bloc.add(FileOpenEvent(filePath));
    }
  }
}
