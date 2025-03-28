import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cine_remote_colors.dart';
import '../../live_view/widgets/live_view_player.dart';
import '../../screen_orientation/widgets/force_orientation_button.dart';
import '../bloc/camera_control_layout_cubit.dart';
import '../widgets/camera_control_base_layout.dart';
import '../widgets/control_actions_bar.dart';
import '../widgets/control_prop_value_picker.dart';
import '../widgets/control_props_bar.dart';
import '../widgets/menu/camera_control_menu.dart';

class CameraControlPagePortrait extends StatelessWidget {
  const CameraControlPagePortrait({super.key});

  @override
  Widget build(BuildContext context) {
    return CameraControlBaseLayout(
      appBarBuilder: (context, state) => AppBar(
        leadingWidth: 80,
        leading: TextButton(
          onPressed: () =>
              context.read<CameraControlLayoutCubit>().toggleMenu(),
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(
                state.showMenu ? CineRemoteColors.primary : Colors.white),
          ),
          child: const Text('Menu'),
        ),
        backgroundColor: Colors.black,
      ),
      builder: (context, state) => SafeArea(
        child: Column(
          children: [
            LiveViewPlayer(
              children: [
                const Align(
                  alignment: Alignment.bottomRight,
                  child: ForceOrientationButton(
                    forceTo: Orientation.landscape,
                  ),
                ),
                if (state.showMenu)
                  Container(
                    color: CineRemoteColors.overlayBackground,
                    child: const Center(
                      child: SizedBox(
                        width: 200,
                        child: CameraControlMenu(
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                      ),
                    ),
                  )
              ],
            ),
            const SizedBox(height: 16),
            ControlPropsBar.portrait(
              selectedType: state.activePropType,
              onPropSelected: (propType) {
                context.read<CameraControlLayoutCubit>().setActivePropType(
                    state.activePropType == propType ? null : propType);
              },
            ),
            Expanded(
              child: state.activePropType != null
                  ? Container(
                      color: Colors.grey[850],
                      child: ControlPropValuePicker.grid(
                        propType: state.activePropType!,
                      ),
                    )
                  : Container(),
            ),
            const SizedBox(height: 32),
            const ControlActionsBar.portrait(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
