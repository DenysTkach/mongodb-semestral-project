const adminDb = db.getSiblingDB("admin");
print("listShards:");
printjson(adminDb.runCommand({ listShards: 1 }));
print("\nsh.status():");
sh.status();
