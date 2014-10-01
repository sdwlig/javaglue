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
			Stephen Williams sdw@lig.net - Support for passing null.
-->

<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
	xmlns:xd="http://www.pnp-software.com/XSLTdoc"
	xmlns:xbig="http://xbig.sourceforge.net/XBiG">

	<xsl:import href="../../util/metaMethodName.xslt" />
	<xsl:import href="../../util/metaTypeInfo.xslt" />

	<xd:doc type="stylesheet">
		<xd:short>Iterate over parameters of a method.</xd:short>
	</xd:doc>

	<xd:doc type="template">
		<xd:short>
			Generates parameter types and names for public and native methods.
		</xd:short>
		<xd:param name="config">config.xml file.</xd:param>
		<xd:param name="class">Class which contains current method.</xd:param>
		<xd:param name="method">method to be processed.</xd:param>
		<xd:param name="with_types">
			If set to the string 'true', types are generated.
			If it has a different value, only names are generated
		</xd:param>
		<xd:param name="writingNativeMethod">With this call a native method is generated.</xd:param>
		<xd:param name="callingNativeMethod">
			With this call the body of a  public method is generated.
		</xd:param>
	</xd:doc>
	<xsl:template name="javaMethodParameterList">
		<xsl:param name="config" />
		<xsl:param name="class" />
		<xsl:param name="method" />
		<xsl:param name="with_types" />
		<xsl:param name="writingNativeMethod" as="xs:boolean" />
		<xsl:param name="callingNativeMethod" as="xs:boolean" />

		<!-- iterator through all parameters -->
		<xsl:for-each select="$method/parameters/parameter">

			<!-- if writing java types switched on -->
			<xsl:if test="$with_types eq 'true'">

				<!-- write parameter type -->
				<xsl:choose>
					<xsl:when test="($writingNativeMethod eq true()) 
									and ((./@passedBy='pointer' and not(./type='char' and xbig:isTypeConst(.))) or 
									(./@passedBy eq 'reference' and not(xbig:isTypeConst(.))))">
						<xsl:value-of select="'long'" />
					</xsl:when>

					<!-- if this parameter is a parametrized template -->
					<xsl:when test="($writingNativeMethod eq true()) and
						 (contains(./type, '&lt;'))">
						<xsl:value-of select="'long'" />
					</xsl:when>

					<xsl:otherwise>
						<xsl:call-template name="javaType">
							<xsl:with-param name="config" select="$config" />
							<xsl:with-param name="param" select="." />
							<xsl:with-param name="class" select="$class" />
							<xsl:with-param name="writingNativeMethod" select="$writingNativeMethod" />
							<xsl:with-param name="typeName" select="./type" />
							<xsl:with-param name="isTypeParameter" select="false()" />
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:if>

			<!-- seperator type and name -->
			<xsl:text>&#32;</xsl:text>

			<!-- write parameter name -->
			<!-- if there is no param name in original lib -->
			<xsl:variable name="parameterPosition" select="position()"/>
			<xsl:variable name="paramName">
				<xsl:choose>
					<xsl:when test="not(./name) or ./name = ''">
						<xsl:value-of select="concat($config/config/meta/parameter/defaultName,
												$parameterPosition)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="./name"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:value-of select="$paramName" />

			<!-- resolve typedefs -->
			<xsl:variable name="resolvedType" select="xbig:resolveTypedef(./type, $class, $root)"/>

			<xsl:variable name="fullTypeName" select="$resolvedType"/>

			<!-- extract jni type depending on meta type, const/non-const, pass type
				 needed for next if -->
			<xsl:variable name="type_info">
				<xsl:call-template name="metaFirstTypeInfo">
					<xsl:with-param name="root" 
						select="$config/config/java/types" />
					<xsl:with-param name="param" select="." />
					<xsl:with-param name="typeName" select="$fullTypeName" />
				</xsl:call-template>
			</xsl:variable>

			<!-- if we call a native method and have to pass an InstancePointer -->
			<xsl:if test="($callingNativeMethod eq true())
						 and $type_info/type/@java
						 and ((./@passedBy='pointer' and not(./type='char' and xbig:isTypeConst(.))) or 
						 (./@passedBy eq 'reference' and not(xbig:isTypeConst(.))))">
				<xsl:value-of select="'.object.pointer'" />
			</xsl:if>

			<!-- if this parameter is a enum -->
			<xsl:if test="($callingNativeMethod eq true()) and
				 		  (xbig:isEnum($fullTypeName, $class, $root))">
				<xsl:value-of select="if (./@passedBy = 'pointer')
										then '.getInstancePointer().pointer'
										else '.getValue()'" />
			</xsl:if>

			<!-- if this parameter is a class or struct -->
			<xsl:if test="($callingNativeMethod eq true()) and
				 		  (xbig:isClassOrStruct($fullTypeName, $class, $root))">
			  	<xsl:text disable-output-escaping="yes">==null ? 0L : </xsl:text>
			  	<xsl:value-of select="$paramName"/>
				<xsl:text>.getInstancePointer().pointer</xsl:text>
			</xsl:if>

			<!-- if this parameter is a parametrized template -->
			<xsl:if test="($callingNativeMethod eq true()) and
				 		  (contains($fullTypeName, '&lt;'))">
				<xsl:value-of select="'.getInstancePointer().pointer'" />
			</xsl:if>

			<!-- if this parameter is a template typedef -->
			<xsl:if test="($callingNativeMethod eq true()) and
				 		  (xbig:isTemplateTypedef($fullTypeName, $class, $root))">
				<xsl:value-of select="'.getInstancePointer().pointer'" />
			</xsl:if>

			<!-- if another parameter follows, write seperator -->
			<xsl:if test="position()!=last()">
				<xsl:text>,&#32;</xsl:text>
			</xsl:if>

		</xsl:for-each>


	</xsl:template>

</xsl:stylesheet>
