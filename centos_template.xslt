<?xml version="1.0"?>
<!--
  dirlist.xslt - transform nginx's into lighttpd look-alike dirlistings

  I'm currently switching over completely from lighttpd to nginx. If you come
  up with a prettier stylesheet or other improvements, please tell me :)

-->
<!--
   Copyright (c) 2016 by Moritz Wilhelmy <mw@barfooze.de>
   All rights reserved

   Redistribution and use in source and binary forms, with or without
   modification, are permitted providing that the following conditions
   are met:
   1. Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.

   THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
   IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
   WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
   ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
   DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
   DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
   OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
   STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
   IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
   POSSIBILITY OF SUCH DAMAGE.
-->
<!DOCTYPE fnord [<!ENTITY nbsp "&#160;">]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns="http://www.w3.org/1999/xhtml" xmlns:func="http://exslt.org/functions" version="1.0" exclude-result-prefixes="xhtml" extension-element-prefixes="func">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.1//EN" doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" indent="yes" media-type="application/xhtml+xml"/>
  <xsl:strip-space elements="*" />

  <xsl:template name="size">
    <!-- transform a size in bytes into a human readable representation -->
    <xsl:param name="bytes"/>
    <xsl:choose>
      <xsl:when test="$bytes &lt; 1000"><xsl:value-of select="$bytes" />B</xsl:when>
      <xsl:when test="$bytes &lt; 1048576"><xsl:value-of select="format-number($bytes div 1024, '0.0')" />K</xsl:when>
      <xsl:when test="$bytes &lt; 1073741824"><xsl:value-of select="format-number($bytes div 1048576, '0.0')" />M</xsl:when>
      <xsl:otherwise><xsl:value-of select="format-number(($bytes div 1073741824), '0.00')" />G</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="timestamp">
    <!-- transform an ISO 8601 timestamp into a human readable representation -->
    <xsl:param name="iso-timestamp" />
    <xsl:value-of select="concat(substring($iso-timestamp, 0, 11), ' ', substring($iso-timestamp, 12, 5))" />
  </xsl:template>

  <xsl:template match="directory">
    <tr>
      <td valign="top">
        <img src="/icons/folder.gif" alt="[DIR]" />
      </td>
      <td>
        <a href="{current()}/"><xsl:value-of select="."/>/</a>
      </td>
      <td align="right"><xsl:call-template name="timestamp"><xsl:with-param name="iso-timestamp" select="@mtime" /></xsl:call-template></td>
      <td align="right">  - </td><td>&nbsp;</td>
    </tr>
  </xsl:template>

  <xsl:template name="icon">
    <xsl:param name="path"/>
    <xsl:variable name="extension">
      <xsl:call-template name="get-file-extension">
        <xsl:with-param name="path" select="$path" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$extension = 'txt'">
        <img src="/icons/text.gif" alt="[TXT]" />
      </xsl:when>
      <xsl:when test="$extension = 'sh'">
        <img src="/icons/script.gif" alt="[DIR]" />
      </xsl:when>
      <xsl:when test="$extension = 'gz'">
        <img src="/icons/compressed.gif" alt="[   ]" />
      </xsl:when>
      <xsl:when test="$extension = 'zip'">
        <img src="/icons/compressed.gif" alt="[   ]" />
      </xsl:when>
      <xsl:otherwise>
        <img src="/icons/unknown.gif" alt="[   ]" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get-file-extension">
    <xsl:param name="path"/>
    <xsl:choose>
      <xsl:when test="contains($path, '/')">
        <xsl:call-template name="get-file-extension">
          <xsl:with-param name="path" select="substring-after($path, '/')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($path, '.')">
        <xsl:call-template name="get-file-extension">
          <xsl:with-param name="path" select="substring-after($path, '.')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$path"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="file">
    <tr>
      <td valign="top">
        <xsl:call-template name="icon"><xsl:with-param name="path" select="." /></xsl:call-template>
      </td>
      <td>
        <a href="{current()}"><xsl:value-of select="." /></a>
      </td>
      <td align="right"><xsl:call-template name="timestamp"><xsl:with-param name="iso-timestamp" select="@mtime" /></xsl:call-template></td>
      <td align="right"><xsl:call-template name="size"><xsl:with-param name="bytes" select="@size" /></xsl:call-template></td>
      <td>&nbsp;</td>
    </tr>
  </xsl:template>

  <xsl:template match="/">
    <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
        <title>CentOS Mirror</title>
        <link rel="stylesheet" type="text/css" charset="utf-8" media="screen" href="/CentOS/HEADER.images/screen.css" />
      </head>
      <body>
        <div id="header">
          <div id="logo">
            <a href="/"><img src="HEADER.images/modern-CentOS-logo.png" alt="CentOS" border="0" /></a>
          </div>
        </div>
        <table bgcolor="#e0d2e3" text="#5e5e5e" cellSpacing="0" cellPadding="0" width="100%" border="0" align="center">
          <tbody>
            <tr>
              <td vAlign="top">
                <table width="100%" border="0" cellspacing="0" cellpadding="0" height="25">
                  <tr>
                    <td valign="center">&nbsp;<font size="4" face="Verdana, Arial, Helvetica, sans-serif" color="#000000"><b>CentOS on the Web:  <a href="http://www.centos.org/">CentOS.org</a> | <a href="http://wiki.centos.org/GettingHelp/ListInfo">Mailing Lists</a> | <a href="http://www.centos.org/download/mirrors/">Mirror List</a> | <a href="http://wiki.centos.org/irc">IRC</a> | <a href="https://www.centos.org/forums/">Forums</a> | <a href="http://bugs.centos.org/">Bugs</a> | <a href="http://www.centos.org/sponsors/">Donate</a>  </b></font></td>\
                  </tr>
                </table>
              </td>
            </tr>
          </tbody>
        </table>
        <table>
          <tr><th valign="top"><img src="/icons/blank.gif" alt="[ICO]" /></th><th>Name</th><th>Last modified</th><th>Size</th><th>Description</th></tr>
          <tr><th colspan="5"><hr /></th></tr>
          <tr><td valign="top"><img src="/icons/back.gif" alt="[PARENTDIR]" /></td><td><a href="..">Parent Directory</a>       </td><td>&nbsp;</td><td align="right">  - </td><td>&nbsp;</td></tr>
          <xsl:apply-templates />
          <tr><th colspan="5"><hr /></th></tr>
        </table>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
