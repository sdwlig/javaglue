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
	xmlns:fn="http://www.w3.org/2005/xpath-methods"
	xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
	xmlns:xd="http://www.pnp-software.com/XSLTdoc"
	xmlns:xbig="http://xbig.sourceforge.net/XBiG">

	<xsl:import href="cppMethodDeclaration.xslt" />
	<xsl:import href="cppCodeWriter.xslt" />
	<xsl:import href="../../util/metaTypeInfo.xslt" />
	<xsl:import href="../../util/firstLetterToUpperCase.xslt" />

	<xd:doc type="stylesheet">
		<xd:short>Conversion of JNI parameters to C++ types.</xd:short>
	</xd:doc>

	<xd:doc type="template">
		<xd:short>Generates a C++ variable for each parameter and assigns a value to it.
		</xd:short>
		<xd:param name="config">config file.</xd:param>
		<xd:param name="class">meta class which contains method.</xd:param>
		<xd:param name="method">meta function element to be processed.</xd:param>
	</xd:doc>
	<xsl:template name="cppMethodParameterConversion">
		<xsl:param name="config"/>
		<xsl:param name="class"/>
		<xsl:param name="method"/>

		<!-- iterate through all parameters for conversion -->
		<xsl:for-each select="$method/parameters/parameter">
			<xsl:variable name="parameterPosition" select="position()"/>

			<!-- resolve typedefs -->
			<xsl:variable name="resolvedParameter" select="xbig:resolveTypedef(
				./type, $class, $root)"/>

			<xsl:variable name="fullTypeName" select="$resolvedParameter"/>

			<!-- parameter name -->
			<xsl:variable name="param_name" select="xbig:createParameterName(., position(), $config)" />

			<!-- parameter name for call native function -->
			<xsl:variable name="lib_var"
				select="xbig:cpp-param($config, $param_name)" />

			<!-- write new line separator for parameter declaration -->
			<xsl:text>#nl#</xsl:text>

			<!-- type info -->
			<xsl:variable name="type_info">
				<xsl:call-template name="metaExactTypeInfo">
					<xsl:with-param name="root"
						select="$config/config/cpp/jni/types" />
					<xsl:with-param name="param" select="." />
					<xsl:with-param name="typeName" select="$fullTypeName" />
				</xsl:call-template>
			</xsl:variable>

			<!-- check for <pre_jni2cpp> -->
			<xsl:choose>
				<xsl:when test="./type/@const = 'true'">
					<xsl:if test="$type_info/type[@const = 'true']/pre_jni2cpp">
						<xsl:value-of select="replace(replace(xbig:removeCDATA($type_info/type[@const = 'true']/pre_jni2cpp), '#jni_var#', $param_name), '#cpp_var#', $lib_var)" />
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="$type_info/type[@const = 'false' or not(@const)]/pre_jni2cpp">
						<xsl:value-of select="replace(replace(xbig:removeCDATA($type_info/type[@const = 'false' or not(@const)]/pre_jni2cpp), '#jni_var#', $param_name), '#cpp_var#', $lib_var)" />
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>

			<!-- write type for transformation -->
			<!-- take cpp attribute if available, otherwise write meta -->
			<xsl:value-of select="xbig:cpp-type($config, ., $class, $fullTypeName, true())" />

			<!-- write separator for variable -->
			<xsl:text>&#32;</xsl:text>

			<!-- write variable for transformed variable -->
			<xsl:value-of select="$lib_var" />

			<!-- write assignment operator -->
			<xsl:text>&#32;=&#32;</xsl:text>

			<!-- write conversion to C++ type -->
			<xsl:value-of select="replace(xbig:jni-to-cpp(
							$config, $class, $method, ., $fullTypeName, $param_name, $type_info), '#cpp_var#', $lib_var)" />

			<!-- finish conversion statement -->
			<xsl:text>;</xsl:text>

		</xsl:for-each>
		<!-- call library method call -->

	</xsl:template>


</xsl:stylesheet>
