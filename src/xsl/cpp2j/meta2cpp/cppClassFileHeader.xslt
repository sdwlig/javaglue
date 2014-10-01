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

	<xsl:import href="cppFileHeader.xslt" />
	<xsl:import href="cppMethodDeclaration.xslt" />
	<xsl:import href="../meta2java/javaUtil.xslt" />
	<xsl:import href="../../util/metaInheritedMethods.xslt" />

	<xd:doc type="stylesheet">
		<xd:short>Generation of jni header files.</xd:short>
	</xd:doc>

	<xd:doc type="template">
		<xd:short>Creates header file with declarations of JNI functions.
		</xd:short>
		<xd:param name="config">config file.</xd:param>
		<xd:param name="class">meta class to be processed.</xd:param>
		<xd:param name="class_prefix">
			prefix for class name. Contains java package and '$' of inner classes.
		</xd:param>
		<xd:param name="helper_methods">generated meta function elements. E.g. destructors.</xd:param>
	</xd:doc>
	<xsl:template name="cppClassFileHeader">
		<xsl:param name="config" />
		<xsl:param name="class" />
		<xsl:param name="class_prefix" />
		<xsl:param name="helper_methods" />

		<!-- 
		<xsl:variable name="isAbstract"
			select="xbig:areThereUnimplementedAbstractMethods($class)" />		
		 -->
		<xsl:variable name="isAbstract"
			select="$class/@abstract = 'true'" />

		<!-- write file header with copyright information -->
		<xsl:call-template name="cppFileHeader">
			<xsl:with-param name="config" select="$config" />
		</xsl:call-template>

		<!-- generate macro name for preventing multiple inclusion -->
		<xsl:variable name="header_macro"
			select="concat( '__Included_', $class_prefix , '__')" />

		<!-- write standard C++ header macros for preventing multiple inclusion -->
		<xsl:text>&#10;#ifndef&#32;</xsl:text>
		<xsl:value-of select="$header_macro" />
		<xsl:text>&#10;</xsl:text>

		<xsl:text>#define&#32;</xsl:text>
		<xsl:value-of select="$header_macro" />
		<xsl:text>&#10;&#10;</xsl:text>

		<!-- include basic JNI utility functions -->
		<xsl:text>&#10;#include "jni_base.h"</xsl:text>

		<!-- open C environment for C++ compiler -->
		<xsl:text>&#10;&#10;#ifdef __cplusplus&#10;</xsl:text>
		<xsl:text>extern "C" {</xsl:text>
		<xsl:text>&#10;#endif /* __cplusplus */</xsl:text>

		<!-- iterate through all member functions -->
		<!-- <xsl:for-each select="$class/function"> -->
		<!-- get methods, with inherited -->
		<xsl:variable name="inheritedMethods">
			<xsl:call-template name="findRelevantInheritedMethods">
				<xsl:with-param name="config" select="$config" />
				<xsl:with-param name="class" select="$class" />
			</xsl:call-template>
		</xsl:variable>

		<!-- remove function that are equal to java -->
		<xsl:variable name="inheritedMethodsForJava">
			<xsl:call-template name="getValidMethodList">
				<xsl:with-param name="functionNodeList"
					select="$inheritedMethods" />
			</xsl:call-template>
		</xsl:variable>

		<!-- generate method impl -->
		<xsl:for-each select="$inheritedMethodsForJava/function">
			<!-- test if abstract class and ctor -->
			<xsl:if test="$isAbstract = false() or xbig:isCtor($class,.) = false()">
				<xsl:call-template name="cppMethodDeclaration">
					<xsl:with-param name="config" select="$config" />
					<xsl:with-param name="class_prefix"
						select="$class_prefix" />
					<xsl:with-param name="method" select="." />
					<xsl:with-param name="class" select="$class" />
				</xsl:call-template>

				<!-- end of method declaration -->
				<xsl:text>;</xsl:text>
			</xsl:if>
		</xsl:for-each>

		<!-- iterate through all helper functions -->
		<xsl:for-each select="$helper_methods/function">

			<xsl:call-template name="cppMethodDeclaration">
				<xsl:with-param name="config" select="$config" />
				<xsl:with-param name="class_prefix"
					select="$class_prefix" />
				<xsl:with-param name="method" select="." />
				<xsl:with-param name="class" select="$class" />
			</xsl:call-template>

			<!-- end of method declaration -->
			<xsl:text>;</xsl:text>
		</xsl:for-each>

		<!-- generate public attributes getters and setters -->
		<xsl:for-each
			select="$inheritedMethods/attribute/variable">
			<xsl:variable name="publicAttributeGettersAndSetters">
				<xsl:call-template
					name="createFunctionsForPublicAttribute">
					<xsl:with-param name="variable" select="." />
				</xsl:call-template>
			</xsl:variable>

			<xsl:for-each
				select="$publicAttributeGettersAndSetters/function">
				<xsl:call-template name="cppMethodDeclaration">
					<xsl:with-param name="config" select="$config" />
					<xsl:with-param name="class_prefix"
						select="$class_prefix" />
					<xsl:with-param name="method" select="." />
					<xsl:with-param name="class" select="$class" />
				</xsl:call-template>

				<!-- end of method declaration -->
				<xsl:text>;</xsl:text>
			</xsl:for-each>
		</xsl:for-each>

		<!-- close C environment for C++ compiler -->
		<xsl:text>&#10;&#10;#ifdef __cplusplus</xsl:text>
		<xsl:text>&#10;} /* extern "C" */</xsl:text>
		<xsl:text>&#10;#endif /* __cplusplus */</xsl:text>

		<!-- close condition for preventing multiple inclusion -->
		<xsl:text>&#10;&#10;#endif /*</xsl:text>
		<xsl:value-of select="$header_macro" />
		<xsl:text>*/&#10;</xsl:text>

	</xsl:template>
</xsl:stylesheet>
