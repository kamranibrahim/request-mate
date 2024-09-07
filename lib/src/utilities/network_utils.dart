enum RequestMateType{
  post(value: 'POST'),
  delete(value: 'DELETE'),
  get(value: 'GET'),
  put(value: 'PUT'),
  patch(value: 'PATCH');

  final String value;
  const RequestMateType({this.value = ''});
}