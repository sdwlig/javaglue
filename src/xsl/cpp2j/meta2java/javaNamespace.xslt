<?xml version="1.0" encoding="UTF-8"?>

<!--
	
  This source file is part of XBiG
  (XSLT Bindings Generator)
  For the latest info, see http://sourceforge.net/projects/javaglue
  
  Copyright (c) 2006 The XBiG Development Team
  Also see acknowledgements in Readme.html
  
  This program is free software; you can redistribute it and/or modify it under
  the terms of the GNU Lesser General Public License as published by the Free Software
  Foundation; either version 2 of the License, or (at your option) any later
  version.
  
  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
  
  You should have received a copy of the GNU Lesser General Public License along with
  this program; if not, write to the Free Software Foundation, Inc., 59 Temple
  Place - Suite 330, Boston, MA 02111-1307, USA, or go to
  http://www.gnu.org/copyleft/lesser.txt.
  
  Author: Frank Bielig
  Christoph Nenning
  
-->

<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
  xmlns:xd="http://www.pnp-software.com/XSLTdoc"
  xmlns:xbig="http://xbig.sourceforge.net/XBiG">

  <xsl:import href="javaClassFileStub.xslt" />
  <xsl:import href="../../util/createClassFromTemplateTypedef.xslt" />

  <xd:doc type="stylesheet">
    <xd:short>Handling of meta namespace elements.</xd:short>
  </xd:doc>

  <xd:doc type="template">
    <xd:short>
      Creates java package directories and calls templates for classes,
      enums, ... .
    </xd:short>
    <xd:param name="meta_ns_name">
      parent namespace in meta.xml.
    </xd:param>
    <xd:param name="outdir">
      Directory in which java code is generated.
    </xd:param>
    <xd:param name="config">config file.</xd:param>
    <xd:param name="buildFile">
      ant build.xml file. Needed for project name in static initializer.
      Passed to called templates.
    </xd:param>
    <xd:param name="libName">
      Name of library. Needed for project name in static initializer.
      Passed to called templates.
    </xd:param>
  </xd:doc>
  <xsl:template name="javaNamespace">
    <xsl:param name="meta_ns_name" />
    <xsl:param name="outdir" />
    <xsl:param name="config" />
    <xsl:param name="buildFile" />
    <xsl:param name="libName" />

    <!-- iterate over child namespaces -->
    <xsl:for-each select="namespace">
      <xsl:call-template name="javaNamespace">
        <xsl:with-param name="meta_ns_name" select="xbig:getJavaPackageName(@fullName, $config)" />
        <xsl:with-param name="outdir" select="$outdir" />
        <xsl:with-param name="config" select="$config" />
        <xsl:with-param name="buildFile" select="$buildFile" />
        <xsl:with-param name="libName" select="$libName" />
      </xsl:call-template>
    </xsl:for-each>

    <!-- extract Java namespace from configuration -->
    <!-- <xsl:variable name="java_ns_name"
      select="$config/config/java/namespaces/namespace[@name=$meta_ns_name]" /> -->
    <xsl:variable name="java_ns_name">
      <xsl:choose>
        <xsl:when test="not($meta_ns_name) or $meta_ns_name = ''">
          <xsl:value-of
            select="$config/config/java/namespaces/packageprefix/text()" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of
            select="concat($config/config/java/namespaces/packageprefix/text(),
						   '.', replace($meta_ns_name,'::', '.'))" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- if no mapping in Java configuration vailable -->
    <xsl:if test="empty($java_ns_name)">
      <xsl:message terminate="yes">
        ERROR: no package name for
        <xsl:value-of select="$meta_ns_name" />
      </xsl:message>
    </xsl:if>

    <!-- transform Java namespace to directory name -->
    <xsl:variable name="java_ns_dir"
      select="replace($java_ns_name,'\.', '/')" />


    <!-- iteration over all classes inside current namespace -->
    <xsl:for-each select="class">
      <xsl:call-template name="javaClassFileStub">
        <xsl:with-param name="java_ns_dir" select="$java_ns_dir" />
        <xsl:with-param name="java_ns_name" select="$java_ns_name" />
        <xsl:with-param name="outdir" select="$outdir" />
        <xsl:with-param name="config" select="$config" />
        <xsl:with-param name="buildFile" select="$buildFile" />
        <xsl:with-param name="libName" select="$libName" />
      </xsl:call-template>
    </xsl:for-each>
    <xsl:for-each select="struct">
      <xsl:call-template name="javaClassFileStub">
        <xsl:with-param name="java_ns_dir" select="$java_ns_dir" />
        <xsl:with-param name="java_ns_name" select="$java_ns_name" />
        <xsl:with-param name="outdir" select="$outdir" />
        <xsl:with-param name="config" select="$config" />
        <xsl:with-param name="buildFile" select="$buildFile" />
        <xsl:with-param name="libName" select="$libName" />
      </xsl:call-template>
    </xsl:for-each>

    <!-- iteration over all enums inside current namespace -->
    <xsl:for-each select="enumeration">
      <xsl:call-template name="javaClassFileStub">
        <xsl:with-param name="java_ns_dir" select="$java_ns_dir" />
        <xsl:with-param name="java_ns_name" select="$java_ns_name" />
        <xsl:with-param name="outdir" select="$outdir" />
        <xsl:with-param name="config" select="$config" />
        <xsl:with-param name="buildFile" select="$buildFile" />
        <xsl:with-param name="libName" select="$libName" />
      </xsl:call-template>
    </xsl:for-each>

    <!-- check if we have to generate a class for a typedef -->
    <xsl:for-each select="typedef">
      <xsl:if test="contains(./@basetype, '&lt;')">
        <xsl:variable name="templateBaseName"
          select="normalize-space(substring-before(./@basetype, '&lt;'))" />
        <xsl:variable name="fullTemplateBaseName"
          select="xbig:getFullTypeName($templateBaseName, ., $root)" />
        <xsl:variable name="templateNode"
          select="$root//*[@fullName = $fullTemplateBaseName]" />
        <xsl:variable name="generatedClass">
          <xsl:call-template name="createClassFromTemplateTypedef">
            <xsl:with-param name="template" select="$templateNode" />
            <xsl:with-param name="typedef" select="." />
            <xsl:with-param name="isInnerClass" select="false()" />
          </xsl:call-template>
        </xsl:variable>

        <!-- generate the class -->
        <xsl:for-each select="$generatedClass/*">
          <xsl:call-template name="javaClassFileStub">
            <xsl:with-param name="java_ns_dir" select="$java_ns_dir" />
            <xsl:with-param name="java_ns_name" select="$java_ns_name" />
            <xsl:with-param name="outdir" select="$outdir" />
            <xsl:with-param name="config" select="$config" />
            <xsl:with-param name="buildFile" select="$buildFile" />
	    <xsl:with-param name="libName" select="$libName" />
          </xsl:call-template>
        </xsl:for-each>
      </xsl:if>
    </xsl:for-each>

  </xsl:template>
</xsl:stylesheet>
