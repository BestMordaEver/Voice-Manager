local sqlite = require "sqlite3"

local guildsData = sqlite.open("guildsData.db")
local lobbiesData = sqlite.open("lobbiesData.db")
local channelsData = sqlite.open("channelsData.db")

guildsData:exec("PRAGMA journal_mode=WAL")
lobbiesData:exec("PRAGMA journal_mode=WAL")
channelsData:exec("PRAGMA journal_mode=WAL")

guildsData:exec([[
CREATE TABLE IF NOT EXISTS guilds(
	id VARCHAR PRIMARY KEY,
	cLimit INTEGER DEFAULT 500,
	permissions INTEGER DEFAULT 0,
	logTimeOffset INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS roles(
	id VARCHAR,
	guildID VARCHAR NOT NULL,
	FOREIGN KEY(guildID) REFERENCES guilds(id)
);

CREATE INDEX IF NOT EXISTS idx_roles_guildID ON roles(guildID)
]])

pcall(function () guildsData:exec("ALTER TABLE guilds ADD COLUMN logTimeOffset INTEGER DEFAULT 0") end)

lobbiesData:exec([[
CREATE TABLE IF NOT EXISTS lobbies(
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
	region VARCHAR,
	gaps BOOL DEFAULT 0,
	position VARCHAR DEFAULT 'below',
	cOrder VARCHAR DEFAULT 'descending',
	greeting VARCHAR,
	companionLog VARCHAR
);

CREATE TABLE IF NOT EXISTS roles(
	id VARCHAR,
	lobbyID VARCHAR NOT NULL,
	FOREIGN KEY(lobbyID) REFERENCES lobbies(id)
);

CREATE INDEX IF NOT EXISTS idx_roles_lobbyID ON roles(lobbyID)
]])

channelsData:exec([[
CREATE TABLE IF NOT EXISTS channels(
	id VARCHAR PRIMARY KEY,
	parentType BOOL,
	host VARCHAR NOT NULL,
	parent VARCHAR NOT NULL,
	position INTEGER NOT NULL,
	companion VARCHAR,
	password VARCHAR
);

CREATE TABLE IF NOT EXISTS subscribers(
	channelID VARCHAR NOT NULL,
	userID VARCHAR NOT NULL,
	PRIMARY KEY(channelID, userID),
	FOREIGN KEY(channelID) REFERENCES channels(id)
);

CREATE INDEX IF NOT EXISTS idx_subscribers_channelID ON subscribers(channelID);
CREATE INDEX IF NOT EXISTS idx_subscribers_userID ON subscribers(userID)
]])