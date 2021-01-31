local sqlite = require "sqlite3"

local guildsData = sqlite.open("guildsData.db")
local lobbiesData = sqlite.open("lobbiesData.db")
local channelsData = sqlite.open("channelsData.db")

guildsData:exec([[
CREATE TABLE guilds(
	id VARCHAR PRIMARY KEY,
	role VARCHAR,	/* mutable, default NULL */
	cLimit INTEGER NOT NULL,	/* mutable, default 500 */
	permissions INTEGER NOT NULL,	/* mutable, default 0 */
	prefix VARCHAR NOT NULL	/* mutable, default vm! */
)]])

lobbiesData:exec([[
CREATE TABLE lobbies(
	id VARCHAR PRIMARY KEY,
	isMatchmaking BOOL NOT NULL,	/* mutable, default FALSE */
	template VARCHAR,	/* mutable, default NULL */
	companionTemplate VARCHAR,	/* mutable, default NULL */
	target VARCHAR,	/* mutable, default NULL */
	companionTarget VARCHAR,	/* mutable, default NULL */
	role VARCHAR,	/* mutable, default NULL */
	permissions INTEGER NOT NULL,	/* mutable, default 0 */
	capacity INTEGER	/* mutable, default NULL */
)]])

channelsData:exec([[
CREATE TABLE channels(
	id VARCHAR PRIMARY KEY,
	isPersistent BOOL NOT NULL, /* immutable */
	host VARCHAR NOT NULL,	/* mutable */
	parent VARCHAR NOT NULL,	/* immutable */
	position INTEGER NOT NULL,	/* immutable */
	companion VARCHAR	/* immutable */
)]])