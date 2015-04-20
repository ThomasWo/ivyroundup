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
  xmlns:ivyde="http://ant.apache.org/ivy/ivyde/ns/"
  version="1.0">

    <xsl:output encoding="UTF-8" method="xml" indent="no" media-type="text/xml"/>

    <xsl:variable name="browsebase" select="'https://github.com/archiecobbs/ivyroundup/blob/master/src/modules'"/>

    <xsl:param name="organisation"/>
    <xsl:param name="module"/>
    <xsl:param name="revision"/>

    <xsl:template match="/">
        <xsl:copy>
            <xsl:value-of select="'&#10;'"/>
            <!-- Add stylesheet reference -->
            <xsl:processing-instruction name="xml-stylesheet">type="text/xsl" href="../../../../xsl/ivy-doc.xsl"</xsl:processing-instruction>
            <xsl:value-of select="'&#10;'"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/ivy-module">

        <!-- Various style and consistency checks -->
        <xsl:if test="@version">
            <xsl:call-template name="error">
                <xsl:with-param name="msg" select="'&quot;version&quot; attribute is auto-populated; do not include'"/>
            </xsl:call-template>
        </xsl:if>

        <xsl:value-of select="'&#10;'"/>
        <xsl:comment> GENERATED FILE - DO NOT EDIT </xsl:comment>
        <xsl:value-of select="'&#10;'"/>
        <xsl:copy>
            <!-- Add version and xsi:noNamespaceSchemaLocation attributes -->
            <xsl:attribute name="version">2.0</xsl:attribute>
            <xsl:attribute name="xsi:noNamespaceSchemaLocation">../../../../xsd/ivy.xsd</xsl:attribute>
            <xsl:apply-templates select="@*[name() != 'rev' and name() != 'version' and local-name() != 'noNamespaceSchemaLocation']|node()"/>
        </xsl:copy>
        <xsl:value-of select="'&#10;'"/>
    </xsl:template>

    <xsl:template match="/ivy-module/info">

        <!-- Various style and consistency checks -->
        <xsl:if test="@organisation or @module or @revision">
            <xsl:call-template name="error">
                <xsl:with-param name="msg" select="'&quot;organisation&quot;, &quot;module&quot;, and &quot;revision&quot; are auto-populated; do not include'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="@status = 'release'">
            <xsl:call-template name="error">
                <xsl:with-param name="msg" select="'status=&quot;release&quot; is the default; do not include'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="translate(@publication, '0123456789', '0000000000') != '00000000000000'">
            <xsl:call-template name="error">
                <xsl:with-param name="msg" select="'valid 14-digit &quot;publication&quot; attribute is required in &lt;info&gt; tag'"/>
            </xsl:call-template>
        </xsl:if>

        <xsl:copy>
            <!-- Auto-insert organisation, module, and revision attributes -->
            <xsl:attribute name="organisation">
                <xsl:value-of select="$organisation"/>
            </xsl:attribute>
            <xsl:attribute name="module">
                <xsl:value-of select="$module"/>
            </xsl:attribute>
            <xsl:attribute name="revision">
                <xsl:value-of select="$revision"/>
            </xsl:attribute>
            <xsl:if test="not(@status)">
                <xsl:attribute name="status">release</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@*"/>
            <xsl:value-of select="'&#10;        '"/>
            <xsl:if test="license">
<!-- This is too strict:
                <xsl:if test="not(@url)">
                    <xsl:call-template name="error">
                        <xsl:with-param name="msg" select="'&lt;license&gt; element has no &quot;url&quot; attribute'"/>
                    </xsl:call-template>
                </xsl:if>
