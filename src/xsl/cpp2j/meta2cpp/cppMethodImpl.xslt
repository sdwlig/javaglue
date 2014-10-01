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
	<xsl:import href="cppMethodParameterConversion.xslt" />
	<xsl:import href="../../util/firstLetterToUpperCase.xslt" />

	<xd:doc type="stylesheet">
		<xd:short>Implementation of JNI functions.</xd:short>
	</xd:doc>

	<xd:doc type="template">
		<xd:short>
			Generate method implementation. Selects a code template from config and calls CodeWriter.
		</xd:short>
		<xd:param name="config">config file.</xd:param>
		<xd:param name="class_prefix">
			prefix for class name. Contains java package and '$' of inner classes.
		</xd:param>
		<xd:param name="class">meta class which contains method.</xd:param>
		<xd:param name="method">meta function element to be processed.</xd:param>
		<xd:param name="classPrefixForMethod">
			Full qualified class name with trailing '::' to put before method name or empty string ('').
		</xd:param>
	</xd:doc>
	<xsl:template name="cppMethodImpl">
		<xsl:param name="config" />
		<xsl:param name="class_prefix" />
		<xsl:param name="class" />
		<xsl:param name="method" />
		<xsl:param name="classPrefixForMethod" as="xs:string" />

		<!-- check if method is on ignore list -->
		<xsl:if test="not($ignore_list/ignore_list/function
						[. = concat($class/@fullName, '::', $method/name)])">

			<!-- shortcut for static attribute -->
			<xsl:variable name="static" select="$method/@static" />

			<!-- write method declaration -->
			<xsl:call-template name="cppMethodDeclaration">
				<xsl:with-param name="config" select="$config" />
				<xsl:with-param name="class_prefix" select="$class_prefix" />
				<xsl:with-param name="method" select="." />
				<xsl:with-param name="class" select="$class" />
			</xsl:call-template>

			<!-- start implementation -->
			<xsl:text>&#10;{</xsl:text>

			<!-- calculate name of code template depending on function type -->
			<xsl:variable name="code_template">
				<xsl:choose>

					<!-- if a method has it's own template (like in stl wrapper) -->
					<xsl:when test="boolean($method/jniImplementation)">
						<xsl:copy-of
							select="$method/jniImplementation" />
					</xsl:when>

					<!-- handle constructor -->
					<xsl:when test="not($method/type)">
						<xsl:copy-of
							select="xbig:removeCDATA($config/config/cpp/method/constructor)" />
					</xsl:when>

					<!-- handle destructor -->
					<xsl:when test="$method/@destructor = 'true'">
						<xsl:copy-of
							select="xbig:removeCDATA($config/config/cpp/method/destructor)" />
					</xsl:when>

					<!-- handle public attribute getter -->
					<xsl:when test="$method/@public_attribute_getter = 'true'">
						<xsl:choose>
							<xsl:when test="@static!='true'">
								<xsl:copy-of select="xbig:removeCDATA($config/config/cpp/method/publicattribute/get/nonstatic)" />
							</xsl:when>
							<xsl:when test="@static='true'">
								<xsl:copy-of select="xbig:removeCDATA($config/config/cpp/method/publicattribute/get/static)" />
							</xsl:when>
						</xsl:choose>
					</xsl:when>

					<!-- handle public attribute addrgetter -->
					<!--
					<xsl:when test="$method/@public_attribute_addrgetter = 'true'">
						<xsl:choose>
							<xsl:when test="@static!='true'">
								<xsl:copy-of select="xbig:removeCDATA($config/config/cpp/method/publicattribute/getaddr/nonstatic)" />
							</xsl:when>
							<xsl:when test="@static='true'">
								<xsl:copy-of select="xbig:removeCDATA($config/config/cpp/method/publicattribute/getaddr/static)" />
							</xsl:when>
						</xsl:choose>
					</xsl:when>
					-->

					<!-- handle public attribute setter -->
					<xsl:when test="$method/@public_attribute_setter = 'true'">
						<xsl:choose>
							<xsl:when test="@static!='true'">
								<xsl:copy-of select="xbig:removeCDATA($config/config/cpp/method/publicattribute/set/nonstatic)" />
							</xsl:when>
							<xsl:when test="@static='true'">
								<xsl:copy-of select="xbig:removeCDATA($config/config/cpp/method/publicattribute/set/static)" />
							</xsl:when>
						</xsl:choose>
					</xsl:when>

					<!-- handle static method without return parameter -->
					<xsl:when
						test="($method/type = 'void') and ($static = 'true') and not($method/@passedBy = 'pointer')">
						<xsl:copy-of
							select="xbig:removeCDATA($config/config/cpp/method/static/void)" />
					</xsl:when>

					<!-- handle static method with return parameter -->
					<xsl:when
						test="$static = 'true'">
						<xsl:copy-of
							select="xbig:removeCDATA($config/config/cpp/method/static/return)" />
					</xsl:when>

					<!-- handle normal method without return parameter-->
					<xsl:when test="($method/type = 'void') and not($method/@passedBy = 'pointer')">
						<xsl:copy-of
							select="xbig:removeCDATA($config/config/cpp/method/normal/void)" />
					</xsl:when>

					<!-- handle normal method with return parameter-->
					<xsl:when test="($method/type != 'void') or ($method/type = 'void' and $method/@passedBy = 'pointer')">
						<xsl:copy-of
							select="xbig:removeCDATA($config/config/cpp/method/normal/return)" />
					</xsl:when>
				
					<!-- print message for other stuff -->
					<xsl:otherwise>
						<xsl:message terminate="yes">
							unhandled method:
							<xsl:value-of select="$method/definition" />
						</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<!-- real writing of method implementation -->
			<xsl:value-of
				select="xbig:code($config, $code_template, $class, $method, $classPrefixForMethod)" />


			<!-- end implementation -->
			<xsl:text>&#10;} /*&#32;</xsl:text>
			<xsl:value-of select="definition" />
			<xsl:text>&#32;*/&#10;</xsl:text>

		</xsl:if> <!-- ignore list check -->

	</xsl:template>


</xsl:stylesheet>
