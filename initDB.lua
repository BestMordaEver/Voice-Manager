local sqlite = require "sqlite3"

local guildsData = sqlite.open("guildsData.db")
local lobbiesData = sqlite.open("lobbiesData.db")
local channelsData = sqlite.open("channelsData.db")

guildsData:exec([[
CREATE TABLE guilds(
	id VARCHAR PRIMARY KEY,
	cLimit INTEGER DEFAULT 500,
	permissions INTEGER DEFAULT 0
);

CREATE TABLE roles(
	id VARCHAR,
	guildID VARCHAR NOT NULL,
	FOREIGN KEY(guildID) REFERENCES guilds(id)
)]])

lobbiesData:exec([[
CREATE TABLE lobbies(
	id VARCHAR PRIMARY KEY,
	guild VARCHAR NOT NULL,
	isMatchmaking BOOL DEFAULT 0,
	template VARCHAR,
	companionTemplate VARCHAR,
	target VARCHAR,
	companionTarget VARCHAR,
	cLimit INTEGER DEFAULT 500,
	permissions INTEGER DEFAULT 0,
	capacity INTEGER,
	bitrate INTEGER,
	region VARCHAR
	greeting VARCHAR,
	companionLog VARCHAR
);

CREATE TABLE roles(
	id VARCHAR,
	lobbyID VARCHAR NOT NULL,
	FOREIGN KEY(lobbyID) REFERENCES lobbies(id)
)]])

channelsData:exec([[
CREATE TABLE channels(
	id VARCHAR PRIMARY KEY,
	parentType BOOL,
	host VARCHAR NOT NULL,
	parent VARCHAR NOT NULL,
	position INTEGER NOT NULL,
	companion VARCHAR,
	password VARCHAR
)]])