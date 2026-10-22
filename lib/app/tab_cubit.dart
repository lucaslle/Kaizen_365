import 'package:flutter_bloc/flutter_bloc.dart';

enum AppTab { objectives, journal, review }

class TabCubit extends Cubit<AppTab> {
  TabCubit() : super(AppTab.objectives);

  void selected(AppTab tab) => emit(tab);
}
