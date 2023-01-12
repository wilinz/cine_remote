import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../camera_connection/bloc/camera_connection_cubit.dart';
import '../bloc/camera_control_layout_cubit.dart';
import '../widgets/camera_control_base_layout.dart';
import '../widgets/control_prop_value_picker.dart';
import '../widgets/control_props_bar.dart';
import '../widgets/live_view_player.dart';
import '../widgets/record_button.dart';

class CameraControlPageLandscape extends StatelessWidget {
  const CameraControlPageLandscape({super.key});

  @override
  Widget build(BuildContext context) => CameraControlBaseLayout(
        builder: (context, state) => Row(
          children: [
            SafeArea(
              right: false,
              child: SizedBox(
                width: 120,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 24),
                      child: IconButton(
                        onPressed: () =>
                            context.read<CameraConnectionCubit>().disconnect(),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ControlPropsBar.landscape(
                        selectedType: state.activePropType,
                        onPropSelected: (propType) {
                          context
                              .read<CameraControlLayoutCubit>()
                              .setActivePropType(
                                  state.activePropType == propType
                                      ? null
                                      : propType);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  SafeArea(
                    top: false,
                    bottom: false,
                    left: false,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: LiveViewPlayer(children: [
                        const Align(
                          alignment: Alignment.centerRight,
                          child: RecordButton(),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                            onPressed: () => context
                                .read<CameraControlLayoutCubit>()
                                .setForcedOrientation(Orientation.portrait),
                            icon: const Icon(
                              Icons.fullscreen,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  if (state.activePropType != null)
                    Container(
                      color: Colors.grey[850],
                      child: SafeArea(
                        left: false,
                        child: ControlPropValuePicker(
                          selectedPropType: state.activePropType!,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
}
