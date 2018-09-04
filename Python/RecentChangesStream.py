import json
import pyodbc
from sseclient import SSEClient as EventSource

URL = 'https://stream.wikimedia.org/v2/stream/recentchange'
SERVER = 'recentchangesstream.database.windows.net'
DATABASE = 'RecentChangesStream'
USERNAME = 'rcsuser'
PASSWORD = 'rcs1234!'
DRIVER = '{ODBC Driver 17 for SQL Server}'

eventdict = {'edit': 1, 'external': 2, 'new': 3, 'log': 4, 'categorize': 5}


def connect():
    conn = pyodbc.connect(
        'DRIVER=' + DRIVER + ';SERVER=' + SERVER + ';PORT=1433;DATABASE=' + DATABASE + ';UID=' + USERNAME + ';PWD=' + PASSWORD)
    cursor = conn.cursor()

    return conn, cursor


def store_and_get_username (conn_, cursor_, mediawikiid_, isbot_, username_):
    sql = """\
    DECLARE @RC INT
    EXEC @RC = MediaWiki.StoreAndGetUsername ?, ?, ?
    SELECT @RC AS rc
    """
    values = (mediawikiid_, isbot_, username_)
    cursor_.execute(sql, values)
    rc = cursor_.fetchval()
    conn_.commit()

    return rc


def store_and_get_page (conn_, cursor_, pageuri_, pagetitle_, wiki_):
    sql = """\
    DECLARE @RC INT
    EXEC @RC = MediaWiki.StoreAndGetPage ?, ?, ?
    SELECT @RC AS rc
    """
    values = (pageuri_, pagetitle_, wiki_)
    cursor_.execute(sql, values)
    rc = cursor_.fetchval()
    conn_.commit()

    return rc


def store_page_edit (conn_, cursor_, userid_, pageid_, eventypeid_, edittimestamp_, parsedocument_):
    sql = """\
    DECLARE @RC INT
    EXEC @RC = MediaWiki.StoreAndGetPageEdit ?, ?, ?, ?, ?
    SELECT @RC AS rc
    """
    values = (userid_, pageid_, eventypeid_, edittimestamp_, parsedocument_)
    cursor_.execute(sql, values)
    rc = cursor_.fetchval()
    conn_.commit()

    return rc


def main():
    print('Reading stream... ')

    conn, cursor = connect()
    # while row:
    #     print (str(row[0]))
    #     row = cursor.fetchone()

    for event in EventSource(URL):
        if event.event == 'message':
            try:
                document = json.loads(event.data)
            except ValueError:
                pass
            else:
                isbot = document['bot']
                username = document['user']
                mediawikiid = document['id']
                eventtypeid = eventdict.get(document['type'])
                if eventtypeid is None:
                    eventtypeid = 6
                pageuri = document['meta']['uri']
                pagetitle = document['title']
                wiki = document['wiki']
                edittimestamp = document['timestamp']
                parsedocument = document['parsedcomment']

                userid = store_and_get_username (conn, cursor, mediawikiid, isbot, username)
                pageid = store_and_get_page (conn, cursor, pageuri, pagetitle, wiki)
                rc = store_page_edit (conn, cursor, userid, pageid, eventtypeid, edittimestamp, parsedocument)
                # debugging - printing document
                print(document)


if __name__ == '__main__':
    main()