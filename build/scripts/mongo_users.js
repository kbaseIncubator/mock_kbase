var version = db.version();
use admin;

if (version.find("2.4") === 0) {
    db.addUser({user:"admin",pwd:"admin", roles:["readWrite"]});
}
else {
    db.createUser({user:"admin",pwd:"admin", roles:[{role:"root",db:"admin"}]});
}
