#------------------------------------------------------------------------------
# Copyright (c) 2020, 2024, Oracle and/or its affiliates.
#
# This software is dual-licensed to you under the Universal Permissive License
# (UPL) 1.0 as shown at https://oss.oracle.com/licenses/upl and Apache License
# 2.0 as shown at http://www.apache.org/licenses/LICENSE-2.0. You may choose
# either license.
#
# If you elect to accept the software under the Apache License, Version 2.0,
# the following applies:
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# base_impl.pyx
#
# Cython file for the base implementation that the thin and thick
# implementations use.
#------------------------------------------------------------------------------

# cython: language_level=3

cimport cython
cimport cpython
cimport cpython.datetime as cydatetime

from libc.stdint cimport int8_t, int16_t, int32_t, int64_t
from libc.stdint cimport uint8_t, uint16_t, uint32_t, uint64_t
from libc.stdint cimport UINT8_MAX, UINT16_MAX, UINT32_MAX, UINT64_MAX
from libc.string cimport memcpy
from cpython cimport array

import array

import base64
import datetime
import decimal
import inspect
import json
import os
import random
import re
import secrets
import ssl
import sys
import codecs

cydatetime.import_datetime()

include "impl/base/types.pyx"

# Python types used by the driver
cdef type PY_TYPE_ASYNC_CURSOR
cdef type PY_TYPE_ASYNC_LOB
cdef type PY_TYPE_BOOL = bool
cdef type PY_TYPE_CURSOR
cdef type PY_TYPE_DATE = datetime.date
cdef type PY_TYPE_DATETIME = datetime.datetime
cdef type PY_TYPE_DECIMAL = decimal.Decimal
cdef type PY_TYPE_DB_OBJECT
cdef type PY_TYPE_DB_OBJECT_TYPE
cdef type PY_TYPE_JSON_ID
cdef type PY_TYPE_INTERVAL_YM
cdef type PY_TYPE_LOB
cdef type PY_TYPE_TIMEDELTA = datetime.timedelta
cdef type PY_TYPE_VAR
cdef type PY_TYPE_FETCHINFO

cdef const char* DRIVER_NAME = "python-oracledb"
cdef const char* DRIVER_VERSION
cdef const char* DRIVER_INSTALLATION_URL = \
        "https://python-oracledb.readthedocs.io/en/" \
        "latest/user_guide/initialization.html"

cdef str CS_ENCODING_UTF8 = "UTF-8"
cdef str CS_ENCODING_UTF16 = "UTF-16BE"

cdef int get_preferred_num_type(int16_t precision, int8_t scale):
    if scale == 0 or (scale == -127 and precision == 0):
        return NUM_TYPE_INT
    return NUM_TYPE_FLOAT

charset_map = {'ascii': 1,
               'cp437': 4,
               'cp037': 5,
               'cp500': 6,
               'cp1140': 7,
               'cp850': 10,
               'iso8859-1': 31,
               'iso8859-2': 32,
               'iso8859-3': 33,
               'iso8859-4': 34,
               'iso8859-5': 35,
               'iso8859-6': 36,
               'iso8859-7': 37,
               'iso8859-8': 38,
               'iso8859-9': 39,
               'iso8859-10': 40,
               'tis-620': 41,
               'cp1258': 45,
               'iso8859-15': 46,
               'iso8859-13': 47,
               'iso8859-14': 48,
               'koi8-u': 51,
               'cp424': 92,
               'cp1026': 93,
               'cp852': 150,
               'cp866': 152,
               'cp862': 154,
               'cp855': 155,
               'cp857': 156,
               'cp860': 160,
               'cp861': 161,
               'cp1250': 170,
               'cp1251': 171,
               'cp1253': 174,
               'cp1255': 175,
               'cp1254': 177,
               'cp1252': 178,
               'cp1257': 179,
               'cp273': 180,
               'cp865': 190,
               'koi8-r': 196,
               'cp775': 197,
               'hp-roman8': 261,
               'mac-roman': 351,
               'cp869': 385,
               'cp863': 390,
               'cp1256': 560,
               'euc_jp': 830,
               'shift_jis': 832,
               'euc_kr': 846,
               'gbk': 852,
               'gb18030': 854,
               'big5': 867,
               'big5hkscs': 868,
               'utf-8': 873,
               'utf-16be': 2000,}

cdef str ENCODING = "UTF-8"
cdef str ENCODING_ERRORS = "strict"
cdef int CHARSET_ID = 873

def set_encoding(encoding, errors = "strict"):
    global ENCODING, ENCODING_ERRORS, CHARSET_ID
    info = codecs.lookup(encoding)
    ENCODING = encoding
    CHARSET_ID = charset_map[info.name]
    if errors in ("strict", "ignore", "replace"):
        ENCODING_ERRORS = errors

def get_encoding():
    return ENCODING

def get_encoding_errors():
    return ENCODING_ERRORS

def get_charset_id():
    return CHARSET_ID

include "impl/base/constants.pxi"
include "impl/base/defaults.pyx"
include "impl/base/utils.pyx"
include "impl/base/buffer.pyx"
include "impl/base/oson.pyx"
include "impl/base/vector.pyx"
include "impl/base/connect_params.pyx"
include "impl/base/pool_params.pyx"
include "impl/base/connection.pyx"
include "impl/base/pool.pyx"
include "impl/base/cursor.pyx"
include "impl/base/var.pyx"
include "impl/base/bind_var.pyx"
include "impl/base/dbobject.pyx"
include "impl/base/lob.pyx"
include "impl/base/soda.pyx"
include "impl/base/queue.pyx"
include "impl/base/subscr.pyx"
