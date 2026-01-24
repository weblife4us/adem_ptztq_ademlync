// import 'package:flutter/material.dart';

// import '../../adem_manager/models/adem_manager/aga_8_component_molar_composition_list.dart';
// import '../../adem_manager/utils/enums/enums.dart';
// import '../../models/aga8_molar_list_model.dart';
// import '../../shared_widgets/s_app_bar.dart';
// import '../../shared_widgets/s_card.dart';
// import '../../shared_widgets/s_info.dart';
// import '../../shared_widgets/s_loading_animation.dart';
// import '../../shared_widgets/s_style_text.dart';
// import '../../shared_widgets/smart_body_layout.dart';
// import '../../utils/app_delegate.dart';
// import '../../utils/enums.dart';

// class AGA8MolarListPage extends StatefulWidget {
//   const AGA8MolarListPage({super.key});

//   @override
//   State<AGA8MolarListPage> createState() => _AGA8MolarListPageState();
// }

// class _AGA8MolarListPageState extends State<AGA8MolarListPage> {
//   int? _key;
//   Aga8MolarListPageModel? _model;

//   late Aga8Config _activeAga8;

//   Widget _sInfo({required Chem type, required String text}) {
//     return SInfo(
//       title: type.string,
//       subTitle: SStyleText(type.formula),
//       text: text,
//       unit: '%',
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     final adem = AppDelegate().adem!;
//     _key = adem.aga8ActiveId;
//     _model = Aga8MolarListPageModel(
//       aga8: adem.aga8ActiveConfig!,
//       aga8List: adem.aga8Configs!,
//       chemValues: Chem.values,
//     );
//     _activeAga8 = _model!.aga8;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: SAppBar(
//         text: locale.aga8MolarListString,
//         hasAdemInfoAction: true,
//       ),
//       body: SmartBodyLayout(
//         children: _model != null
//             ? [
//                 SCard.column(
//                   children: [
//                     SInfo.editDropdown(
//                       title: '',
//                       value: _activeAga8.name,
//                       list: _model!.aga8List.map((e) => e.name).toList(),
//                       isEdited: false, // TODO:
//                       onChanged: (v) => setState(() {
//                         for (var e in _model!.aga8List) {
//                           if (e.name == v) {
//                             _key = e.id;
//                             _activeAga8 = e;
//                           }
//                         }
//                       }),
//                     ),
//                     SInfo(
//                       title: locale.dateString,
//                       text: DateTimeFmtManager.dateFmt(_activeAga8.dateTime),
//                     ),
//                     SInfo(
//                       title: locale.timeString,
//                       text: DateTimeFmtManager.timeFmt(_activeAga8.dateTime),
//                     ),
//                   ],
//                 ),
//                 SCard.column(
//                   children: [
//                     for (var e in _model!.chemValues)
//                       _sInfo(
//                         type: e,
//                         text: e.data(_activeAga8).toStringAsFixed(2),
//                       ),
//                   ],
//                 ),
//               ]
//             : [const Center(child: SLoadingAnimationWave())],
//       ),
//     );
//   }
// }