-->
                <xsl:apply-templates select="license"/>
                <xsl:value-of select="'&#10;        '"/>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="ivyauthor">
                    <xsl:apply-templates select="ivyauthor"/>
                    <xsl:value-of select="'&#10;        '"/>
                </xsl:when>
                <xsl:otherwise>
                    <ivyauthor name="Ivy RoundUp Repository">
                        <xsl:attribute name="url">
                            <xsl:value-of select="concat($browsebase, '/', $organisation, '/', $module, '/', $revision, '/')"/>
                        </xsl:attribute>
                    </ivyauthor>
                    <xsl:value-of select="'&#10;        '"/>
                </xsl:otherwise>
            </xsl:choose>

            <!-- Add <repository> tag pointing to Ivy RoundUp -->
            <repository name="ivyroundup" url="https://github.com/archiecobbs/ivyroundup" ivys="true"
              pattern="https://raw.githubusercontent.com/archiecobbs/ivyroundup/master/repo/modules/[organisation]/[module]/[revision]/ivy.xml"/>
            <xsl:value-of select="'&#10;        '"/>
            <xsl:apply-templates select="description"/>
            <xsl:value-of select="'&#10;    '"/>
        </xsl:copy>
    </xsl:template>

    <!-- Check descriptions -->
    <xsl:template match="/ivy-module/info/description">
        <xsl:if test="not(@homepage)">
            <xsl:call-template name="error">
                <xsl:with-param name="msg" select="'&lt;description&gt; element has no &quot;homepage&quot; attribute'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="@homepage = 'http://www.example.com/'">
            <xsl:call-template name="error">
                <xsl:with-param name="msg" select="concat('&quot;homepage&quot; attribute still contains default URL &quot;', @homepage, '&quot;')"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/ivy-module/publications/artifact[not(@type) or @type = 'jar']">
        <xsl:copy>

            <!-- Get this JAR artifact's name -->
            <xsl:variable name="name">
                <xsl:call-template name="get-artifact-name"/>
            </xsl:variable>

            <!-- Try to map it to a source artifact -->
            <xsl:if test="not(@ivyde:source)">
                <xsl:variable name="sources" select="../artifact[@type = 'source']"/>
                <xsl:choose>
                    <xsl:when test="count($sources) = 1">
                        <xsl:attribute name="ivyde:source">
                            <xsl:call-template name="get-artifact-name">
                                <xsl:with-param name="artifact" select="$sources[1]"/>
                            </xsl:call-template>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:when test="$sources[@name = $name]">
                        <xsl:attribute name="ivyde:source">
                            <xsl:call-template name="get-artifact-name">
                                <xsl:with-param name="artifact" select="$sources[@name = $name][1]"/>
                            </xsl:call-template>
                        </xsl:attribute>
                    </xsl:when>
                </xsl:choose>
            </xsl:if>

            <!-- Try to map it to a source artifact -->
            <xsl:if test="not(@ivyde:javadoc)">
                <xsl:variable name="javadocs" select="../artifact[@type = 'javadoc']"/>
                <xsl:choose>
                    <xsl:when test="count($javadocs) = 1">
                        <xsl:attribute name="ivyde:javadoc">
                            <xsl:call-template name="get-artifact-name">
                                <xsl:with-param name="artifact" select="$javadocs[1]"/>
                            </xsl:call-template>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:when test="$javadocs[@name = $name]">
                        <xsl:attribute name="ivyde:javadoc">
                            <xsl:call-template name="get-artifact-name">
                                <xsl:with-param name="artifact" select="$javadocs[@name = $name][1]"/>
                            </xsl:call-template>
                        </xsl:attribute>
                    </xsl:when>
                </xsl:choose>
            </xsl:if>

            <!-- Proceed -->
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/ivy-module/configurations">
        <!-- Various style and consistency checks -->
        <xsl:if test="count(conf) = 0">
            <xsl:call-template name="error">
                <xsl:with-param name="msg" select="'empty &lt;configurations&gt; tag'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="not(conf[@name = 'default'])">
            <xsl:call-template name="error">
                <xsl:with-param name="msg" select="'no &quot;default&quot; &lt;configuration&gt; defined'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/ivy-module/configurations/configuration">
        <!-- Various style and consistency checks -->
        <xsl:if test="@name != 'default' and not(@description)">
            <xsl:call-template name="error">
                <xsl:with-param name="msg" select="'non-default &lt;configuration&gt; tags must have &quot;description&quot; attributes'"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template match="/ivy-module/dependencies">
        <!-- Various style and consistency checks -->
        <xsl:if test="count(dependency) = 0">
            <xsl:call-template name="error">
                <xsl:with-param name="msg" select="'empty &lt;dependencies&gt; tag'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/ivy-module/dependencies/dependency">
        <!-- Various style and consistency checks -->
        <xsl:if test="not(@org) or not(@name) or not(@rev) or not(@conf)">
            <xsl:call-template name="error">
                <xsl:with-param name="msg" select="'&quot;org&quot;, &quot;name&quot;, &quot;rev&quot;, and &quot;conf&quot; attributes are required in &lt;dependency&gt; tags'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="not(contains(@conf, '-&gt;'))">
            <xsl:call-template name="error">
                <xsl:with-param name="msg" select="'&quot;conf&quot; attribute does not specify source configuration(s)'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="contains(@conf, '-&gt;*')">
            <xsl:call-template name="error">
                <xsl:with-param name="msg" select="'&quot;conf&quot; attribute has &quot;*&quot; target configuration'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Check comments -->
    <xsl:template match="comment()" priority="1">

        <!-- Detect "YOUR NAME HERE" -->
        <xsl:if test="contains(., 'YOUR NAME HERE')">
            <xsl:call-template name="error">
                <xsl:with-param name="msg" select="'put your own name in the copyright message'"/>
            </xsl:call-template>
        </xsl:if>

        <!-- Warn about "XXX" and "TODO" markers -->
        <xsl:if test="contains(., 'XXX') or contains(., 'TODO')">
            <xsl:call-template name="warning">
                <xsl:with-param name="msg" select="'comment with &quot;XXX&quot; and/or &quot;TODO&quot; marker found'"/>
            </xsl:call-template>
        </xsl:if>

        <xsl:copy/>
    </xsl:template>

    <!-- Copy everything else exactly -->
    <xsl:template match="@*|node()">

        <!-- Avoid tab characters -->
        <xsl:if test="contains(., '&#9;')">
            <xsl:call-template name="error">
                <xsl:with-param name="msg" select="'file contains tab characters; expand to spaces'"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Get artifact name -->
    <xsl:template name="get-artifact-name">
        <xsl:param name="artifact" select="."/>
        <xsl:choose>
            <xsl:when test="$artifact/@name">
                <xsl:value-of select="$artifact/@name"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$module"/>
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
            <xsl:value-of select="concat('&#10;*** ', $kind, ': ', $organisation, '/', $module, '/', $revision, '/ivy.xml: ', $msg)"/>
            <xsl:if test="$kind = 'ERROR'">&#10;**********************************************************************************</xsl:if>
        </xsl:message>
    </xsl:template>

</xsl:transform>
