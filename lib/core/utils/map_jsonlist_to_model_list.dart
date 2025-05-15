mixin MapJsonListToModelList{
  List<T> mapJsonListToModelList<T>(List<dynamic> jsonList, Function elementConverter){
    return jsonList
        .map((e) => elementConverter(e) as T)
        .toList();
  }
}
