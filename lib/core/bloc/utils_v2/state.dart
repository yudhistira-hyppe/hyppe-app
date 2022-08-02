enum UtilsState {
  init,
  loading,
  getDocumentSuccess,
  getDocumentError,
  getEulaSuccess,
  getEulaError,
  getInterestsSuccess,
  getInterestsError,
  getReactionSuccess,
  getReactionError,
  languagesSuccess,
  languagesError,
  loadCitySuccess,
  loadCityError,
  loadCountrySuccess,
  loadCountryError,
  loadAreaSuccess,
  loadAreaError,
  downloadLanguageSuccess,
  downloadLanguageError,
  welcomeNotesSuccess,
  welcomeNotesError,
  getGenderSuccess,
  getGenderError,
  getMartialStatusSuccess,
  getMartialStatusError,
  searchPeopleSuccess,
  searchPeopleError,
  deleteUserTagSuccess,
  deleteUserTagError,
  updateLangError,
  updateLangSuccess,
}

class UtilsFetch {
  final data;
  final UtilsState utilsState;
  UtilsFetch(this.utilsState, {this.data});
}
