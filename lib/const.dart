final RegExp emailRegEXP = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

final RegExp passwordRegEXP =
    RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');

final RegExp phoneRegEXP = RegExp(r'^9\d{9}$');

final RegExp fullNameRegEXP = RegExp(r"^[A-Za-z]+(?:[ -][A-Za-z]+)*$");

const String profilePictureLink =
    "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png";
