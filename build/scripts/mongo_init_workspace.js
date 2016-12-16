use workspace;

var settings = db.getCollection("settings"),
    init = {
        "type_db": "wstypes",
        "backend": "shock",
        "shock_location": "http://localhost:7044",
        "shock_user": "kbasetest"
    };

settings.update({}, init, {"upsert": true});