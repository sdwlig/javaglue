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

	<xsl:import href="../../util/metaTypeInfo.xslt" />

	<xd:doc type="stylesheet">
		<xd:short>Generate mapping of a single type</xd:short>
	</xd:doc>

	<xd:doc type="template">
		<xd:short>Generates JNI type for a meta type.
			That means basically jlong for classes and jint for enums.
		</xd:short>
		<xd:param name="config">config file.</xd:param>
		<xd:param name="param">parameter or function to process.</xd:param>
		<xd:param name="class">meta class which contains method.</xd:param>
	</xd:doc>
	<xsl:template name="jniType">
		<xsl:param name="config" />
		<xsl:param name="param" />
		<xsl:param name="class" />

		<!-- resolve typedefs -->
		<xsl:variable name="resolvedType">
			<xsl:choose>
				<!-- c-tors don't have a type -->
				<xsl:when test="not($param/type)">
					<xsl:value-of select="'long'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="xbig:resolveTypedef($param/type, $class, $root)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="type_info">
			<xsl:call-template name="metaExactTypeInfo">
				<xsl:with-param name="root"
					select="$config/config/cpp/jni/types" />
				<xsl:with-param name="param" select="$param" />
				<xsl:with-param name="typeName" select="$resolvedType" />
			</xsl:call-template>
		</xsl:variable>

		<!-- check if there is a type in config -->
		<xsl:choose>

			<!-- if no type info is found -> we are dealing with a class / enum / ... -->
			<xsl:when test="not($type_info/type/@jni)">

				<xsl:variable name="fullTypeName" select="$resolvedType"/>

				<xsl:choose>

					<!-- if this type is a parametrized template -->
					<xsl:when test="contains($fullTypeName, '&lt;')">
						<xsl:value-of select="'jlong'"/>
					</xsl:when>

					<!-- if this is a typedef for a template -->
					<xsl:when test="xbig:isTemplateTypedef($fullTypeName, $class, $root)">
						<xsl:value-of select="'jlong'"/>
					</xsl:when>

					<!-- if this type is an enum -->
					<xsl:when test="xbig:isEnum($fullTypeName, $class, $root)">
						<xsl:value-of select="if ($param/@passedBy = 'pointer')
												then 'jlong'
												else 'jint'"/>
					</xsl:when>

					<!-- if this type is a class or struct -->
					<xsl:when test="xbig:isClassOrStruct($fullTypeName, $class, $root)">
						<xsl:value-of select="'jlong'"/>
					</xsl:when>

					<!-- use 'long' as default type -->
					<xsl:otherwise>
						<xsl:value-of select="'jlong'"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<!-- type configured -->
			<xsl:otherwise>
				<xsl:choose>
					<!-- see bug 1712709 -->
					<xsl:when test="$param/@passedBy = 'reference' and xbig:isTypeConst($param)">
						<xsl:value-of select=
							"$config/config/cpp/jni/types/type[@meta=$resolvedType][not(@pass)]/@jni" />
					</xsl:when>

					<xsl:when test="$param/type/@pointerPointer = 'true'">
						<xsl:value-of select="'jlong'"/>
					</xsl:when>

					<!-- print type from config. Take care of const. -->
					<xsl:otherwise>
						<xsl:variable name="constTypeFromConfig" select="$type_info/type[@const = 'true']/@jni" />
						<xsl:variable name="nonConstTypeFromConfig" select="$type_info/type[@const = 'false' or not(@const)]/@jni" />
						<xsl:value-of 
							select="if($param/type/@const = 'true') then
										if($constTypeFromConfig) then
											$constTypeFromConfig
										else
											$type_info/type/@jni
									else if($nonConstTypeFromConfig) then
										$nonConstTypeFromConfig
									else
										$type_info/type/@jni" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

</xsl:stylesheet>
