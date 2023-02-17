enum ReportState { init, loading, getReportOptionsSuccess, getReportOptionsError, reportsSuccess, reportsError, appealSuccess, appealError }

class ReportFetch {
  final data;
  final message;
  final ReportState reportState;
  ReportFetch(this.reportState, {this.data, this.message});
}
