#! /usr/bin/env python3
import os
import Logger

log = Logger.Logger()
files = ["dropAll","user","project","issueStatus","issue","projectMember","comment","linkedIssue"]
outfile = "db.sql"
sqlfolder = "../sql"
os.chdir(os.path.dirname(os.path.realpath(__file__)))

@Logger.staged(log)
def generate_DB_SQL(log) -> str:
    sql = ""
    for index,sqlFile in enumerate(files):
        log.step(index + 1,len(files), f"Extracting {sqlFile}.sql ...")
        with open(f"{sqlfolder}/{sqlFile}.sql","r") as f:
            sql += f"\n#----[[ {sqlFile}.sql ]]----\n{''.join(f.readlines())}\n"
    return sql

log.info(f"Working in {os.getcwd()}")
log.info(f"Reading files ({len(files)})...")

sqlCommands = generate_DB_SQL(log)

log.info(f"Writing commands to {outfile}...")
with open(f"{sqlfolder}/{outfile}", "+w") as out:
    out.write(sqlCommands)

log.info("Done!")

