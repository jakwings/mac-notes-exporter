#!/bin/bash

set -e

export PATH='/usr/bin:/bin:/usr/sbin:/sbin'

outdir=$(dirname -- "$0")

run() {
sqlite3 "$1" <<'EOT'

SELECT PRINTF('<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
.note {
    margin: 10px 15px;
    padding: 5px;
    font-size: 16px;
    line-height: 1.35;
    word-wrap: break-word;
    background: #F9F9F9;
    border: 1px solid #AAA;
}
.title {
    font-size: 36px;
    font-weight: bold;
    border-bottom: 1px solid #EEE;
}
ul, ol {
    margin: 0;
    padding-left: 2em;
}
ul ul, ol ol {
    padding-left: 1em;
}
ul.Apple-dash-list, ul.Apple-dash-list ul {
    list-style-type: none;
}
ul.Apple-dash-list li:before {
    content: "\2013";
    position: absolute;
    margin: 0 -1.25em;
}
ol, ol ol ol ol, ol ol ol ol ol ol ol {
    list-style-type: decimal;
}
ol ol, ol ol ol ol ol, ol ol ol ol ol ol ol ol {
    list-style-type: lower-alpha;
}
ol ol ol, ol ol ol ol ol ol, ol ol ol ol ol ol ol ol ol {
    list-style-type: lower-roman;
}
ol ol ol ol ol ol ol ol ol ol {
    list-style-type: none;
}
ol ol ol ol ol ol ol ol ol ol li:before {
    content: "\2013";
    position: absolute;
    -webkit-margin-start: -1.25em;
}
a {
    color: rgb(158, 75, 47);
    text-decoration: underline;
}
object {
    cursor: default;
    -webkit-user-drag: element;
    -webkit-user-modify: read-only;
    vertical-align: bottom;
}
img {
    vertical-align: top;
    max-width: 100%%;
}
</style>
</head>
<body>');

WITH
        note(id, bid, fid, title) AS (SELECT Z_PK, ZBODY, ZFOLDER, ZTITLE FROM ZNOTE),
        body(id, html) AS (SELECT Z_PK, ZHTMLSTRING FROM ZNOTEBODY),
        folder(id, name) AS (SELECT Z_PK, ZNAME FROM ZFOLDER)
SELECT
        PRINTF('
<div class="note" id="%d">
  <div class="title"><span class="folder-name">%s</span> - <span class="note-title">%s</span></div>
  <div class="content">%s</div>
</div>',
                note.id, folder.name, note.title,
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(body.html, '<html>', ''), '</html>', ''), '<body>', ''), '</body>', ''), '<head>', ''), '</head>', '')
        )
FROM note
JOIN body ON note.bid = body.id
JOIN folder ON note.fid = folder.id
;

SELECT PRINTF('</body></html>');

EOT
}

count=0
for database in ~/Library/Containers/com.apple.Notes/Data/Library/Notes/*.storedata
do
  count=$(( count + 1 ))
  notes="${outdir}/Notes-${count}.html"
  error="${outdir}/Notes-${count}.txt"
  run "${database}" > "${notes}" 2> "${error}" || true
done
