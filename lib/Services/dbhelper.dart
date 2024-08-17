import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'api.dart';
import 'package:sqflite/sqflite.dart';

class AppDataBase {
  static int _adminCounter = 1;

  static const String userDbFileName = 'user.db';
  Future createDbPath() async {
    final String databaseFilePath;
    Directory databasePath = await getApplicationDocumentsDirectory();
    databaseFilePath = join(databasePath.path, userDbFileName);
    return databaseFilePath;
  }

  Future getDataBaseFile() async {
    final File file = File(await createDbPath());
    return file.path;
  }

  initializeDatabase() async {
    Database db = await openDatabase(
      await getDataBaseFile(),
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''CREATE TABLE ADMIN(
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          userid INTEGER,
          name VARCHAR(50),
          contact VARCHAR(10),
          email VARCHAR(50),
          address VARCHAR(100),
          designation TEXT(10),
          password VARCHAR(20)
          )
          ''');
        await db.execute('''CREATE TABLE RECRUITMENT(
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          recruitment_number VARCHAR(10),
          first_name TEXT(20),
          last_name TEXT(20),
          email VARCHAR(50),
          phone VARCHAR(20),
          street VARCHAR(50),
          city VARCHAR(30),
          state VARCHAR(30),
          postal_code VARCHAR(20),
          gender TEXT(6),
          recruitment_status VARCHAR(20),
          applied_designation VARCHAR(10)          
          )
          ''');
      },
    );
    return db;
  }

  Future<Database> getDatabase() async {
    Database db = await initializeDatabase();
    return db;
  }

  Future<bool> isDatabaseInitialized() async {
    final filePath = await getDataBaseFile();
    return File(filePath).exists();
  }

  Future<bool> checkLoginCredentials(String email, String password) async {
    print("mail: $email");
    final Database db = await getDatabase();
    var result = await db.rawQuery(
        'SELECT * FROM ADMIN WHERE email = ? AND password = ?',
        [email, password]);
    print(result.isNotEmpty);
    return result.isNotEmpty;
  }

  Future<void> addAdmin() async {
    final Database db = await getDatabase();
    String userid = 'admin${_adminCounter.toString().padLeft(3, '0')}';
    _adminCounter++;
    Map<String, dynamic> adminDetails = {
      'userid': userid,
      'name': 'Shubham Kumar',
      'contact': '9761740057',
      'email': 'condrian9@gmail.com',
      'address': 'Noida s-63',
      'designation': 'Admin',
      'password': 'p@ssW1rd',
    };
    try {
      await db.insert('ADMIN', adminDetails);
      print('Admin detail added successfully of $userid');
    } catch (e) {
      print('Error adding admin detail: $e');
    }
  }

  Future<void> insertAdmin(
      String username,String email, String password, String phone,String designation) async {
    final Database db = await getDatabase();
    String userid = 'admin${_adminCounter.toString().padLeft(3, '0')}';
    _adminCounter++;
    await db.insert(
      'ADMIN',
      {
        'userid': userid,
        'name': username,
        'contact': phone,
        'email': email,
        'address': 'null',
        'designation': designation,
        'password': password,
      },
    );
  }

  Future<void> addCandidates(List<Candidates> candidates) async {
    final Database db = await getDatabase();
    Batch batch = db.batch();
    for (var candidate in candidates) {
      batch.insert(
        'RECRUITMENT',
        {
          'recruitment_number': candidate.recruitmentNumber,
          'first_name': candidate.firstName,
          'last_name': candidate.lastName,
          'email': candidate.email,
          'phone': candidate.phone,
          'street': candidate.street,
          'city': candidate.city,
          'state': candidate.state,
          'postal_code': candidate.postalCode,
          'gender': candidate.gender,
          'recruitment_status': candidate.recruitmentStatus,
          'applied_designation': candidate.appliedDesignation,
        },
      );
    }
    await batch.commit();
  }

  Future<void> storeDataInDatabase() async {
    List<Candidates> apidata = await DataService().getData();
    final AppDataBase appDatabase = AppDataBase();
    await appDatabase.addCandidates(apidata);
    await appDatabase.addAdmin();
  }

  Future<List<Candidates>> showActiveCandidateList() async {
    Database _dbClient = await getDatabase();
    List<Map<String, dynamic>> dbdata = await _dbClient.rawQuery("""
    SELECT * FROM RECRUITMENT 
    WHERE recruitment_status IN ('new', 'in_progress')
  """);
    List<Candidates> list =
        dbdata.map((map) => Candidates.fromJson(map)).toList();
    print("Active candidates fetched successfully..........");
    return list;
  }

  Future<List<Candidates>> showNewCandidateList() async {
    Database _dbClient = await getDatabase();
    List<Map<String, dynamic>> dbdata = await _dbClient.rawQuery("""
    SELECT * FROM RECRUITMENT 
    WHERE recruitment_status IN ('new')
  """);
    List<Candidates> list =
        dbdata.map((map) => Candidates.fromJson(map)).toList();
    print("New candidates fetched successfully..........");
    return list;
  }

  Future<List<Candidates>> showInProgressCandidateList() async {
    Database _dbClient = await getDatabase();
    List<Map<String, dynamic>> dbdata = await _dbClient.rawQuery("""
    SELECT * FROM RECRUITMENT 
    WHERE recruitment_status IN ('in_progress')
  """);
    List<Candidates> list =
        dbdata.map((map) => Candidates.fromJson(map)).toList();
    print("New candidates fetched successfully..........");
    return list;
  }

  Future<List<Candidates>> showInActiveCandidateList() async {
    Database _dbClient = await getDatabase();
    List<Map<String, dynamic>> dbdata = await _dbClient.rawQuery("""
    SELECT * FROM RECRUITMENT 
    WHERE recruitment_status IN ('rejected', 'selected')
  """);
    List<Candidates> list =
        dbdata.map((map) => Candidates.fromJson(map)).toList();
    print("InActive candidates fetched successfully..........");
    return list;
  }

  Future<List<Candidates>> showSelectedCandidateList() async {
    Database _dbClient = await getDatabase();
    List<Map<String, dynamic>> dbdata = await _dbClient.rawQuery("""
    SELECT * FROM RECRUITMENT 
    WHERE recruitment_status IN ('selected')
  """);
    List<Candidates> list =
        dbdata.map((map) => Candidates.fromJson(map)).toList();
    print("selected candidates fetched successfully..........");
    return list;
  }

  Future<List<Candidates>> showRejectedCandidateList() async {
    Database _dbClient = await getDatabase();
    List<Map<String, dynamic>> dbdata = await _dbClient.rawQuery("""
    SELECT * FROM RECRUITMENT 
    WHERE recruitment_status IN ('rejected')
  """);
    List<Candidates> list =
        dbdata.map((map) => Candidates.fromJson(map)).toList();
    print("rejected candidates fetched successfully..........");
    return list;
  }

  Future<Map<String, double>> getRecruitmentStatusCount() async {
    Database _dbClient = await getDatabase();
    List<Map<String, dynamic>> dbdata = await _dbClient.rawQuery("""
    SELECT recruitment_status, COUNT(*) as count 
    FROM RECRUITMENT 
    GROUP BY recruitment_status
  """);

    Map<String, double> statusCountMap = {};
    for (var data in dbdata) {
      statusCountMap[data['recruitment_status']] = data['count'].toDouble();
    }
    return statusCountMap;
  }

  Future<Map<String, double>> getCandidatesByGenderCount() async {
    Database _dbClient = await getDatabase();
    List<Map<String, dynamic>> dbdata = await _dbClient.rawQuery("""
    SELECT gender, COUNT(*) as count 
    FROM RECRUITMENT 
    GROUP BY gender
  """);
    print(dbdata);

    Map<String, double> genderCountMap = {};
    for (var data in dbdata) {
      genderCountMap[data['gender']] = data['count'].toDouble();
    }
    print(genderCountMap);
    return genderCountMap;
  }

  Future<Map<String, double>> getCandidatesByDesignationCount() async {
    Database _dbClient = await getDatabase();
    List<Map<String, dynamic>> dbdata = await _dbClient.rawQuery("""
    SELECT applied_designation, COUNT(*) as count 
    FROM RECRUITMENT 
    GROUP BY applied_designation
  """);

    Map<String, double> designationCountMap = {};
    for (var data in dbdata) {
      designationCountMap[data['applied_designation']] =
          data['count'].toDouble();
    }
    print(designationCountMap);
    return designationCountMap;
  }

  Future<void> updateCandidateStatus(
      String? recruit_number, String newStatus) async {
    Database _dbClient = await getDatabase();
    await _dbClient.rawUpdate("""
    UPDATE RECRUITMENT
    SET recruitment_status = ?
    WHERE recruitment_number = ?
  """, [newStatus, recruit_number]);
    print("Candidate status updated successfully..........");
  }

  Future<Map<String, dynamic>?> getAdminByEmail(String email) async {
    Database _dbClient = await getDatabase();

    final result = await _dbClient.rawQuery('''
    SELECT * FROM ADMIN
    WHERE email = ?
  ''', [email]);

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }
}
