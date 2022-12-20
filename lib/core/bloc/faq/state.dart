enum FAQState {
  init,
  faqSuccess,
  loading,
  faqError,
}

class FAQFetch {
  final data;
  final FAQState state;
  final version;
  FAQFetch(this.state, {this.data, this.version});
}