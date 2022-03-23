enum ReportState {
  init, loading,
  getReportOptionsSuccess, getReportOptionsError,
  reportsSuccess, reportsError
}
class ReportFetch {
  final data;
  final ReportState reportState;
  ReportFetch(this.reportState, {this.data});
}
