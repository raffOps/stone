
# This file was generated by 'versioneer.py' (0.18) from
# revision-control system data, or from the parent directory name of an
# unpacked source archive. Distribution tarballs contain a pre-generated copy
# of this file.

import json

version_json = '''
{
 "date": "2021-02-13T12:01:20+0000",
 "dirty": false,
 "error": null,
 "full-revisionid": "cdc26c16280e3ba43325ac77cf654dd16288f9d6",
 "version": "1.2.2"
}
'''  # END VERSION_JSON


def get_versions():
    return json.loads(version_json)
