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

	<xsl:import href="javaType.xslt" />
	<xsl:import href="javaMethodParameterList.xslt" />
	<xsl:import href="../../util/metaMethodName.xslt" />

	<xd:doc type="stylesheet">
		<xd:short>Generates native methods.</xd:short>
	</xd:doc>

	<xd:doc type="template">
		<xd:short>Generates java native methods.
				That means all modifiers, return type, method name and parameter list (again types and names).
		</xd:short>
		<xd:param name="config">config file.</xd:param>
		<xd:param name="class">class which contains current method.</xd:param>
		<xd:param name="method">method to be generated.</xd:param>
	</xd:doc>
	<xsl:template name="javaNativeMethod">
		<xsl:param name="config" />
		<xsl:param name="class" />
		<xsl:param name="method" />

		<!-- shortcut of function name -->
		<xsl:variable name="method_name" select="
				if (starts-with($method/name, 'operator'))
				then $config/config/java/operators/op
					[. = normalize-space(substring-after($method/name, 'operator'))]/@javaName
    			else $method/name" />

		<!-- check if method is on ignore list -->
		<xsl:if test="not($ignore_list/ignore_list/function
						[. = concat($class/@fullName, '::', $method_name)])
					  and
						not($ignore_list/ignore_list/item[. = $class/@fullName])">

			<!-- shortcut for return type, take long for constructors, pointers and references -->
			<!-- 
			<xsl:variable name="return_type">
				<xsl:choose>
					<xsl:when test="$method/@passedBy='pointer' or $method/@passedBy='reference'">
						<value-of select="'long'" />
					</xsl:when>
					<xsl:otherwise>
						<value-of select="if($method/type) then $method/type else 'long'" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			 -->

			<!-- shortcut for static property -->
			<xsl:variable name="static" select="$method/@static" />

			<!-- shortcut for virtuality property -->
			<xsl:variable name="virtuality" select="$method/@virt" />

			<!-- write visibility modifier -->
			<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
			<xsl:text>private</xsl:text>

			<!-- write native method modifier -->
			<xsl:text>&#32;native</xsl:text>

			<!-- write static method modifier (static attribute or constructor -->
			<xsl:if test="$static eq'true' or not($method/type)">
				<xsl:text>&#32;static</xsl:text>
			</xsl:if>

			<!-- handle virtual modifiers -->
			<xsl:choose>
				<xsl:when test="$virtuality = 'non-virtual'">
					<!-- <xsl:text>&#32;final</xsl:text> -->
				</xsl:when>

				<!-- this is not necessary because 
					 of the interfaces that are generated for multiple inheritance -->
				<xsl:when test="$virtuality = 'pure-virtual'">
					<!-- <xsl:text>&#32;abstract</xsl:text> -->
				</xsl:when>

				<xsl:when test="$virtuality = 'virtual'" />
				<xsl:otherwise>
					<xsl:message terminate="no">
						ERROR: virtual type '
						<xsl:value-of select="$virtuality" />
						' not allowed.
					</xsl:message>
				</xsl:otherwise>
			</xsl:choose>

			<!-- write seperator for return type -->
			<xsl:text>&#32;</xsl:text>

			<!-- resolve typedefs -->
			<xsl:variable name="resolvedType">
				<xsl:choose>
					<xsl:when test="not($method/type)">
						<!-- <xsl:value-of select="''"/> -->
						<xsl:sequence select="''"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="xbig:resolveTypedef($method/type, $class, $root)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="fullTypeName" select="$resolvedType"/>
		

			<!-- write return type -->
			<xsl:choose>

				<!-- if this method returns a parametrized template -->
				<xsl:when test="contains($method/type, '&lt;')">
					<!-- <value-of select="'long'" /> -->
					<xsl:text>long</xsl:text>
				</xsl:when>

				<xsl:when test="($method/@passedBy='pointer' and not($resolvedType='char' and xbig:isTypeConst($method))) or
							($method/@passedBy eq 'reference'
				            and not(xbig:isTypeConst($method))
				            and not(xbig:isEnum($fullTypeName, $class, $root)))">
					<xsl:value-of select="'long'" />
				</xsl:when>

				<!-- c-tor -->
				<xsl:when test="not($method/type)">
					<xsl:value-of select="'long'" />
				</xsl:when>

				<xsl:when test="xbig:isTemplateTypedef($fullTypeName, $class, $root)">
					<xsl:value-of select="'long'" />
				</xsl:when>

				<xsl:when test="xbig:isClassOrStruct($fullTypeName, $class, $root)">
					<xsl:value-of select="'long'" />
				</xsl:when>

				<xsl:when test="xbig:isEnum($fullTypeName, $class, $root)">
					<xsl:value-of select="'int'" />
				</xsl:when>

				<xsl:when test="$fullTypeName = 'unsigned long long'">
					<xsl:value-of select="'long'" />
				</xsl:when>

				<xsl:otherwise>
					<xsl:call-template name="javaType">
						<xsl:with-param name="config" select="$config" />
						<xsl:with-param name="param" select="$method" />
						<xsl:with-param name="class" select="$class" />
						<xsl:with-param name="typeName" select="$method/type" />
						<xsl:with-param name="writingNativeMethod" select="true()" />
						<xsl:with-param name="isTypeParameter" select="false()" />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>

			<!-- write method name -->
			<xsl:text>&#32;</xsl:text>
			<xsl:call-template name="metaMethodName">
				<xsl:with-param name="config" select="$config" />
				<xsl:with-param name="method" select="$method" />
			</xsl:call-template>

			<!-- begin parameter declaration -->
			<xsl:text>(</xsl:text>

			<!-- write instance pointer if no static function and no constructor -->
			<xsl:if test="$static ne 'true' and $method/type">

				<xsl:text>long _pointer_</xsl:text>

				<!-- if more parameters available -->
				<xsl:if test="count($method/parameters/parameter) > 0">
					<!-- write seperator for following parameters -->
					<xsl:text>,&#32;</xsl:text>
				</xsl:if>
			</xsl:if>

			<!-- write real parameter list including types -->
			<xsl:call-template name="javaMethodParameterList">
				<xsl:with-param name="config" select="$config" />
				<xsl:with-param name="class" select="$class" />
				<xsl:with-param name="method" select="$method" />
				<xsl:with-param name="with_types" select="'true'" />
				<xsl:with-param name="writingNativeMethod" select="true()" />
				<xsl:with-param name="callingNativeMethod" select="false()" />
			</xsl:call-template>

			<!-- end parameter declaration -->
			<xsl:text>);</xsl:text>

		</xsl:if> <!-- ignore list check -->

	</xsl:template>

</xsl:stylesheet>
