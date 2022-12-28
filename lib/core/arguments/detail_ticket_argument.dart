import 'package:hyppe/core/models/collection/support_ticket/appeal_model.dart';
import 'package:hyppe/core/models/collection/support_ticket/ticket_model.dart';

class DetailTicketArgument{
  TicketModel? ticketModel;
  AppealModel? appealModel;

  DetailTicketArgument({this.ticketModel, this.appealModel});
}