# Let's just use the local mongod instance. Edit as needed.

# Please note that MONGO_HOST and MONGO_PORT could very well be left
# out as they already default to a bare bones local 'mongod' instance.
MONGO_HOST = 'localhost'
MONGO_PORT = 27017

# Skip these if your db has no auth. But it really should.
# MONGO_USERNAME = '<your username>'
# MONGO_PASSWORD = '<your password>'
# MONGO_AUTH_SOURCE = 'admin'  # needed if --auth mode is enabled

MONGO_DBNAME = 'fx'

news_schema = {
    # Schema definition, based on Cerberus grammar. Check the Cerberus project
    # (https://github.com/pyeve/cerberus) for details.
    'key': {
        'type': 'string',
    },
    'country': {
        'type': 'string',
    },
    'title': {
        'type': 'string',
    },
    'impact': {
        'type': 'string',
    },
    'previous': {
        'type': 'string',
    },
}

news = {
    'item_title': 'event',
    'schema': news_schema
}

cots_schema = {
    # Schema definition, based on Cerberus grammar. Check the Cerberus project
    # (https://github.com/pyeve/cerberus) for details.
    'key': {
        'type': 'string',
    },
    'Dealer_Positions_Long_All': {
        'type': 'string',
    }
}

cots = {
    'item_title': 'cot',
    'schema': cots_schema
}

DOMAIN = {
    'news': news,
    'cots': cots,
}
