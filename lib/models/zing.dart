// class Zing {
//   int _species_id;
//   String _species_name;
//   String _species_common_name;
//   String _species_family;
//   String _species_description;

//   //constructors

//   Zing(this._species_id, this._species_name, this._species_common_name,
//       this._species_family, this._species_description);

//   //     //making description optional
//   // Zing(this._species_id, this._species_name, this._species_common_name,
//   //     this._species_family, this._date_added, [this._species_description]);

//   //constructor that will accept ID
//   Zing.withId(this._species_id, this._species_name, this._species_common_name,
//       this._species_family, this._species_description);

//   //create getters
//   int get id => _species_id;
//   String get species_name => _species_name;
//   String get species_common_name => _species_common_name;
//   String get species_family => _species_family;
//   String get species_description => _species_description;

//   //create setters
//   //no setter for ID because it will be generated autoatically in database

//   set species_name(String newSpeciesName) {
//     if (newSpeciesName.length <= 255) {
//       this._species_name = newSpeciesName;
//     }
//   }

//   set species_common_name(String newSpeciesCommonName) {
//     if (newSpeciesCommonName.length <= 255) {
//       this._species_common_name = newSpeciesCommonName;
//     }
//   }

//   set species_family(String newSpeciesFamily) {
//     if (newSpeciesFamily.length <= 255) {
//       this._species_family = newSpeciesFamily;
//     }
//   }

//   set species_description(String newSpeciesDescription) {
//     if (newSpeciesDescription.length <= 255) {
//       this._species_description = newSpeciesDescription;
//     }
//   }

//   //function to help convert Zing object into map object
//   //instantiate empty map object

//   Map<String, dynamic> toMap() {
//     var map = Map<String, dynamic>();

//     //check if ID is null or not
//     if (id != null) {
//       map['species_id'] = _species_id;
//     }

//     map['species_name'] = _species_name;
//     map['species_common_name'] = _species_common_name;
//     map['species_family'] = _species_family;
//     map['species_description'] = _species_description;

//     return map;
//   }

//   //extract zing object from map object
//   Zing.fromMapObject(Map<String, dynamic> map) {
//     this._species_id = map['species_id'];
//     this._species_name = map['species_name'];
//     this._species_common_name = map['species_common_name'];
//     this._species_family = map['species_family'];
//     this._species_description = map['species_description'];
//   }
// }
