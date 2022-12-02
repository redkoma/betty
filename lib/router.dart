import 'package:betty/screen/scrb001_setup_company.dart';
import 'package:betty/screen/scrb002_setup_working_time.dart';
import 'package:betty/screen/scrb003_setup_department.dart';
import 'package:betty/screen/scrb004_setup_holiday.dart';
import 'package:betty/screen/scrb005_edit_working_time.dart';
import 'package:betty/screen/scrb006_edit_time.dart';
import 'package:betty/screen/scrb007_edit_department.dart';
import 'package:betty/screen/scrb008_edit_holiday.dart';
import 'package:betty/screen/scrb009_user_management.dart';
import 'package:betty/screen/scrb010_edit_user.dart';
import 'package:betty/screen/scrb011_edit_invite.dart';
import 'package:betty/screen/scrb012_edit_join.dart';
import 'package:betty/screen/scrb013_setting_leave.dart';
import 'package:betty/screen/scrb014_setting_leave_flow.dart';
import 'package:betty/screen/scrb015_setting_leave_department_manager.dart';
import 'package:betty/screen/scrb016_setting_leave_type.dart';
import 'package:betty/screen/scrb017_select_user.dart';
import 'package:betty/screen/scrb018_edit_leave_type.dart';
import 'package:betty/screen/scrb019_checkin.dart';
import 'package:betty/screen/scrb020_checkout.dart';
import 'package:betty/screen/scrb021_timesheet.dart';
import 'package:betty/screen/scrb022_setting_shift_calendar.dart';
import 'package:betty/screen/scrb023_chat.dart';
import 'package:betty/screen/scrb024_application_leave.dart';
import 'package:betty/screen/scrb025_application_expense.dart';
import 'package:betty/screen/scrb026_application_training.dart';
import 'package:betty/screen/scrb027_application_memo.dart';
import 'package:betty/screen/scrb028_application_ot.dart';
import 'package:betty/screen/scrb029_application_booking.dart';
import 'package:betty/screen/scrb030_form_leave.dart';
import 'package:betty/screen/scrb031_setting_news.dart';
import 'package:betty/screen/scrb032_edit_news.dart';
import 'package:betty/screen/scrb033_setting_expense.dart';
import 'package:betty/screen/scrb034_setting_expense_flow.dart';
import 'package:betty/screen/scrb035_setting_expense_type.dart';
import 'package:betty/screen/scrb036_form_expense.dart';
import 'package:betty/screen/scrb037_setting_memo.dart';
import 'package:betty/screen/scrb038_form_memo.dart';
import 'package:betty/screen/scrb039_form_memo_select_user.dart';
import 'package:betty/screen/scrb040_setting_memo_type.dart';
import 'package:betty/screen/scrb041_setting_training.dart';
import 'package:betty/screen/scrb042_setting_training_type.dart';
import 'package:betty/screen/scrb043_form_training.dart';
import 'package:betty/screen/scrb044_setting_okrs.dart';
import 'package:betty/screen/scrb045_application_okr.dart';
import 'package:betty/screen/scrb046_form_okr.dart';
import 'package:betty/screen/scrb047_form_task.dart';
import 'package:betty/screen/scrb048_team_info.dart';
import 'package:betty/screen/scrb049_application_time_adjust.dart';
import 'package:betty/screen/scrb050_form_time_adjust.dart';
import 'package:betty/screen/scrb051_report_leave.dart';
import 'package:betty/screen/scrb052_report_timesheet.dart';
import 'package:betty/screen/scrb053_report_expense.dart';
import 'package:betty/screen/scrb054_report_training.dart';
import 'package:betty/screen/scrb055_report_okr.dart';
import 'package:betty/screen/scrb056_view_news.dart';
import 'package:betty/screen/scrb057_report_expense_by_project.dart';
import 'package:betty/screen/util100_list_inbox.dart';
import 'package:betty/screen/util101_select_datetime.dart';
import 'package:betty/screen/util102_image_slide.dart';
import 'package:betty/screen/util103_list_data.dart';
import 'package:flutter/material.dart';
import 'package:betty/screen/scr000_signup.dart';
import 'package:betty/screen/scr001_login_with.dart';
import 'package:betty/screen/scr002_main.dart';
import 'package:betty/screen/scr006_select_people.dart';
import 'package:betty/screen/scr00_delete_user.dart';
import 'package:betty/screen/scr00_forgot_password.dart';

const startScreen = "/scr001";
const mainScreen = "/scr002";

