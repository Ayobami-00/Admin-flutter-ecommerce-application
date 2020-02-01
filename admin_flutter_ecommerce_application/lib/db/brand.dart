import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class BrandService{
  Firestore _firestore = Firestore.instance;
  String ref = 'brands';
  void createBrand(String name){
    var id = Uuid();
    String brandId = id.v1();

    _firestore.collection('brands').document(brandId).setData({'brand': name});
  }

Future<List<DocumentSnapshot>> getBrands(){
  return _firestore.collection(ref).getDocuments().then((snaps){
    return snaps.documents;
  });
}

}
