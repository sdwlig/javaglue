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
	xmlns:xd="http://www.pnp-software.com/XSLTdoc"
	xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl"
	xmlns:xbig="http://xbig.sourceforge.net/XBiG">

	<xsl:import href="cppNamespace.xslt" />
	<xsl:import href="../meta2java/javaUtil.xslt" />
	<!--<xsl:import href="cppGlobals.xslt" />
	<xsl:import href="cppEnum.xslt" />-->

	<!-- gives a great performance boost -->
	<xsl:strip-space elements="*"/>

	<xd:doc type="stylesheet">
		<xd:author>Frank Bielig</xd:author>
		<xd:author>Christoph Nenning</xd:author>
		<xd:copyright>OneStepAhead AG</xd:copyright>
		<xd:copyright>netAllied GmbH</xd:copyright>
		<xd:short>Transforms the meta layer to C++ (JNI)</xd:short>
		<xd:detail>
			This Stylesheet generates the JNI functions to access the
			existing C++ library.
		</xd:detail>
	</xd:doc>

	<xsl:output method="text" name="textOutput" />

	<!-- global Parameters -->
	<xd:doc>config.xml file.</xd:doc>
	<xsl:param name="config" />
	<xd:doc>directory in which header files are generated.</xd:doc>
	<xsl:param name="include_dir" />
	<xd:doc>directory in which src files are generated.</xd:doc>
	<xsl:param name="lib_dir" />
	<xd:doc>
		ignore_list.xml file. Contains full names of types that are
		known to cause compile errors and that are not needed in java.
	</xd:doc>
	<xsl:param name="ignore_list" />

	<!-- local variables -->


	<!-- global variables -->
	<!-- it seems there is a bug in saxon when trying to select root in javaType.xslt or in some callers -->
	<xsl:variable name="root" select="/" />

	<!-- main transformation process for generating C++ -->
	<xsl:template match="/*[local-name() = 'meta']">

		<xsl:result-document href="" format="textOutput">

			<!-- iteration over all available namespaces -->
			<xsl:for-each select="namespace">

				<xsl:call-template name="cppNamespace">
					<xsl:with-param name="meta_ns_name"
							select="xbig:getJavaPackageName(@fullName, $config)" />
					<xsl:with-param name="include_dir"
						select="$include_dir" />
					<xsl:with-param name="lib_dir" select="$lib_dir" />
					<xsl:with-param name="config" select="$config" />
				</xsl:call-template>

			</xsl:for-each>


			<!-- global classes and structs -->
			<!--
			<xsl:for-each select="class">
				<xsl:call-template name="cppGlobals">
					<xsl:with-param name="meta_ns_name" select="''" />
					<xsl:with-param name="include_dir" select="$include_dir" />
					<xsl:with-param name="lib_dir" select="$lib_dir" />
					<xsl:with-param name="config" select="$config" />
				</xsl:call-template>
			</xsl:for-each>
			<xsl:for-each select="struct">
				<xsl:call-template name="cppGlobals">
					<xsl:with-param name="meta_ns_name" select="''" />
					<xsl:with-param name="include_dir" select="$include_dir" />
					<xsl:with-param name="lib_dir" select="$lib_dir" />
					<xsl:with-param name="config" select="$config" />
				</xsl:call-template>
			</xsl:for-each>
			-->


			<!-- global enums -->
			<!--
			<xsl:for-each select="enumeration">
				<xsl:call-template name="cppGlobals">
					<xsl:with-param name="meta_ns_name" select="''" />
					<xsl:with-param name="include_dir" select="$include_dir" />
					<xsl:with-param name="lib_dir" select="$lib_dir" />
					<xsl:with-param name="config" select="$config" />
				</xsl:call-template>
			</xsl:for-each>
			-->


			<xsl:text>done</xsl:text>
		</xsl:result-document>

	</xsl:template>

</xsl:stylesheet>

