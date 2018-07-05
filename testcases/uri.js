var uri = 'https://mozilla.org/?x=шеллы';
var encoded = encodeURI(uri);
print(encoded);
// expected output: "https://mozilla.org/?x=%D1%88%D0%B5%D0%BB%D0%BB%D1%8B"

//try {
  print(decodeURI(encoded));
  // expected output: "https://mozilla.org/?x=шеллы"
// } catch(e) { // catches a malformed URI
//   console.error(e);
// }
