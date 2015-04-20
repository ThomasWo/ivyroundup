<?xml version="1.0" encoding="ISO-8859-1"?>

<!--
    Copyright 2008 Archie L. Cobbs.

    Licensed under the Apache License, Version 2.0 (the "License"); you may
    not use this file except in compliance with the License. You may obtain
    a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
    License for the specific language governing permissions and limitations
    under the License.
-->

<xsl:transform
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  version="1.0">

    <xsl:output encoding="UTF-8" method="xml" indent="yes" media-type="text/xml"/>

    <xsl:param name="organisation"/>
    <xsl:param name="module"/>
    <xsl:param name="revision"/>

    <xsl:template match="/">
        <xsl:copy>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/packager-module">
        <xsl:value-of select="'&#10;'"/>
        <xsl:comment> GENERATED FILE - DO NOT EDIT </xsl:comment>
        <xsl:value-of select="'&#10;'"/>
        <xsl:copy>
            <!-- Add version and xsi:noNamespaceSchemaLocation attributes -->
            <xsl:attribute name="version">1.0</xsl:attribute>
            <xsl:attribute name="xsi:noNamespaceSchemaLocation">../../../../xsd/packager-1.0.xsd</xsl:attribute>
            <xsl:apply-templates select="@*[name() != 'rev']|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Detect "YOUR NAME HERE" -->
    <xsl:template match="comment()[contains(., 'YOUR NAME HERE')]">
        <xsl:call-template name="error">
            <xsl:with-param name="msg" select="'you need to put your own name in the copyright message'"/>
        </xsl:call-template>
    </xsl:template>

    <!-- Detect use of ${version} ant property (see issue #14) -->
    <xsl:template match="property[@name = 'version']">
        <xsl:call-template name="error">
            <xsl:with-param name="msg" select="'avoid the ${version} ant property; see https://github.com/archiecobbs/ivyroundup/issues/14 for details'"/>
        </xsl:call-template>
    </xsl:template>

    <!-- Detect redundant Maven stuff -->
    <xsl:template match="m2resource[@groupId or @artifactId or @repo]">

        <!-- Check groupId -->
        <xsl:variable name="implicitGroupId">
            <xsl:call-template name="slash2dot">
                <xsl:with-param name="s" select="$organisation"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="groupIdWithDots">
            <xsl:call-template name="slash2dot">
                <xsl:with-param name="s" select="@groupId"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:if test="$implicitGroupId = $groupIdWithDots or @groupId = '${ivy.packager.organisation}'">
            <xsl:call-template name="error">
                <xsl:with-param name="msg" select="concat('redundant groupId attribute &quot;', @groupId, '&quot; (implied by organisation name)')"/>
            </xsl:call-template>
        </xsl:if>

        <!-- Check artifactId -->
        <xsl:if test="@artifactId = $module or @artifactId = '${ivy.packager.module}'">
            <xsl:call-template name="error">
                <xsl:with-param name="msg" select="concat('redundant artifactId attribute &quot;', @artifactId, '&quot; (implied by module name)')"/>
            </xsl:call-template>
        </xsl:if>

        <!-- Check version -->
        <xsl:if test="@version = $revision or @version = '${ivy.packager.revision}'">
            <xsl:call-template name="error">
                <xsl:with-param name="msg" select="concat('redundant version attribute &quot;', @version, '&quot; (implied by module revision)')"/>
            </xsl:call-template>
        </xsl:if>

        <!-- Check repository -->
        <xsl:if test="@repo = 'http://repo1.maven.org/maven2/'">
            <xsl:call-template name="error">
                <xsl:with-param name="msg" select="concat('redundant maven repository &quot;', @repo, '&quot;')"/>
            </xsl:call-template>
        </xsl:if>

        <!-- OK, proceed -->
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Copy everything else exactly -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Convert slashes to dots -->
    <xsl:template name="slash2dot">
        <xsl:param name="s"/>
        <xsl:choose>
            <xsl:when test="contains($s, '/')">
                <xsl:value-of select="concat(substring-before($s, '/'), '.')"/>
                <xsl:call-template name="slash2dot">
                    <xsl:with-param name="s" select="substring-after($s, '/')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$s"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Warning and error templates -->
    <xsl:template name="error">
        <xsl:param name="msg"/>
        <xsl:call-template name="message">
            <xsl:with-param name="msg" select="$msg"/>
            <xsl:with-param name="kind" select="'ERROR'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="warning">
        <xsl:param name="msg"/>
        <xsl:call-template name="message">
            <xsl:with-param name="msg" select="$msg"/>
            <xsl:with-param name="kind" select="'WARNING'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="message">
        <xsl:param name="msg"/>
        <xsl:param name="kind"/>
        <xsl:message>
            <xsl:if test="$kind = 'ERROR'">&#10;**********************************************************************************</xsl:if>
            <xsl:value-of select="concat('&#10;*** ', $kind, ': ', $organisation, '/', $module, '/', $revision, '/packager.xml: ', $msg)"/>
            <xsl:if test="$kind = 'ERROR'">&#10;**********************************************************************************</xsl:if>
        </xsl:message>
    </xsl:template>

</xsl:transform>
