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
	
-->

<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
	xmlns:xd="http://www.pnp-software.com/XSLTdoc">

	<xsl:import href="javaType.xslt" />
	<xsl:import href="javaAccessMethodDeclaration.xslt" />
	<xsl:import href="javaConstructorImpl.xslt" />
	<xsl:import href="javaVoidMethodImpl.xslt" />
	<xsl:import href="javaReturnMethodImpl.xslt" />

	<xd:doc type="stylesheet">
		<xd:short>Generation of public java methods.</xd:short>
	</xd:doc>

	<xd:doc type="template">
		<xd:short>Generates public java methods.
				Calls javaAccessMethodDeclaration and one of the implementation Templates:
				javaConstructorImpl, javaVoidMethodImpl or javaReturnMethodImpl.
		</xd:short>
		<xd:param name="config">config file.</xd:param>
		<xd:param name="class">class which contains current method.</xd:param>
		<xd:param name="method">method to be generated.</xd:param>
	</xd:doc>
	<xsl:template name="javaAccessMethod">
		<xsl:param name="config" />
		<xsl:param name="class" />
		<xsl:param name="method" />

		<!-- check if method is on ignore list -->
		<xsl:if test="not($ignore_list/ignore_list/function
						[. = concat($class/@fullName, '::', $method/name)])
					  or
					  	$ignore_list/ignore_list/function
						[. = concat($class/@fullName, '::', $method/name)]/@generateDeclaration = 'true'">

			<!-- write parameter type -->
			<xsl:call-template name="javaAccessMethodDeclaration">
				<xsl:with-param name="config" select="$config" />
				<xsl:with-param name="class" select="$class" />
				<xsl:with-param name="method" select="$method" />
			</xsl:call-template>

			<xsl:text>&#32;</xsl:text>

			<!-- start implementation -->
			<xsl:text>{</xsl:text>
			<xsl:text>&#10;</xsl:text>
			<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
			<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>

			<!-- choose correct implementation -->
			<xsl:choose>

				<!-- methods of ignored classes -->
				<xsl:when test="$ignore_list/ignore_list/function
									[. = concat($class/@fullName, '::', $method/name)]">
					<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
					<xsl:text>throw</xsl:text>
					<xsl:text>&#32;</xsl:text>
					<xsl:text>new</xsl:text>
					<xsl:text>&#32;</xsl:text>
					<xsl:text>UnsupportedOperationException(&quot;</xsl:text>
					<xsl:text>This method is on ignore list!</xsl:text>
					<xsl:text>&quot;);</xsl:text>
				</xsl:when>

				<!-- methods from ignore list -->
				<xsl:when test="$ignore_list/ignore_list/item[. = $class/@fullName]">
					<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
					<xsl:text>throw</xsl:text>
					<xsl:text>&#32;</xsl:text>
					<xsl:text>new</xsl:text>
					<xsl:text>&#32;</xsl:text>
					<xsl:text>UnsupportedOperationException(&quot;</xsl:text>
					<xsl:text>This type is on ignore list!</xsl:text>
					<xsl:text>&quot;);</xsl:text>
				</xsl:when>

				<!-- constructor -->
				<xsl:when test="not($method/type)">
					<xsl:call-template name="javaConstructorImpl">
						<xsl:with-param name="config" select="$config" />
						<xsl:with-param name="class" select="$class" />
						<xsl:with-param name="method" select="$method" />
					</xsl:call-template>
				</xsl:when>

				<!-- method without return value -->
				<xsl:when test="$method/type eq 'void'">
					<xsl:call-template name="javaVoidMethodImpl">
						<xsl:with-param name="config" select="$config" />
						<xsl:with-param name="class" select="$class" />
						<xsl:with-param name="method" select="$method" />
					</xsl:call-template>
				</xsl:when>

				<!-- methods with return value -->
				<xsl:otherwise>
					<xsl:call-template name="javaReturnMethodImpl">
						<xsl:with-param name="config" select="$config" />
						<xsl:with-param name="class" select="$class" />
						<xsl:with-param name="method" select="$method" />
					</xsl:call-template>
				</xsl:otherwise>

			</xsl:choose>


			<!-- implementation finished -->
			<xsl:text>&#10;</xsl:text>
			<xsl:text>&#32;&#32;&#32;&#32;</xsl:text>
			<xsl:text>}</xsl:text>

		</xsl:if> <!-- ignore list check -->
	</xsl:template>

</xsl:stylesheet>
