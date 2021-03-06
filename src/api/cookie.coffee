###
Copyright (c) 2014, Groupon, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of GROUPON nor the names of its contributors may be
used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
###

{tryParse} = require './json'
{truthy, hasType} = require 'assertive'

decode = (value) ->
  (new Buffer value, 'base64').toString('utf8')

parseTestiumCookie = (cookie) ->
  value = decode(cookie.value)
  tryParse(value)

getCookie = (cookies, name) ->
  foundCookie = null

  #CSR doesn't allow for-in with return, yet
  for cookie in cookies
    if cookie.name == name
      foundCookie = cookie

  foundCookie

getTestiumCookie = (cookies) ->
  testiumCookie = getCookie(cookies, '_testium_')

  if !testiumCookie?
    throw new Error 'Unable to communicate with internal proxy. Make sure you are using relative paths.'

  parseTestiumCookie(testiumCookie)

removeTestiumCookie = (cookies) ->
  cookies.filter (item) ->
    item.name != '_testium_'

validateCookie = (invocation, cookie) ->
  hasType "#{invocation} - cookie must be an object", Object, cookie
  if !cookie.name
    throw new Error "#{invocation} - cookie must contain `name`"
  if !cookie.value
    throw new Error "#{invocation} - cookie must contain `value`"

module.exports = (driver) ->
  setCookie: (cookie) ->
    validateCookie 'setCookie(cookie)', cookie

    driver.setCookie(cookie)

  setCookies: (cookies) ->
    for cookie in cookies
      @setCookie(cookie)

  getCookie: (name) ->
    hasType 'getCookie(name) - requires (String) name', String, name

    cookies = driver.getCookies()
    getCookie(cookies, name)

  getCookies: ->
    removeTestiumCookie driver.getCookies()

  clearCookies: ->
    driver.clearCookies()

  getStatusCode: ->
    cookies = driver.getCookies()
    testiumCookie = getTestiumCookie(cookies)
    testiumCookie?.statusCode

  getHeaders: ->
    cookies = driver.getCookies()
    testiumCookie = getTestiumCookie(cookies)
    testiumCookie?.headers

  getHeader: (name) ->
    hasType 'getHeader(name) - require (String) name', String, name
    @getHeaders()[name]

