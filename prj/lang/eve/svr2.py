# -*- coding: utf-8 -*-
from eve import Eve

app = Eve(settings='svr2_settings.py')

if __name__ == '__main__':
    app.run(port=5002)
