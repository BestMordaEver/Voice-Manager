local sqlite = require "sqlite3"

local guildsData = sqlite.open("guildsData.db")
local lobbiesData = sqlite.open("lobbiesData.db")
local channelsData = sqlite.open("channelsData.db")

guildsData:exec([[
CREATE TABLE guilds(
	id VARCHAR PRIMARY KEY,
	role VARCHAR,					/* mutable, default NULL */
	cLimit INTEGER NOT NULL,		/* mutable, default 500 */
	permissions INTEGER NOT NULL	/* mutable, default 0 */
)]])

lobbiesData:exec([[
CREATE TABLE lobbies(
	id VARCHAR PRIMARY KEY,
	guild VARCHAR NOT NULL,			/* immutable */
	isMatchmaking BOOL NOT NULL,	/* mutable, default FALSE */
	template VARCHAR,				/* mutable, default NULL */
	companionTemplate VARCHAR,		/* mutable, default NULL */
	target VARCHAR,					/* mutable, default NULL */
	companionTarget VARCHAR,		/* mutable, default NULL */
	role VARCHAR,					/* mutable, default NULL */
	permissions INTEGER NOT NULL,	/* mutable, default 0 */
	capacity INTEGER,				/* mutable, default NULL */
	bitrate INTEGER,				/* mutable, default NULL */
	greeting VARCHAR,				/* mutable, default NULL */
	companionLog VARCHAR			/* mutable, default NULL */
)]])

channelsData:exec([[
CREATE TABLE channels(
	id VARCHAR PRIMARY KEY,
	parentType BOOL, 			/* immutable */
	host VARCHAR NOT NULL,		/* mutable */
	parent VARCHAR NOT NULL,	/* immutable */
	position INTEGER NOT NULL,	/* immutable */
	companion VARCHAR,			/* immutable */
	password VARCHAR			/* mutable, default NULL */
)]])