final Map<String, WidgetBuilder> map = {
  // Use native Splash Screen
  '/forgot_password': (BuildContext context) => const Scr00ForgotPassword(),
  '/signup': (BuildContext context) => const Scr000Signup(),
  '/delete': (BuildContext context) => const Scr00DeleteUser(),
  '/scr001': (BuildContext context) => const Scr001LoginWith(),
  '/scr002': (BuildContext context) => const Scr002Main(),
  '/scr006': (BuildContext context) => const Scr006SelectPeople(),

  '/util100': (BuildContext context) => const Util100ListInbox(),
  '/util101': (BuildContext context) => const Util101SelectDate(),
  '/util102': (BuildContext context) => const Util102ImageSlide(),
  '/util103': (BuildContext context) => const Util103ListData(),

  '/scrb001': (BuildContext context) => const Scrb001SetupCompany(),
  '/scrb002': (BuildContext context) => const Scrb002SetupWorkingTime(),
  '/scrb003': (BuildContext context) => const Scrb003SetupDepartment(),
  '/scrb004': (BuildContext context) => const Scrb004SetupHoliday(),
  '/scrb005': (BuildContext context) => const Scrb005EditWorkingTime(),
  '/scrb006': (BuildContext context) => const Scrb006EditTime(),
  '/scrb007': (BuildContext context) => const Scrb007EditDepartment(),
  '/scrb008': (BuildContext context) => const Scrb008EditHoliday(),
  '/scrb009': (BuildContext context) => const Scrb009UserManagement(),
  '/scrb010': (BuildContext context) => const Scrb010EditUser(),
  '/scrb011': (BuildContext context) => const Scrb011EditInvite(),
  '/scrb012': (BuildContext context) => const Scrb012EditJoin(),
  '/scrb013': (BuildContext context) => const Scrb013LeaveSetting(),
  '/scrb014': (BuildContext context) => const Scrb014SettingLeaveFlow(),
  '/scrb015': (BuildContext context) => const Scrb015SettingLeaveDepartmentManager(),
  '/scrb016': (BuildContext context) => const Scrb016SettingLeaveType(),
  '/scrb017': (BuildContext context) => const Scrb017SelectUser(),
  '/scrb018': (BuildContext context) => const Scrb018EditLeaveType(),
  '/scrb019': (BuildContext context) => const Scrb019CheckIn(),
  '/scrb020': (BuildContext context) => const Scrb020CheckOut(),
  '/scrb021': (BuildContext context) => const Scrb021TimeSheet(),
  '/scrb022': (BuildContext context) => const Scrb022SettingShiftCalendar(),
  '/scrb023': (BuildContext context) => const Scrb023Chat(),
  '/scrb024': (BuildContext context) => const Scrb024ApplicationLeave(),
  '/scrb025': (BuildContext context) => const Scrb025ApplicationExpense(),
  '/scrb026': (BuildContext context) => const Scrb026ApplicationTraining(),
  '/scrb027': (BuildContext context) => const Scrb027ApplicationMemo(),
  '/scrb028': (BuildContext context) => const Scrb028ApplicationOT(),
  '/scrb029': (BuildContext context) => const Scrb029ApplicationBooking(),
  '/scrb030': (BuildContext context) => const Scrb030FormLeave(),
  '/scrb031': (BuildContext context) => const Scrb031NewsSetting(),
  '/scrb032': (BuildContext context) => const Scrb032EditNews(),
  '/scrb033': (BuildContext context) => const Scrb033ExpenseSetting(),
  '/scrb034': (BuildContext context) => const Scrb034SettingExpenseFlow(),
  '/scrb035': (BuildContext context) => const Scrb035SettingExpenseType(),
  '/scrb036': (BuildContext context) => const Scrb036FormExpense(),
  '/scrb037': (BuildContext context) => const Scrb037MemoSetting(),
  '/scrb038': (BuildContext context) => const Scrb038FormMemo(),
  '/scrb039': (BuildContext context) => const Scrb039FormMemoSelectUser(),
  '/scrb040': (BuildContext context) => const Scrb040SettingMemoType(),
  '/scrb041': (BuildContext context) => const Scrb041TrainingSetting(),
  '/scrb042': (BuildContext context) => const Scrb042SettingTrainingType(),
  '/scrb043': (BuildContext context) => const Scrb043FormTraining(),
  '/scrb044': (BuildContext context) => const Scrb044OKRsSetting(),
  '/scrb045': (BuildContext context) => const Scrb045ApplicationOKR(),
  '/scrb046': (BuildContext context) => const Scrb046FormOKR(),
  '/scrb047': (BuildContext context) => const Scrb047FormTask(),
  '/scrb048': (BuildContext context) => const Scrb048TeamInfo(),
  '/scrb049': (BuildContext context) => const Scrb049ApplicationTimeAdjust(),
  '/scrb050': (BuildContext context) => const Scrb050FormTimeAdjust(),
  '/scrb051': (BuildContext context) => const Scrb051ReportLeave(),
  '/scrb052': (BuildContext context) => const Scrb052ReportTimeSheet(),
  '/scrb053': (BuildContext context) => const Scrb053ReportExpense(),
  '/scrb054': (BuildContext context) => const Scrb054ReportTraining(),
  '/scrb055': (BuildContext context) => const Scrb055ReportOKR(),
  '/scrb056': (BuildContext context) => const Scrb056ViewNews(),
  '/scrb057': (BuildContext context) => const Scrb057ReportExpenseByProject(),
};
